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

/* RENDERTARGETS: 0,5,11 */
layout(location = 0) out vec3 SceneColor;
layout(location = 1) out vec3 MinColor;
layout(location = 2) out vec3 MaxColor;

#include "/lib/head.glsl"

in vec2 uv;

uniform vec2 viewSize, taaOffset;

uniform sampler2D colortex0, colortex2;

/*
    Neighbourhood Clipping based on BSL Shaders
*/

vec2 neighbourhoodOffsets[8] = vec2[8](
	vec2( 0.0, -1.0),
	vec2(-1.0,  0.0),
	vec2( 1.0,  0.0),
	vec2( 0.0,  1.0),
	vec2(-1.0, -1.0),
	vec2( 1.0, -1.0),
	vec2(-1.0,  1.0),
	vec2( 1.0,  1.0)
);

vec3 RGB_To_YCC(vec3 Color) {
	return vec3(
		Color.r * 0.25 + Color.g * 0.5 + Color.b * 0.25,
		Color.r * 0.5 - Color.b * 0.5,
		Color.r * -0.25 + Color.g * 0.5 + Color.b * -0.25
	);
}

vec3 YCC_To_RGB(vec3 Color) {
	float n = Color.r - Color.b;
	return clamp16F(vec3(n + Color.g, Color.r + Color.b, n - Color.g));
}

ivec2 ClampToViewport(ivec2 UV) {
    return clamp(UV, ivec2(0), ivec2(viewSize * ResolutionScale));
}

vec3 Reinhard(vec3 HDR){
	return HDR / (1.0 + getLuma(HDR));
}
vec3 InverseReinhard(vec3 SDR){
	return SDR / max(1.0 - getLuma(SDR), 1e-10);
}

void GatherNeighbourhoodLimits(inout vec3 MinColor, inout vec3 MaxColor) {
    float Exposure = max(texture(colortex2, vec2(0.0)).a, 1e-8);

    MinColor = vec3(99999);
    MaxColor = vec3(-99999);

    vec3 SoftMinColor = vec3(99999);
    vec3 SoftMaxColor = vec3(-99999);

    const int Radius = 1;

    vec3 MeanColor = vec3(0.0);
    vec3 MeanSqrColor = vec3(0.0);

	for(int x = -Radius; x <= Radius; ++x) {
        for (int y = -Radius; y <= Radius; ++y) {
            ivec2 Pixel     = ivec2(gl_FragCoord.xy) + ivec2(x, y);

            if (ClampToViewport(Pixel) != Pixel) continue;

            vec3 Sample = texelFetch(colortex0, Pixel, 0).rgb;
                //Sample  = Reinhard(Sample * Exposure);
                Sample  = RGB_To_YCC(Sample);
                MinColor = min(MinColor, Sample);
                MaxColor = max(MaxColor, Sample);

                MeanColor += Sample;
                MeanSqrColor += sqr(Sample);

            if (x == 0 || y == 0) {
                SoftMinColor = min(MinColor, Sample);
                SoftMaxColor = max(MaxColor, Sample);
            }
        }
	}

    MeanColor /= 9.0; MeanSqrColor /= 9.0;

    MinColor = mix(MinColor, SoftMinColor, 0.5);
    MaxColor = mix(MaxColor, SoftMaxColor, 0.5);

    vec3 Variance = sqrt(MeanSqrColor - sqr(MeanColor));

    MinColor = max(MinColor, MeanColor - 1.25 * Variance);
    MaxColor = min(MaxColor, MeanColor + 1.25 * Variance);
}

void main() {
    SceneColor  = texelFetch(colortex0, ivec2(gl_FragCoord.xy), 0).rgb;

    float Exposure = max(texture(colortex2, vec2(0.0)).a, 1e-8);
    SceneColor  = Reinhard(SceneColor.rgb * Exposure);

    GatherNeighbourhoodLimits(MinColor, MaxColor);

    MinColor.rgb = clamp16FN(MinColor.rgb);
    MaxColor.rgb = clamp16FN(MaxColor.rgb);
}