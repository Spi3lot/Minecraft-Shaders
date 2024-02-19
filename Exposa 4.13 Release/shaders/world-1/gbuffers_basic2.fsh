#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable

uniform sampler2D tex;
uniform sampler2D lightmap;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 tint;

flat in vec3 normal;

flat in float id;

/* DRAWBUFFERS:03 */

#include "/lib/includes.glsl"

void main() {
	vec4 color = texture(tex, texcoord);
	color.rgb *= tint.rgb;
	color.rgb *= texture(lightmap, lmcoord).y;
	color.rgb = pow(color.rgb, vec3(2.2));

	gl_FragData[0] = color;
	gl_FragData[1] = vec4(normal.xy*0.5+0.5, id/65535,1.0);
}
