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

vec3 projectSphere(vec2 uv) {
    uv  *= vec2(tau, pi);
    vec2 lon = sincos(uv.x) * sin(uv.y);
    return vec3(lon.x, cos(uv.y), lon.y);
}
vec2 unprojectSphere(vec3 dir) {
    vec2 lonlat     = vec2(atan(-dir.x, -dir.z), acos(dir.y));
    return lonlat * vec2(rcp(tau), rpi) + vec2(0.5, 0.0);
}