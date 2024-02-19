#version 150 compatibility



uniform mat4 textureMatrix = mat4(1.0);





out vec2 texcoord;
out vec4 tint;

void main() {
	gl_Position = ftransform();
	texcoord    = (textureMatrix * vec4(gl_MultiTexCoord0.xy, 0.0, 1.0)).xy;
	tint        = gl_Color;
}
