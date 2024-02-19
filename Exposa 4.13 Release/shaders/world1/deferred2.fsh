#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable

#define FOGMULTIPLIER 0.1 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]

uniform sampler2D colortex0;

in vec2 texcoord;

/* DRAWBUFFERS:09 */
layout(location = 0) out vec4 colortex0Out;
layout(location = 1) out vec4 colortex9Out;

#include "/lib/includes.glsl"
#include "/lib/sky.glsl"

void main() {
	vec3 viewSpaceCoord = viewSpacePos(texcoord, depth);
	vec3 color = texture2D(colortex0, texcoord).rgb;
	vec3 worldPos = mat3(gbufferModelViewInverse)*normalize(viewSpaceCoord);

	vec3 worldPosClouds = worldPos*float(worldPos.y >= 0.0)+frameTimeCounter*0.03;
	float test2 = clamp01(4.0*noiseTexSampleClouds(worldPos.yy, 4.0, vec2(frameTimeCounter+0.03)));

	vec3 skyEnd = atmosphericScattering(worldPos, normalize(endLightPos))*endLightColor;
	skyEnd += 0.02*(1.0-test2);

	if(!terrainMask) {
		color += skyEnd;
	}

	// if(!terrainMask) color = abs(mat3(gbufferModelViewInverse)*normalize(sunPosition)-mat3(gbufferModelViewInverse)*normalize(moonPosition));

	// float fogMixTerrain = clamp01(pow2(length(viewSpaceCoord.xz)/far)*FOGMULTIPLIER*(1.0+5.0*rainStrength));

	// if(terrainMask) color = mix(color, skySun+skyNight, fogMixTerrain*pow2EyeBrightnessMult);
	
	colortex0Out = vec4(color, 1.0);
	colortex9Out = vec4(skyEnd, 1.0);
}
