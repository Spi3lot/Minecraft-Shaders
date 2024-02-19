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


const vec2 scaleFactor  = vec2(256.0 / 254.0, 128.0 / 126.0);


vec2 projectSky(vec3 dir, int index) {
        dir.y       = sqrt(saturate(abs(dir.y))) * sign(dir.y);

    vec2 lonlat     = vec2(atan(-dir.x, -dir.z), acos(-dir.y));
        lonlat      = lonlat * vec2(rcp(tau), rpi) + vec2(0.5, 0.0);

    vec2 paddedUV   = (lonlat - 0.5) / scaleFactor;
        paddedUV    = (paddedUV + 0.5);

    return paddedUV / vec2(1.0, 3.0) + vec2(0.0, float(index) / 3.0);
}
vec3 unprojectSky(vec2 uv) {
        uv   = (uv - 0.5) * scaleFactor;
        uv   = (uv + 0.5);
        uv  *= vec2(tau, pi);
    vec2 lon = sincos(uv.x) * sin(uv.y);

    vec3 direction = vec3(lon.x, -cos(uv.y), lon.y);
        direction.y = sqr(saturate(abs(direction.y))) * sign(direction.y);

    return direction;
}