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

const ivec2 temporalOffset4[4]  = ivec2[4] (
    ivec2(0, 0),
    ivec2(1, 1),
    ivec2(0, 1),
    ivec2(1, 0)
);

const ivec2 temporalOffset9[9]  = ivec2[9] (
    ivec2( 0, 0),
    ivec2( 2, 0),
    ivec2( 0, 2),
    ivec2( 2, 2),
    ivec2( 0, 1),
    ivec2( 2, 1),
    ivec2( 1, 0),
    ivec2( 1, 2),
    ivec2( 1, 1)
);

#ifdef ditherPass
float ditherBluenoiseCheckerboard(vec2 offset) {
    ivec2 uv = ivec2(gl_FragCoord.xy + offset);
    float noise = texelFetch(noisetex, uv & 255, 0).a;

        noise   = fract(noise+float(floor(frameCounter/checkerboardDivider))/pi*2);

    return noise;
}
float ditherGradNoiseCheckerboard(vec2 offset){
    return fract(52.9829189*fract(0.06711056*(gl_FragCoord.x + offset.x) + 0.00583715*(gl_FragCoord.y + offset.y) + 0.00623715 * (float(floor(frameCounter/checkerboardDivider)) * 0.31)));
}
#endif