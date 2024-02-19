layout(location = 0) out vec3 color;

/*
    const int colortex0Format = RGBA16F;
    const int colortex2Format = RGBA16F;
    const int gaux1Format = RGBA16F;
    const int gaux2Format = RGBA16F;
    const int gaux3Format = RGBA16F;
    const int gaux4Format = RGBA16F;
*/

#include "/lib/universal/universal.glsl"

uniform sampler2D colortex0;
uniform sampler2D gaux1;
uniform sampler2D gaux2;
uniform sampler2D gaux3;
uniform sampler2D gaux4;
uniform sampler2D shadowtex0;

in vec2 textureCoordinate;

#include "/lib/fragment/dither/bayer.glsl"

vec3 vibrance(in vec3 color) {
    float lum = dot(color, lumacoeff_rec709);
    vec3 mask = (color - vec3(lum));
    mask = clamp(mask, 0.0, 1.0);
    float lum_mask = dot(lumacoeff_rec709, mask);
    lum_mask = 1.0 - lum_mask;
    return mix(vec3(lum), color, (1.0 + 0.1) * lum_mask);
}

const float overlapRG = 0.15;
const float overlapRB = 0.02;
const float overlapGB = 0.05;
const mat3 m = mat3(
    1.0 - overlapRG - overlapRB, overlapRG, overlapRB,
    overlapRG, 1.0 - overlapRG - overlapGB, overlapGB,
    overlapRB, overlapGB, 1.0 - overlapRB - overlapGB
);

void main() {
    color = texture(colortex0, textureCoordinate).rgb;
    color = inverse(m) * (color * m);
    color = 1.0 - exp(-color * 1.75);
	color = vibrance(color);
	color = linearToSrgb(color);

    color += bayer128(gl_FragCoord.st)/128.0;

    //color = vec3(texture(gaux1, textureCoordinate).rgb);
}