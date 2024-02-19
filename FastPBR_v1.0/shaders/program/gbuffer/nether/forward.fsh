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

#ifndef gTRANSLUCENT
    /* RENDERTARGETS: 0,1,6 */
    layout(location = 0) out vec4 sceneColor;
    layout(location = 1) out vec4 GData;
    layout(location = 2) out vec4 lightingData;
#else
    /* RENDERTARGETS: 5,1,6,7 */
    layout(location = 0) out vec4 sceneColor;
    layout(location = 1) out vec4 GData;
    layout(location = 2) out vec4 lightingData;
    layout(location = 3) out vec4 sceneTint;
#endif

#define RSSBO_ENABLE_COLOR
#include "/lib/head.glsl"
#include "/lib/util/colorspace.glsl"
#include "/lib/util/encoders.glsl"

uniform vec2 viewSize;
#include "/lib/downscaleTransform.glsl"

in vec2 uv;
in vec2 lightmapUV;

flat in vec3 vertexNormal;

in vec4 tint;

#ifdef gTERRAIN
    flat in int matID;

    uniform float frameTimeCounter;
#endif

#ifdef gTEXTURED
    uniform sampler2D gcolor;
    uniform sampler2D specular;

    #ifdef normalmapEnabled
        flat in mat3 tbn;

        uniform sampler2D normals;

        vec3 decodeNormalTexture(vec3 ntex, inout float materialAO) {
            if(all(lessThan(ntex, vec3(0.003)))) return vertexNormal;

            vec3 nrm    = ntex * 2.0 - (254.0 * rcp(255.0));

            #if normalmapFormat==0
                nrm.z  = sqrt(saturate(1.0 - dot(nrm.xy, nrm.xy)));
                materialAO = ntex.z;
            #elif normalmapFormat==1
                materialAO = length(nrm);
                nrm    = normalize(nrm);
            #endif

            return normalize(tbn * nrm);
        }
    #endif

    #ifdef gENTITY
        uniform vec4 entityColor;
    #endif
#endif

#define FUTIL_LIGHTMAP
#include "/lib/fUtil.glsl"


/*
    This offset thing is from spectrum, and zombye has it from here:
    http://extremelearning.com.au/unreasonable-effectiveness-of-quasirandom-sequences/
*/
vec2 R2(float n) {
	const float s0 = 0.5;
	const vec2 alpha = 1.0 / vec2(rho, rho * rho);
	return fract(n * alpha + s0);
}

uniform sampler2D noisetex;

uniform int frameCounter;

#include "/lib/frag/bluenoise.glsl"

vec4 packReflectionAux(vec3 directLight, vec3 albedo) {
    vec4 lightRGBE  = encodeRGBE8(directLight);
    vec4 albedoRGBE = encodeRGBE8(albedo);

    return vec4(pack2x8(lightRGBE.xy),
                pack2x8(lightRGBE.zw),
                pack2x8(albedoRGBE.xy),
                pack2x8(albedoRGBE.zw));
}

#if (defined gTRANSLUCENT && defined gTERRAIN)

in float viewDist;
in vec3 worldPos;

#include "/lib/util/bicubic.glsl"

#include "/lib/atmos/waterWaves.glsl"

#ifdef G_WATER
in vec3 tangentViewDir;

#define waterParallaxDepth 3.0

vec3 waterParallax(vec3 pos, vec3 dir) {    //based on spectrum by zombye
    const uint steps    = 5;

    vec3 interval   = inversesqrt(float(steps)) * dir / -dir.y;
    float height    = waterWaves(pos) * waterParallaxDepth;
    float stepSize  = height;
        pos.xz     += stepSize * interval.xz;

    float offset    = stepSize * interval.y;
        height      = waterWaves(pos) * waterParallaxDepth;

    for (uint i = 1; i < steps - 1 && height < offset; ++i) {
        stepSize    = offset - height;
        pos.xz     += stepSize * interval.xz;

        offset     += stepSize * interval.y;
        height      = waterWaves(pos) * waterParallaxDepth;
    }

    if (height < offset) {
        stepSize    = offset - height;
        pos.xz     += stepSize * interval.xz;
    }

    return pos;
}
#endif
vec3 waterNormal() {
    vec3 pos    = worldPos;
    #ifdef G_WATER
        pos = waterParallax(pos, tangentViewDir.xzy);
    #endif

    float dstep   = 0.02 + (1.0 - exp(-viewDist * rcp(32.0))) * 0.06;

    vec2 delta;
        delta.x     = waterWaves(pos + vec3( dstep, 0.0, -dstep));
        delta.y     = waterWaves(pos + vec3(-dstep, 0.0,  dstep));
        delta      -= waterWaves(pos + vec3(-dstep, 0.0, -dstep));

    return normalize(vec3(-delta.x, 2.0 * dstep, -delta.y));
}

#endif

void main() {
    if (OutsideDownscaleViewport()) discard;
    
    vec3 sceneNormal    = vertexNormal;
    vec4 sceneMaterial  = vec4(0.0);
    float occlusion     = 1.0;

    #ifndef gTERRAIN
    const int matID     = 1;
    #endif

    #ifdef gTEXTURED
        sceneColor      = texture(gcolor, uv);
        if (sceneColor.a < 0.1) discard;

        sceneColor.rgb *= tint.rgb;

        #ifdef normalmapEnabled
        sceneNormal     = decodeNormalTexture(texture(normals, uv).rgb, occlusion);
        #endif

        #ifdef gTRANSLUCENT
        sceneColor.a    = pow(sceneColor.a, 1.0);
        sceneColor.a    = 0.1 + sqr(linStep(sceneColor.a, 0.1, 1.0)) * 0.9;
        #endif

        sceneMaterial   = texture(specular, uv);

        #ifdef gENTITY
            sceneColor.rgb = mix(sceneColor.rgb, entityColor.rgb, entityColor.a);
        #endif
    #else
        sceneColor      = tint;
        if (sceneColor.a<0.01) discard;
        sceneColor.a    = 1.0;
    #endif

    convertToPipelineAlbedo(sceneColor.rgb);

    #if (defined gTRANSLUCENT && defined gTERRAIN)
        if (matID == 102) {
            #ifdef customWaterNormals
            sceneNormal     = waterNormal();
            #endif

            #ifdef customWaterColor
            sceneColor      = vec4(vec3(waterRed, waterGreen, waterBlue) * rpi, max(waterAlpha, 0.101));
            #endif
        }
    #endif


    #ifdef gTRANSLUCENT
    sceneTint           = sceneColor;
    sceneTint.rgb       = normalize(max(sceneColor.rgb, 1e-3));
    sceneTint.a         = sqrt(sceneTint.a);
    #endif

    occlusion          *= sqr(tint.a) * 0.9 + 0.1;

    vec3 indirectLight  = RColorTable.Skylight;

        indirectLight  *= occlusion;

    vec3 blockLight     = getBlocklightMap(RColorTable.Blocklight, lightmapUV.x);
        blockLight     *= occlusion;
    if (lightmapUV.x > (15.0/16.0) || matID == 5) {
        float albedoLum = getLuma(sceneColor.rgb);
            albedoLum   = mix(cube(albedoLum), albedoLum, albedoLum);
        blockLight += RColorTable.Blocklight * pi * albedoLum;
    }

    lightingData    = packReflectionAux(vec3(0), sceneColor.rgb);

    sceneColor.rgb *= indirectLight + blockLight;

    //sceneColor.rgb = indirectLight;

    GData.xy        = encodeNormal(sceneNormal);
    GData.z         = pack2x8(vec2(lightmapUV.y, float(matID) / 255.0));
    GData.w         = pack2x8(sceneMaterial.xy);
}