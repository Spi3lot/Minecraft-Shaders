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

/* bloom downsampling method based on chocapic13's shaders */
/* pass 0 - horizontal gauss and downsampling */
/* pass 1 - vertical gauss and downsampling */

uniform sampler2D colortex5;

uniform vec2 bloomResolution;
uniform vec2 pixelSize;
uniform vec2 viewSize;

in vec2 uv;

vec2 rscale     = bloomResolution/max(viewSize, bloomResolution);

vec3 gauss_1d(vec2 uv, vec2 dir, float alpha, int steps) {
    vec4 result     = vec4(0.0);

    #if pass == 0
        float maxcoord = 0.25*rscale.x;
    #elif pass == 1
        float maxcoord = 0.25*rscale.y;
    #endif

    float mincoord  = 0.0;

    //steps *= 2;

    for (int i = -steps; i<steps+1; i++) {
        float weight    = exp(-i*i*alpha*4.0);
        vec2 spcoord    = uv+dir*pixelSize*(i*2.0);
        #if pass == 0
            result    += vec4(textureLod(colortex5, spcoord, 0).rgb, 1.0)*weight*float(spcoord.x>mincoord && spcoord.x<maxcoord);
        #elif pass == 1
            result    += vec4(textureLod(colortex5, spcoord, 0).rgb, 1.0)*weight*float(spcoord.y>mincoord && spcoord.y<maxcoord);
        #endif
    }
    return result.rgb/max(1.0, result.a);
}

#if pass == 0
const uvec2 downsampleScale     = uvec2(4);
const float scaleMult           = 0.25 * 0.25;
#elif pass == 1
const uvec2 downsampleScale     = uvec2(4);
const float scaleMult           = 0.25 * 0.25 * 0.25;
#endif

float getLuminance4x4(sampler2D tex) {
    uvec2 startPos  = uvec2(floor(gl_FragCoord.xy / vec2(downsampleScale))) * downsampleScale;

    float lumaSum   = 0.0;
    uint samples    = 0;

    for (uint x = 0; x < downsampleScale.x; ++x) {
        for (uint y = 0; y < downsampleScale.y; ++y) {
            uvec2 pos   = (startPos + ivec2(x, y)) * downsampleScale;
                pos     = clamp(pos, uvec2(0), uvec2(viewSize * sqrt(scaleMult)));
            lumaSum += texelFetch(tex, ivec2(pos), 0).a;
            ++samples;
        }
    }
    lumaSum /= max(samples, 1);

    return lumaSum;
}



void main() {
    if (clamp(uv, -0.003, 1.003) != uv) discard;
    vec2 tcoord     = (gl_FragCoord.xy*vec2(2.0, 4.0)*pixelSize);
    vec3 blur       = vec3(0.0);
    float lumaDownscale   = 0.0;

    if (uv.x < scaleMult && uv.y < scaleMult) lumaDownscale = clamp16F(getLuminance4x4(colortex5));

    #ifdef bloomEnabled
    
    #if pass == 0
        vec2 gaussdir   = vec2(1.0, 0.0);

        vec2 tc2        = tcoord*vec2(2.0, 1.0)/2.0;
        if (tc2.x<1.0*rscale.x && tc2.y<1.0*rscale.y)
        blur  = gauss_1d(tc2/2.0, gaussdir, 0.16, 0);

        vec2 tc4        = tcoord*vec2(4.0, 1.0)/2.0-vec2(0.5*rscale.x+4.0*pixelSize.x, 0.0)*2.0;
        if (tc4.x>0.0 && tc4.y>0.0 && tc4.x < 1.0*rscale.x && tc4.y <= 1.0*rscale.y)
        blur  = gauss_1d(tc4/2.0, gaussdir, 0.16, 3);

        vec2 tc8        = tcoord*vec2(8.0, 1.0)/2.0-vec2(0.75*rscale.x+8.0*pixelSize.x, 0.0)*4.0;
        if (tc8.x>0.0 && tc8.y>0.0 && tc8.x < 1.0*rscale.x && tc8.y <= 1.0*rscale.y)
        blur  = gauss_1d(tc8/2.0, gaussdir, 0.035, 6);

        //1:64
        vec2 tc16       = tcoord*vec2(8.0, 1.0/2.0)-vec2(0.875*rscale.x+12.0*pixelSize.x, 0.0)*8.0;
        if (tc16.x>0.0 && tc16.y>0.0 && tc16.x < 1.0*rscale.x && tc16.y <= 1.0*rscale.y)
        blur  = gauss_1d(tc16/2.0, gaussdir, 0.0085, 12);

        vec2 tc32       = tcoord*vec2(16.0, 1.0/2.0)-vec2(0.9375*rscale.x+16.0*pixelSize.x, 0.0)*16.0;
        if (tc32.x>0.0 && tc32.y>0.0 && tc32.x < 1.0*rscale.x && tc32.y <= 1.0*rscale.y)
        blur  = gauss_1d(tc32/2.0, gaussdir, 0.002, 28);

        vec2 tc64       = tcoord*vec2(32.0, 1.0/2.0)-vec2(0.96875*rscale.x+20.0*pixelSize.x, 0.0)*32.0;
        if (tc64.x>0.0 && tc64.y>0.0 && tc64.x < 1.0*rscale.x && tc64.y <= 1.0*rscale.y)
        blur  = gauss_1d(tc64/2.0, gaussdir, 0.0005, 60);

        //blur = texture(colortex5, gl_FragCoord.xy*pixelSize).rgb;
    #elif pass == 1
        vec2 gaussdir   = vec2(0.0, 1.0);
        if (gl_FragCoord.y*pixelSize.y > 0.22) blur = textureLod(colortex5, gl_FragCoord.xy*pixelSize, 0).rgb; 

        vec2 tc2        = tcoord*vec2(2.0, 1.0);
        if (tc2.x<1.0*rscale.x && tc2.y<=1.0*rscale.y)
        blur  = gauss_1d(tcoord/vec2(2.0, 4.0), gaussdir, 0.16, 0);

        vec2 tc4        = tcoord*vec2(4.0, 2.0)-vec2(0.5*rscale.x+4.0*pixelSize.x, 0.0)*4.0;
        if (tc4.x>0.0 && tc4.y>0.0 && tc4.x<1.0*rscale.x && tc4.y<=1.0*rscale.y)
        blur  = gauss_1d(tcoord/vec2(2.0), gaussdir, 0.16, 3);

        vec2 tc8        = tcoord*vec2(8.0, 4.0)-vec2(0.75*rscale.x+8.0*pixelSize.x, 0.0)*8.0;
        if (tc8.x>0.0 && tc8.y>0.0 && tc8.x<1.0*rscale.x && tc8.y<=1.0*rscale.y)
        blur  = gauss_1d(tcoord*vec2(1.0, 2.0)/vec2(2.0), gaussdir, 0.035, 6);

        //1:64
        vec2 tc16       = tcoord*vec2(16.0, 8.0)-vec2(0.875*rscale.x+12.0*pixelSize.x, 0.0)*16.0;    //aaaa
        if (tc16.x>0.0 && tc16.y>0.0 && tc16.x<1.0*rscale.x && tc16.y<=1.0*rscale.y)
        blur  = gauss_1d(tcoord*vec2(1.0, 4.0)/vec2(2.0), gaussdir, 0.0085, 12);

        vec2 tc32       = tcoord*vec2(32.0, 16.0)-vec2(0.9375*rscale.x+16.0*pixelSize.x, 0.0)*32.0;
        if (tc32.x>0.0 && tc32.y>0.0 && tc32.x<1.0*rscale.x && tc32.y<=1.0*rscale.y)
        blur  = gauss_1d(tcoord*vec2(1.0, 8.0)/vec2(2.0), gaussdir, 0.002, 30);

        vec2 tc64       = tcoord*vec2(64.0, 32.0)-vec2(0.96875*rscale.x+20.0*pixelSize.x, 0.0)*64.0;
        if (tc64.x>0.0 && tc64.y>0.0 && tc64.x<1.0*rscale.x && tc64.y<=1.0*rscale.y)
        blur  = gauss_1d(tcoord*vec2(1.0, 16.0)/vec2(2.0), gaussdir, 0.0005, 60);
    #endif

    bloomData = clamp16F(vec4(blur.rgb, lumaDownscale));

    #endif
}