//Fragment Output
layout(location = 0) out vec3 outTemporal;

//Samplers
uniform sampler2D colortex0;
uniform sampler2D colortex2;

uniform sampler2D depthtex1;

//Uniforms
uniform mat4 gbufferProjection;
uniform mat4 gbufferModelViewInverse, gbufferProjectionInverse;
uniform mat4 gbufferPreviousProjection, gbufferPreviousModelView;

uniform vec3 cameraPosition, previousCameraPosition;

uniform vec2 viewSize, viewPixelSize;

uniform float frameTime;

//Fragment Inputs
in vec2 textureCoordinate;

const bool colortex0Clear = false;
const bool colortex1Clear = false;
const bool colortex2Clear = false;
const bool colortex3Clear = false;
const bool colortex5Clear = false;
const bool colortex6Clear = false;
const bool colortex7Clear = false;

const bool colortex0MipmapEnabled = true;

#include "/lib/universal/universal.glsl"

vec4 temporalAntiAliasing();

/* DRAWBUFFERS:2 */
void main() {
    outTemporal = temporalAntiAliasing().rgb;
}

vec4 reproject(vec4 position) {
	position = position * 2.0 - 1.0;

	position      = gbufferModelViewInverse * gbufferProjectionInverse * position;
	position     /= position.w;
	position.xyz += cameraPosition;

	position.xyz -= previousCameraPosition;
	position      = gbufferPreviousProjection * gbufferPreviousModelView * position;
	position     /= position.w;

	position = position * 0.5 + 0.5;
	return position;
}

vec4 temporalAntiAliasing() {
    vec4 returnColor = vec4(0.0);
	vec4 position = vec4(textureCoordinate, texture(depthtex1, textureCoordinate).r, 1.0);
	vec4 reprojectedPosition = reproject(position);

	float blendWeight = 0.95;

	cFloat offcenterRejection = 0.5;
	vec2 pixelCenterDist = 1.0 - abs(2.0 * fract(reprojectedPosition.xy * viewSize) - 1.0);
	blendWeight *= sqrt(pixelCenterDist.x * pixelCenterDist.y) * offcenterRejection + (1.0 - offcenterRejection);

	if (clamp(reprojectedPosition.xy, 0.0, 1.0) != reprojectedPosition.xy) { blendWeight *= 0.0; }

	vec4 currentFrame = textureCatmullRom(colortex0, position.xy);
	vec4 previousFrame = vec4(textureCatmullRom(colortex2, reprojectedPosition.xy).rgb, 1.0);

	vec3 tl = textureCatmullRom(colortex0, viewPixelSize * vec2(-1,-1) + textureCoordinate).rgb;
	vec3 tc = textureCatmullRom(colortex0, viewPixelSize * vec2( 0,-1) + textureCoordinate).rgb;
	vec3 tr = textureCatmullRom(colortex0, viewPixelSize * vec2( 1,-1) + textureCoordinate).rgb;
	vec3 ml = textureCatmullRom(colortex0, viewPixelSize * vec2(-1, 0) + textureCoordinate).rgb;
	vec3 mc = currentFrame.rgb;
	vec3 mr = textureCatmullRom(colortex0, viewPixelSize * vec2( 1, 0) + textureCoordinate).rgb;
	vec3 bl = textureCatmullRom(colortex0, viewPixelSize * vec2(-1, 1) + textureCoordinate).rgb;
	vec3 bm = textureCatmullRom(colortex0, viewPixelSize * vec2( 0, 1) + textureCoordinate).rgb;
	vec3 br = textureCatmullRom(colortex0, viewPixelSize * vec2( 1, 1) + textureCoordinate).rgb;

	vec3 min_col = min(min(min(min(min(min(min(min(tl, tc), tr), ml), mc), mr), bl), bm), br);
	vec3 max_col = max(max(max(max(max(max(max(max(tl, tc), tr), ml), mc), mr), bl), bm), br);

	returnColor.rgb = mix(currentFrame.rgb, clamp(previousFrame.rgb, min_col, max_col), blendWeight);

    return returnColor;
}