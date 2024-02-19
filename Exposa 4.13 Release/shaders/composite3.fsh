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
	float RTAO = texture2D(colortex5, texcoord*0.5).x;
	// RTAO = float(depthWeightedGuassianBlur(colortex5, 1.0, depthtex0, 5.0,1));
	colortex5Out = RTAO;
}
