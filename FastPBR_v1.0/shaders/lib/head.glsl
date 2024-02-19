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

#include "/settings.glsl"
#include "internal.glsl"
#include "util/const.glsl"
#include "util/macros.glsl"
#include "util/functions.glsl"

#ifdef RSSBO_ENABLE_COLOR
layout(std430, binding = 0) buffer RColorSSBO {
    vec3 Sunlight;
    vec3 Moonlight;
    vec3 Skylight;
    vec3 Blocklight;
    vec3 DirectLight;
    vec3 CloudDirectLight;
    vec3 CloudSkylight;
    vec3 AtmosIlluminance;
    mat3x4 SkylightSH;
} RColorTable;
#endif