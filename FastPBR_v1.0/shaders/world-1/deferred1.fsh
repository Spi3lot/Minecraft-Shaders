#version 430

/* RENDERTARGETS: 0,5,7,10 */
layout(location = 0) out vec3 sceneColor;
layout(location = 1) out vec4 Out5;
layout(location = 2) out vec4 Out7;
layout(location = 3) out vec4 Out10;

#include "/lib/head.glsl"

in vec2 uv;

uniform sampler2D colortex0, colortex12, colortex13;
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

void main() {
    sceneColor      = texture(colortex0, uv).rgb;

    Out5 = vec4(0,0,0,0);

    Out7 = texture(colortex12, uv);
    Out10 = texture(colortex13, uv);
}