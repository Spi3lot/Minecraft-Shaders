#version 150 compatibility
#define TAA

out vec2 lmcoord;
out vec2 texcoord;

#include "/lib/vshjitter.glsl"

void main() {
	gl_Position = ftransform();
	texcoord    = gl_MultiTexCoord0.xy;
	lmcoord     = gl_MultiTexCoord2.xy * (1.0 / 256.0) + (1.0 / 32.0);

    #ifdef TAA
    gl_Position.xy = taaJitter(gl_Position.xy, gl_Position.w);
    #endif

}
