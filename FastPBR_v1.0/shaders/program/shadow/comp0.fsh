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

layout(location = 0) out vec4 data0;

#include "/lib/head.glsl"

#define gSHADOW

in vec2 uv;

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;

uniform mat4 shadowModelView, shadowProjection;
uniform mat4 shadowModelViewInverse, shadowProjectionInverse;

#include "/lib/light/warp.glsl"

vec3 shadowScreenToView(vec3 position, float warp) {
    position    = position * 2.0 - 1.0;
    position.z /= 0.2;
    position.xy *= warp;
    position    = projMAD(inverse(shadowProjection), position);

    return position;
}
vec3 shadowViewToScene(vec3 position) {
    position     = transMAD(inverse(shadowModelView), position);

    return position;
}

#include "/lib/atmos/waterConst.glsl"

vec3 getWaterExtinction(vec3 color, float dist, vec3 tint){
	    dist 	= dist * waterDensity;
		dist 	= max((dist), 0.0);

    color  *= exp(-dist * waterAttenCoeff);

	return color;
}

void main() {
    vec4 albedo     = texture(shadowcolor0, uv);

    vec2 depth      = vec2(texture(shadowtex0, uv).x, texture(shadowtex1, uv).x);

    data0           = vec4(vec3(1.0), 0.0);

    if (depth.x < depth.y) {
        data0 = albedo;

        if (texture(shadowcolor1, uv).x > 0.5) {
            float warp      = calculateWarp(uv * 2.0 - 1.0);

            vec3 viewPos0   = shadowScreenToView(vec3(uv, depth.x), warp);
            vec3 scenePos0  = shadowViewToScene(viewPos0);
            vec3 viewPos1   = shadowScreenToView(vec3(uv, depth.y), warp);
            vec3 scenePos1  = shadowViewToScene(viewPos1);
            float surfaceDist = distance(scenePos0, scenePos1);

            vec3 tintCoeff  = normalize(max(data0.rgb, 1e-3));

            data0.rgb   = getWaterExtinction(vec3(1.0), surfaceDist, tintCoeff);
            data0.a     = 1.0;
        }
    }
}