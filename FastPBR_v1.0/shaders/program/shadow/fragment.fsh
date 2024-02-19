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

layout(location = 0) out vec4 data0;
layout(location = 1) out float data1;

#define shadowmapTextureMipBias 0   //[1 2 3 4]

#include "/lib/head.glsl"
#include "/lib/util/colorspace.glsl"
#include "/lib/shadowconst.glsl"

#define gSHADOW

flat in int matID;

in vec2 uv;

in vec3 tint;

uniform sampler2D gcolor;

uniform int blockEntityId;

void main() {
    if (blockEntityId == 10201) discard;

    data0           = texture(gcolor, uv, -shadowmapTextureMipBias);
    if (data0.a < 0.1) discard;
        data0.rgb  *= tint;

    data0.rgb       = toLinear(data0.rgb);

    if (matID == 102) {
        #ifdef customWaterColor
        data0       = vec4(waterRed, waterGreen, waterBlue, max(waterAlpha, 0.101));
        data0 = vec4(1,1,1,0.1);
        #endif
    }
    data0.a     = sqrt(data0.a);

    data1   = float(matID == 102);
}