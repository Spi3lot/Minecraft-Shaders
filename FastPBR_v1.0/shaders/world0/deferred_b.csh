#version 430

layout (local_size_x = 4, local_size_y = 4) in;

const vec2 workGroupsRender = vec2(0.5, 0.5);

layout (rgba16f) writeonly uniform image2D colorimg5;
layout (rgba16f) writeonly uniform image2D colorimg9;

#include "/lib/head.glsl"

uniform sampler2D colortex7, colortex10;
uniform sampler2D depthtex0, depthtex2;

uniform int frameCounter;

uniform vec2 viewSize, pixelSize;

uniform vec3 cameraPosition, previousCameraPosition;

uniform mat4 gbufferModelView, gbufferModelViewInverse;
uniform mat4 gbufferProjection, gbufferProjectionInverse;
uniform mat4 gbufferPreviousProjection, gbufferPreviousModelView;

#define FUTIL_D3X3
#include "/lib/fUtil.glsl"

#include "/lib/util/bicubic.glsl"

const ivec2 CheckerboardOffset4[4]  = ivec2[4] (
    ivec2(0, 0),
    ivec2(1, 1),
    ivec2(0, 1),
    ivec2(1, 0)
);

const ivec2 CheckerboardOffset9[9]  = ivec2[9] (
    ivec2( 0, 0),
    ivec2( 2, 0),
    ivec2( 0, 2),
    ivec2( 2, 2),
    ivec2( 0, 1),
    ivec2( 2, 1),
    ivec2( 1, 0),
    ivec2( 1, 2),
    ivec2( 1, 1)
);

const ivec2 CheckerboardOffset16[16]  = ivec2[16] (
    ivec2(1, 1),
    ivec2(2, 2),
    ivec2(2, 1),
    ivec2(1, 2),
    ivec2(3, 3),
    ivec2(3, 0),
    ivec2(0, 0),
    ivec2(0, 3),
    ivec2(3, 2),
    ivec2(1, 0),
    ivec2(0, 2),
    ivec2(2, 3),
    ivec2(3, 1),
    ivec2(2, 0),
    ivec2(0, 1),
    ivec2(1, 3)
);

vec2 GetHistoryUV(vec2 ViewUV, float SceneDepth, bool IsHand) {
    vec4 ViewPos = vec4(ViewUV, SceneDepth, 1.0);
        ViewPos = ViewPos * 2.0 - 1.0;
        ViewPos = gbufferProjectionInverse * ViewPos;
        ViewPos /= ViewPos.w;
        ViewPos = gbufferModelViewInverse * ViewPos;
    vec3 ScenePos = (ViewPos).xyz;

    vec3 PreviousScenePos = ScenePos - previousCameraPosition + cameraPosition;
    vec4 PreviousViewPos = gbufferPreviousModelView * vec4(PreviousScenePos, 1.0);
        PreviousViewPos = gbufferPreviousProjection * PreviousViewPos;

    vec2 PreviousUV = PreviousViewPos.xy / PreviousViewPos.w;
        PreviousUV = PreviousUV * 0.5 + 0.5;

    return PreviousUV;
}

vec4 textureCatmullRom(sampler2D tex, vec2 uv) {
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

void main() {
    
    ivec2 UV = ivec2(gl_GlobalInvocationID.xy);
    int FrameIndex = (frameCounter) % 4;
    ivec2 FrameOffset = CheckerboardOffset4[FrameIndex];

    ivec2 SampleUV = ivec2(gl_GlobalInvocationID.xy * 0.5);

    bool IsNewSamplePixel = ivec2(gl_LocalInvocationID.xy % 2) == FrameOffset;

    vec2 ViewUV = vec2(gl_GlobalInvocationID.xy + 0.5) / (viewSize * workGroupsRender);
    ivec2 ViewPixel = ivec2(gl_GlobalInvocationID.xy / workGroupsRender);

    float SceneDepth = depthMax3x3(depthtex2, ViewUV * ResolutionScale, (pixelSize / workGroupsRender));
    bool IsSky  = !landMask(SceneDepth);

    vec4 FinalScene = vec4(0,0,0,1);
    vec2 FinalNewData = vec2(0,0);

    if (IsSky) {
        vec2 HistoryUV = GetHistoryUV(ViewUV, 1.0, false);

        bool ValidHistory = saturate(HistoryUV) == HistoryUV;
            HistoryUV *= 0.5;
            HistoryUV = clamp(HistoryUV, vec2(0.0), vec2(0.5) - pixelSize);

        vec4 CurrentSample = texelFetch(colortex10, SampleUV, 0);
        vec4 SmoothSample = textureBicubic(colortex10, clamp(vec2(gl_GlobalInvocationID.xy * 0.5 + 0.5) * (pixelSize) - FrameOffset * (pixelSize / 2.0), vec2(0.0), vec2(0.25) - pixelSize));

        FinalScene = SmoothSample;

        if (ValidHistory) {
            vec4 HistoryScene = clamp16F(textureCatmullRom(colortex7, HistoryUV));
            vec2 HistoryData = clamp16F(textureCatmullRom(colortex7, HistoryUV + vec2(0.5, 0.0)).xy);

            if (HistoryData.x > (1.0 - 1e-6)) {
                float PixelAge = HistoryData.y * 256.0;

                float ValidSamples = max(PixelAge - 4, 1.0);

                float SampleWeight = 1.0 - max(1.0 / ValidSamples, 0.25);
                vec2 PixelDelta = 1.0 - abs(2.0 * fract(HistoryUV * viewSize) - 1.0);
                SampleWeight *= sqrt(PixelDelta.x * PixelDelta.y) * 0.5 + 0.5;
                SampleWeight = 1.0 - SampleWeight;
                SampleWeight *= float(IsNewSamplePixel);

                FinalScene = mix(HistoryScene, CurrentSample, SampleWeight);
                FinalNewData.y = saturate((PixelAge + 1.0) / 256.0);
            }
        }
        FinalNewData.x = 1.0;
    }

    imageStore(colorimg5, UV, clamp16F(FinalScene));
    imageStore(colorimg9, UV, clamp16F(FinalScene));
    imageStore(colorimg9, UV + ivec2(viewSize * vec2(0.5, 0.0)), clamp16F(vec4(FinalNewData,0,0)));

}