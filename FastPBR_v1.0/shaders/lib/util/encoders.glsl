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

/*
    Normals encoding and decoding based on Spectrum by Zombye
*/
vec2 encodeNormal(vec3 normal) {
    normal.xy /= abs(normal.x) + abs(normal.y) + abs(normal.z);
    return (normal.z <= 0.0 ? (1.0 - abs(normal.yx)) * vec2(normal.x >= 0.0 ? 1.0 : -1.0, normal.y >= 0.0 ? 1.0 : -1.0) : normal.xy) * 0.5 + 0.5;
}
vec3 decodeNormal(vec2 encodedNormal) {
    encodedNormal = encodedNormal * 2.0 - 1.0;
	vec3 normal = vec3(encodedNormal, 1.0 - abs(encodedNormal.x) - abs(encodedNormal.y));
	float t = max(-normal.z, 0.0);
	normal.xy += vec2(normal.x >= 0.0 ? -t : t, normal.y >= 0.0 ? -t : t);
	return normalize(normal);
}

/*
    From Spectrum by Zombye
*/
vec4 encodeRGBE8(vec3 rgb) {
	float exponentPart = floor(log2(max(max(rgb.r, rgb.g), max(rgb.b, exp2(-127.0))))); // can remove the clamp to above exp2(-127) if you're sure you're not going to input any values below that
	vec3  mantissaPart = clamp((128.0 / 255.0) * exp2(-exponentPart) * rgb, 0.0, 1.0);
	      exponentPart = clamp(exponentPart / 255.0 + (127.0 / 255.0), 0.0, 1.0);

	return vec4(mantissaPart, exponentPart);
}
vec3 decodeRGBE8(vec4 rgbe) {
	const float add = log2(255.0 / 128.0) - 127.0;
	return exp2(rgbe.a * 255.0 + add) * rgbe.rgb;
}

/*
float pack2x8(vec2 toEnc) {
    uvec2 bitfield = uvec2(toEnc * 255.0 + 0.5);
    return float(bitfield.x | bitfield.y << 8u) / 65535.0;
}
float pack2x8(float toEncA, float toEncB) {
    uvec2 bitfield = uvec2(vec2(toEncA, toEncB) * 255.0 + 0.5);
    return float(bitfield.x | bitfield.y << 8u) / 65535.0;
}
vec2 unpack2x8(float toDec) {
    uint bitfield = uint(toDec * 65535u);
    return vec2(bitfield & 255u, bitfield >> 8u) / 255.0;
}*/

float encode2x16(vec2 toEnc) {
    uvec2 bitfield = uvec2(toEnc * 65535.0 + 0.5);
    return float(bitfield.x | bitfield.y << 16u) / 4294967295.0;
}
vec2 decode2x16(float toDec) {
    uint bitfield = uint(toDec * 4294967295u);
    return vec2(bitfield & 65535, bitfield >> 16u) / 65535.0;
}

vec3 decode3x8(float a){
    int bf = int(a*65535.);
    return vec3(bf%32, (bf>>5)%64, bf>>11) / vec3(31,63,31);
}

float encodeMatID16(int x) {
    float id    = float(x)/65535.0;
    return id;
}
float encodeMatID8(int x) {
    float id    = float(x)/255.0;
    return id;
}

/*
    16 Bit Target Encoders
*/
float pack2x8(in vec2 toPack) {
    toPack  = saturate(toPack) * 255.0;

    uint bf = uint(toPack.x);
        bf  = bitfieldInsert(bf, uint(toPack.y), 8, 8);

    return float(bf) / 65535.0;
}
float pack2x8(in ivec2 toPack) {
    toPack  = clamp(toPack, 0, 255);

    uint bf = uint(toPack.x);
        bf  = bitfieldInsert(bf, uint(toPack.y), 8, 8);

    return float(bf) / 65535.0;
}
float pack2x8(in float toPackA, in float toPackB) {
    toPackA = saturate(toPackA) * 255.0;
    toPackB = saturate(toPackB) * 255.0;

    uint bf = uint(toPackA);
        bf  = bitfieldInsert(bf, uint(toPackB), 8, 8);

    return float(bf) / 65535.0;
}
vec2 unpack2x8(in float data) {
    uint bf = uint(data * 65535.0);

    return vec2(bitfieldExtract(bf, 0, 8), bitfieldExtract(bf, 8, 8)) / 255.0;
}
ivec2 unpack2x8I(in float data) {
    uint bf = uint(data * 65535.0);

    return ivec2(bitfieldExtract(bf, 0, 8), bitfieldExtract(bf, 8, 8));
}


float pack4x4(in vec4 toPack) {
    toPack  = saturate(toPack) * 15.0;

    uint bf = uint(toPack.x);
        bf  = bitfieldInsert(bf, uint(toPack.y), 4, 4);
        bf  = bitfieldInsert(bf, uint(toPack.y), 8, 4);
        bf  = bitfieldInsert(bf, uint(toPack.y), 12, 4);

    return float(bf) / 65535.0;
}
vec4 unpack4x4(in float data) {
    uint bf = uint(data * 65535.0);

    vec4 fl = vec4(0.0);
    fl.x    = bitfieldExtract(bf, 0, 4);
    fl.y    = bitfieldExtract(bf, 4, 4);
    fl.z    = bitfieldExtract(bf, 8, 4);
    fl.w    = bitfieldExtract(bf, 12, 4);

    return fl / 15.0;
}

/*
    Unsigned Int encoders
*/
uint pack2x16UI(in vec2 toPack) {
    toPack *= 65535.0;
    uint bf = uint(toPack.x);
    bf      = bitfieldInsert(bf, uint(toPack.y), 16, 16);
    return bf;
}
vec2 unpack2x16(in uint ui) {
    vec2 fl = vec2(0.0);
    fl.x    = bitfieldExtract(ui, 0, 16);
    fl.y    = bitfieldExtract(ui, 16, 16);
    return fl / 65535.0;
}

uint pack2x8UI(in vec2 toPack) {
    toPack *= 255.0;
    uint bf = uint(toPack.x);
    bf      = bitfieldInsert(bf, uint(toPack.y), 8, 8);
    return bf;
}
vec2 unpack2x8(in uint ui) {
    vec2 fl = vec2(0.0);
    fl.x    = bitfieldExtract(ui, 0, 8);
    fl.y    = bitfieldExtract(ui, 8, 8);
    return fl / 255.0;
}

uint pack4x8UI(in vec4 toPack) {
    toPack *= 255.0;
    uint bf = uint(toPack.x);
    bf      = bitfieldInsert(bf, uint(toPack.y), 8, 8);
    bf      = bitfieldInsert(bf, uint(toPack.z), 16, 8);
    bf      = bitfieldInsert(bf, uint(toPack.w), 24, 8);
    return bf;
}
vec4 unpack4x8(in uint ui) {
    vec4 fl = vec4(0.0);
    fl.x    = bitfieldExtract(ui, 0, 8);
    fl.y    = bitfieldExtract(ui, 8, 8);
    fl.z    = bitfieldExtract(ui, 16, 8);
    fl.w    = bitfieldExtract(ui, 24, 8);
    return fl / 255.0;
}

uint pack2x4UI(in vec2 toPack) {
    toPack *= 15.0;
    uint bf = uint(toPack.x);
    bf      = bitfieldInsert(bf, uint(toPack.y), 4, 4);
    return bf;
}
vec2 unpack2x4(in uint ui) {
    vec2 fl = vec2(0.0);
    fl.x    = bitfieldExtract(ui, 0, 4);
    fl.y    = bitfieldExtract(ui, 4, 4);
    return fl / 15.0;
}