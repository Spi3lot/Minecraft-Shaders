layout(location = 0) out vec4 color;

/* DRAWBUFFERS:0 */

#include "/lib/universal/universal.glsl"

uniform mat4 gbufferModelViewInverse;

uniform vec3 fogColor;
uniform vec3 skyColor;

uniform ivec2 eyeBrightnessSmooth, eyeBrightness;

uniform int isEyeInWater;

in vec3 viewPosition;

void main() {
    float cosTheta = exp(-dot(vec3(0, 1, 0), fNormalize(mat3(gbufferModelViewInverse) * viewPosition)));
    vec3 colorSky = mix(fogColor*1.8, skyColor, saturate(1.0 - pow(cosTheta, 4.0)));
		 colorSky = mix(fogColor*1.8*clamp(eyeBrightnessSmooth.y/100.0, 0.1, 1.0), colorSky, eyeBrightnessSmooth.y / 255.0);

    color.rgb = colorSky;

    if(isEyeInWater == 1) {
        color.rgb *= dot(skyColor, vec3(0.25));
    }
    color.rgb = srgbToLinear(color.rgb) / pi;
    color.a   = 1.0;
}