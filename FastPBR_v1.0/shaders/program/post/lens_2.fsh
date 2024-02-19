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

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 sceneColor;

#include "/lib/head.glsl"

in vec2 uv;

uniform sampler2D colortex0;
uniform sampler2D colortex5;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;

uniform sampler2D noisetex;

uniform float frameTime;
uniform float viewWidth, viewHeight;

uniform vec2 viewSize;

uniform vec3 cameraPosition, previousCameraPosition;

uniform mat4 gbufferModelViewInverse, gbufferProjectionInverse;
uniform mat4 gbufferModelView, gbufferProjection;
uniform mat4 gbufferPreviousModelView, gbufferPreviousProjection;


/* ------ functions ------ */
float ditherBluenoiseStatic() {
    ivec2 uv = ivec2(fract(gl_FragCoord.xy/256.0)*256.0);
    float noise = texelFetch(noisetex, uv, 0).a;

    return noise;
}

vec3 getMotionblur(float depth, bool hand) {
    const uint samples      = motionblurSamples;
    const float blurSize    = 0.16 * motionblurScale;

    float dither    = ditherBluenoiseStatic();
    vec2 viewport   = 2.0 / viewSize;

    vec4 currPos    = vec4(uv, depth, 1.0) * 2.0 - 1.0;

    vec4 fragPos    = gbufferProjectionInverse * currPos;
        fragPos     = gbufferModelViewInverse * fragPos;
        fragPos    /= fragPos.w;

        if (!hand) fragPos.xyz += cameraPosition;

    vec4 prevPos    = fragPos;
        if (!hand) prevPos.xyz -= previousCameraPosition;
        prevPos     = gbufferPreviousModelView * prevPos;
        prevPos     = gbufferPreviousProjection * prevPos;
        prevPos    /= prevPos.w;

    float scale     = blurSize * min(rcp(frameTime * 30.0), 2.0);

    vec2 velocity   = (currPos - prevPos).xy;
        if (hand) velocity *= 0.15;
        velocity    = clamp(velocity, -2.8, 2.8);
        velocity   *= scale * rcp(float(samples));
        velocity    = velocity - velocity * 0.5;

    vec2 motionCoord = uv + velocity * dither;

    vec3 color  = vec3(0.0);
    uint weight = 0;

    for (uint i = 0; i < samples; ++i, motionCoord += velocity) {
        if (saturate(motionCoord) != motionCoord) {
            color  += textureLod(colortex0, uv, 0).rgb;
            ++weight;
            break;
        } else {
            vec2 pos    = clamp(motionCoord, viewport, 1.0 - viewport);
            color  += textureLod(colortex0, pos, 0).rgb;
            ++weight;
        }
    }
    color  /= float(weight);

    return color;
}

void main() {
    sceneColor  = stexLod(colortex0, 0);

    #ifdef motionblurToggle
    float sceneDepth    = texture(depthtex1, uv * ResolutionScale).x;

    bool hand   = sceneDepth < texture(depthtex2, uv * ResolutionScale).x;

    sceneColor.rgb = getMotionblur(sceneDepth, hand);
    #endif

    #ifdef lensFlareToggle
        sceneColor.rgb += textureLod(colortex5, uv * 0.5, 0).rgb;
    #endif

    sceneColor  = clamp16F(sceneColor);
}