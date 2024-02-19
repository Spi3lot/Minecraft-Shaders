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

#ifndef DIM
    #define rtaoSkySample
#elif DIM == -1
    #define NOSHADOWMAP
#endif


#define SKY_RENDER_LOD 3

#define DEBUG_VIEW 0    //[0 1 2 3 4 5 6] 0-off, 1-whiteworld, 2-indirect Occlusion, 3-indirect light, 4-albedo, 5-hdr, 6-reflections
//#define DEBUG_WITH_ALBEDO
//#define RTAO_NOSKYMAP

//#define deffNAN
//#define compNAN

#define blocklightBaseMult 1.0

#define netherSkylightColor vec3(1.0, 0.23, 0.08)
#define endSkylightColor vec3(0.7, 0.5, 1.0)
#define endSunlightColor vec3(1.0, 0.4, 0.7)
#define RColor_Lightmap vec3(1.0 * blocklightRedMult, 0.5 * blocklightGreenMult, 0.2 * blocklightBlueMult)

#define cloudShadowmapRenderDistance 4e3
#define cloudShadowmapResolution 512

//#define shadowcompCaustics

//const float indirectResScale = sqrt(1.0 / indirectResReduction);

#define ResolutionScale 1.0     //[0.25 0.5 0.75 1.0]