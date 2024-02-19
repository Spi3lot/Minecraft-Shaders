#version 120

#include "/lib/head.glsl"

uniform sampler2D colortex0;

uniform sampler2D depthtex0;

uniform float frameTime;

uniform vec2 viewSize, pixelSize;
uniform vec2 taaOffset;

uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

uniform mat4 gbufferModelViewInverse, gbufferProjectionInverse;
uniform mat4 gbufferModelView, gbufferProjection;
uniform mat4 gbufferPreviousModelView, gbufferPreviousProjection;

varying vec2 uv;

vec3 getMotionblur(float depth, bool hand) {
    const int samples      = motionblurSamples;
    const float blurSize    = 0.16 * motionblurScale;

    float dither    = bayer16(gl_FragCoord.xy);
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
    int weight = 0;

    for (int i = 0; i < samples; ++i, motionCoord += velocity) {
        if (saturate(motionCoord) != motionCoord) {
            color  += texture2D(colortex0, uv, 0).rgb;
            ++weight;
            break;
        } else {
            vec2 pos    = clamp(motionCoord, viewport, 1.0 - viewport);
            color  += texture2D(colortex0, pos, 0).rgb;
            ++weight;
        }
    }
    color  /= float(weight);

    return color;
}

void main() {
	vec3 sceneColor = texture2D(colortex0, uv).rgb;

    #ifdef motionblurToggle
    float sceneDepth = texture2D(depthtex0, uv).x;

    sceneColor  = ditherR11G11B10(getMotionblur(sceneDepth, sceneDepth < 0.56));
    #endif

    /* DRAWBUFFERS:0 */
	gl_FragData[0] = saturate(vec4(sceneColor, 1.0));
}