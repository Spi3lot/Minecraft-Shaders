#version 330 compatibility

#include "lib/Uniforms.inc"


out vec4 texcoord;
out vec4 lmcoord;

out vec4 glcolor;


void main() {
	gl_Position = ftransform();

    texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;
	lmcoord  = gl_TextureMatrix[1] * gl_MultiTexCoord1;
    glcolor = gl_Color;
}
