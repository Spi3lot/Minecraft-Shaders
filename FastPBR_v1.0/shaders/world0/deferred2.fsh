#version 430

/* RENDERTARGETS: 0,5 */
layout(location = 0) out vec3 sceneColor;
layout(location = 1) out vec4 Out5;

#include "/lib/head.glsl"
#include "/lib/util/encoders.glsl"

in vec2 uv;

uniform sampler2D colortex0, colortex5, colortex6;
uniform sampler2D depthtex0;

#include "/lib/util/bicubic.glsl"

vec3 UnpackAlbedo(vec4 data){
    vec3 albedo     = decodeRGBE8(vec4(unpack2x8(data.z), unpack2x8(data.w)));

    return saturate(albedo);
}
vec3 UnpackDirectLight(vec4 data){
    vec3 albedo     = decodeRGBE8(vec4(unpack2x8(data.x), unpack2x8(data.y)));

    return max0(albedo);
}

void main() {
    sceneColor      = texture(colortex0, uv).rgb;

    bool IsTerrain  = landMask(stex(depthtex0).x);

    if (IsTerrain) {
        vec4 Tex6 = texture(colortex6, uv);
        vec3 Albedo = UnpackAlbedo(Tex6);
        vec3 DirectLight = UnpackDirectLight(Tex6) * Albedo;

        DirectLight = saturate(DirectLight / (sceneColor + 1e-4));
        //sceneColor = vec3(1);
        sceneColor *= mix(vec3(textureBicubic(colortex5, uv * 0.5).a), vec3(1.0), DirectLight * 0.75);
        sceneColor += textureBicubic(colortex5, uv * 0.5).rgb * Albedo;

        //sceneColor = vec3(textureBicubic(colortex5, uv * 0.5).rgb);

        //sceneColor = DirectLight;
    }

    Out5 = vec4(0,0,0,0);
}