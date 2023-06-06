#version 330 compatibility


uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 shadowLightPosition;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;


void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;  // Player pos but just with added rotation ??
	vec4 playerPos = gbufferModelViewInverse * viewPos;  // gl_ModelViewMatrix * gbufferModelViewInverse = model matrix (because gbufferModelViewInverse is actually gbufferViewInverse)

	gl_Position = gl_ProjectionMatrix * viewPos;
}
