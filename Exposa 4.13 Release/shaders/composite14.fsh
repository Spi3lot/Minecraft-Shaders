#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable

uniform sampler2D colortex0;

in vec2 texcoord;

/* DRAWBUFFERS:1 */
layout(location = 0) out vec3 colortex1Out;

#include "/lib/includes.glsl"
// #include "/lib/shadows.glsl"
// #include "/lib/sky.glsl"
#include "/lib/bloom.glsl"

void main() {
	// vec3 screenSpaceCoord = vec3(texcoord*2.0, 1.0);
	// screenSpaceCoord.z = texelFetch(depthtex0, ivec2(gl_FragCoord.xy*2.0),0).x;
	// vec3 viewSpaceCoord = viewSpacePos(screenSpaceCoord.xy,screenSpaceCoord.z);
	// vec3 downScaledNormals = texelFetch(colortex1, ivec2(gl_FragCoord.xy*2.0),0).rgb*2.0-1.0;
	
	vec3 blur = bloomTile(3,vec2(0.0,0.26));
	// blur += bloomTile(3,vec2(0.0,0.26));
	// blur += bloomTile(4,vec2(0.135,0.26));
	// blur += bloomTile(5,vec2(0.2075,0.26));
	// blur += bloomTile(6,vec2(0.235,0.3325));
	// blur += bloomTile(7,vec2(0.260625,0.3325));
	// blur += bloomTile(8,vec2(0.3784375,0.3325));

	colortex1Out = blur;
}