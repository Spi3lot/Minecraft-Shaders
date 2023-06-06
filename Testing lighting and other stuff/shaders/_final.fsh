#version 330 compatibility


#include "lib/Uniforms.inc"


in vec4 texcoord;
in vec4 c;

void main() {
	vec2 uv = texcoord.st;
	vec3 col = texture2D(gcolor, uv).rgb;
	//float depth = texture2D(gdepthtex, uv).r - near;
	//vec3 col = vec3(depth);
	
	gl_FragColor = vec4(col, 1.0);
}
