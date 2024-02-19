#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable

uniform sampler2D colortex0;

in vec2 texcoord;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec3 colortex0Out;

#include "/lib/includes.glsl"
#include "/lib/dof.glsl"

void main() {
	vec3 color = texelFetchShort(colortex0).rgb;

	#ifdef DOF
	if(!(depth < 0.56)) color = DOFunction(color, depth1);
	#endif

	colortex0Out = color;
}