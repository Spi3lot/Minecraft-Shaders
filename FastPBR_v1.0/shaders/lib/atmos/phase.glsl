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

const float rayleighPN      = 0.034;

float rayleighPhase0(float cosTheta) {
    float phase = 0.8 * (1.4 + 0.5 * cosTheta);
        phase  /= pi4;
  	return phase;
}

float rayleighPhase(float cosTheta) {
    float y     = rayleighPN * rcp(2.0 - rayleighPN);
    float p1    = 3.0 * rcp(4.0 * (2.0*y + 1.0));
    float p2    = (3.0*y + 1.0) + (1.0 - y) * sqr(cosTheta);
    float phase = p1 * p2;
        phase  /= pi4;
        
    return phase;
}
vec3 rayleighPhase3(float cosTheta){
    const vec3 depolarization = vec3(2.786, 2.842, 2.899) * 1.e-2;
    const vec3 gamma    = depolarization / (2.0 - depolarization);
    return 3.0 / (16.0 * pi * (1.0 + 2.0 * gamma)) * ((1.0 + 3.0 * gamma) + (1.0 - gamma) * sqr(cosTheta));
}

float mieHG(float cosTheta, float g) {
    float mie   = 1.0 + sqr(g) - 2.0*g*cosTheta;
        mie     = (1.0 - sqr(g)) / ((4.0*pi) * mie*(mie*0.5+0.5));
    return mie;
}

float mieCS(float cosTheta, float g) {
  	float gg = sqr(g);
  	float p1 = 3.0 * (1.0 - gg) * rcp((pi * (2.0 + gg)));
  	float p2 = (1.0 + sqr(cosTheta)) * rcp(pow((1.0 + gg - 2.0 * g * cosTheta), 3.0/2.0));
  	float phase = p1 * p2;
        phase  /= 8.0;
  	return max(phase, 0.0);
}