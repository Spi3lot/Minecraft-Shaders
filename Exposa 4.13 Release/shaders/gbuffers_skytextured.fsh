#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable

uniform sampler2D gtexture;

in vec2 texcoord;
in vec4 tint;

/* DRAWBUFFERS:0 */
void main() {
	vec4 color = texture2D(gtexture, texcoord) * tint;

	gl_FragData[0] = color;
}
