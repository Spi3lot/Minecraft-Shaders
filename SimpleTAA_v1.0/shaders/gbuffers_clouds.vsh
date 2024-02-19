#version 120

varying vec3 sceneLocation;

varying vec2 uv;
varying vec4 glcolor;

uniform vec2 taaOffset;

void main() {
	gl_Position     = gl_ModelViewMatrix * gl_Vertex;
    sceneLocation   = gl_Position.xyz;
    gl_Position     = gl_ProjectionMatrix * gl_Position;
    gl_Position.xy += taaOffset * gl_Position.w;

	uv = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;
}