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

float fresnelSchlick(float f0, float VoH) {
    return saturate(f0 + (1.0 - f0) * pow5(1.0 - VoH));
}
float fresnelSchlickInverse(float f0, float VoH) {
    return 1.0 - saturate(f0 + (1.0 - f0) * pow5(1.0 - VoH));
}
float fresnelSchlick(float f0, float f90, float VoH) {
    return saturate(f0 + ((f90 - f0) * pow5(1.0 - VoH)));
}

float fresnelDielectric(float cosTheta, float f0) {
        f0      = min(sqrt(f0), 0.99999);
        f0      = (1.0 + f0) * rcp(1.0 - f0);

    float sinThetaI = sqrt(saturate(1.0 - sqr(cosTheta)));
    float sinThetaT = sinThetaI * rcp(max(f0, 1e-16));
    float cosThetaT = sqrt(1.0 - sqr(sinThetaT));

    float Rs        = sqr((cosTheta - (f0 * cosThetaT)) * rcp(max(cosTheta + (f0 * cosThetaT), 1e-10)));
    float Rp        = sqr((cosThetaT - (f0 * cosTheta)) * rcp(max(cosThetaT + (f0 * cosTheta), 1e-10)));

    return saturate((Rs + Rp) * 0.5);
}
float fresnelDielectric(vec2 data) {
    data.y  = min(sqrt(data.y), 0.99999);
    data.y  = (1.0 + data.y) * rcp(1.0 - data.y);

    float sinThetaI     = sqrt(saturate(1.0 - sqr(data.x)));
    float sinThetaT     = sinThetaI * rcp(max(data.y, 1e-16));
    float cosThetaT     = sqrt(1.0 - sqr(sinThetaT));

    float Rs    = sqr((data.x - (data.y * cosThetaT)) * rcp(max(data.x + (data.y * cosThetaT), 1e-10)));
    float Rp    = sqr((cosThetaT - (data.y * data.x)) * rcp(max(cosThetaT + (data.y * data.x), 1e-10)));

    return saturate((Rs + Rp) * 0.5);
}

vec3 fresnelConductor(float cosTheta, mat2x3 data) {
    vec3 eta            = data[0];
    vec3 etak           = data[1];
    float cosTheta2     = sqr(cosTheta);
    float sinTheta2     = 1.0 - cosTheta2;
    vec3 eta2           = sqr(eta);
    vec3 etak2          = sqr(etak);

    vec3 t0             = eta2 - etak2 - sinTheta2;
    vec3 a2plusb2       = sqrt(sqr(t0) + 4.0 * eta2 * etak2);
    vec3 t1             = a2plusb2 + cosTheta2;
    vec3 a              = sqrt(0.5 * (a2plusb2 + t0));
    vec3 t2             = 2.0 * a * cosTheta;
    vec3 Rs             = (t1 - t2) * rcp(max(t1 + t2, 1e-16));

    vec3 t3             = cosTheta2 * a2plusb2 + sinTheta2 * sinTheta2;
    vec3 t4             = t2 * sinTheta2;   
    vec3 Rp             = Rs * (t3 - t4) * rcp(max(t3 + t4, 1e-16));

    return saturate((Rs + Rp) * 0.5);
}
vec3 fresnelTinted(float cosTheta, vec3 tint) {
    vec3 tintSqrt   = sqrt(clamp(tint, 0.0, 0.99));
    vec3 n          = (1.0 + tintSqrt) / (1.0 - tintSqrt);
    vec3 g          = sqrt(sqr(n) + sqr(cosTheta) - 1);

    return 0.5 * sqr((g - cosTheta) / (g + cosTheta)) * (1.0 + sqr(((g + cosTheta) * cosTheta - 1.0) / ((g - cosTheta) * cosTheta + 1.0)));
}