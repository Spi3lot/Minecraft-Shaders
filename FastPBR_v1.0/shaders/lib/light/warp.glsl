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

#define shadowmapDistortionBias 0.85

float calculateWarp(in vec2 x) {
    return length(x * 1.169) * shadowmapDistortionBias + (1.0 - shadowmapDistortionBias);
}

vec2 shadowmapWarp(vec2 coord, out float distortion) {
    distortion = calculateWarp(coord);
    return coord/distortion;
}
vec2 shadowmapWarp(vec2 coord) {
    float distortion = calculateWarp(coord);
    return coord/distortion;
}