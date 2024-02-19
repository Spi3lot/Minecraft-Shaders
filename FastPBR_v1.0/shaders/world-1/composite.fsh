#version 430 compatibility

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
layout(location = 0) out vec3 sceneColor;

#define RSSBO_ENABLE_COLOR
#include "/lib/head.glsl"
#include "/lib/util/encoders.glsl"
#include "/lib/shadowconst.glsl"

in vec2 uv;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5, colortex6, colortex7;

uniform sampler2D noisetex;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform int frameCounter;
uniform int isEyeInWater;
uniform int worldTime;

uniform float eyeAltitude;
uniform float far, near;
uniform float frameTimeCounter;
uniform float lightFlip;
uniform float sunAngle;
uniform float rainStrength, wetness;
uniform float worldAnimTime;

uniform ivec2 eyeBrightness;
uniform ivec2 eyeBrightnessSmooth;

uniform vec2 taaOffset;
uniform vec2 viewSize, pixelSize;

uniform vec3 cameraPosition;

uniform mat4 gbufferModelView, gbufferModelViewInverse;
uniform mat4 gbufferProjection, gbufferProjectionInverse;

/* ------ INCLUDES ------ */
#define FUTIL_MAT16
#define FUTIL_TBLEND
#define FUTIL_LINDEPTH
#include "/lib/fUtil.glsl"
#include "/lib/frag/bluenoise.glsl"
#include "/lib/frag/gradnoise.glsl"
#include "/lib/util/transforms.glsl"
#include "/lib/atmos/air/const.glsl"
#include "/lib/atmos/phase.glsl"
#include "/lib/atmos/waterConst.glsl"
#include "/lib/frag/noise.glsl"

/* ------ REFRACTION ------ */
vec3 refract2(vec3 I, vec3 N, vec3 NF, float eta) {     //from spectrum by zombye
    float NoI = dot(N, I);
    float k = 1.0 - eta * eta * (1.0 - NoI * NoI);
    if (k < 0.0) {
        return vec3(0.0); // Total Internal Reflection
    } else {
        float sqrtk = sqrt(k);
        vec3 R = (eta * dot(NF, I) + sqrtk) * NF - (eta * NoI + sqrtk) * N;
        return normalize(R * sqrt(abs(NoI)) + eta * I);
    }
}

#define DIM -1

#include "/lib/atmos/fog.glsl"

/* --- TEMPORAL CHECKERBOARD --- */

#define checkerboardDivider 4
#define ditherPass
#include "/lib/frag/checkerboard.glsl"

void main() {
    sceneColor  = stex(colortex0).rgb;

    vec2 sceneDepth = vec2(stex(depthtex0).x, stex(depthtex1).x);

    vec3 viewPos0   = screenToViewSpace(vec3(uv / ResolutionScale, sceneDepth.x));
    vec3 scenePos0  = viewToSceneSpace(viewPos0);

    vec3 viewPos1   = screenToViewSpace(vec3(uv / ResolutionScale, sceneDepth.y));
    vec3 scenePos1  = viewToSceneSpace(viewPos1);

    vec3 viewDir    = normalize(viewPos0);
    vec3 worldDir   = normalize(scenePos0);

    bool translucent    = sceneDepth.x < sceneDepth.y;

    float cave      = saturate(float(eyeBrightnessSmooth.y) / 240.0);

    if (translucent){
        vec4 tex1           = stex(colortex1);
        vec3 sceneNormal    = decodeNormal(tex1.xy);
        vec3 viewNormal     = mat3(gbufferModelView) * sceneNormal;
        vec3 flatNormal     = normalize(cross(dFdx(scenePos0), dFdy(scenePos0)));
        vec3 flatViewNormal = normalize(mat3(gbufferModelView) * flatNormal);

        vec3 normalCorrected = dot(viewNormal, viewDir) > 0.0 ? -viewNormal : viewNormal;

        vec3 refractedDir   = refract2(normalize(viewPos1), normalCorrected, flatViewNormal, rcp(1.33));
        //vec3 refractedDir   = refract(normalize(viewPos1), normalCorrected, rcp(1.33));

        float refractedDist = distance(viewPos0, viewPos1);

        vec3 refractedPos   = viewPos1 + refractedDir * refractedDist;

        vec3 screenPos      = viewToScreenSpace(refractedPos);

        float distToEdge    = maxOf(abs(screenPos.xy * 2.0 - 1.0));
            distToEdge      = sqr(sstep(distToEdge, 0.7, 1.0));

            screenPos.xy    = mix(screenPos.xy, uv / ResolutionScale, distToEdge);

        //vec2 refractionDelta = uv - screenPos.xy;

        float sceneDepthNew = texture(depthtex1, screenPos.xy * ResolutionScale).x;

        if (sceneDepthNew > sceneDepth.x) {
            sceneDepth.y    = sceneDepthNew;
            viewPos1        = screenToViewSpace(vec3(screenPos.xy, sceneDepth.y));
            scenePos1       = viewToSceneSpace(viewPos1);

            sceneColor.rgb  = texture(colortex0, screenPos.xy * ResolutionScale).rgb;
        }
    }

    float bluenoise = ditherBluenoise();

    vec4 GData      = texture(colortex1, uv);
    int matID       = int(unpack2x8(GData.z).y * 255.0);
    bool water      = matID == 102;

    if (translucent) {

        if (water && isEyeInWater == 0) {
            sceneColor  = waterFog(sceneColor, distance(scenePos0, scenePos1), RColorTable.Skylight);
        }

        vec4 translucencyColor  = stex(colortex5);
        vec4 reflectionAux      = stex(colortex7);

        vec3 albedo     = reflectionAux.rgb;

        vec3 tint       = sqr(saturate(normalize(albedo)));

        #ifdef customWaterColor
        if (water) tint = vec3(1.0);
        #endif

        sceneColor  = blendTranslucencies(sceneColor, translucencyColor, tint);
    }

    sceneColor      = clamp16F(sceneColor);
}