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

#define roughnessFade
const float specularMaxClamp    = sqrPi * tau;

float brdfDistBeckmann(vec2 data) {
    //data.y  = max(sqr(data.y), 2e-4);
    /*data.x *= data.x;

    return rcp(pi * data.y * cos(sqr(data.x))) * (exp((data.x - 1.0) * rcp(data.y * tan(data.x))));*/

    float ndoth = data.x;
    float alpha2 = max(data.y, 5e-5);

        ndoth *= ndoth;
    float e = exp((ndoth - 1.0) / (alpha2 * tan(ndoth)));
    float num = rcp(pi * alpha2 * cos(ndoth * ndoth));
    return num*e;
}
float brdfDistTrowbridgeReitz(vec2 data) {
    data.x *= data.x;
    data.y *= data.y;

    return max(data.y, 1e-5) * rcp(max(pi * sqr(data.x * (data.y - 1.0) + 1.0), 1e-10));
}
float brdfGeometrySchlick(vec2 data) {  //y = sqr(roughness + 1) / 8.0
    return data.x * rcp(data.x * (1.0 - data.y) + data.y);
}
float brdfGeometryBeckmann(vec2 data) {
    float c     = data.x * rcp(data.y * sqrt(1.0 - sqr(data.x)));

    if (c >= 1.6) return 1.0;
    else return (3.535 * c + 2.181 * sqr(c)) * rcp(1.0 + 2.276 * c + 2.577 * sqr(c));
}

float brdfShadowSmithBeckmann(float nDotV, float nDotL, float roughness) {
    return brdfGeometryBeckmann(vec2(nDotL, roughness)) * brdfGeometryBeckmann(vec2(nDotV, roughness));
}
float brdfShadowSmithSchlick(float nDotV, float nDotL, float roughness) {
    roughness   = sqr(roughness + 1.0) / 8.0;
    return brdfGeometrySchlick(vec2(nDotL, roughness)) * brdfGeometrySchlick(vec2(nDotV, roughness));
}

vec3 specularTrowbridgeReitzGGX(vec3 viewDir, vec3 lightDir, vec3 normal, materialProperties material, vec3 albedo) {
    vec3 halfWay    = normalize(viewDir + lightDir);

    float nDotL     = max0(dot(normal, lightDir));
    float nDotH     = max0(dot(normal, halfWay));
    float vDotN     = max0(dot(viewDir, normal));
    float vDotH     = max0(dot(viewDir, halfWay));

    vec2 dataD      = vec2(nDotH, material.roughness);

    float D         = 0.0;
    float G         = 0.0;
    float result    = 0.0;

    if (material.conductor) {
        D       = brdfDistTrowbridgeReitz(dataD);
        G       = brdfShadowSmithSchlick(vDotN, nDotL, material.roughness);

        result  = max0(D * G * rcp(max(4.0 * vDotN * nDotL, 1e-10)));

        vec3 fresnel = material.conductorComplex ? fresnelConductor(vDotH, material.eta) : fresnelTinted(vDotH, albedo);

        return vec3(result) * fresnel;
    } else {
        #if 1
            D       = brdfDistTrowbridgeReitz(dataD);
            G       = brdfShadowSmithSchlick(vDotN, nDotL, material.roughness);

            result  = max0(D * G * rcp(max(4.0 * vDotN * nDotL, 1e-10)));

            return vec3(result * fresnelDielectric(vec2(vDotH, material.f0)));
        #else
            D       = brdfDistBeckmann(dataD);
            G       = brdfShadowSmithBeckmann(vDotN, nDotL, material.roughness);

            result  = max0(D * G * rcp(4.0 * vDotN * nDotL));

            #ifdef roughnessFade
            result *= 1.0 - sstep(material.roughness, 0.8, 1.0) * 0.9;
            #endif

            return vec3(result * fresnelDielectric(vDotH, material.f0));
        #endif
    }
}

vec3 specularBeckmann(vec3 viewDir, vec3 lightDir, vec3 normal, materialProperties material) {
    vec3 halfWay    = normalize(viewDir + lightDir);

    float nDotL     = max0(dot(normal, lightDir));
    float nDotH     = max0(dot(normal, halfWay));
    float vDotN     = max0(dot(viewDir, normal));
    float vDotH     = max0(dot(viewDir, halfWay));

    vec2 dataD      = vec2(nDotH, material.roughness);

    float D         = 0.0;
    float G         = 0.0;
    float result    = 0.0;

    D       = brdfDistBeckmann(dataD);
    G       = brdfShadowSmithBeckmann(vDotN, nDotL, material.roughness);

    result  = max0(D * G * rcp(4.0 * vDotN * nDotL));
    result  = min(result, specularMaxClamp);

    #ifdef roughnessFade
        result *= 1.0 - sstep(material.roughness, 0.8, 1.0) * 0.9;
    #endif

    return vec3(result * fresnelDielectric(vDotH, material.f0));
}

vec3 BRDFfresnel(vec3 viewDir, vec3 normal, materialProperties material, vec3 albedo) {
    float vDotN     = max0(dot(viewDir, normal));

    if (material.conductor) {
        return material.conductorComplex ? fresnelConductor(vDotN, material.eta) : fresnelTinted(vDotN, albedo);
    } else {
        return vec3(fresnelDielectric(vDotN, material.f0));
    }
}
vec3 BRDFfresnel(vec3 viewDir, vec3 normal, materialProperties material) {
    float vDotN     = max0(dot(viewDir, normal));
    return vec3(fresnelDielectric(vDotN, material.f0));
}