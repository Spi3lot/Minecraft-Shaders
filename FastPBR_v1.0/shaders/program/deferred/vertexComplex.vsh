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
uniform vec2 viewSize;
#define VERTEX_STAGE
#include "/lib/downscaleTransform.glsl"

out vec2 uv;

vec3 blackbody(float temperature){
    vec4 vx = vec4(-0.2661239e9, -0.2343580e6, 0.8776956e3, 0.179910);
    vec4 vy = vec4(-1.1063814, -1.34811020, 2.18555832, -0.20219683);
    float it = rcp(temperature);
    float it2= sqr(it);
    float x = dot(vx, vec4(it * it2, it2, it, 1.0));
    float x2 = sqr(x);
    float y = dot(vy,vec4(x * x2, x2, x, 1.0));
    float z = 1.0 - x - y;
    
    vec3 REC2020   = vec3(x * rcp(y), 1.0, z * rcp(y)) * CT_XYZ_2020;
    return max(REC2020, 0.0);
}

#ifndef DIM
#include "/lib/atmos/colorsDefault.glsl"
#elif DIM == -1
#include "/lib/atmos/colorsNether.glsl"
#elif DIM == 1
#include "/lib/atmos/colorsEnd.glsl"
#endif

void main() {
    gl_Position = vec4(gl_Vertex.xy * 2.0 - 1.0, 0.0, 1.0);
    uv = gl_MultiTexCoord0.xy;

    #ifndef FULLRES_PASS
    VertexDownscaling(gl_Position, uv);
    #endif

    getColorPalette();
}