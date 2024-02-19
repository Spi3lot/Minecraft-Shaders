vec4 inPosition = gl_Vertex;
vec4 inTint = gl_Color;
vec3 inNormal = gl_Normal;
vec4 inTexCoord = gl_MultiTexCoord0;
vec4 inLMCoord = gl_MultiTexCoord1;

#define attribute in
attribute vec4 at_tangent;
attribute vec4 mc_Entity;
attribute vec2 mc_midTexCoord;

#include "/lib/universal/universal.glsl"

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse, gbufferModelViewInverse;

uniform vec3 cameraPosition;

uniform vec2 taaOffset;

uniform float sunAngle;
uniform float frameTimeCounter;


mat4 projectionInverse;
mat4 projection;

void calculateGbufferMatrices() {
	projection = gl_ProjectionMatrix;
	projectionInverse = gbufferProjectionInverse;
}

vec4 projectVertex(vec3 position) {
	return vec4(projection[0].x, projection[1].y, projection[2].zw) * position.xyzz + projection[3] + vec4(projection[2].xy * position.z, 0.0, 0.0);
}


out vec4 timeVector;
out vec3 worldPosition;
out vec3 scenePosition;
out vec3 viewPosition;
flat out vec3 vertexNormal;
out vec3 tint;
out vec2 lightmapping;
out vec2 textureCoordinate;
out float ao;
out float blockId;

void main() {
    calculateGbufferMatrices();

    vec4 position = inPosition;

    vec2 noonNight   = vec2(0.0);
         noonNight.x = (0.25 - clamp(sunAngle, 0.0, 0.5));
         noonNight.y = (0.75 - clamp(sunAngle, 0.5, 1.0));

    timeVector.x = 1.0 - saturate(square(abs(noonNight.x) * 4.0));
    timeVector.y = 1.0 - saturate(pow(abs(noonNight.y) * 4.0, 128.0));
    timeVector.z = 1.0 - (timeVector.x + timeVector.y);
    timeVector.w = 1.0 - ((1.0 - saturate(square(max0(noonNight.x) * 4.0))) + (1.0 - saturate(pow(max0(noonNight.y) * 4.0, 128.0))));

	worldPosition = (gbufferModelViewInverse * gl_ModelViewMatrix * position).xyz + cameraPosition;
	scenePosition = (gbufferModelViewInverse * gl_ModelViewMatrix * position).xyz;
	viewPosition = (gl_ModelViewMatrix * position).xyz;

    vertexNormal = mat3(gbufferModelViewInverse) * fNormalize(gl_NormalMatrix * inNormal);

    tint = inTint.rgb;

    lightmapping = inLMCoord.st/255.0;
    lightmapping = cube(lightmapping);
    textureCoordinate = inTexCoord.st;

    ao = inTint.a;

    blockId = mc_Entity.x;

    gl_Position.xyz = mat3(gl_ModelViewMatrix) * position.xyz + gl_ModelViewMatrix[3].xyz;
    gl_Position     = projectVertex(gl_Position.xyz);
    gl_Position.xy += taaOffset * gl_Position.w;
}