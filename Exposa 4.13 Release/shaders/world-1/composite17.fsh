#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable

uniform sampler2D colortex0;

in vec2 texcoord;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec3 colortex0Out;

#include "/lib/includes.glsl"
// #include "/lib/shadows.glsl"
// #include "/lib/sky.glsl"
#include "/lib/bloom.glsl"

void main() {
	// vec3 screenSpaceCoord = vec3(texcoord*2.0, 1.0);
	// screenSpaceCoord.z = texelFetch(depthtex0, ivec2(gl_FragCoord.xy*2.0),0).x;
	// vec3 viewSpaceCoord = viewSpacePos(screenSpaceCoord.xy,screenSpaceCoord.z);
	// vec3 downScaledNormals = texelFetch(colortex1, ivec2(gl_FragCoord.xy*2.0),0).rgb*2.0-1.0;
	
	vec3 color = texelFetchShort(colortex0).rgb;

    color += getBloom(color, texcoord, vec2(0.135, 0.26), 16.0);

	colortex0Out = color;
}