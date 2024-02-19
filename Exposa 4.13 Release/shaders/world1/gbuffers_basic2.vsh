#version 150 compatibility

#define TAA

in vec4 at_tangent;
in vec3 mc_Entity;

flat out vec3 normal;

flat out float id;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 tint;

#include "/lib/vshjitter.glsl"

void main() {
	gl_Position = ftransform();
	texcoord    = gl_MultiTexCoord0.xy;
	lmcoord     = gl_MultiTexCoord2.xy * (1.0 / 256.0) + (1.0 / 32.0);
	tint        = gl_Color;
	normal      = normalize(gl_NormalMatrix*gl_Normal);

    #ifdef TAA
    gl_Position.xy = taaJitter(gl_Position.xy, gl_Position.w);
    #endif

    id = mc_Entity.x;
}
