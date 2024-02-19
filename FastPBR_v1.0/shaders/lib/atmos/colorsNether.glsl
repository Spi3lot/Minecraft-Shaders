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

#include "/lib/util/colorspace.glsl"

flat out mat2x3 lightColor;

uniform vec3 fogColor;

void getColorPalette() {
    lightColor[0]  = netherSkylightColor;
    lightColor[0]  = mix(lightColor[0], LinearToRec2020(normalize(toLinear(fogColor))), 0.9);

    lightColor[1]  = RColor_Lightmap * blocklightIllum * blocklightBaseMult * pi;
}