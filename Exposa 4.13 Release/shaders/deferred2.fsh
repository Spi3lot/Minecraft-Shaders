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
	// if(!terrainMask) color += vec3(0.001,0.01,0.05)*0.1;
	vec3 skySun = atmosphericScattering(mat3(gbufferModelViewInverse)*normalize(viewSpaceCoord),mat3(gbufferModelViewInverse)*normalize(sunPosition)+vec3(0.0,0.15,0.0))*constSkyColor;
	vec3 skyNight = atmosphericScattering(mat3(gbufferModelViewInverse)*normalize(viewSpaceCoord),mat3(gbufferModelViewInverse)*normalize(moonPosition))*constSkyNightColor;

	vec3 skyOverall = abs(skyNight+skySun);

	if(!terrainMask) color += skyOverall;
	// if(!terrainMask) color = abs(mat3(gbufferModelViewInverse)*normalize(sunPosition)-mat3(gbufferModelViewInverse)*normalize(moonPosition));

	// float fogMixTerrain = clamp01(pow2(length(viewSpaceCoord.xz)/far)*FOGMULTIPLIER*(1.0+5.0*rainStrength));

	// if(terrainMask) color = mix(color, skySun+skyNight, fogMixTerrain*pow2EyeBrightnessMult);
	
	colortex0Out = vec4(color, 1.0);
	colortex9Out = vec4(skyOverall, 1.0);
}
