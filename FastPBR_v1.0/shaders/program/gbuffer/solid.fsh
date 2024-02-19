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

/* RENDERTARGETS: 0,1,2,3 */
layout(location = 0) out vec4 sceneColor;
layout(location = 1) out vec4 GData01;
layout(location = 2) out vec4 GData02;
layout(location = 3) out vec4 GeoNormals;

#include "/lib/head.glsl"
#include "/lib/util/colorspace.glsl"
#include "/lib/util/encoders.glsl"

uniform vec2 viewSize;
#include "/lib/downscaleTransform.glsl"

in mat2x2 uv;

in vec4 tint;

flat in vec3 normal;

#ifdef vertexAttributeFix
    /* - */
#endif

#ifdef gTEXTURED
    uniform sampler2D gcolor;
    uniform sampler2D specular;

    #if (MC_VERSION >= 11500 && (defined gBLOCK || defined gENTITY || defined gHAND) && defined vertexAttributeFix)
        #ifdef normalmapEnabled
            #undef normalmapEnabled
        #endif

        #ifdef pomEnabled
            #undef pomEnabled
        #endif
    #endif

    #if (defined normalmapEnabled || defined pomEnabled)
        uniform sampler2D normals;

        //flat in int validAtTangent;

        flat in mat3 tbn;
    #endif
    
    #ifdef normalmapEnabled
        vec3 decodeNormalTexture(vec3 ntex, inout float materialAO) {
            if(all(lessThan(ntex, vec3(0.003)))) return normal;

            vec3 nrm    = ntex * 2.0 - (254.0 * rcp(255.0));

            #if normalmapFormat==0
                nrm.z  = sqrt(saturate(1.0 - dot(nrm.xy, nrm.xy)));
                materialAO = ntex.z;
            #elif normalmapFormat==1
                materialAO = length(nrm);
                nrm    = normalize(nrm);
            #endif

            return normalize(nrm * tbn);
        }
    #endif

    in float vertexDist;
    in vec2 vCoord;
    in vec4 vCoordAM;
    in vec3 viewVec;
#endif

#ifdef gTERRAIN
flat in int foliage;
flat in int matID;
in vec3 worldPos;
#else
flat in int emitter;
#endif

#ifdef gENTITY
uniform vec4 entityColor;
#endif

uniform vec2 taaOffset;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;

vec3 screenToViewSpace(vec3 screenpos, mat4 projInv, const bool taaAware) {
    screenpos   = screenpos*2.0-1.0;

    #ifdef taaEnabled
        if (taaAware) screenpos.xy -= taaOffset;
    #endif

    vec3 viewpos    = vec3(vec2(projInv[0].x, projInv[1].y)*screenpos.xy + projInv[3].xy, projInv[3].z);
        viewpos    /= projInv[2].w*screenpos.z + projInv[3].w;
    
    return viewpos;
}
vec3 screenToViewSpace(vec3 screenpos, mat4 projInv) {    
    return screenToViewSpace(screenpos, projInv, true);
}

vec3 screenToViewSpace(vec3 screenpos) {
    return screenToViewSpace(screenpos, gbufferProjectionInverse);
}

#ifdef directionalLMEnabled
    /* - */
#endif


#ifdef gTEXTURED

uniform int frameCounter;

#ifdef pomEnabled
    #include "/lib/frag/gradnoise.glsl"

    vec4 readTexture(sampler2D tex, vec2 uv, mat2 dCoord) {
        return textureGrad(tex, fract(uv) * vCoordAM.zw + vCoordAM.xy, dCoord[0], dCoord[1]);
    }
    vec4 textureParallax(sampler2D tex, vec2 uv, mat2 dCoord) {
        return textureGrad(tex, uv, dCoord[0], dCoord[1]);
    }

    vec4 getParallaxCoord(vec2 uv, mat2 dCoord) {
        vec2 parallaxPos    = vCoord * vCoordAM.zw + vCoordAM.xy;
        vec2 rCoord         = vCoord;

        float fade          = 1.0 - sstep(vertexDist, 24.0, 48.0);

        const float rStep   = 1.0 / float(pomSamples);

        const float minCoord = 1.0/(4096.0);

        if (fade > 0.0) {
            float parallaxDepth = readTexture(normals, vCoord, dCoord).a;

            if (viewVec.z < 0.0 && parallaxDepth < (1.0 - rStep)) {
                vec2 currStep   = viewVec.xy * pomDepth * fade * rcp(-viewVec.z * float(pomSamples));

                rCoord     += currStep * ditherGradNoiseTemporal();

                for (uint i = 0; i < pomSamples; i++) {
                    if (readTexture(normals, rCoord, dCoord).a < (1.0 - float(i) * rStep)) rCoord += currStep;
                    else break;
                }

                if (rCoord.y < minCoord && readTexture(gcolor, vec2(rCoord.x, minCoord), dCoord).a == 0.0) {
                    rCoord.y = minCoord;
                    discard;
                }
            }

            parallaxPos     = fract(rCoord) * vCoordAM.zw + vCoordAM.xy;
        }

        return vec4(parallaxPos, rCoord);
    }

    uniform vec3 lightDir;

    float getParallaxShadow(vec3 normal, vec4 parallaxCoord, mat2 dCoord, float height) {
        float shadow    = 1.0;

        float nDotL     = saturate(dot(normal, lightDir));

        float fade      = 1.0 - sstep(vertexDist, 24.0, 48.0);

        if (fade > 0.01 && nDotL > 0.01) {
            vec3 dir    = tbn * lightDir;
                dir     = dir;
                dir.xy *= 0.3;
                float step = 1.28 / float(pomShadowSamples);

            vec3 baseOffset = step * dir * ditherGradNoiseTemporal();

            for (uint i = 0; i < pomShadowSamples; i++) {
                float currZ    = height + dir.z * step * i + baseOffset.z;

                float heightO  = textureParallax(normals, fract(parallaxCoord.zw + dir.xy * i * step + baseOffset.xy) * vCoordAM.zw + vCoordAM.xy, dCoord).a;
                    
                    shadow *= saturate(1.0 - (heightO - currZ) * 40.0);

                if (shadow < 0.01) break;
            }

            shadow  = mix(1.0, shadow, fade);
        }
        return shadow;
    }
#endif

#endif

#ifdef gTERRAIN

uniform sampler2D noisetex;

#include "/lib/util/bicubic.glsl"

#define normalStep 0.002

uniform float frameTimeCounter;
uniform float wetness;
uniform float rainStrength;

float puddleWaves(vec2 pos) {
    float noise     = texture(noisetex, pos + vec2(frameTimeCounter) * vec2(0.3, 0.1)).z;
        noise      += texture(noisetex, pos * 1.8 + vec2(frameTimeCounter) * vec2(-0.1, -0.4)).z * 0.5;

    noise *= 0.5;

    return noise;
}

void getWetness(inout float wetnessOut, inout vec3 normalOut, inout vec2 material, in float height) {
    vec2 pos    = worldPos.xz * 0.02;

    float intensity = sstep(normal.y, 0.5, 0.9) * sstep(uv[1].y, 0.8, 0.95);

    if (min(wetness, intensity) <= 1e-2) return;

    #if wetnessMode == 0
    float noise = texture(noisetex, pos).z;
        noise  += textureBicubic(noisetex, pos * 0.2).x * 0.5;
        noise  /= 1.5;
        noise  += (1.0 - height) * 0.15;
        noise  -= saturate(1.0 - normal.y);
        noise  -= saturate(1.0 - sqrt(wetness) * 1.3) * 0.55;
        noise  *= intensity;
    #else
    float noise = intensity;
    #endif

    vec3 flatNormal = normal;

    vec2 delta;
        delta.x     = puddleWaves(pos * 11.0 + vec2( normalStep, -normalStep));
        delta.y     = puddleWaves(pos * 11.0 + vec2(-normalStep,  normalStep));
        delta      -= puddleWaves(pos * 11.0 + vec2(-normalStep, -normalStep));

    flatNormal  = mix(flatNormal, normalize(vec3(-delta.x, 2.0 * normalStep, -delta.y)), 0.02 * sstep(noise, 0.55, 0.62) * rainStrength);

    normalOut   = mix(normalOut, flatNormal, sstep(noise, 0.5, 0.57));

    wetnessOut     = sqr(linStep(noise, 0.35, 0.57));

    material.x  = mix(material.x, 1.0, wetnessOut);
    material.y  = max(material.y, 0.04 * wetnessOut);

    wetnessOut     = sqr(linStep(noise, 0.3, 0.565));
}

#endif

void main() {
    if (OutsideDownscaleViewport()) discard;
    vec3 normalOut      = normal;
    vec2 lmap           = uv[1];
    vec4 specularData   = vec4(0.0);
    float parallaxShadow = 1.0;
    vec2 ambientOcclusion = vec2(1.0);
    float wetnessVal    = 0.0;

    #ifdef gTEXTURED
            sceneColor  = texture(gcolor, uv[0], -1);

        #ifdef normalmapEnabled
            vec4 normalTex      = texture(normals, uv[0], -1);
        #else
            vec4 normalTex      = vec4(0.5, 0.5, 1.0, 1.0);
        #endif

        #ifdef pomEnabled
            bool normalCheck    = all(equal(normalTex, vec4(0.0)));
            
            if (normalCheck) {
                specularData    = texture(specular, uv[0]);
                if (sceneColor.a < 0.1) discard;
            } else {
                mat2 dCoord         = mat2(dFdx(uv[0]), dFdy(uv[0]));

                vec4 parallaxCoord  = getParallaxCoord(uv[0], dCoord);

                    sceneColor      = textureParallax(gcolor, parallaxCoord.xy, dCoord);
                    if (sceneColor.a<0.1) discard;

                    normalTex       = textureParallax(normals, parallaxCoord.xy, dCoord);

                    parallaxShadow  = getParallaxShadow(normalOut, parallaxCoord, dCoord, normalTex.a);

                    specularData = textureParallax(specular, parallaxCoord.xy, dCoord);
            }

            #ifdef normalmapEnabled
                normalOut   = decodeNormalTexture(normalTex.rgb, ambientOcclusion.y);
            #endif
        #else
            if (sceneColor.a<0.1) discard;

            #ifdef normalmapEnabled
                normalOut   = decodeNormalTexture(normalTex.rgb, ambientOcclusion.y);
            #endif

                specularData = texture(specular, uv[0], -1);
        #endif

        sceneColor.rgb *= tint.rgb;
        
        #ifdef gTERRAIN
            ambientOcclusion.x  = tint.a;

            #if wetnessMode != 2
            if (wetness > 1e-2) getWetness(wetnessVal, normalOut, specularData.xy, normalTex.w);
            #endif

            #if (defined normalmapEnabled && defined directionalLMEnabled)
            if(lmap.x > 0.001) {
                vec3 viewPos    = screenToViewSpace(vec3(gl_FragCoord.xy/viewSize, gl_FragCoord.z));

                vec3 dirLM_T    = normalize(dFdx(viewPos));
                vec3 dirLM_B    = normalize(dFdy(viewPos));
                vec3 dirLM_N    = cross(dirLM_T, dirLM_B);

                float dirLM     = 1.0;
                vec3 viewNormal = mat3(gbufferModelView) * normalOut;
                vec2 lmDeriv    = vec2(dFdx(lmap.x), dFdy(lmap.x)) * 256.0;
                vec3 lmDir      = normalize(vec3(lmDeriv.x * dirLM_T + 0.0005 * dirLM_N + lmDeriv.y * dirLM_B));

                float lmDiff    = clamp(dot(viewNormal, lmDir), -1.0, 1.0) * lmap.x;
                if (abs(lmDiff) > 0) lmDiff = pow(abs(lmDiff), mix(0.25, 1.0, lmap.x)) * sign(lmDiff);
                if (length(lmDeriv) > 0.001) dirLM = pow(lmap.x, 1.0 - lmDiff);
                lmap.x = mix(lmap.x, saturate(min(dirLM, lmap.x)), sqr(sstep(lmap.x, 0.125, 0.5)));
                //lmap.x = saturate(lmDiff);
            }
            #endif

        #else
            ambientOcclusion.x  = 1.0;
        #endif

        #ifdef gENTITY
            sceneColor.rgb  = mix(sceneColor.rgb, entityColor.rgb, entityColor.a);
        #endif
    #else
            sceneColor      = tint;
        //if (sceneColor.a<0.01) discard;
            ambientOcclusion.x  = 1.0;

        if (minOf(sceneColor.rgb) < 0.01) lmap.xy = vec2(0.0);
    #endif

        convertToPipelineAlbedo(sceneColor.rgb);

    #ifndef gTERRAIN
        #ifdef gNODIFF
        int matID = 2;
        #else
        int matID = 1;
        #endif

        if (emitter == 1) matID = 5;
    #endif

    sceneColor      = drawbufferClamp(sceneColor);

    GData01.xy      = encodeNormal(normalOut);
    GData01.z       = pack2x8(lmap);
    GData01.w       = pack2x8(saturate(parallaxShadow), wetnessVal);

    GData02.x       = pack2x8(specularData.xy);
    GData02.y       = pack2x8(specularData.zw);
    GData02.z       = encodeMatID16(matID);
    GData02.w       = pack2x8(ambientOcclusion);

    GeoNormals.xyz = normal * 0.5 + 0.5;
}