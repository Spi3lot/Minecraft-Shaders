#version 400 compatibility

vec4 inPosition = gl_Vertex;
vec4 inTint = gl_Color;

#include "/lib/universal/universal.glsl"

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse, gbufferModelViewInverse;

uniform vec2 taaOffset;

mat4 projectionInverse;
mat4 projection;

void calculateGbufferMatrices() {
	projection = gbufferProjection;
	projectionInverse = gbufferProjectionInverse;
}

vec4 projectVertex(vec3 position) {
	return vec4(projection[0].x, projection[1].y, projection[2].zw) * position.xyzz + projection[3] + vec4(projection[2].xy * position.z, 0.0, 0.0);
}


flat out vec4 tint;

void main() {
    calculateGbufferMatrices();

    vec4 position = inPosition;

    tint = inTint;

    gl_Position.xyz = mat3(gl_ModelViewMatrix) * position.xyz + gl_ModelViewMatrix[3].xyz;
    gl_Position     = projectVertex(gl_Position.xyz);
    gl_Position.xy += taaOffset * gl_Position.w;
}