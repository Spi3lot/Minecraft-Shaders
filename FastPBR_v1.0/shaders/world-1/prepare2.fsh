#version 430

/* RENDERTARGETS: 0,5 */
layout(location = 0) out vec3 sceneColor;
layout(location = 1) out vec4 Out5;

#define RSSBO_ENABLE_COLOR
#include "/lib/head.glsl"

in vec2 uv;

uniform sampler2D colortex3, colortex5;

uniform sampler2D noisetex;

uniform int worldTime;

uniform float wetness;

uniform vec2 taaOffset;

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
    vec3 position   = vec3(uv / ResolutionScale, 1.0);
        position    = screenToViewSpace(position);
        position    = viewToSceneSpace(position);

    vec3 direction  = normalize(position);

    sceneColor      = RColorTable.Skylight * rpi;

    Out5 = vec4(0);
}