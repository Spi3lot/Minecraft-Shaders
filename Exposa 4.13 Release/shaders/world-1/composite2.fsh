#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable

uniform sampler2D colortex5;

in vec2 texcoord;

/* DRAWBUFFERS:5 */
layout(location = 0) out float colortex5Out; //RTAO

#include "/lib/includes.glsl"
// #include "/lib/shadows.glsl"
// #include "/lib/sky.glsl"
// #include "/lib/rtao.glsl"

void main() {
	// float RTAO = texelFetchShort(colortex5).x;
	float RTAO = float(depthWeightedGuassianBlur(colortex5, 2.0, depthtex0, 1.0,2));
	colortex5Out = RTAO;
}
