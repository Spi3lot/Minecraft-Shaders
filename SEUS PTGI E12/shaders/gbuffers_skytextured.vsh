#version 120

varying vec4 color;
varying vec4 texcoord;

uniform vec3 sunPosition;
uniform vec3 moonPosition;

void main() {
	gl_Position = ftransform();
	
	color = gl_Color;
	
	texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;

	gl_FogFragCoord = gl_Position.z;

	vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;


	vec3 viewVec = normalize(viewPos.xyz);


}
