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

#include "/lib/head.glsl"

out vec2 uv;

flat out float exposure;

uniform sampler2D colortex5;
uniform sampler2D colortex2;

uniform float frameTime;
uniform float viewHeight;
uniform float viewWidth;
uniform float nightVision;

uniform vec2 viewSize;

ivec2 tiles   = ivec2(viewSize * cube(0.25) - 1);

#ifdef exposureComplexEnabled

float getExposureLuma() {
    vec2 averageLuminance   = vec2(0.0);
    int total               = 0;
    float totalWeight       = 0.0;

    /*
        Get weighted average.
    */

    for (int x = 0; x < tiles.x; ++x) {
        for (int y = 0; y < tiles.y; ++y) {
            float currentLuminance = texelFetch(colortex5, ivec2(x, y), 0).a;

            vec2 uv          = vec2(x, y) / vec2(tiles);

            float weight        = 1.0 - linStep(length(uv * 2.0 - 1.0), 0.25, 0.75);
                weight          = cubeSmooth(weight) * 0.9 + 0.1;

            averageLuminance   += vec2(currentLuminance, currentLuminance * weight);
            ++total;
            totalWeight    += weight;
        }
    }
    averageLuminance.x     /= max(total, 1);
    averageLuminance.y     /= max(totalWeight, 1.0);

    /*
        Determine distribution above or below average.
    */

    int aboveAverage            = 0;
    vec2 aboveAverageData       = vec2(0.0);
    int belowAverage            = 0;
    vec2 belowAverageData       = vec2(0.0);

    vec2 luminanceThreshold     = vec2(averageLuminance.x * (1.0 + exposureBrightPercentage), averageLuminance.x * (1.0 - exposureDarkPercentage));

    for (int x = 0; x < tiles.x; ++x) {
        for (int y = 0; y < tiles.y; ++y) {
            vec2 uv          = vec2(x, y) / vec2(tiles);

            float weight        = 1.0 - linStep(length(uv * 2.0 - 1.0), 0.25, 0.75);
                weight          = cubeSmooth(weight) * 0.9 + 0.1;

            float currentLuminance = texelFetch(colortex5, ivec2(x, y), 0).a;

            if (currentLuminance > luminanceThreshold.x) {

                ++aboveAverage;
                aboveAverageData   += vec2(currentLuminance * weight, weight);

            } else if (currentLuminance < luminanceThreshold.y) {

                ++belowAverage;
                belowAverageData   += vec2(currentLuminance * weight, weight);

            }
        }
    }

    aboveAverageData.x /= max(aboveAverageData.y, 1.0);
    belowAverageData.x /= max(belowAverageData.y, 1.0);

    vec2 areaPercentages = vec2(aboveAverage, belowAverage) / max(total, 1);

    float weightedLuma  = mix(averageLuminance.y, belowAverageData.x, areaPercentages.y);
        weightedLuma    = mix(weightedLuma, aboveAverageData.x, areaPercentages.x);

    return weightedLuma;
}

#else

float getExposureLuma() {
    float averageLuminance  = 0.0;
    int total = 0;
    float totalWeight   = 0.0;

    for (int x = 0; x < tiles.x; ++x) {
        for (int y = 0; y < tiles.y; ++y) {
            float currentLuminance = texelFetch(colortex5, ivec2(x, y), 0).a;

            vec2 uv          = vec2(x, y) / vec2(tiles);

            float weight        = 1.0 - linStep(length(uv * 2.0 - 1.0), 0.25, 0.75);
                weight          = cubeSmooth(weight) * 0.9 + 0.1;

            averageLuminance   += currentLuminance * weight;
            ++total;
            totalWeight    += weight;
        }
    }
    averageLuminance   /= max(totalWeight, 1);

    return averageLuminance;
}

#endif

float temporalExp() {

    
    #if DIM == -1
    const float exposureLowClamp    = 0.075;
    const float exposureHighClamp   = 0.15;
    #elif DIM == 1
    const float exposureLowClamp    = 0.1;
    const float exposureHighClamp   = 0.15;
    #else
    const float exposureLowClamp    = 0.020;
    const float exposureHighClamp   = 1.5;
    #endif

    float expCurr   = clamp(texelFetch(colortex2, ivec2(0), 0).a, 0.0, 65535.0);
    float expTarg   = getExposureLuma();
        expTarg     = 1.0 / clamp(expTarg, exposureLowClamp * exposureDarkClamp * rcp(nightVision + 1.0), exposureHighClamp * exposureBrightClamp);
        expTarg     = log2(expTarg * rcp(6.25));    //adjust this
        expTarg     = 1.2 * pow(2.0, expTarg);

    //return expTarg;

    float adaptBaseSpeed = expTarg < expCurr ? 0.075 : 0.05;

    //return 0.3;

    return mix(expCurr, expTarg, saturate(adaptBaseSpeed * exposureDecay * (frameTime * rcp(0.033))));
}

void main() {
    gl_Position = vec4(gl_Vertex.xy * 2.0 - 1.0, 0.0, 1.0);
    uv = gl_MultiTexCoord0.xy;

    exposure  = temporalExp();
}