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

#include "/lib/pipeline.glsl"

layout(location = 0) out vec3 sceneImage;

#include "/lib/head.glsl"
#include "/lib/util/colorspace.glsl"

in vec2 uv;

uniform sampler2D colortex0;

uniform int hideGUI;

uniform float aspectRatio;

uniform vec2 pixelSize;
uniform vec2 viewSize;

float bayer2  (vec2 c) { c = 0.5 * floor(c); return fract(1.5 * fract(c.y) + c.x); }
float bayer4  (vec2 c) { return 0.25 * bayer2 (0.5 * c) + bayer2(c); }
float bayer8  (vec2 c) { return 0.25 * bayer4 (0.5 * c) + bayer2(c); }
float bayer16 (vec2 c) { return 0.25 * bayer8 (0.5 * c) + bayer2(c); }

#define screenBitdepth 8   //[1 2 4 6 8]

vec3 ditherImage(vec3 color) {
    const uint bits = uint(pow(2, screenBitdepth));

    vec3 cDither    = color;
        cDither    *= bits;
        cDither    += bayer16(gl_FragCoord.xy) - 0.5;

    return round(cDither)/bits;
}

#include "/lib/util/bicubic.glsl"

vec3 textureCAS(sampler2D tex, vec2 uv, const float w) {   //~8fps
    vec2 res    = textureSize(tex, 0);
    vec2 pixelSize = rcp(res);

    vec3 tl     = textureLod(tex, uv + vec2( 1.0,  1.0)*pixelSize, 0).rgb;
    vec3 tc     = textureLod(tex, uv + vec2( 0.0,  1.0)*pixelSize, 0).rgb;
    vec3 tr     = textureLod(tex, uv + vec2(-1.0,  1.0)*pixelSize, 0).rgb;

    vec3 ml     = textureLod(tex, uv + vec2( 1.0,  0.0)*pixelSize, 0).rgb;
    vec3 mc     = textureLod(tex, uv, 0).rgb;
    vec3 mr     = textureLod(tex, uv + vec2(-1.0,  0.0)*pixelSize, 0).rgb;

    vec3 bl     = textureLod(tex, uv + vec2( 1.0, -1.0)*pixelSize, 0).rgb;
    vec3 bc     = textureLod(tex, uv + vec2( 0.0, -1.0)*pixelSize, 0).rgb;
    vec3 br     = textureLod(tex, uv + vec2(-1.0, -1.0)*pixelSize, 0).rgb;

    vec3 avg    = (tl + tc + tr + ml + mc + mr + bl + bc + br) * rcp(9.0);

    vec3 delta  = abs(tl - avg) + abs(tc - avg) + abs(tr - avg) + 
                abs(ml - avg) + abs(mc - avg) + abs(mr - avg) +
                abs(bl - avg) + abs(bc - avg) + abs(br - avg);
    
    float contrast  = 1.0 - getLuma(delta) * rcp(9.0);

    vec3 color  = mc * (1.0 + w * contrast);
        color  -= (tc + bc + ml + mr + (tl + tr + bl + br) * rcp(2.0)) * rcp(6.0) * w * contrast;

    if (color.x < 0.0 || color.y < 0.0 || color.z < 0.0) color = mc;

    return max(color, 0.0);
}

int drawLine(float x, float value, const float thickness) {
    return int(saturate(step(value - thickness, x) - step(value + thickness, x)));
}

//#define framingToolEnabled
//#define framingThirdsHor
//#define framingToAspect
#define framingAspectX 21   //[3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21]
#define framingAspectY 9    //[2 3 4 5 6 7 8 9 10 11 12]
#define framingToAspectCenter 0.5   //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]

vec3 framingGuide(vec2 uv, vec3 color) {
    int frame   = 0;

    #ifdef framingThirdsHor
        frame  += drawLine(uv.x, rcp(3.0), pixelSize.x * 2);
        frame  += drawLine(uv.x, rcp(3.0) * 2.0, pixelSize.x * 2);
        frame  += drawLine(uv.y, rcp(3.0), pixelSize.y * 2);
        frame  += drawLine(uv.y, rcp(3.0) * 2.0, pixelSize.y * 2);
    #endif

    #ifdef framingToAspect
        const float targetAspect = float(framingAspectX) / float(framingAspectY);

        if (targetAspect < aspectRatio) {
            float aspectCoeff = targetAspect * rcp(aspectRatio);
            float invCoeff  = 1.0 - aspectCoeff;

            frame  += drawLine(uv.x, invCoeff * framingToAspectCenter, pixelSize.x * 2);
            frame  += drawLine(uv.x, aspectCoeff + invCoeff * framingToAspectCenter, pixelSize.x * 2);

        } else if (targetAspect > aspectRatio) {
            float aspectCoeff = aspectRatio * rcp(targetAspect);
            float invCoeff  = 1.0 - aspectCoeff;

            frame  += drawLine(uv.y, invCoeff * framingToAspectCenter, pixelSize.y * 2);
            frame  += drawLine(uv.y, aspectCoeff + invCoeff * framingToAspectCenter, pixelSize.y * 2);
        }
    #endif

    if (frame != 0) return vec3(1.0);
    else return color;
}

#define CAS_Strength 0.5    //[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

void main() {
    sceneImage      = vec3(0.0);
    
    if (CAS_Strength > 0.0) {
            sceneImage  = textureCAS(colortex0, uv, CAS_Strength).rgb;
    } else {
        if (MC_RENDER_QUALITY > 0.9) {
            sceneImage  = textureLod(colortex0, uv, 0).rgb;
        } else {
            sceneImage  = textureBicubic(colortex0, uv).rgb;
        }
    }

    #ifdef framingToolEnabled
        if (hideGUI == 0) sceneImage      = framingGuide(uv, sceneImage);
    #endif

    sceneImage  = ditherImage(sceneImage);
}