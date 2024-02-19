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

/* RENDERTARGETS: 5 */
layout(location = 0) out vec4 bloomData;

#include "/lib/head.glsl"

//bloom downsampling method based on chocapic13's shaders

uniform vec2 bloomResolution;
uniform vec2 pixelSize;
uniform vec2 viewSize;

in vec2 uv;

#if pass == 0
    uniform sampler2D colortex0;
#elif pass == 1
    uniform sampler2D colortex0;
    uniform sampler2D colortex5;

const uvec2 downsampleScale     = uvec2(4);
const float scaleMult           = 0.25;

const float exposureLuminanceLimit  = 12.0;

float getLuminance4x4(sampler2D tex) {
    uvec2 startPos  = uvec2(floor(gl_FragCoord.xy / vec2(downsampleScale))) * downsampleScale;

    float lumaSum   = 0.0;
    uint samples    = 0;

    for (uint x = 0; x < downsampleScale.x; ++x) {
        for (uint y = 0; y < downsampleScale.y; ++y) {
            uvec2 pos   = (startPos + ivec2(x, y)) * downsampleScale;
            lumaSum += min(getLuma(texelFetch(tex, ivec2(pos), 0).rgb), exposureLuminanceLimit);
            ++samples;
        }
    }
    lumaSum /= max(samples, 1);

    return lumaSum;
}
#endif

#define BWEIGHT_0   0.5
#define BWEIGHT_1   0.25
#define BWEIGHT_2   0.125

void main() {
    bloomData       = vec4(0.0);

    #ifdef bloomEnabled

    #if pass == 0
        vec2 rscale     = max(viewSize, bloomResolution)/bloomResolution;
        vec2 qrescoord  = (gl_FragCoord.xy*2.0*pixelSize-vec2(0.0, 0.5))*rscale;
    #elif pass == 1
        vec2 qrescoord  = gl_FragCoord.xy*2.0*pixelSize+vec2(0.0, 0.25);
        if (uv.x < scaleMult && uv.y < scaleMult) bloomData.a = clamp16F(getLuminance4x4(colortex0));
    #endif

    #if pass == 0
        #define coltex colortex0
    #elif pass == 1
        #define coltex colortex5
    #endif

    if (saturate(qrescoord) == qrescoord) {
        //0.5
        vec4 blur       = textureLod(coltex, qrescoord-1.0*vec2(pixelSize.x, pixelSize.y), 0) * BWEIGHT_0;
            blur       += textureLod(coltex, qrescoord+1.0*vec2(pixelSize.x, pixelSize.y), 0) * BWEIGHT_0;
            blur       += textureLod(coltex, qrescoord+1.0*vec2(-pixelSize.x, pixelSize.y), 0) * BWEIGHT_0;
            blur       += textureLod(coltex, qrescoord+1.0*vec2(pixelSize.x, -pixelSize.y), 0) * BWEIGHT_0;

        //0.25
            blur       += textureLod(coltex, qrescoord-2.0*vec2(pixelSize.x, 0.0), 0) * BWEIGHT_1;
            blur       += textureLod(coltex, qrescoord+2.0*vec2(0.0, pixelSize.y), 0) * BWEIGHT_1;
            blur       += textureLod(coltex, qrescoord+2.0*vec2(-pixelSize.x, 0.0), 0) * BWEIGHT_1;
            blur       += textureLod(coltex, qrescoord+2.0*vec2(0.0, -pixelSize.y), 0) * BWEIGHT_1;

        //0.125
            blur       += textureLod(coltex, qrescoord-2.0*vec2(pixelSize.x, pixelSize.y), 0) * BWEIGHT_2;
            blur       += textureLod(coltex, qrescoord+2.0*vec2(pixelSize.x, pixelSize.y), 0) * BWEIGHT_2;
            blur       += textureLod(coltex, qrescoord+2.0*vec2(-pixelSize.x, pixelSize.y), 0) * BWEIGHT_2;
            blur       += textureLod(coltex, qrescoord+2.0*vec2(pixelSize.x, -pixelSize.y), 0) * BWEIGHT_2;

            blur       += textureLod(coltex, qrescoord, 0) * BWEIGHT_2;

            blur       /= 4.0;

        #if pass == 0
            if (qrescoord.x>1.0-3.5*pixelSize.x || qrescoord.y>1.0-3.5*pixelSize.y || qrescoord.x<3.5*pixelSize.x || qrescoord.y<3.5*pixelSize.y) blur = vec4(0.0);
        #endif

        bloomData.rgb = clamp16F(blur.rgb);
    }

    #else

    #if pass == 1
    if (uv.x < scaleMult && uv.y < scaleMult) bloomData.a = clamp16F(getLuminance4x4(colortex0));
    #endif

    #endif
}