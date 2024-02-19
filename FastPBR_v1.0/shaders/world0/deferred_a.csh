#version 430

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

layout (local_size_x = 8, local_size_y = 4) in;

const vec2 workGroupsRender = vec2(1.0, 1.0);

layout (rgba16f) writeonly uniform image2D colorimg7;
layout (rgba16f) writeonly uniform image2D colorimg10;

#include "/lib/head.glsl"

uniform sampler2D colortex5, colortex9;

void main() {
    ivec2 UV = ivec2(gl_GlobalInvocationID.xy);

    imageStore(colorimg7, UV, clamp16F(texelFetch(colortex9, ivec2(gl_GlobalInvocationID.xy), 0)));
    imageStore(colorimg10, UV, clamp16F(texelFetch(colortex5, ivec2(gl_GlobalInvocationID.xy), 0)));
}