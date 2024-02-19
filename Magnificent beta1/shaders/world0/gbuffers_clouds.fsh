#version 400

layout(location = 0) out vec4 color;

/* DRAWBUFFERS:0 */

#include "/lib/universal/universal.glsl"

uniform sampler2D colortex0;

uniform mat4 gbufferModelViewInverse;

uniform vec3 fogColor;
uniform vec3 skyColor;

in vec3 viewPosition;
in vec2 textureCoordinate;

void main() {
    float cosTheta = exp(-dot(vec3(0, 1, 0), fNormalize(mat3(gbufferModelViewInverse) * viewPosition)));
    float cloudsBlend = saturate(square(dot(vec3(0, 1, 0), fNormalize(mat3(gbufferModelViewInverse) * viewPosition))));
    color.rgb = mix(fogColor*1.8, skyColor, saturate(1.0 - pow(cosTheta, 4.0)));
    color.rgb = mix(color.rgb, fogColor*texture(colortex0, textureCoordinate).rgb * 3.0, saturate(pow(cloudsBlend, 2.0) * 6.0));
    color.rgb = srgbToLinear(color.rgb) / pi;
    color.a   = mix(texture(colortex0, textureCoordinate).a, 0.0, 0.7);
}