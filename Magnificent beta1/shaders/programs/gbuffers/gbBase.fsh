#define PROGRAM FORWARD
#define FLOOD_FILL

//#define SHADER_SKY_LIGHT

//#define BICUBIC_INTERPOLATION

layout(location = 0) out vec4 color;

/* DRAWBUFFERS:0 */

#include "/lib/universal/universal.glsl"

uniform sampler2D colortex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowcolor0;
uniform sampler2D gaux1;
uniform sampler2D gaux2;

uniform mat4 gbufferModelViewInverse, gbufferModelView;

uniform vec4 entityColor;

uniform vec3 sunVector, moonVector, upVector;
uniform vec3 sunPosition, upPosition;

uniform vec3 skyColor;
uniform vec3 fogColor;

uniform vec3 cameraPosition, previousCameraPosition;

uniform vec2 viewSize;
uniform ivec2 eyeBrightnessSmooth, eyeBrightness;

uniform float screenBrightness;
uniform float far;
uniform float rainStrength;

uniform int isEyeInWater;
uniform int heldBlockLightValue, heldBlockLightValue2;
uniform int heldItemId, heldItemId2;
uniform int frameCounter;

in vec3 worldPosition;
in vec3 viewPosition;
in vec3 scenePosition;
flat in vec3 vertexNormal;
in vec3 tint;
in vec2 lightmapping;
in vec2 textureCoordinate;
in float ao;
in float blockId;

#include "/lib/voxel/voxelization.glsl"
#include "/lib/voxel/lpv/functions.glsl"
#include "/lib/voxel/lpv/functionsSL.glsl"

#include "/lib/fragment/dither/bayer.glsl"

vec3 getLight(vec3 lpvPosition) {
	lpvPosition = lpvPosition * lpvDetail;

	vec3 lpvPositionFloor = floor(lpvPosition);
	vec3 lpvPositionFloorP1 = lpvPositionFloor + 1.0;

	vec3 x = round(lpvPosition);
    bvec3 xEqual = bvec3(x.x == lpvPositionFloor.x, x.y == lpvPositionFloor.y, x.z == lpvPositionFloor.z);

	vec3 letters[8] = vec3[](
		x,
		vec3(xEqual.x ? lpvPositionFloorP1.x : lpvPositionFloor.x, x.y, x.z),
		vec3(x.x, xEqual.y ? lpvPositionFloorP1.y : lpvPositionFloor.y, x.z),
		vec3(x.x, x.y, xEqual.z ? lpvPositionFloorP1.z : lpvPositionFloor.z),
		vec3(xEqual.x ? lpvPositionFloorP1.x : lpvPositionFloor.x, x.y, xEqual.z ? lpvPositionFloorP1.z : lpvPositionFloor.z),
		vec3(xEqual.x ? lpvPositionFloorP1.x : lpvPositionFloor.x, xEqual.y ? lpvPositionFloorP1.y : lpvPositionFloor.y, x.z),
		vec3(x.x, xEqual.y ? lpvPositionFloorP1.y : lpvPositionFloor.y, xEqual.z ? lpvPositionFloorP1.z : lpvPositionFloor.z),
		vec3(xEqual.x ? lpvPositionFloorP1.x : lpvPositionFloor.x, xEqual.y ? lpvPositionFloorP1.y : lpvPositionFloor.y, xEqual.z ? lpvPositionFloorP1.z : lpvPositionFloor.z)
	);

	bool isLetter[8] = bool[](
		true,
		false,
		false,
		false,
		false,
		false,
		false,
		false
	);

	if(!getVoxelOccupancy(letters[1])) {
		isLetter[1] = true;
		if(!getVoxelOccupancy(letters[4])) {
			isLetter[4] = true;
			if(!getVoxelOccupancy(letters[7])) {
				isLetter[7] = true;
			}
		}
		if(!getVoxelOccupancy(letters[5])) {
			isLetter[5] = true;
			if(!getVoxelOccupancy(letters[7])) {
				isLetter[7] = true;
			}
		}
	}

	if(!getVoxelOccupancy(letters[2])) {
		isLetter[2] = true;
		if(!getVoxelOccupancy(letters[5])) {
			isLetter[5] = true;
			if(!getVoxelOccupancy(letters[7])) {
				isLetter[7] = true;
			}
		}
		if(!getVoxelOccupancy(letters[6])) {
			isLetter[6] = true;
			if(!getVoxelOccupancy(letters[7])) {
				isLetter[7] = true;
			}
		}
	}

	if(!getVoxelOccupancy(letters[3])) {
		isLetter[3] = true;
		if(!getVoxelOccupancy(letters[6])) {
			isLetter[6] = true;
			if(!getVoxelOccupancy(letters[7])) {
				isLetter[7] = true;
			}
		}
		if(!getVoxelOccupancy(letters[4])) {
			isLetter[4] = true;
			if(!getVoxelOccupancy(letters[7])) {
				isLetter[7] = true;
			}
		}
	}

	vec3 lightInterpolated = vec3(0.0);
	for(int n = 0; n < 8; ++n) {
		int id = getVoxelID(letters[n]);
		if(blockId == 0 || id == 3 || id == 4 || id == 5 || id == 6 || id == 7 || id == 8 || id == 10 || id == 11 || id == 12  || id == 13 || id == 20 || id == 90) {
			isLetter[n] = true;
		}
		if(isLetter[n]) {
			vec3 weights = saturate(1.0 - abs(lpvPosition - letters[n]));
			float weight = weights.x * weights.y * weights.z;
			lightInterpolated += getLight(ivec3(letters[n])) * weight;
		}
	}

	return isInPropagationVolume(ivec3(lpvPositionFloor)) ? lightInterpolated : pow(lightmapping.x, 3.0) * (vec3(1.0, 0.9, 0.8) * 2.0);
}

vec3 getSkyLight(vec3 lpvPosition) {
	lpvPosition = lpvPosition * lpvDetail;

	vec3 lpvPositionFloor = floor(lpvPosition);
	vec3 lpvPositionFloorP1 = lpvPositionFloor + 1.0;

	vec3 x = round(lpvPosition);
    bvec3 xEqual = bvec3(x.x == lpvPositionFloor.x, x.y == lpvPositionFloor.y, x.z == lpvPositionFloor.z);

	vec3 letters[8] = vec3[](
		x,
		vec3(xEqual.x ? lpvPositionFloorP1.x : lpvPositionFloor.x, x.y, x.z),
		vec3(x.x, xEqual.y ? lpvPositionFloorP1.y : lpvPositionFloor.y, x.z),
		vec3(x.x, x.y, xEqual.z ? lpvPositionFloorP1.z : lpvPositionFloor.z),
		vec3(xEqual.x ? lpvPositionFloorP1.x : lpvPositionFloor.x, x.y, xEqual.z ? lpvPositionFloorP1.z : lpvPositionFloor.z),
		vec3(xEqual.x ? lpvPositionFloorP1.x : lpvPositionFloor.x, xEqual.y ? lpvPositionFloorP1.y : lpvPositionFloor.y, x.z),
		vec3(x.x, xEqual.y ? lpvPositionFloorP1.y : lpvPositionFloor.y, xEqual.z ? lpvPositionFloorP1.z : lpvPositionFloor.z),
		vec3(xEqual.x ? lpvPositionFloorP1.x : lpvPositionFloor.x, xEqual.y ? lpvPositionFloorP1.y : lpvPositionFloor.y, xEqual.z ? lpvPositionFloorP1.z : lpvPositionFloor.z)
	);

	bool isLetter[8] = bool[](
		true,
		false,
		false,
		false,
		false,
		false,
		false,
		false
	);

	if(!getVoxelOccupancy(letters[1])) {
		isLetter[1] = true;
		if(!getVoxelOccupancy(letters[4])) {
			isLetter[4] = true;
			if(!getVoxelOccupancy(letters[7])) {
				isLetter[7] = true;
			}
		}
		if(!getVoxelOccupancy(letters[5])) {
			isLetter[5] = true;
			if(!getVoxelOccupancy(letters[7])) {
				isLetter[7] = true;
			}
		}
	}

	if(!getVoxelOccupancy(letters[2])) {
		isLetter[2] = true;
		if(!getVoxelOccupancy(letters[5])) {
			isLetter[5] = true;
			if(!getVoxelOccupancy(letters[7])) {
				isLetter[7] = true;
			}
		}
		if(!getVoxelOccupancy(letters[6])) {
			isLetter[6] = true;
			if(!getVoxelOccupancy(letters[7])) {
				isLetter[7] = true;
			}
		}
	}

	if(!getVoxelOccupancy(letters[3])) {
		isLetter[3] = true;
		if(!getVoxelOccupancy(letters[6])) {
			isLetter[6] = true;
			if(!getVoxelOccupancy(letters[7])) {
				isLetter[7] = true;
			}
		}
		if(!getVoxelOccupancy(letters[4])) {
			isLetter[4] = true;
			if(!getVoxelOccupancy(letters[7])) {
				isLetter[7] = true;
			}
		}
	}

	vec3 lightInterpolated = vec3(0.0);
	for(int n = 0; n < 8; ++n) {
		int id = getVoxelID(letters[n]);
		if(id == 3 || id == 4 || id == 5 || id == 6 || id == 7 || id == 8 || id == 10 || id == 11 || id == 12  || id == 13 || id == 20 || id == 90) {
			isLetter[n] = true;
		}
		if(isLetter[n]) {
			vec3 weights = saturate(1.0 - abs(lpvPosition - letters[n]));
			float weight = weights.x * weights.y * weights.z;
			lightInterpolated += getSkyLight(ivec3(letters[n])) * weight;
		}
	}

	return isInPropagationVolumeSky(ivec3(lpvPositionFloor)) ? lightInterpolated : pow(lightmapping.y, 3.0) * vec3(1.4);
}

vec3 getLightLinear(in vec3 lpvPosition) {
	lpvPosition *= lpvDetail;
	ivec3 lpvIndex = ivec3(floor(lpvPosition));
	vec3 lerp = lpvPosition - lpvIndex;

	vec3 lightLoYLoZ = mix(getLight(lpvIndex + ivec3(0,0,0)), getLight(lpvIndex + ivec3(1,0,0)), lerp.x);
	vec3 lightLoYHiZ = mix(getLight(lpvIndex + ivec3(0,0,1)), getLight(lpvIndex + ivec3(1,0,1)), lerp.x);
	vec3 lightHiYLoZ = mix(getLight(lpvIndex + ivec3(0,1,0)), getLight(lpvIndex + ivec3(1,1,0)), lerp.x);
	vec3 lightHiYHiZ = mix(getLight(lpvIndex + ivec3(0,1,1)), getLight(lpvIndex + ivec3(1,1,1)), lerp.x);

	vec3 lightLoZ = mix(lightLoYLoZ, lightHiYLoZ, lerp.y);
	vec3 lightHiZ = mix(lightLoYHiZ, lightHiYHiZ, lerp.y);

	return mix(lightLoZ, lightHiZ, lerp.z);
}

#ifdef BICUBIC_INTERPOLATION
	vec3 getLightBicubic(vec3 position) {
		position *= lpvDetail;
		position = position - 0.5;

		vec3 f = fract(position);
		position -= f;

		vec3 ff = f * f;
		vec3 w0_1;
		vec3 w0_2;
		vec3 w1_1;
		vec3 w1_2;
		w0_1 = 1 - f; w0_1 *= w0_1 * w0_1;
		w1_2 = ff * f;
		w1_1 = 3 * w1_2 + 4 - 6 * ff;
		w0_2 = 6 - w1_1 - w1_2 - w0_1;

		vec3 s1 = w0_1 + w1_1;
		vec3 s2 = w0_2 + w1_2;
		vec3 cLo = position.xyz + vec3(-0.5) + w1_1 / s1;
		vec3 cHi = position.xyz + vec3(1.5) + w1_2 / s2;

		vec3 m = s1 / (s1 + s2);
			 m = 1.0 - m;

		vec3 lightLoYLoZ = mix(getLightLinear(vec3(cLo.x, cLo.y, cLo.z) / lpvDetail), getLightLinear(vec3(cHi.x, cLo.y, cLo.z) / lpvDetail), m.x);
		vec3 lightLoYHiZ = mix(getLightLinear(vec3(cLo.x, cLo.y, cHi.z) / lpvDetail), getLightLinear(vec3(cHi.x, cLo.y, cHi.z) / lpvDetail), m.x);
		vec3 lightHiYLoZ = mix(getLightLinear(vec3(cLo.x, cHi.y, cLo.z) / lpvDetail), getLightLinear(vec3(cHi.x, cHi.y, cLo.z) / lpvDetail), m.x);
		vec3 lightHiYHiZ = mix(getLightLinear(vec3(cLo.x, cHi.y, cHi.z) / lpvDetail), getLightLinear(vec3(cHi.x, cHi.y, cHi.z) / lpvDetail), m.x);

		vec3 lightLoZ = mix(lightLoYLoZ, lightHiYLoZ, m.y);
		vec3 lightHiZ = mix(lightLoYHiZ, lightHiYHiZ, m.y);

		return mix(lightLoZ, lightHiZ, m.z);
	}
#endif

vec3 doBlockLight(in vec3 position) {
	#ifdef BICUBIC_INTERPOLATION
		return getLightBicubic(position);
	#else
		return getLight(position);
	#endif
}

vec3 calculateHandLighting() {
	vec3 lightPos = vec3(0.0, 0.1, 0.0) * 0.8;

	vec3 lightRelativePos = -viewPosition - lightPos;

	float lightDistance = length(lightRelativePos);

	vec3 lightVector = normalize(lightRelativePos);

	float handLight = max(0.4, dot(lightVector, mat3(gbufferModelView) * vertexNormal));
		  handLight *= exp(-lightDistance * 1.6);
		  handLight *= heldBlockLightValue / 4.0;

    float brightness = 0.0;
    if(heldItemId == 1 || heldItemId2 == 1) brightness = 60.0;
    if(heldItemId == 2 || heldItemId2 == 2) brightness = 25.0;
    if(heldItemId == 3 || heldItemId2 == 3) brightness = 10.0;
    if(heldItemId == 4 || heldItemId2 == 4) brightness = 10.0;
    if(heldItemId == 5 || heldItemId2 == 5) brightness = 4.00;
    if(heldItemId == 10 || heldItemId2 == 10) brightness = 10.0;
    if(heldItemId == 11 || heldItemId2 == 11) brightness = 10.0;
    if(heldItemId == 12 || heldItemId2 == 12) brightness = 5.00;
    if(heldItemId == 13 || heldItemId2 == 13) brightness = 20.0;
    if(heldItemId == 14 || heldItemId2 == 14) brightness = 15.0;
    if(heldItemId == 15 || heldItemId2 == 15) brightness = 20.0;
    if(heldItemId == 16 || heldItemId2 == 16) brightness = 10.0;

	vec3 lightColor = vec3(0.0);
    if(heldItemId == 1 || heldItemId2 == 1) lightColor = vec3(0.2, 0.8, 1.0) * .5;
	if(heldItemId == 2 || heldItemId2 == 2) lightColor = vec3(1.0, 0.7, 0.4);
    if(heldItemId == 3 || heldItemId2 == 3) lightColor = vec3(0.7, 0.5, 0.9) * 1.1;
	if(heldItemId == 4 || heldItemId2 == 4) lightColor = vec3(1.00, 0.60, 0.30);
	if(heldItemId == 5 || heldItemId2 == 5) lightColor = vec3(1.00, 0.30, 0.10);
	if(heldItemId == 11 || heldItemId2 == 11) lightColor = vec3(1.00, 0.60, 0.30);
	if(heldItemId == 12 || heldItemId2 == 12) lightColor = vec3(0.1, 0.8, 1.0);
	if(heldItemId == 13 || heldItemId2 == 13) lightColor = vec3(1.0, 0.5, 0.2);
	if(heldItemId == 14 || heldItemId2 == 14) lightColor = vec3(1.0, 0.6, 0.4);
	if(heldItemId == 15 || heldItemId2 == 15) lightColor = vec3(0.6, 0.7, 1.0);
	if(heldItemId == 16 || heldItemId2 == 16) lightColor = vec3(1.0, 0.2, 0.1);

	return handLight * (srgbToLinear(lightColor) * (brightness/2.0));
}

void applyLighting(inout vec3 objectColor) {
    objectColor = srgbToLinear(objectColor) / pi;
    vec3 diffuse = objectColor * mix(max(0.4, dot(vertexNormal, vec3(0, 1, 0))), 1.0, saturate(1.0 - lightmapping.y));
		 diffuse = diffuse * mix(1.0, .3, max(0.1, -vertexNormal.y));

	vec3 skyLightColor = srgbToLinear(skyColor);
	vec3 fogLightColor = srgbToLinear(fogColor);

    float lightmapMin = mix(0.005, 0.030, screenBrightness);
    float skylightMin = mix(mix(0.02, 0.075, screenBrightness), 2.0, smoothstep(0.0, 0.5, dot(sunVector, upVector)));
	#if WORLD == NETHER
    	  //skylightMin = mix(0.02, 0.075, screenBrightness) * 5.0;
	#endif

	float skyLightBoost = 1.0 - (eyeBrightnessSmooth.y / 255.0);

    vec3 skyLight = skyLightColor;
		 skyLight = dot(skyLight, skyLight*vec3(0.7, 0.5, 0.6)*12.0) * mix(fogLightColor, (skyLightColor + fogLightColor)/2.0, dot(vertexNormal, vec3(0, 1, 0)));
		 skyLight = clamp(skyLightColor, skylightMin*2.0, 1.0) * (skyLightBoost + 0.75);

	vec3 unlit = lightmapping.x * vec3(1.0) * 3.0 * objectColor;

    vec3 shading = vec3(0.0);

    #ifndef SKY_TEXTURED
		#ifdef SHADER_SKY_LIGHT
			vec3 skyLightmap = vec3(0.0);
			#ifdef RAIN
				skyLightmap = getSkyLight(ivec3(sceneSpaceToLPVSpace(scenePosition)));
			#else
				skyLightmap = getSkyLight(sceneSpaceToLPVSpace(scenePosition + vertexNormal * 0.25));
			#endif
		#else
			vec3 skyLightmap = pow(lightmapping.y, 3.0) * vec3(1.4) * ao;
		#endif
    	shading = skyLightmap * skyLight * diffuse + shading;
	#else
        shading = unlit + shading;
	#endif

	vec3 blockLight = vec3(0.0);

	#ifdef RAIN
		blockLight = getLight(ivec3(sceneSpaceToLPVSpace(scenePosition)));
	#else
		blockLight = doBlockLight(sceneSpaceToLPVSpace(scenePosition + vertexNormal * 0.25));
	#endif

	#ifdef TEXTURED_LIT
		blockLight = getLight(sceneSpaceToLPVSpace(scenePosition));
	#endif

	vec3 blockLighting = max(blockLight, 0.0) * objectColor;
    #ifndef SKY_TEXTURED
        shading = blockLighting + shading;
    #else
        shading = unlit + shading;
    #endif

	shading += calculateHandLighting() * ao * objectColor;

    #ifdef TEXTURED_LIT
        //shading = unlit + shading;
    #endif

    shading = lightmapMin * vec3(1.0) * diffuse * ao + shading;

    objectColor = shading;
}

vec3 lpvVolume(vec3 color, vec3 start, vec3 end) {
	const vec3 overworldAbsorb 		= vec3(5e-2, 13e-2, 33e-2);
	const vec3 netherWastesAbsorb	= vec3(0.01,  0.30,  0.50);
	const vec3 soulSandValleyAbsorb = vec3(0.40,  0.01,  0.03);
	const vec3 crimsonForestAbsorb	= vec3(0.01,  0.07,  0.40);
	const vec3 warpedForestAbsorb	= vec3(0.40,  0.06,  0.01);
	const vec3 basaltDeltasAbsorb	= vec3(0.04,  0.05,  0.06);

	const vec3 overworldScatter		 = overworldAbsorb * 10.0;
	const vec3 netherWastesScatter	 = vec3(0.70, 0.40, 0.10);
	const vec3 soulSandValleyScatter = vec3(0.03, 0.60, 0.70);
	const vec3 crimsonForestScatter	 = vec3(0.90, 0.20, 0.10);
	const vec3 warpedForestScatter	 = vec3(0.03, 0.30, 0.80);
	const vec3 basaltDeltasScatter	 = vec3(0.40, 0.50, 0.45);

	vec3 absorption = fogColor * 0.01;
	vec3 scatteringCoefficient = fogColor * 0.1;
	vec3 extinctionCoefficient = scatteringCoefficient + absorption;

	const int steps = 4;
	float rayDistance = distance(end, start);
	vec3 worldDirection = normalize(end - start);

	float dither = fract(fract(frameCounter * (1.0 / phi)) + bayer16(gl_FragCoord.st));
	vec3 ambientLighting = fogColor * (screenBrightness/50.0);

	vec3 scattering = vec3(0.0);
	vec3 scatteringAmbient = vec3(0.0);
	vec3 transmittance = exp(-extinctionCoefficient * rayDistance);

	vec3 scatteringIntegral = scatteringCoefficient * (1.0 - transmittance) / extinctionCoefficient;
	for(int i = 0; i < steps; ++i) {
		vec3 f = vec3(i + dither) / steps;
				f = f * (1.0 - transmittance) + transmittance;
		vec3 t = -log(f) / extinctionCoefficient;

		vec3 weight = vec3(1.0);

		mat3x3 worldPosition = mat3x3(
			start + worldDirection * t.r, 
			start + worldDirection * t.g, 
			start + worldDirection * t.b
		);

		vec3 lighting = vec3(getLight((sceneSpaceToLPVSpace(worldPosition[0]))).r, getLight((sceneSpaceToLPVSpace(worldPosition[1]))).g, getLight((sceneSpaceToLPVSpace(worldPosition[2]))).b);
		lighting += vec3(getSkyLight((sceneSpaceToLPVSpace(worldPosition[0]))).r, getSkyLight((sceneSpaceToLPVSpace(worldPosition[1]))).g, getSkyLight((sceneSpaceToLPVSpace(worldPosition[2]))).b);

		scattering += lighting * weight;
		scatteringAmbient += weight;
	}

	vec3 scattered  = scattering * (0.25 / pi);
			scattered += scatteringAmbient * ambientLighting * (0.25 / pi);
			scattered *= scatteringIntegral / steps;

	return color * transmittance + scattered;
}

void main() {
    initializeLpvVariables();
    initializeLpvVariablesSky();

    float cosTheta = exp(-dot(vec3(0, 1, 0), fNormalize(mat3(gbufferModelViewInverse) * viewPosition)));
    vec3 colorSky = mix(fogColor*1.8, skyColor, saturate(1.0 - pow(cosTheta, 4.0)));
		 colorSky = mix(fogColor*1.8*clamp(eyeBrightnessSmooth.y/100.0, 0.1, 1.0), colorSky, eyeBrightnessSmooth.y / 255.0);

	float fogDistance = distance(viewPosition, vec3(0.0)) / mix(far/1.1, far/2.3, rainStrength);
	
	if(isEyeInWater > 0) {
		fogDistance = pow(fogDistance * 2.0, 0.25);
		colorSky *= dot(skyColor, vec3(0.25));
	} else {
		fogDistance = pow(fogDistance, mix(3.0, 0.75, rainStrength));
	}

	if(texture(colortex0, textureCoordinate).a < 0.108) {
		discard;
	}

    color.rgb = texture(colortex0, textureCoordinate).rgb * tint;
	color.rgb += entityColor.rgb * entityColor.a;
    #ifndef SKY_TEXTURED
    	applyLighting(color.rgb);
		color.rgb = mix(color.rgb, srgbToLinear(colorSky) / pi, saturate(fogDistance));
	#endif
	#ifdef SKY_TEXTURED
		color.rgb = mix(color.rgb, srgbToLinear(colorSky) / 200.0, saturate(rainStrength + float(isEyeInWater > 0)));
	#endif
    color.a = texture(colortex0, textureCoordinate).a;
	if(abs(float(blockId) - 1060.0) < 0.6) {
		color.a = 0.8;
	}

}