#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable

in vec2 texcoord;
in vec4 tint;

/* DRAWBUFFERS:0 */
void main() {

	gl_FragData[0] = vec4(0.0,0.0,0.0,1.0);
}
