/*
====================================================================================================

    Copyright (C) 2023 RRe36

    All Rights Reserved unless otherwise explicitly stated.


    By downloading this you have agreed to the license and terms of use.
    These can be found inside the included license-file
    or here: https://rre36.com/copyright-license

    Violating these terms may be penalized with actions according to the Digital Millennium
    Copyright Act (DMCA), the Information Society Directive and/or similar laws
    depending on your country.

====================================================================================================
*/

/* RENDERTARGETS: 0,2,8 */
layout(location = 0) out vec4 sceneColor;
layout(location = 1) out vec4 temporalData;
layout(location = 2) out vec4 temporalAux;

#include "/lib/head.glsl"

const bool colortex2Clear   = false;
const bool colortex8Clear   = false;

in vec2 uv;

uniform sampler2D colortex0, colortex5, colortex11;
uniform sampler2D colortex2, colortex8;

uniform sampler2D depthtex0, depthtex1, depthtex2;

uniform vec2 pixelSize, viewSize, taaOffset;

uniform vec3 cameraPosition, previousCameraPosition;

uniform mat4 gbufferModelView, gbufferModelViewInverse;
uniform mat4 gbufferProjection, gbufferProjectionInverse;
uniform mat4 gbufferPreviousModelView, gbufferPreviousProjection;

vec2 ReprojectView(vec2 uv, float depth, bool hand) {
    vec4 pos    = vec4(uv, depth, 1.0)*2.0-1.0;
        pos     = gbufferProjectionInverse*pos;
        pos    /= pos.w;
        pos     = gbufferModelViewInverse*pos;

    vec4 ppos   = pos + vec4(cameraPosition-previousCameraPosition, 0.0) * float(hand);
        ppos    = gbufferPreviousModelView*ppos;
        ppos    = gbufferPreviousProjection*ppos;

    return (ppos.xy/ppos.w)*0.5+0.5;
}

vec4 textureCatmullRom(sampler2D tex, vec2 uv) {   //~5fps
    vec2 res    = textureSize(tex, 0);

    vec2 coord  = uv*res;
    vec2 coord1 = floor(coord - 0.5) + 0.5;

    vec2 f      = coord-coord1;

    vec2 w0     = f * (-0.5 + f * (1.0 - (0.5 * f)));
    vec2 w1     = 1.0 + sqr(f) * (-2.5 + (1.5 * f));
    vec2 w2     = f * (0.5 + f * (2.0 - (1.5 * f)));
    vec2 w3     = sqr(f) * (-0.5 + (0.5 * f));

    vec2 w12    = w1+w2;
    vec2 delta12 = w2 * rcp(w12);

    vec2 uv0    = (coord1 - vec2(1.0)) * pixelSize;
    vec2 uv3    = (coord1 + vec2(1.0)) * pixelSize;
    vec2 uv12   = (coord1 + delta12) * pixelSize;

    vec4 col    = vec4(0.0);
        col    += textureLod(tex, vec2(uv0.x, uv0.y), 0)*w0.x*w0.y;
        col    += textureLod(tex, vec2(uv12.x, uv0.y), 0)*w12.x*w0.y;
        col    += textureLod(tex, vec2(uv3.x, uv0.y), 0)*w3.x*w0.y;

        col    += textureLod(tex, vec2(uv0.x, uv12.y), 0)*w0.x*w12.y;
        col    += textureLod(tex, vec2(uv12.x, uv12.y), 0)*w12.x*w12.y;
        col    += textureLod(tex, vec2(uv3.x, uv12.y), 0)*w3.x*w12.y;

        col    += textureLod(tex, vec2(uv0.x, uv3.y), 0)*w0.x*w3.y;
        col    += textureLod(tex, vec2(uv12.x, uv3.y), 0)*w12.x*w3.y;
        col    += textureLod(tex, vec2(uv3.x, uv3.y), 0)*w3.x*w3.y;

    return clamp(col, 0.0, 65535.0);
}

/* geometric hue angle calculation */
float rgbHue(vec3 rgb) {
    float hue;
    if (rgb.x == rgb.y && rgb.y == rgb.z) hue = 0.0;
    else hue = (180.0 * rcp(pi)) * atan(2.0 * rgb.x - rgb.y - rgb.z, sqrt(3.0) * (rgb.y - rgb.z));

    if (hue < 0.0) hue = hue + 360.0;

    return clamp(hue, 0.0, 360.0);
}
float centerHue(float hue, float center) {
    float hueCentered = hue - center;

    if (hueCentered < -180.0) hueCentered += 360.0;
    else if (hueCentered > 180.0) hueCentered -= 360.0;

    return hueCentered;
}
float rgbSaturation(vec3 rgb) {
    float minrgb    = minOf(rgb);
    float maxrgb    = maxOf(rgb);

    return (max(maxrgb, 1e-10) - max(minrgb, 1e-10)) / max(maxrgb, 1e-2);
}

vec3 RGB_To_YCC(vec3 Color) {
	return vec3(
		Color.r * 0.25 + Color.g * 0.5 + Color.b * 0.25,
		Color.r * 0.5 - Color.b * 0.5,
		Color.r * -0.25 + Color.g * 0.5 + Color.b * -0.25
	);
}
vec3 YCC_To_RGB(vec3 Color) {
	float n = Color.r - Color.b;
	return vec3(n + Color.g, Color.r + Color.b, n - Color.g);
}

vec3 Reinhard(vec3 HDR){
	return HDR / (1.0 + getLuma(HDR));
}
vec3 InverseReinhard(vec3 SDR){
	return SDR / max(1.0 - getLuma(SDR), 1e-10);
}

ivec2 ClampToViewport(ivec2 UV) {
    return clamp(UV, ivec2(0), ivec2(viewSize * ResolutionScale));
}

#include "/lib/util/bicubic.glsl"

/*
    From SixthSurge
*/
vec3 ClipAabb(vec3 q, vec3 aabbMin, vec3 aabbMax, out bool HasClipped) {
    vec3 pClip = 0.5 * (aabbMax + aabbMin);
    vec3 eClip = 0.5 * (aabbMax - aabbMin);

    vec3 vClip = q - pClip;
    vec3 vUnit = vClip / eClip;
    vec3 aUnit = abs(vUnit);
    float maUnit = maxOf(aUnit);

    HasClipped = maUnit > 1.0;
    return HasClipped ? pClip + vClip / maUnit : q;
}
float GetAabbClipDistance(vec3 q, vec3 aabbMin, vec3 aabbMax, float Exposure) {
	float Dist = length(min((q - aabbMin), (aabbMax - q))) * Exposure;
	return saturate(Dist);
}

float LanczosWeight(float x, const float a) {
	float w = a * sin(pi * x) * sin(pi * x / a) / (pi * pi * x * x);
	return x == 0.0 ? 1.0 : w;
}

#define CONFIDENCE 1.0
#define SAMPLE_RAD 1

vec4 TextureLanczosTonemapped(sampler2D sampler, vec2 uv, float Exposure) {      // Eliminates NaNs caused by HDR
	ivec2 res = ivec2(textureSize(sampler, 0));
	vec2 pos = uv * res - 0.5;
	ivec2 texel = ivec2(pos);

	vec3 sum = vec3(0.0);
	float weightSum = 0.0;
	float confidence = 0.0;

	for (int x = -SAMPLE_RAD; x < SAMPLE_RAD; ++x) {
		int texelX = texel.x + x;
		float wX = LanczosWeight(pos.x - texelX, CONFIDENCE);

		for (int y = -SAMPLE_RAD; y < SAMPLE_RAD; ++y) {
			int texelY = texel.y + y;
			float wY = LanczosWeight(pos.y - texelY, CONFIDENCE);
			float w = max(wX * wY, 1e-10);

			sum += w * texelFetch(sampler, ivec2(texelX, texelY), 0).rgb;
			weightSum += w;
			confidence = max(confidence, w);
		}
	}

	return vec4(InverseReinhard(saturate(sum) / weightSum) / Exposure, confidence);
}

vec3 GetClosestTexel(sampler2D depth, vec2 uv) {
    vec3 ClosestTexel = vec3(uv, texelFetch(depth, ivec2(uv * viewSize), 0).x);

    for (int x = -1; x <= 1; ++x) {
        if (x == 0) continue;

        vec2 currentUV  = uv + vec2(x, 0) * pixelSize;

        ivec2 PixelUV   = ivec2(currentUV * viewSize);

        if (ClampToViewport(PixelUV) != PixelUV) continue;

        float currentDepth  = texelFetch(depth, PixelUV, 0).x;

        if (currentDepth < ClosestTexel.z) {
            ClosestTexel = vec3(currentUV, currentDepth);
        }
    }

    for (int y = -1; y <= 1; ++y) {
        if (y == 0) continue;

        vec2 currentUV  = uv + vec2(0, y) * pixelSize;

        ivec2 PixelUV   = ivec2(currentUV * viewSize);

        if (ClampToViewport(PixelUV) != PixelUV) continue;

        float currentDepth  = texelFetch(depth, PixelUV, 0).x;

        if (currentDepth < ClosestTexel.z) {
            ClosestTexel = vec3(currentUV, currentDepth);
        }
    }

    return ClosestTexel;
}


vec3 NeighbourhoodClamping(vec3 Color, vec3 HistoryColor, float Exposure, out float ClipDistance) {
	vec3 MinColor = clamp16FN(textureLod(colortex5, uv * ResolutionScale, 0).rgb);
	vec3 MaxColor = clamp16FN(textureLod(colortex11, uv * ResolutionScale, 0).rgb);

	HistoryColor = RGB_To_YCC(HistoryColor);
    //MinColor = RGB_To_YCC(MinColor);
    //MaxColor = RGB_To_YCC(MaxColor);

    bool HasClipped = false;
	HistoryColor = ClipAabb(HistoryColor, MinColor, MaxColor, HasClipped);
    ClipDistance = HasClipped ? 0.0 : GetAabbClipDistance(HistoryColor, MinColor, MaxColor, Exposure);
    //HistoryColor = clamp(HistoryColor, MinColor, MaxColor);

	return YCC_To_RGB(HistoryColor);
}

#define TAA_OFFCENTER_REJECTION 0.25
#define taaBlendWeight 0.1          //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define taaMotionRejection 1.0      //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define taaAntiGhosting 1.0         //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define taaAntiFlicker 0.5          //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define taaLumaRejection 1.0        //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define taaHueRejection 1.0         //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define taaCatmullRom

vec3 TemporalUpscaling(float SceneDepth, float Exposure) {
    vec3 ClosestSample  = GetClosestTexel(depthtex1, uv * ResolutionScale);
        ClosestSample.xy /= ResolutionScale;
    vec2 HistoryUV  = ReprojectView(ClosestSample.xy, ClosestSample.z, texture(depthtex2, uv * ResolutionScale).x == SceneDepth);

    vec2 Velocity   = ClosestSample.xy - HistoryUV;

        HistoryUV   = uv - Velocity;

    vec2 AdjustedUV = uv * ResolutionScale + taaOffset * 0.5;

    vec4 SceneColor = TextureLanczosTonemapped(colortex0, AdjustedUV, Exposure);
    //return SceneColor.rgb;

    if (saturate(HistoryUV) == HistoryUV) {
        vec4 HistoryAux = clamp16F(textureCatmullRom(colortex8, HistoryUV));
            HistoryAux.x    = clamp(1.0 + HistoryAux.x, 1.0, 256.0);

        vec3 HistoryColor   = textureCatmullRom(colortex2, HistoryUV).rgb;

        float ColorClipDistance = 0.0;
        vec3 HistoryClamped = NeighbourhoodClamping(SceneColor.rgb, HistoryColor, Exposure, ColorClipDistance);
            //HistoryClamped      = HistoryColor; 


        // Doing TAA(U) in a Tonemapped Color Space introduces lots of weird artifacts and is *not* good, unlike what many papers say.
        // Might yield better results with a better Tonemap though.
            //SceneColor.rgb  = saturate(Reinhard(SceneColor.rgb * Exposure));
            //HistoryColor    = saturate(Reinhard(HistoryColor * Exposure));
            //HistoryClamped  = saturate(Reinhard(HistoryClamped * Exposure));


        // Offcenter rejection (reduces blur in motion)
        vec2 pixelOffset = 1.0 - abs(2.0 * fract(HistoryUV * viewSize) - 1.0);
        float OffcenterRejection = sqrt(pixelOffset.x * pixelOffset.y) * TAA_OFFCENTER_REJECTION + (1.0 - TAA_OFFCENTER_REJECTION);

        float Alpha     = max(sqr(1.0 / HistoryAux.x), 0.075);
            Alpha      *= SceneColor.a;
            Alpha      *= 1.0 - ColorClipDistance;

            Alpha       = 1.0 - Alpha;

            Alpha  *= OffcenterRejection;

        // Luma Rejection
        float LumaDifference  = distance((HistoryColor), (SceneColor.rgb)) / max(getLuma((HistoryColor)), 1e-4);
            LumaDifference    = sqr(LumaDifference) * taaLumaRejection;

        Alpha   = 1.0 - Alpha;

        Alpha  /= 1.0 + LumaDifference * taaAntiFlicker;

        vec3 Accumulated = mix(HistoryClamped, SceneColor.rgb, saturate(Alpha));
        HistoryAux.x *= OffcenterRejection;

        temporalAux     = HistoryAux;

        return Accumulated;
    } else {
        temporalAux     = vec4(1.0);
    }

    return SceneColor.rgb;
}
void main() {
        sceneColor   = textureLod(colortex0, uv * ResolutionScale, 0);
        temporalAux  = vec4(0.0);

    float Exposure  = texture(colortex2, vec2(0.0)).a;

    vec3 Supersampled = TemporalUpscaling(texture(depthtex1, uv * ResolutionScale).x, max(Exposure, 1e-8));

        //sceneColor.rgb = Supersampled;
        sceneColor.rgb = Reinhard(Supersampled * max(Exposure, 1e-8));

        //Supersampled = InverseReinhard(Supersampled) / Exposure;

    sceneColor      = clamp16F(sceneColor);
    temporalData    = clamp16F(vec4(Supersampled, Exposure));
}