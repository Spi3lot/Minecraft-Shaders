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


uniform float frameTimeCounter;

uniform sampler2D noisetex;

float windTick     = frameTimeCounter*pi;

#include "/lib/frag/noise.glsl"

vec2 rotatePosXY(vec2 pos, const float angle) {
    return vec2(cos(angle)*pos.x + sin(angle)*pos.y, 
                cos(angle)*pos.y - sin(angle)*pos.x);
}

float windMacrogust(vec3 pos, const float speed) {
    float p     = pos.x + pos.z + pos.y*0.2;
    float t     = windTick * speed;

    float s1    = sin(t + p) * 0.7 + 0.2;
    float c1    = cos(t * 0.655 + p)*0.7+0.2;

    return s1+c1;
}
float windWave(vec3 pos, const float speed) {
    float p     = (pos.x + pos.z) * 0.5;
    float t     = windTick * speed;

    float s1    = sin(t + p) * 0.68 + 0.2;

    return s1;
}

vec2 vertexWindEffect(vec3 pos, const float amp, const float size) {
    vec3 p      = pos * size;
        p.xz    = rotatePosXY(p.xz, pi*rcp(3.0));

    vec2 macroWave = vec2(0.0);
        macroWave += windMacrogust(p, 1.0) * vec2(1.0, 0.1);
        macroWave += windWave(p, 1.2)*vec2(1.0, -0.1);

    vec2 microWave = vec2(0.0);
        microWave += Value3D(p * 2.8 + vec3(1.0, 0.5, 0.8) * windTick * 0.6)  * vec2(1.0, 0.7);
        microWave -= Value3D(p * 3.9 + vec3(0.7, 0.7, 1.0) * windTick * 0.52) * vec2(1.0, -0.5);
        microWave += Value3D(p * 4.3 + vec3(1.0, 0.8, 0.9) * windTick * 0.45) * vec2(1.0, 0.8);
        microWave.x += 0.2;
        microWave *= max(windWave(p*0.05, 0.1) + 0.6, 0.0)*0.5+0.2;

    return (macroWave * 0.33 + microWave * 1.1) * vec2(-1.0, 1.0) * 0.75 * amp * windIntensity;
}