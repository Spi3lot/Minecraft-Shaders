#version 330 compatibility

#include "lib/Common.inc"
#include "lib/Uniforms.inc"


in vec4 glvertex;
in vec4 viewPos;


void main() {
	float dist = length(viewPos);
	float depth = dist / 255.0;
	//float depth = percentage(near, far, dist);

	gl_FragColor = vec4(depth);
}
