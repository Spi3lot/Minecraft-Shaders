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

/*DRAWBUFFERS:0*/
layout(location = 0) out vec4 sceneAlbedo;

#include "/lib/head.glsl"
#include "/lib/util/colorspace.glsl"

uniform vec2 viewSize;
#include "/lib/downscaleTransform.glsl"

in vec2 uv;
in vec4 tint;

uniform sampler2D gcolor;

void main() {
    if (OutsideDownscaleViewport()) discard;
    vec4 sceneColor   = texture(gcolor, uv);
        sceneColor   *= tint;

    if (sceneColor.a < 0.01) discard;

        convertToPipelineAlbedo(sceneColor.rgb);

    #ifdef gSPIDEREYES
        sceneColor.rgb *= pi;
    #endif


    sceneAlbedo     = drawbufferClamp(sceneColor);
}