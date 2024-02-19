#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable

#define TAA
//#define StainedGlassRefraction
//#define RoughReflections

#define FOGMULTIPLIER 0.1 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]
#define ENDFOGMULTIPLIER 0.5 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]

uniform sampler2D colortex0;
uniform sampler2D colortex9;
uniform sampler2D colortex15;

uniform mat4 gbufferModelView;

uniform float blindness;

uniform int isEyeInWater;

in vec2 texcoord;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec3 colortex0Out;

#include "/lib/includes.glsl"
#include "/lib/sky.glsl"

// bool rayTrace(float stepLength, int samples, vec3 viewPos, float dither, vec3 reflectedVector, inout vec3 reflectedScreenPos) {//function by Tech, modified by me

vec3 refractedColor(vec3 color, vec3 viewSpaceCoord) {
	vec3 refractedCoord = vec3(texcoord, depth);
	vec3 refractedVector = normalize(refract(viewSpaceCoord,normalCol, 0.000));

	// float blueDither = bayer64(gl_FragCoord.xy);
	float blueDither = blueNoiseSample(texcoord.xy, 1.0, vec2(0.0));

	#ifdef TAA
	blueDither = fractDither(blueDither);
	#endif

	bool hit = rayTrace(0.0, 8, viewSpaceCoord, blueDither, refractedVector, refractedCoord,ditherStrength, true);

	vec3 refractedColor = textureLod(colortex0, refractedCoord.xy,0).rgb;

	if(hit) { return refractedColor; }

	return color;
}

vec3 refractedColorFast(vec3 color, vec3 viewSpaceCoord) {
	vec3 viewSpaceCoord1 = viewSpacePos(texcoord, depth1);
	vec3 refractedVector = refract(normalize(viewSpaceCoord), max0((normalCol - flatNormalCol)*16.0), 0.000);
	vec3 refractedCoordView = viewSpaceCoord1 + refractedVector;
	vec3 refractedCoord = screenSpacePos(refractedCoordView);

	if(clamp01(refractedCoord) == refractedCoord) return texture(colortex0, refractedCoord.xy).rgb;
	return color;
}

vec3 terrainFogMix(in vec3 color, in vec3 sky, in vec3 viewSpaceCoord) {
	float fogMixTerrain = clamp01(pow2(length(viewSpaceCoord.xz)/far)*ENDFOGMULTIPLIER*(1.0+5.0*rainStrength));
	return mix(color, sky, (fogMixTerrain));
}

vec3 terrainFogMixBlindness(in vec3 color, in vec3 viewSpaceCoord) {
	float fogMixTerrain = clamp01((length(viewSpaceCoord.xz)/far)*65.0*(1.0+5.0*rainStrength));
	return mix(color, vec3(0.0), fogMixTerrain*blindness);
}


vec3 reflectedWater(vec3 color, vec3 viewSpaceCoord, bool puddles, float blueDither) {
	vec3 reflectedCoord = vec3(texcoord, depth);
	vec3 reflectedVector = normalize(reflect(viewSpaceCoord,normalCol));

	if(puddles) reflectedVector = normalize(reflect(normalize(viewSpaceCoord),normalize((flatNormalCol))));
	
	if(clamp01(reflectedCoord) != reflectedCoord) return color;

	bool hit = rayTrace(0.0, 32, viewSpaceCoord, blueDither, reflectedVector, reflectedCoord, ditherStrength, true);

	vec3 reflectedColor = textureLod(colortex0,reflectedCoord.xy,0).rgb;

	vec3 reflectedViewSpacePos = viewSpacePos(reflectedCoord.xy, reflectedCoord.z);

	vec3 reflectedSky = textureLod(colortex9, reflectedCoord.xy,0).rgb;
	
	float reflectedSkyMix = max0(getAngle(dot(normalize(upPosition), reflectedVector)));

	reflectedColor = terrainFogMix(reflectedColor, reflectedSky, reflectedViewSpacePos);

	float reflectedDepth = textureLod(depthtex0,reflectedCoord.xy,0).x;

	if(clamp01(reflectedCoord.xy) != reflectedCoord.xy) reflectedDepth = 1.0;

	float waterf0 = 1.0;

    float reflectionFresnel = mix(waterf0, 1.0, pow(1.0 - clamp01(dot(normalCol, normalize(viewSpaceCoord))), 5.0));
	// float reflectedLMap = pow2(texture(colortex2, reflectedCoord.xy).g);

	color = mix(color, reflectedSky, pow2(reflectedSkyMix)*sqrt(1.0));

	color = mix(color, reflectedColor, reflectionFresnel*float(hit));
	

	return color;

}

vec3 waterShading(in vec3 color, in vec3 viewSpaceCoord, in vec3 mWaterFogColor, in vec3 waterFogColor, in float mFogMix, in float fogMix, in float blueDither) {
	color = refractedColorFast(color, viewSpaceCoord);

 	color *= mix(mWaterFogColor, color, clamp01(mFogMix+(1.0-pow2EyeBrightnessMult)));

 	color = mix(waterFogColor, color, clamp01(fogMix+(1.0-pow2EyeBrightnessMult)));

	color = mix(color, reflectedWater(color, viewSpaceCoord, false, blueDither), (mat3(gbufferModelViewInverse)*normalCol).y);

	return color;
}


vec3 roughReflections(in vec3 color, in vec3 viewSpaceCoord, in float blueDither) {
	vec3 roughReflectedPos = vec3(texcoord, depth);
	vec3 roughReflectedDir = vec3(0.0);
	vec3 roughReflectedFresnel = vec3(0.0);

	vec3 roughReflectionsColor = ssrRough(roughReflectedPos, viewSpaceCoord, normalCol, blueDither, roughness, reflectance*255, colortex0, roughReflectedDir, roughReflectedFresnel)*reflectance;

	return mix(color, roughReflectionsColor, roughReflectedFresnel);

}

void main() {
	vec3 viewSpaceCoord = viewSpacePos(texcoord, depth);
	// vec4 LQClouds = textureLod(colortex4, texcoord, 5.0);
	vec3 color = texelFetchShort(colortex0).rgb;

	float blueDither = blueNoiseSample(texcoord.xy, 1.0, vec2(0.0));

	#ifdef TAA
	blueDither = fractDither(blueDither);
	#endif

	#ifdef StainedGlassRefraction
	if(glassMask) color = refractedColor(color, viewSpaceCoord);
	#endif
	
    vec3 mWaterFogColor = (vec3(0.2, 0.85, 1.0)*0.5);
	// mWaterFogColor = max(mWaterFogColor,1.0);
	// vec3 waterFogColor = vec3(0.2, 0.65,1.0)*0.02;
    vec3 waterFogColor = (vec3(0.2, 0.65, 1.0)*0.05);
	waterFogColor *= 0.5;
	// float deppe = texture(depthtex0,texcoord).x;
	// float deppe4 = texture(depthtex1,texcoord).x;

    vec3 worldSpacePos0 = worldSpacePos(texcoord, depth);
    vec3 worldSpacePos1 = worldSpacePos(texcoord, depth1);

	// vec3 underneathNormal = calcNormal(worldSpacePos1);

	vec3 customFogColor = atmosphericScattering(mat3(gbufferModelViewInverse)*normalize(viewSpaceCoord),mat3(gbufferModelViewInverse)*normalize(sunPosition)+vec3(0.0, 0.1, 0.0))*constSkyColor;
	customFogColor += atmosphericScattering(mat3(gbufferModelViewInverse)*normalize(viewSpaceCoord),mat3(gbufferModelViewInverse)*normalize(moonPosition))*constSkyNightColor;

	float dist = distance(worldSpacePos0.y, worldSpacePos1.y); //Help by Jessie, who develops shaders such as Chronos and Magnificent and NV
    float dist2 = distance(viewSpaceCoord, gbufferModelViewInverse[3].xyz);

	float mFogMix = exp(-dist*0.65);
	float fogMix = exp(-dist*0.35);
	float fogMix1 = exp(-dist2*0.2);
	// float fogMixTerrain = pow(min((abs(worldSpacePos1.z)+abs(worldSpacePos1.x)) * (FOGMULTIPLIER*0.75+(0.5*rainStrength)) / far, 1.0), 2.0);
	// float fogMixTerrain = clamp01(pow(lind(depth1),1.25)/far);
    // fogMixTerrain = 1.0 - exp(-0.1 * pow(fogMixTerrain, 10.0));
	float fogMixTerrain = clamp01(pow2(length(viewSpaceCoord.xz)/far)*FOGMULTIPLIER*(1.0+5.0*rainStrength));

	float puddles = clamp01(clamp01(1.0-(noiseTexSampleClouds(worldSpacePos0.xz, 0.7, vec2(0.0))))*(mat3(gbufferModelViewInverse)*flatNormalCol).y*rainStrength);

	if(terrainMask && !waterMask) {
		color = mix(color, reflectedWater(color, viewSpaceCoord, false, blueDither), clamp01(mat3(gbufferModelViewInverse)*flatNormalCol).y*rainStrength*pow2(lightMapPow3.y));
		// color = mix(color, reflectedWater(color, viewSpaceCoord, true, blueDither), puddles*pow2(lightMapPow3.y));
	}
	// if(terrainMask && !waterMask) color = mix(color, vec3(puddles), puddles);

	if(waterMask && isEyeInWater == 0) {
		// color = refractedColorFast(color, viewSpaceCoord);
 		// color *= mix(mWaterFogColor, color, clamp01(mFogMix+(1.0-pow2EyeBrightnessMult)));
 		// color = mix(waterFogColor, color, clamp01(fogMix+(1.0-pow2EyeBrightnessMult)));
		// color = reflectedWater(color, viewSpaceCoord);
		// color = clamp01(color*1.8);
		// color *= lightMapPow3.y+pow2(pow2(lightMapPow3.x));
		color = mix(waterShading(color, viewSpaceCoord, mWaterFogColor, waterFogColor, mFogMix, fogMix, blueDither), color, fogMixTerrain*pow2EyeBrightnessMult);
	}

	if(terrainMask && !waterMask && !lightMask) {
		#ifdef RoughReflections
		if(reflectance != 0.0) color = roughReflections(color, viewSpaceCoord, blueDither);
		#endif
	}

	if(isEyeInWater == 1) {
	 	color *= mWaterFogColor*2.0;
		color = mix(waterFogColor, color, fogMix1);
	}

	if(terrainMask && isEyeInWater == 0) {
		// color = vec3(clamp01(fogMixTerrain));
		// color = mix(color, LQSky, (fogMixTerrain)*eyeBrightnessMult*(1.0-texelFetchShort(colortex15).a));
		color = terrainFogMix(color, textureLod(colortex9, texcoord, 4.0).rgb, viewSpaceCoord);

		// color = textureLod(colortex9, texcoord, 5.0).rgb;
		// color = vec3(eyeBrightness.y/240);
	}

	color = terrainFogMixBlindness(color, viewSpaceCoord);

	// color = vec3(texelFetchShort(colortex15).a);

	colortex0Out = color;
}
