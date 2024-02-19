#define PROGRAM FORWARD
#define FLOOD_FILL

layout(location = 0) out vec4 color;

/* DRAWBUFFERS:0 */

#include "/lib/universal/universal.glsl"

uniform sampler2D colortex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowcolor0;
uniform sampler2D gaux1;

uniform mat4 gbufferModelViewInverse;

uniform vec4 entityColor;

uniform vec3 sunVector, moonVector, upVector;
uniform vec3 sunPosition, upPosition;

uniform vec3 skyColor;
uniform vec3 fogColor;

uniform vec3 cameraPosition, previousCameraPosition;

uniform vec2 viewSize;
uniform ivec2 eyeBrightnessSmooth, eyeBrightness;

uniform float screenBrightness;
uniform float far;

uniform int isEyeInWater;

in vec3 worldPosition;
in vec3 viewPosition;
in vec3 scenePosition;
flat in vec3 vertexNormal;
in vec3 tint;
in vec2 lightmapping;
in vec2 textureCoordinate;
in float ao;
in float blockId;

void main() {
    float cosTheta = exp(-dot(vec3(0, 1, 0), fNormalize(mat3(gbufferModelViewInverse) * viewPosition)));
    vec3 colorSky = mix(fogColor*1.8, skyColor, saturate(1.0 - pow(cosTheta, 4.0)));
		 colorSky = mix(fogColor*1.8*clamp(eyeBrightnessSmooth.y/100.0, 0.1, 1.0), colorSky, eyeBrightnessSmooth.y / 255.0);

	float fogDistance = distance(viewPosition, vec3(0.0)) / (far/1.3);
		  fogDistance = pow(fogDistance, 4.0);
	
	if(isEyeInWater > 0) {
		fogDistance = pow(fogDistance * 20.0, 0.25);
		colorSky *= dot(skyColor, vec3(0.25));
	}

    color.rgb = texture(colortex0, textureCoordinate).rgb * tint;
    color.a = texture(colortex0, textureCoordinate).a;
	if(abs(float(blockId) - 1060.0) < 0.6) {
		color.a = 0.8;
	}
}