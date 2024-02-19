/*
====================================================================================================

    Copyright (C) 2021 RRe36

    All Rights Reserved unless otherwise explicitly stated.


    By downloading this you have agreed to the license and terms of use.
    These can be found inside the included license-file
    or here: https://rre36.com/copyright-license

    Violating these terms may be penalized with actions according to the Digital Millennium
    Copyright Act (DMCA), the Information Society Directive and/or similar laws
    depending on your country.

====================================================================================================
*/

float rcp(int x)    { return mRcp(float(x)); }
float rcp(float x)  { return mRcp(x); }
vec2 rcp(vec2 x)    { return mRcp(x); }
vec3 rcp(vec3 x)    { return mRcp(x); }
vec4 rcp(vec4 x)    { return mRcp(x); }

float sqr(float x)  { return x * x; }
vec2 sqr(vec2 x)    { return x * x; }
vec3 sqr(vec3 x)    { return x * x; }
vec4 sqr(vec4 x)    { return x * x; }

int sqr(int x)      { return x * x; }
ivec2 sqr(ivec2 x)  { return x * x; }
ivec3 sqr(ivec3 x)  { return x * x; }
ivec4 sqr(ivec4 x)  { return x * x; }

float cube(float x) { return sqr(x)*x; }
vec2 cube(vec2 x)   { return sqr(x)*x; }
vec3 cube(vec3 x)   { return sqr(x)*x; }
vec4 cube(vec4 x)   { return sqr(x)*x; }

float pow4(float x) { return sqr(x)*sqr(x); }
float pow5(float x) { return pow4(x)*x; }
float pow6(float x) { return pow5(x)*x; }
float pow8(float x) { return pow4(x)*pow4(x); }

float log10(float x)        { return log(x) * rLog10; }
vec2 log10(vec2 x)          { return log(x) * rLog10; }
vec3 log10(vec3 x)          { return log(x) * rLog10; }

float cubeSmooth(float x)   { return mCubeSmooth(x); }
vec2 cubeSmooth(vec2 x)     { return mCubeSmooth(x); }
vec3 cubeSmooth(vec3 x)     { return mCubeSmooth(x); }

float avgOf(vec2 a)             { return (a.x + a.y) * 0.5; }
float avgOf(float a, float b)   { return (a + b) * 0.5; }
float avgOf(vec3 a)             { return (a.x + a.y + a.z) * rcp(3.0); }
float avgOf(float a, float b, float c) { return (a + b + c) * rcp(3.0); }
float avgOf(vec4 a)             { return (a.x + a.y + a.z + a.w) * rcp(4.0); }

float minOf(vec2 a)         { return min(a.x, a.y); }
float minOf(vec3 a)         { return min(a.x, min(a.y, a.z)); }
float minOf(float a, float b, float c) { return min(a, min(b, c)); }

float maxOf(vec2 a)         { return max(a.x, a.y); }
float maxOf(vec3 a)         { return max(a.x, max(a.y, a.z)); }
float maxOf(float a, float b, float c) { return max(a, max(b, c)); }

float dotSelf(vec2 x)       { return dot(x, x); }
float dotSelf(vec3 x)       { return dot(x, x); }

float fLength(vec2 x)       { return sqrt(dotSelf(x)); }
float fLength(vec3 x)       { return sqrt(dotSelf(x)); }

float saturate(float x)     { return mSaturate(x); }
vec2 saturate(vec2 x)       { return mSaturate(x); }
vec3 saturate(vec3 x)       { return mSaturate(x); }
vec4 saturate(vec4 x)       { return mSaturate(x); }

float linStep(float x, float low, float high)   { return saturate((x-low)/(high-low)); }
vec2 linStep(vec2 x, float low, float high)     { return saturate((x-low)/(high-low)); }
vec3 linStep(vec3 x, float low, float high)     { return saturate((x-low)/(high-low)); }

float getLuma(vec3 x)       { return dot(x, lumacoeffAP1); }

vec3 colorSaturation(vec3 color, const float SAT) { return mix(vec3(getLuma(color)), color, SAT); }

vec2 sincos(float x)        { return vec2(sin(x), cos(x)); }

bool isOnScreenDownscale(vec2 coord, vec2 pixel, const float lod) {
    return clamp(coord, -pixel * lod, 1.0 + pixel * lod) == coord;
}

float thresholdStep(float x, float low) {
    if (x < low) return 0.0;
    return x * linStep(x, low, low + low * 0.5);
}

vec3 drawbufferClamp(vec3 color) {
    #ifdef MC_GL_RENDERER_GEFORCE
        return clamp(color, 1.0/65530.0, 65535.0);   //NaN fix on nvidia
    #else
        return clamp16F(color);
    #endif
}
vec4 drawbufferClamp(vec3 color, float alpha) {
    #ifdef MC_GL_RENDERER_GEFORCE
        return vec4(clamp(color, 1.0/65530.0, 65535.0), saturate(alpha));   //NaN fix on nvidia
    #else
        return vec4(clamp16F(color), saturate(alpha));
    #endif
}
vec4 drawbufferClamp(vec4 color) {
    #ifdef MC_GL_RENDERER_GEFORCE
        return vec4(clamp(color.rgb, 1.0/65530.0, 65535.0), saturate(color.a));   //NaN fix on nvidia
    #else
        return vec4(clamp16F(color.rgb), saturate(color.a));
    #endif
}