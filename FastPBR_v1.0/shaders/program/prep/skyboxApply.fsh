/* RENDERTARGETS: 0,5 */
layout(location = 0) out vec3 sceneColor;
layout(location = 1) out vec4 Out5;

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

vec3 skyStars(vec3 worldDir) {
    vec3 plane  = worldDir/(worldDir.y+length(worldDir.xz)*0.66);
    float rot   = worldTime*rcp(2400.0);
    plane.x    += rot*0.6;
    plane.yz    = rotatePos(plane.yz, (25.0/180.0)*pi);
    vec2 uv1    = floor((plane.xz)*768)/768;
    vec2 uv2    = (plane.xz)*0.04;

    vec3 starcol = vec3(0.3, 0.78, 1.0);
        starcol  = mix(starcol, vec3(1.0, 0.7, 0.6), Noise2D(uv2).x);
        starcol  = normalize(starcol)*(Noise2D(uv2*1.5).x+1.0);

    float star  = 1.0;
        star   *= Noise2D(uv1).x;
        star   *= Noise2D(uv1+0.1).x;
        star   *= Noise2D(uv1+0.26).x;

    star        = max(star-0.25, 0.0);
    star        = saturate(star*4.0);

    return star*starcol*0.25*sqrt(daytime.w);
}

vec3 sunDisk(vec3 worldDir) {
    float sun   = 1.0 - dot(sunDir, worldDir);

    const float size = 0.0006;
    float maxsize = size * 1.2;
        maxsize  += linStep(sunDir.y, -0.04, 0.04) * size * 0.3;

    float s   = 1.0-linStep(sun, size, maxsize);
        //s    *= 1.0-sstep(sun, 0.004, 0.0059)*0.5;

    float limb = 1.0 - cube(linStep(sun, 0.0, maxsize))*0.8;
        s    *= limb;

    return s * sunIllum * 5e1 * sstep(worldDir.y, 0.0, 0.01);
}

void main() {
    vec3 position   = vec3(uv / ResolutionScale, 1.0);
        position    = screenToViewSpace(position);
        position    = viewToSceneSpace(position);

    vec3 direction  = normalize(position);

    vec3 Transmittance = textureBicubic(colortex3, projectSky(direction, 1)).rgb;

    sceneColor      = texture(colortex3, projectSky(direction, 0)).rgb;
    if (direction.y > -0.1) sceneColor += skyStars(direction) * sstep(direction.y, -0.1, 0.0) * (1 - wetness) * Transmittance;
    sceneColor     += sunDisk(direction) * Transmittance;

    //vec4 Clouds = textureBicubic(colortex5, uv * 1.0);

    //sceneColor = (sceneColor.rgb * Clouds.a) + Clouds.rgb;

    //sceneColor  = texture(colortex3, uv).rgb;

    Out5 = vec4(0);
}