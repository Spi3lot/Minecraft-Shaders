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

#ifndef valNoiseInc

#define valNoiseInc

vec3 Noise2D(vec2 pos) {
    return texture(noisetex, pos).xyz;
}

float Value3D(vec3 pos) {
    vec3 p  = floor(pos); 
    vec3 b  = fract(pos);

    vec2 uv = (p.xy+vec2(-97.0)*p.z)+b.xy;
    vec2 rg = texture(noisetex, (uv)/256.0).xy;

    return cubeSmooth(mix(rg.x, rg.y, b.z));
}
#endif