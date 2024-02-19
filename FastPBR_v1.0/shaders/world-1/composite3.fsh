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
//layout(location = 1) out vec4 exposureTemp;

#define RSSBO_ENABLE_COLOR
#include "/lib/head.glsl"
#include "/lib/util/colorspace.glsl"
#include "/lib/util/encoders.glsl"

in vec2 uv;


uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex11;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform sampler2D noisetex;

uniform int frameCounter;
uniform int isEyeInWater;

uniform float near, far;
uniform float lightFlip;
uniform float sunAngle;

uniform ivec2 eyeBrightnessSmooth;
uniform vec2 taaOffset;
uniform vec2 pixelSize, viewSize;

uniform vec3 lightDir, lightDirView;

uniform mat4 gbufferModelView, gbufferModelViewInverse;
uniform mat4 gbufferProjection, gbufferProjectionInverse;

#define FUTIL_MAT16
#define FUTIL_LINDEPTH
#include "/lib/fUtil.glsl"
#include "/lib/frag/bluenoise.glsl"
#include "/lib/frag/gradnoise.glsl"
#include "/lib/util/transforms.glsl"
#include "/lib/brdf/fresnel.glsl"
#include "/lib/brdf/material.glsl"
#include "/lib/brdf/specular.glsl"
#include "/lib/frag/capture.glsl"
#include "/lib/atmos/project.glsl"

/*
    These two functions used for rough reflections are based on zombye's spectrum shaders
    https://github.com/zombye/spectrum
*/

mat3 getRotationMat(vec3 x, vec3 y) {
	float cosine = dot(x, y);
	vec3 axis = cross(y, x);

	float tmp = 1.0 / dot(axis, axis);
	      tmp = tmp - tmp * cosine;
	vec3 tmpv = axis * tmp;

	return mat3(
		axis.x * tmpv.x + cosine, axis.x * tmpv.y - axis.z, axis.x * tmpv.z + axis.y,
		axis.y * tmpv.x + axis.z, axis.y * tmpv.y + cosine, axis.y * tmpv.z - axis.x,
		axis.z * tmpv.x - axis.y, axis.z * tmpv.y + axis.x, axis.z * tmpv.z + cosine
	);
}
vec3 ggxFacetDist(vec3 viewDir, float roughness, vec2 xy) {
	/*
        GGX VNDF sampling
        http://www.jcgt.org/published/0007/04/01/
    */

    viewDir     = normalize(vec3(roughness * viewDir.xy, viewDir.z));

    float clsq  = dot(viewDir.xy, viewDir.xy);
    vec3 T1     = vec3(clsq > 0.0 ? vec2(-viewDir.y, viewDir.x) * inversesqrt(clsq) : vec2(1.0, 0.0), 0.0);
    vec3 T2     = vec3(-T1.y * viewDir.z, viewDir.z * T1.x, viewDir.x * T1.y - T1.x * viewDir.y);

	float r     = sqrt(xy.x);
	float phi   = tau * xy.y;
	float t1    = r * cos(phi);
	float a     = saturate(1.0 - t1 * t1);
	float t2    = mix(sqrt(a), r * sin(phi), 0.5 + 0.5 * viewDir.z);

	vec3 normalH = t1 * T1 + t2 * T2 + sqrt(saturate(a - t2 * t2)) * viewDir;

	return normalize(vec3(roughness * normalH.xy, normalH.z));
}

mat2x3 unpackReflectionAux(vec4 data){
    vec3 shadows    = decodeRGBE8(vec4(unpack2x8(data.x), unpack2x8(data.y)));
    vec3 albedo     = decodeRGBE8(vec4(unpack2x8(data.z), unpack2x8(data.w)));

    return mat2x3(shadows, albedo);
}

vec3 screenspaceRT(vec3 position, vec3 direction, float noise) {
    const uint maxSteps     = 8;

  	float rayLength = ((position.z + direction.z * far * sqrt3) > -near) ?
                      (-near - position.z) / direction.z : far * sqrt3;

    vec3 screenPosition     = viewToScreenSpace(position);
    vec3 endPosition        = position + direction * rayLength;
    vec3 endScreenPosition  = viewToScreenSpace(endPosition);

    vec3 screenDirection    = normalize(endScreenPosition - screenPosition);
        screenDirection.xy  = normalize(screenDirection.xy);

    vec3 maxLength          = (step(0.0, screenDirection) - screenPosition) / screenDirection;
    float stepMult          = minOf(maxLength);
    vec3 screenVector       = screenDirection * stepMult / float(maxSteps);

    vec3 screenPos          = screenPosition + screenDirection * maxOf(pixelSize * pi);

    if (saturate(screenPos.xy) == screenPos.xy) {
        float depthSample   = texelFetch(depthtex0, ivec2(screenPos.xy * viewSize * ResolutionScale), 0).x;
        float linearSample  = depthLinear(depthSample);
        float currentDepth  = depthLinear(screenPos.z);

        if (linearSample < currentDepth) {
            float dist      = abs(linearSample - currentDepth) / currentDepth;
            if (dist <= 0.25) return vec3(screenPos.xy, depthSample);
        }
    }

        screenPos          += screenVector * noise;

    for (uint i = 0; i < maxSteps; ++i) {
        if (saturate(screenPos.xy) != screenPos.xy) break;

        float depthSample   = texelFetch(depthtex0, ivec2(screenPos.xy * viewSize * ResolutionScale), 0).x;
        float linearSample  = depthLinear(depthSample);
        float currentDepth  = depthLinear(screenPos.z);

        if (linearSample < currentDepth) {
            float dist      = abs(linearSample - currentDepth) / currentDepth;
            if (dist <= 0.5) return vec3(screenPos.xy, depthSample);
        }

        screenPos      += screenVector;
    }

    return vec3(1.1);
}
/*
//based on robobo1221's shaders because my old ssr is shit
vec4 ssrTrace(vec3 rdir, vec3 vpos, vec3 screenpos, float dither, float nDotV, const int steps, const int refine) {
    //const int steps     = 16;
    //const int refine    = 5;

    float rlength   = ((vpos.z + rdir.z * far * sqrt(3.0)) > -near) ? (-near - vpos.z) / rdir.z : far * sqrt(3.0);
    vec3 dir        = normalize(view_screenspace(rdir * rlength + vpos) - screenpos);
        dir.xy      = normalize(dir.xy);

    float maxlength = rcp(float(steps));
    float minlength = maxlength*0.05;

    float steplength = mix(minlength, maxlength, (max(nDotV, 0.0)));
    float stepweight = 1.0 / abs(dir.z);

    vec3 pos        = screenpos + dir*(steplength*(dither + 0.5));

    float depth     = texelFetch(depthtex1, ivec2(pos.xy * viewSize), 0).x;
    bool ray_hit     = false;

    int i       = steps;
    int j       = refine;

    while (--i > 0) {
        steplength = clamp((depth - pos.z) * stepweight, minlength, maxlength);
        pos += dir*steplength;
        depth = texelFetch(depthtex1, ivec2(pos.xy * viewSize), 0).x;

        if (saturate(pos) != pos) return vec4(0.0);

        if (depth <= pos.z) break;
    }
    float mdepth    = depth;

    vec3 refpos     = pos;
    float refdepth  = depth;

    while (--j > 0) {
        refpos      = dir * clamp((depth - pos.z)*stepweight, -steplength, steplength) + pos;
        refdepth    = texelFetch(depthtex1, ivec2(refpos.xy * viewSize), 0).x;
        bool rayhit = refdepth <= refpos.z;
        if (rayhit) ray_hit = true;

        pos         = rayhit ? refpos : pos;
        depth       = rayhit ? refdepth : depth;

        steplength *= 0.5;
    }

    float sdepth    = texture(depthtex1, pos.xy).x;

    if (sdepth >= 1.0) return vec4(0.0);

    bool visible    = abs(pos.z - mdepth) * min(stepweight, 400.0) <= maxlength;

    return visible ? vec4(texture(colortex0, pos.xy).rgb, 1.0) : vec4(0.0);
}
vec4 ssrTrace(vec3 rdir, vec3 vpos, vec3 screenpos, float dither, float nDotV) {
    return ssrTrace(rdir, vpos, screenpos, dither, nDotV, 16, 5);
}*/


vec4 readSkybox(float occlusion, vec3 direction) {
    return vec4(texture(colortex3, projectSky(direction, 2)).rgb * occlusion, occlusion);
}

#include "/lib/atmos/air/const.glsl"
#include "/lib/atmos/waterConst.glsl"

#define DIM -1

#include "/lib/atmos/fog.glsl"

vec3 clampNormal(vec3 n, vec3 v){
    float NoV = clamp( dot(n, v), 0., 1. );
    return normalize( NoV * v + n );
}

void main() {
    sceneColor  = stex(colortex0).rgb;

    float sceneDepth = stex(depthtex0).x;

    vec3 viewPos    = screenToViewSpace(vec3(uv / ResolutionScale, sceneDepth));
    vec3 viewDir    = normalize(viewPos);
    vec3 scenePos   = viewToSceneSpace(viewPos);

    float cave      = saturate(float(eyeBrightnessSmooth.y) / 240.0);

    if (landMask(sceneDepth)) {
        vec4 tex1       = stex(colortex1);

        vec3 sceneNormal = decodeNormal(tex1.xy);
        vec3 viewNormal = mat3(gbufferModelView) * sceneNormal;

        float lightmaps  = saturate(unpack2x8(tex1.z)).x;

        int matID       = int(unpack2x8(tex1.z).y * 255.0);

        bool water      = matID == 102;

        mat2x3 reflectionAux = unpackReflectionAux(stex(colortex6));
            reflectionAux[0] *= pi;

        materialProperties material = materialProperties(1.0, 0.02, false, false, mat2x3(0.0));
        if (water) material = materialProperties(0.00001, 0.02, false, false, mat2x3(0.0));

        if (dot(viewDir, viewNormal) > 0.0) viewNormal = -viewNormal;

        //viewNormal = clampNormal(viewNormal, viewDir);

        vec3 reflectDir = reflect(viewDir, viewNormal);
        
        vec4 reflection = vec4(0.0);
        vec3 fresnel    = vec3(0.0);

        float skyOcclusion  = cubeSmooth(sqr(linStep(lightmaps, skyOcclusionThreshold - 0.2, skyOcclusionThreshold)));
        // --- WATER REFLECTIONS --- //
        if (water) {
            vec3 reflectSceneDir = mat3(gbufferModelViewInverse) * reflectDir;
            vec2 sphereCoord = unprojectSphere(reflectSceneDir);

            #ifdef screenspaceReflectionsEnabled
                vec3 reflectedPos = screenspaceRT(viewPos, reflectDir, ditherBluenoise());
                if (reflectedPos.z < 1.0) reflection += vec4(texelFetch(colortex0, ivec2(reflectedPos.xy * viewSize * ResolutionScale), 0).rgb, 1.0);
                else reflection += readSkybox(skyOcclusion, reflectSceneDir);
            #else
                reflection += readSkybox(skyOcclusion, reflectSceneDir);
            #endif

                if (clamp16F(reflection) != reflection) reflection = vec4(0.0);

                fresnel    += BRDFfresnel(-viewDir, viewNormal, material, reflectionAux[1]);
            sceneColor.rgb = mix(sceneColor.rgb, reflection.rgb, fresnel * reflection.a);
        }   

        if (isEyeInWater == 0) {
            sceneColor  = simpleFog(sceneColor, length(scenePos), RColorTable.Skylight * rpi);
        }
    }

    if (isEyeInWater == 1) {
        sceneColor  = waterFog(sceneColor, length(scenePos), RColorTable.Skylight);
    }

    //exposureTemp    = vec4(0.0);

    //sceneColor.rgb  = texture(colortexC, 1-uv).rgb;
}