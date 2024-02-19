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



float ditherBluenoise() {
    ivec2 uv = ivec2(gl_FragCoord.xy);
    float noise = texelFetch(noisetex, uv & 255, 0).a;

        noise   = fract(noise+float(frameCounter)/pi);

    return noise;
}

float ditherBluenoiseTemporal() {
    ivec2 UV = ivec2(gl_FragCoord.xy);
    float noise = texelFetch(noisetex, UV & 255, 0).a;

        noise   = fract(noise+float(frameCounter)/pi);

    return noise;
}

float ditherBluenoiseStatic() {
    ivec2 uv = ivec2(gl_FragCoord.xy);
    float noise = texelFetch(noisetex, uv & 255, 0).a;

    return noise;
}