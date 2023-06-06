#version 330 compatibility

#include "lib/Uniforms.inc"


out vec4 texcoord;
out vec4 c;


void main() {
	// Here we're just setting up things we'll need in final.fsh
	gl_Position = ftransform();
	
	texcoord = /*gl_TextureMatrix[0] * */gl_MultiTexCoord0;
	//gl_Position = texcoord * 2.0 - 1.0;  // SAME AS ftransform !!!
}
