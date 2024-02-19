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

#ifdef FUTIL_LINDEPTH
float depthLinear(float depth) {
    return (2.0*near) / (far+near-depth * (far-near));
}
#endif

#ifdef FUTIL_D3X3
float depthMax3x3(sampler2D depthtex, vec2 uv, vec2 px) {
    float tl    = texture(depthtex, uv + vec2(-px.x, -px.y)).x;
    float tc    = texture(depthtex, uv + vec2(0.0, -px.y)).x;
    float tr    = texture(depthtex, uv + vec2(px.x, -px.y)).x;
    float tmin  = max(tl, max(tc, tr));

    float ml    = texture(depthtex, uv + vec2(-px.x, 0.0)).x;
    float mc    = texture(depthtex, uv).x;
    float mr    = texture(depthtex, uv + vec2(px.x, 0.0)).x;
    float mmin  = max(ml, max(mc, mr));

    float bl    = texture(depthtex, uv + vec2(-px.x, px.y)).x;
    float bc    = texture(depthtex, uv + vec2(0.0, px.y)).x;
    float br    = texture(depthtex, uv + vec2(px.x, px.y)).x;
    float bmin  = max(bl, max(bc, br));

    return max(tmin, max(mmin, bmin));
}
#endif

#ifdef FUTIL_TBLEND
vec3 blendTranslucencies(vec3 sceneColor, vec4 translucents, vec3 albedo) {
    vec3 color  = sceneColor;
        color  *= mix(vec3(1.0), albedo, translucents.a);
        color   = color * (1.0 - translucents.a) + translucents.rgb;

    return color;
}
#endif

#ifdef FUTIL_MAT16
int decodeMatID16(float x) {
    return int(x*65535.0);
}
int decodeMatID8(float x) {
    return int(x*255.0);
}
#endif

#ifdef FUTIL_LIGHTMAP
vec3 getBlocklightMap(vec3 color, float intensity) {
    return pow5(intensity) * color;
}
#endif

#ifdef FUTIL_ROT2
vec2 rotatePos(vec2 pos, const float angle) {
    return vec2(cos(angle)*pos.x + sin(angle)*pos.y, 
                cos(angle)*pos.y - sin(angle)*pos.x);
}
#endif