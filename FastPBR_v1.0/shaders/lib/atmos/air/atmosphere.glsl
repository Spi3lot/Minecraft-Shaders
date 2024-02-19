#include "density.glsl"

float GetEarthShadow(vec3 WorldDirection, vec3 LightDirection) {
    float intensity = exp(-max(LightDirection.y, 0.0) * tau);

    float sunVisibility = 1.0 - linStep(-LightDirection.y, 1.0 / tau, 1.0 / pi);
        sunVisibility   = exp(-max(-LightDirection.y, 0.0) * tau) * sunVisibility;

    if (sunVisibility < 1e-16) return 0.0;

    if ((intensity) < 1e-16) return 1.0;

    float dL    = dot(WorldDirection, LightDirection);

    vec3 dir    = mix(vec3(0.0, 1.0, 0.0), LightDirection, saturate(dL * 0.5 + 0.5) * 0.2 + 0.2);

    float f1    = 1.0 - exp(-max(-LightDirection.y, 0.0) * sqr(tau));

    float s     = dot(WorldDirection, normalize(dir));
        s       = max(s + 0.15 + (1.0 - f1) * 0.15, 0.0);

    float falloff   = LightDirection.y * 0.5 + 0.55;
        falloff     = 1.0 - exp(-s * falloff * 0.6);

    return mix(1.0, falloff, intensity) * sunVisibility;
}

vec2 airPhaseFunction(float cosTheta) {
    return vec2(rayleighPhase(cosTheta), mieCS(cosTheta, airMieG));
}

vec3 GetAtmosIlluminance(vec3 Direction, mat2x3 LightDirection) {
    vec3 thickness = GetAtmosphereDensity(Direction);

    vec3 sunAirmass = airExtinctMat * GetAtmosphereDensity(LightDirection[0]);
    vec3 moonAirmass = airExtinctMat * GetAtmosphereDensity(LightDirection[1]);

    vec3 opticalDepth = airExtinctMat * thickness;

    vec4 phase = vec4(airPhaseFunction(dot(Direction, LightDirection[0])), airPhaseFunction(dot(Direction, LightDirection[1])));
    float phaseIso = 0.25 * pi;

    vec3 sunlightAtten = exp(-sunAirmass);
    vec3 moonlightAtten = exp(-moonAirmass);
    vec3 transmittance = exp(-opticalDepth);

	vec3 sunScattering  = airScatterMat * (thickness.xy * phase.xy);
	vec3 moonScattering = airScatterMat * (thickness.xy * phase.zw);

        sunlightAtten = d0fix(sunlightAtten - transmittance) / d0fix(sunAirmass - opticalDepth);
        moonlightAtten = d0fix(moonlightAtten - transmittance) / d0fix(moonAirmass - opticalDepth);

    float shadow    = GetEarthShadow(Direction, LightDirection[0]);

    sunScattering = sunIllum * (sunScattering * sunlightAtten) * sqrt(shadow);
    moonScattering = moonIllum.b * (moonScattering * moonlightAtten);

    return sunScattering + moonScattering;
}


vec2 GetIlluminanceIntensity(vec3 Direction) {
    Direction.y = mix(abs(Direction.y), max0(Direction.y), 0.33);
    float y     = -Direction.y * planetRad;
    const vec2 sr = planetRad + illuminanceFalloff;
    const float r2 = planetRad * planetRad;
    vec2 z = y + sqrt(sr * sr + (sqr(y) - r2));

    return max0(vec2(z.xy) / atmosDepth);
}

mat2x3 GetAtmosphere(vec3 Direction, mat2x3 LightDirection, vec3 atmosIlluminance, mat2x3 illuminanceMod) {
    vec3 thickness = GetAtmosphereDensity(Direction);

    vec3 sunAirmass = airExtinctMat * GetAtmosphereDensity(LightDirection[0]);
    vec3 moonAirmass = airExtinctMat * GetAtmosphereDensity(LightDirection[1]);

    vec3 opticalDepth = airExtinctMat * thickness;

    vec4 phase = vec4(airPhaseFunction(dot(Direction, LightDirection[0])), airPhaseFunction(dot(Direction, LightDirection[1])));
    float phaseIso = 0.25 * pi;

    vec3 sunlightAtten = exp(-sunAirmass);
    vec3 moonlightAtten = exp(-moonAirmass);
    vec3 transmittance = exp(-opticalDepth);
    vec3 transmittanceFraction = saturate((transmittance - 1.0) / -opticalDepth);

	vec3 sunScattering  = airScatterMat * (thickness.xy * phase.xy);
	vec3 moonScattering = airScatterMat * (thickness.xy * phase.zw);
    vec3 multiScattering = airScatterMat * (thickness.xy) * transmittanceFraction;

        sunlightAtten = d0fix(sunlightAtten - transmittance) / d0fix(sunAirmass - opticalDepth);
        moonlightAtten = d0fix(moonlightAtten - transmittance) / d0fix(moonAirmass - opticalDepth);

    float shadow    = GetEarthShadow(Direction, LightDirection[0]);

    sunScattering = sunIllum * (sunScattering * sunlightAtten);
    sunScattering *= shadow;
    moonScattering = moonIllum.b * (moonScattering * moonlightAtten);

    vec2 illuminanceIntensity = GetIlluminanceIntensity(Direction);

    vec2 illumPhase = mix(phase.xz, vec2(1.0), 0.5);

    vec3 multiIllum = getLuma(atmosIlluminance) * pow(normalize(atmosIlluminance), vec3(rpi)) * illuminanceIntensity.x * halfPi;
        multiIllum += atmosIlluminance.z * illuminanceIntensity.y * pi;
        multiIllum *= illuminanceMod[0] * illumPhase.x + illuminanceMod[1] * illumPhase.y;

    float horizonBoost = (exp(-((abs(Direction.y)) * 12.0))) * sqrt2;

    multiScattering = atmosIlluminance * ((normalizeSafe(atmosIlluminance)) * multiScattering + multiIllum) * phaseIso + (multiIllum * atmosIlluminance.z * horizonBoost);

    return mat2x3(sunScattering + moonScattering + multiScattering, transmittance);
}