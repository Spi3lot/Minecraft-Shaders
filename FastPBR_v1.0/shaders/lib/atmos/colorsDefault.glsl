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

#ifdef cloudPass
    const float eyeAltitude = 800.0;
    #define airmassStepBias 0.33
#else
    uniform float eyeAltitude;
    #define airmassStepBias 0.4
#endif

uniform float wetness;

uniform vec3 sunDir;
uniform vec3 moonDir;

uniform vec4 daytime;

uniform sampler2D gaux1;

flat out mat4x3 lightColor;

void getColorPalette() {
    lightColor[0]  = texelFetch(gaux1, ivec2(2,0),0).rgb;

    #if !(defined cloudPass || defined skyboxPass)
        lightColor[0] *= (1.0 - wetness * 0.95);
    #endif

    lightColor[1]  = texelFetch(gaux1, ivec2(3,0),0).rgb;
    
    #ifdef fogPass
        lightColor[2]  = texelFetch(gaux1, ivec2(0,0),0).rgb * skylightIllum;
    #elif (defined cloudPass)
        lightColor[2]  = texelFetch(gaux1, ivec2(0,0),0).rgb * sqrt3;
    #else
        lightColor[2]  = texelFetch(gaux1, ivec2(0,0),0).rgb * skylightIllum;
    #endif

    lightColor[2] *= vec3(skylightRedMult, skylightGreenMult, skylightBlueMult);
        
    #ifndef skipBlocklight
        lightColor[3]  = RColor_Lightmap * blocklightIllum * blocklightBaseMult;
    #endif
}