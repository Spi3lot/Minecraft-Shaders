#include "const.glsl"

uniform vec3 airDensityCoeff;

vec3 GetAtmosphereDensity(vec3 Direction) {
    float y     = -Direction.y * planetRad;
    const vec4 sr = planetRad + vec4(
        scaleHeight.x, scaleHeight.y, ozonePeakAlt, ozonePeakAlt + scaleHeight.x
    );
    const float r2 = planetRad * planetRad;
    vec4 z = y + sqrt(sr * sr + (sqr(y) - r2));

    return vec3(z.xy, max0(z.w-z.z) * pi4) * airDensityCoeff;
}

#define d0fix(a) (abs(a) + 1e-35)

vec3 GetAtmosphereAbsorption(vec3 Direction) {
    vec3 thickness = GetAtmosphereDensity(Direction);

    vec3 skyCoeffs = airExtinctMat * thickness;

    vec3 skyAbsorb = exp(-skyCoeffs);

    return d0fix(skyAbsorb);
}