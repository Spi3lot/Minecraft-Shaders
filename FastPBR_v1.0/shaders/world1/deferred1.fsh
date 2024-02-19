#version 430

/* RENDERTARGETS: 0,5,7,10 */
layout(location = 0) out vec3 sceneColor;
layout(location = 1) out vec4 Out5;
layout(location = 2) out vec4 Out7;
layout(location = 3) out vec4 Out10;

#include "/lib/head.glsl"

in vec2 uv;

uniform sampler2D colortex0, colortex5, colortex12, colortex13;
uniform sampler2D depthtex0;

uniform sampler2D noisetex;

uniform int worldTime;

uniform float wetness;

uniform vec2 taaOffset, pixelSize;

uniform vec3 sunDir, sunDirView;

uniform vec4 daytime;

uniform mat4 gbufferProjectionInverse, gbufferModelViewInverse;
uniform mat4 gbufferProjection, gbufferModelView;

#define FUTIL_ROT2
#include "/lib/fUtil.glsl"

#include "/lib/util/bicubic.glsl"
#include "/lib/util/transforms.glsl"
#include "/lib/atmos/air/const.glsl"
#include "/lib/atmos/project.glsl"

#include "/lib/frag/noise.glsl"

vec4 TextureCatmullRom(sampler2D tex, vec2 uv) {
    vec2 res    = textureSize(tex, 0);

    vec2 coord  = uv*res;
    vec2 coord1 = floor(coord - 0.5) + 0.5;

    vec2 f      = coord-coord1;

    vec2 w0     = f * (-0.5 + f * (1.0 - (0.5 * f)));
    vec2 w1     = 1.0 + sqr(f) * (-2.5 + (1.5 * f));
    vec2 w2     = f * (0.5 + f * (2.0 - (1.5 * f)));
    vec2 w3     = sqr(f) * (-0.5 + (0.5 * f));

    vec2 w12    = w1+w2;
    vec2 delta12 = w2 * rcp(w12);

    vec2 uv0    = (coord1 - vec2(1.0)) / res;
    vec2 uv3    = (coord1 + vec2(1.0)) / res;
    vec2 uv12   = (coord1 + delta12) / res;

    vec4 col    = vec4(0.0);
        col    += textureLod(tex, vec2(uv0.x, uv0.y), 0)*w0.x*w0.y;
        col    += textureLod(tex, vec2(uv12.x, uv0.y), 0)*w12.x*w0.y;
        col    += textureLod(tex, vec2(uv3.x, uv0.y), 0)*w3.x*w0.y;

        col    += textureLod(tex, vec2(uv0.x, uv12.y), 0)*w0.x*w12.y;
        col    += textureLod(tex, vec2(uv12.x, uv12.y), 0)*w12.x*w12.y;
        col    += textureLod(tex, vec2(uv3.x, uv12.y), 0)*w3.x*w12.y;

        col    += textureLod(tex, vec2(uv0.x, uv3.y), 0)*w0.x*w3.y;
        col    += textureLod(tex, vec2(uv12.x, uv3.y), 0)*w12.x*w3.y;
        col    += textureLod(tex, vec2(uv3.x, uv3.y), 0)*w3.x*w3.y;

    return clamp(col, 0.0, 65535.0);
}

void main() {
    sceneColor      = texture(colortex0, uv).rgb;

    bool IsSky  = !landMask(stex(depthtex0).x);

    if (IsSky) {
        vec4 Clouds = TextureCatmullRom(colortex5, uv * 0.5 / ResolutionScale);

        sceneColor = clamp16F((sceneColor.rgb * Clouds.a) + Clouds.rgb);
    }

    //sceneColor = stex(colortex9).rgb;
    Out5 = vec4(0,0,0,0);

    Out7 = texture(colortex12, uv);
    Out10 = texture(colortex13, uv);
}