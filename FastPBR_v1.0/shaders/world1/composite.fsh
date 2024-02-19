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

/* RENDERTARGETS: 0,5,11 */
layout(location = 0) out vec3 sceneColor;
layout(location = 1) out vec4 fogScattering;
layout(location = 2) out vec3 fogTransmittance;

#define RSSBO_ENABLE_COLOR
#include "/lib/head.glsl"
#include "/lib/util/encoders.glsl"
#include "/lib/shadowconst.glsl"

const bool shadowHardwareFiltering = true;

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

uniform sampler2DShadow shadowtex0;
uniform sampler2DShadow shadowtex1;
uniform sampler2D shadowcolor0;

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
uniform vec3 lightDir, lightDirView;

uniform mat4 gbufferModelView, gbufferModelViewInverse;
uniform mat4 gbufferProjection, gbufferProjectionInverse;
uniform mat4 shadowModelView, shadowModelViewInverse;
uniform mat4 shadowProjection, shadowProjectionInverse;

/* ------ INCLUDES ------ */
#define FUTIL_MAT16
#define FUTIL_TBLEND
#define FUTIL_LINDEPTH
#include "/lib/fUtil.glsl"
#include "/lib/frag/bluenoise.glsl"
#include "/lib/frag/gradnoise.glsl"
#include "/lib/util/transforms.glsl"
#include "/lib/atmos/phase.glsl"
#include "/lib/atmos/waterConst.glsl"
#include "/lib/frag/noise.glsl"

/* ------ SHADOW PREP ------ */
#include "/lib/light/warp.glsl"

float readCloudShadowmap(sampler2D shadowmap, vec3 position) {
    position    = mat3(shadowModelView) * position;
    position   /= cloudShadowmapRenderDistance;
    position.xy = position.xy * 0.5 + 0.5;

    position.xy /= vec2(1.0, 1.0 + (1.0 / 3.0));

    return texture(shadowmap, position.xy).a;
}
vec3 shadowColorSample(sampler2D tex, vec2 position) {
    vec4 colorSample = texture(shadowcolor0, position);
    return mix(vec3(1.0), colorSample.rgb * 4.0, colorSample.a);
}

/* ------ VOLUMETRIC FOG ------ */

const float airMieG         = 0.72;

const vec2 fogFalloffScale  = 1.0 / vec2(8e1, 2e1);
const vec2 fogAirScale      = vec2(6e1, 4e1);

vec2 airPhaseFunction(float cosTheta) {
    return vec2(rayleighPhase(cosTheta), mieCS(cosTheta, airMieG));
}
float airMieBackscatter(float cosTheta, float g) {
    return mieHG(cosTheta, -g * rcp(pi));
}

const vec3 airRayleighCoeff = vec3(5e-5, 3e-5, 1e-4);   //628 574 466
const vec3 airMieCoeff      = vec3(6e-6, 2e-5, 8e-5);

const mat2x3 fogScatterMat  = mat2x3(airRayleighCoeff, airMieCoeff);
const mat2x3 fogExtinctMat  = mat2x3(airRayleighCoeff, airMieCoeff * 1.1);

#define fogMistAltitude 100.0   //[30.0 40.0 50.0 60.0 70.0 80.0 90.0 100.0 110.0 120.0 130.0 140.0 150.0]
#define fogSeaLevel 64.0    //[8.0 16.0 24.0 32.0 40.0 48.0 56.0 64.0 72.0 80.0 88.0 96.0]

#ifdef freezeAtmosAnim
    const float fogTime   = float(atmosAnimOffset) * 0.006;
#else
    #ifdef volumeWorldTimeAnim
        float fogTime     = worldAnimTime * 3.6;
    #else
        float fogTime     = frameTimeCounter * 0.006;
    #endif
#endif

vec2 fogAirDensity(vec3 rPos, float altitude) {
    rPos   += cameraPosition;

    float maxFade = sqr(1.0 - linStep(altitude, 144.0, 256.0));

    vec2 rm     = expf(-max0((altitude - fogSeaLevel) * fogFalloffScale));

    return vec2(rm * fogAirScale * maxFade * fogDensityMult);
}

#define airDensity 1.0
#define fogMinSteps 8
#define fogAdaptiveSteps 8     //[4 6 8 10 12 14 16 18]
#define fogClipDist 512.0       //[256.0 384.0 448.0 512.0 768.0 1024.0]

mat2x3 volumetricFog(vec3 scenePos, vec3 sceneDir, bool isSky, float vDotL, float dither, float cave) {
    float topDist    = length(sceneDir * ((256.0 - eyeAltitude) * rcp(sceneDir.y)));
    float bottomDist = length(sceneDir * ((-32.0 - eyeAltitude) * rcp(sceneDir.y)));

    float volumeHull = sceneDir.y > 0.0 ? topDist : bottomDist;

    float endDist   = isSky ? min(volumeHull, fogClipDist) : length(scenePos);
    float startDist = eyeAltitude > 256.0 ? topDist : 1.0;

    vec3 startPos   = eyeAltitude > 256.0 ? sceneDir * startDist : vec3(0.0);
        startPos   += gbufferModelViewInverse[3].xyz;
    vec3 endPos     = isSky ? sceneDir * endDist : scenePos;

    float baseStep  = length(endPos - startPos);
    float stepCoeff = saturate(baseStep * rcp(clamp(far, 256.0, 512.0)));

    uint steps      = fogMinSteps + uint(stepCoeff * fogAdaptiveSteps);

    vec3 rStep      = (endPos - startPos) / float(steps);
    vec3 rPos       = startPos + rStep * dither;
    float rLength   = length(rStep);

    vec3 shadowStartPos = transMAD(shadowModelView, (startPos));
        shadowStartPos  = projMAD(shadowProjection, shadowStartPos);
        shadowStartPos.z *= 0.2;
    vec3 shadowEndPos   = transMAD(shadowModelView, (endPos));
        shadowEndPos    = projMAD(shadowProjection, shadowEndPos);
        shadowEndPos.z *= 0.2;

    vec3 shadowStep = (shadowEndPos - shadowStartPos) / float(steps);
    vec3 shadowPos  = shadowStartPos + shadowStep * dither;

    mat2x3 scattering = mat2x3(0.0);
    vec3 transmittance = vec3(1.0);

    vec2 phase  = vec2(rayleighPhase(vDotL), mieCS(vDotL, airMieG * 0.8));
    float phaseIso  = 0.25;

    vec3 sunlight       = RColorTable.DirectLight;
    vec3 skylight       = RColorTable.Skylight;

    float pFade         = saturate(mieHG(vDotL, 0.65));

    uint i = 0;
    do {
        rPos += rStep; shadowPos += shadowStep;
    //for (uint i = 0; i < steps; ++i, rPos += rStep, shadowPos += shadowStep) {
        if (maxOf(transmittance) < 0.01) break;

        float altitude  = rPos.y + eyeAltitude;

        if (altitude > 256.0) continue;

        vec2 density    = fogAirDensity(rPos, altitude);

        //if (max3(density) < 1e-32) continue;

        vec2 stepRho    = density * rLength;
        vec3 od         = fogExtinctMat * stepRho;

        vec3 stepT      = expf(-od);
        vec3 scatterInt = saturate((stepT - 1.0) * rcp(-max(od, 1e-16)));
        vec3 visScatter = transmittance * scatterInt;

        vec3 sunScatter = vec3(0.0);
        vec3 skyScatter = vec3(0.0);

        sunScatter     += fogScatterMat * (stepRho * phase) * visScatter;

        skyScatter     += fogScatterMat * (stepRho * phaseIso) * visScatter;

        vec3 shadowCoord = vec3(shadowmapWarp(shadowPos.xy), shadowPos.z) * 0.5 + 0.5;

        float shadow0   = texture(shadowtex0, shadowCoord);

        float shadow    = 1.0;
        vec3 shadowCol  = vec3(1.0);
        
        if (shadow0 < 1.0) {
            shadow      = texture(shadowtex1, shadowCoord);

            if (abs(shadow - shadow0) > 0.1) {
                shadowCol   = shadowColorSample(shadowcolor0, shadowCoord.xy);
            }
        }

        scattering[0]  += (sunScatter * shadowCol * transmittance) * shadow;
        scattering[1]  += skyScatter * transmittance;

        transmittance  *= stepT;
    } while (++i < steps);

    vec3 color  = scattering[0] * sunlight + scattering[1] * skylight;

    if (color != color) {   //because NaNs on nVidia don't need a logic cause to happen
        color = vec3(0.0);
        transmittance = vec3(1.0);
    }

    return mat2x3(color, saturate(transmittance));
}


void applyFogData(inout vec3 color, in mat2x3 data) {
    color = color * data[1] + data[0];
}

#include "/lib/atmos/fog.glsl"

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

    float vDotL     = dot(viewDir, lightDirView);
    float bluenoise = ditherBluenoise();

    vec4 GData      = texture(colortex1, uv);
    int matID       = int(unpack2x8(GData.z).y * 255.0);
    bool water      = matID == 102;

    if (translucent) {

        if (water && isEyeInWater == 0) {
            sceneColor  = waterFog(sceneColor, distance(scenePos0, scenePos1), RColorTable.Skylight * cave);
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

    fogScattering   = vec4(0.0);
    fogTransmittance = vec3(1.0);

    #ifdef fogVolumeEnabled
    bool isSky      = !landMask(sceneDepth.x);

    mat2x3 fogData  = mat2x3(vec3(0.0), vec3(1.0));

    if (isEyeInWater != 1) {
        fogData    = volumetricFog(scenePos0, worldDir, isSky, vDotL, bluenoise, cave);
    }

    fogScattering.rgb = fogData[0];
    fogScattering.a = depthLinear(sceneDepth.x);
    fogTransmittance = fogData[1];

    fogScattering       = clamp16F(fogScattering);

    #endif
}