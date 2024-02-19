#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable

//#define RayTracedAmbientOcclusion
#define accurateCaustics
#define TAA
#define causticsDistanceThreshold 0.15 //[0.05 0.15 0.25 0.35 0.45 0.55 0.65 0.75]

#define FOGMULTIPLIER 0.1 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]
#define torchLightMult 1.5 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]

uniform sampler2D colortex0;
uniform sampler2D colortex5;
uniform sampler2D colortex15;

uniform mat4 gbufferModelView;

uniform vec3 shadowLightPosition;

uniform int blockEntityId;

in vec2 texcoord;
flat in vec3 lightVec;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec3 colortex0Out;

#include "/lib/includes.glsl"
#include "/lib/shadows.glsl"
// #include "/lib/sky.glsl"
// #include "/lib/rtao.glsl"

//https://github.com/wdas/brdf/blob/master/src/brdfs/disney.brdf
float schlickWeight(float cosTheta) {
    float m = clamp01(1. - cosTheta);
    return pow2(pow2(pow2(pow2(m))));
}
// float xsqrtx(float x) {
//     return x*sqrt(x);
// }
// float henyeyGreensteinPhase(float nu, float g) {
//     float isotropicPhase = 0.25/PI;
//     float gg = g * g;

//     return (isotropicPhase - isotropicPhase * gg) / xsqrtx(1.0 + gg - 2.0 * g * nu);
// }
float disneySubsurface(float NdotL, float NdotV, float LdotH, float roughness) {

    float FL = schlickWeight(NdotL), FV = schlickWeight(NdotV);
    float Fss90 = LdotH*LdotH*roughness;
    float Fss = mix(1.0, Fss90, FL) * mix(1.0, Fss90, FV);
    float ss = 1.25 * (Fss * (1. / (NdotL + NdotV) - .5) + .5);

    return clamp01((1/PI) * ss);
}

// float BiLambertianPlatePhaseFunction(in float kd, in float cosTheta) {
//     float phase = 2.0 * (-PI * kd * cosTheta + sqrt(1.0 - square(cosTheta)) + cosTheta * acos(-cosTheta));
//     return phase / (3.0 * square(PI));
// }

#ifdef accurateCaustics
float accurateWaterCaustics(vec3 worldSpacePos, float dither) {
	#ifdef TAA
    dither    = fractDither(dither);
	#endif
	vec3 NWLightvec = vec3(0.0, -1.0, 0.0);
	float detectwVL = min(abs(worldSpacePos.y), 2.0);
	vec3 FRFvec = refract(NWLightvec, vec3(0.0, 1.0, 0.0), 1.0 / 1.8);
	float detectwL = detectwVL / -FRFvec.y;
	vec3 lookupCenter = worldSpacePos.xyz - FRFvec * detectwL;

	int s = 1;
	int c = 0;

	float caustics = 0.0;

	for (int i = 0; i <= s; i++)
	{
			vec2 offset = vec2(i + dither) * 0.35;
			vec3 detectlookup = lookupCenter + vec3(offset.x, 0.0, offset.y);
			vec3 wNormal = vec3(waterH2(detectlookup));
			vec3 RFvec = refract(NWLightvec, wNormal, 1.0 / 1.3333);
			float rayL = detectwVL / RFvec.y;
			vec3 detectcollision = detectlookup - RFvec * rayL;

			float dist = dot(detectcollision - worldSpacePos, detectcollision - worldSpacePos) * 7.1;

			caustics += 1.0 - clamp01(dist * rcp(causticsDistanceThreshold));

			c++;
	}

	caustics /= c;

	return caustics * rcp(causticsDistanceThreshold) * 5.0;
}
#endif

// float disneySubsurface(float NdotL, float NdotV, float LdotH, float roughness) {
// 	float FL = schlickWeight(NdotL), FV = schlickWeight(NdotV);
//     float Fss90 = LdotH*LdotH*roughness;
//     float Fss = mix(1.0, Fss90, FL) * mix(1.0, Fss90, FV);
//     float ss = 1.25 * (Fss * (1.0 / (NdotL + NdotV) - .5) + .5);
// 	return ss;
// }

vec3 shadowLighting(vec3 col, out vec3 viewSpaceCoord, in float fogMix) {
	vec3 screenSpaceCoord = vec3(texcoord, depth1);

	vec3 worldPos1 = worldSpacePos(texcoord,depth1);
	vec3 worldPos2 = worldPos1.yxz;
	vec3 worldPos3 = worldPos1.xzy;

	vec3 underneathNormal = calcNormal(worldPos1);

	vec3 shadowSpaceCoord = shadowSpacePos(screenSpaceCoord.xy, screenSpaceCoord.z, lightVec, 0.03, underneathNormal, true) * 0.5 + 0.5;
	
	viewSpaceCoord = viewSpacePos(screenSpaceCoord.xy,screenSpaceCoord.z);

	mat2 rotMatrix = rotationMatrix(texcoord);

	float shadow = 0.0;

	vec3 coloredShadow = vec3(1.0);
	
	shadows(shadowSpaceCoord, rotMatrix, waterMask, shadow, coloredShadow);

	shadow = mix(shadow, 0.0, rainStrength);

	coloredShadow = mix(coloredShadow, vec3(1.0), rainStrength);

	float lambertDiffuse = max0(dot(normalCol, normalize(shadowLightPosition)));

	if(isEyeInWater == 0 && waterMask) {
		lambertDiffuse = max0(dot(normalize(mat3(gbufferModelView)*underneathNormal), normalize(shadowLightPosition)));
	}

	if(glassMask) lambertDiffuse *= max0(dot(normalize(mat3(gbufferModelView)*underneathNormal), normalize(shadowLightPosition)));

	float rayTracedAO = 1.0;
	#ifdef RayTracedAmbientOcclusion
	rayTracedAO = texelFetchShort(colortex5).x;
	#endif

	float vanillaAO = pow2(texelFetchShort(colortex3).a);
	#ifdef RayTracedAmbientOcclusion
	vanillaAO = 1.0;
	#endif

    #ifdef accurateCaustics
	float caustics = accurateWaterCaustics(worldPos1, blueNoiseSample(texcoord, 1.0, vec2(0.0)));
	caustics = mix(accurateWaterCaustics(worldPos2, blueNoiseSample(texcoord, 1.0, vec2(0.0))), caustics, float(abs(underneathNormal).y));
	caustics = mix(caustics, accurateWaterCaustics(worldPos3, blueNoiseSample(texcoord, 1.0, vec2(0.0))), float(abs(underneathNormal).z));
    if (waterMask && isEyeInWater == 0) {
        shadow *= caustics;
    } else if (!waterMask && isEyeInWater == 1) {
		col *= 2.5;
        shadow *= caustics;
    }
    #endif

	shadow = min(shadow, lambertDiffuse);

	float shadowStrength = 1.0*times.sunrise + 1.5*times.noon + 1.0*times.sunset + 0.15*times.night;
	if(waterMask || isEyeInWater != 0) shadowStrength *= 2.5*times.sunrise + 1.0*times.noon + 2.5*times.sunset + 3.5*times.night;
	shadowStrength *= mix(lightMapPow3.y, 1.0, pow2EyeBrightnessMult);
	vec3 shadowColors = constShadowColor;
	shadow *= shadowStrength;

	vec3 sunColors = vec3(0.6,0.7,1.0);

	if(waterMask) lightMapPow3.y = lightMap.y;
	if(isEyeInWater != 0) lightMapPow3.y = 1.0;
	if(glassMask) lightMapPow3.y = pow2EyeBrightnessMult;
	float lightMapBlock = (lightMapPow3.x) * torchLightMult;
	vec3 lMapColored = vec3(1.08,0.4,0.1)*lightMapBlock;

	vec3 shadowMult = shadow+shadowColors* lightMapPow3.y *vanillaAO*rayTracedAO*normalAO;
	vec3 finalMult = (shadowMult*sqrt(coloredShadow));
	finalMult *= (0.75*times.noon + 1.0*times.sunrise + 0.75*times.sunset + 0.06*times.night);
	finalMult += lMapColored;
	if(lightMask) finalMult *= 3.0+pow2(col);

	// if(isEyeInWater==1) col *= 1.5;
	// return clamp01(mix(col*finalMult, col, fogMix));
	return clamp01(col*finalMult);
	// return vec3(lambertDiffuse);
	// return col*rayTracedAO;
	// return texture2D(shadowcolor0, texcoord).rgb;

}

void main() {
	vec3 viewSpaceCoord;
	vec3 color = texelFetchShort(colortex0).rgb;

	float mixFogTerrain = clamp01(pow2(length(viewSpaceCoord.xz)/far)*FOGMULTIPLIER*(1.0+5.0*rainStrength))*pow2EyeBrightnessMult;

	vec3 lightingCalc = shadowLighting(color, viewSpaceCoord, mixFogTerrain);
	if(terrainMask) {
		color = mix(lightingCalc, color, texelFetchShort(colortex15).a); //mainly shadows
		color = mix(color, mix(vec3(luminance(color)), color, clamp(lightMap.x+(1.0-lightMapPow3.y), 0.5, 1.0)), times.night); //purkinje effect
	}

	colortex0Out = color;
}
