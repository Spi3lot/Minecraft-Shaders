#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable

//#define RayTracedAmbientOcclusion

uniform sampler2D colortex0;

in vec2 texcoord;

/* DRAWBUFFERS:5 */
layout(location = 0) out vec4 colortex5Out; //RTAO

#include "/lib/includes.glsl"
// #include "/lib/shadows.glsl"
// #include "/lib/sky.glsl"
#include "/lib/rtao.glsl"

void main() {
	vec3 screenSpaceCoord = vec3(texcoord*2.0, 1.0);
	screenSpaceCoord.z = texelFetch(depthtex0, ivec2(gl_FragCoord.xy*2.0),0).x;
	vec3 viewSpaceCoord = viewSpacePos(screenSpaceCoord.xy,screenSpaceCoord.z);
	vec3 downScaledNormals = texelFetch(colortex1, ivec2(gl_FragCoord.xy*2.0),0).rgb;

	#ifdef RayTracedAmbientOcclusion 
	colortex5Out = vec4(RTAO(downScaledNormals, viewSpaceCoord, screenSpaceCoord),vec3(1.0));
	#else
	colortex5Out = vec4(0.0);
	#endif
}