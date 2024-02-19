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

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 SceneColor;

#include "/lib/head.glsl"

in vec2 uv;

uniform vec2 pixelSize, viewSize, taaOffset;

uniform sampler2D colortex0, colortex5, colortex2;

#define COLOR_SAMPLER colortex0

/*
    FXAA Implementation from BSL Shaders by Capt Tatsu
*/

//FXAA 3.11 from http://blog.simonrodriguez.fr/articles/30-07-2016_implementing_fxaa.html
float quality[12] = float[12] (1.0, 1.0, 1.0, 1.0, 1.0, 1.5, 2.0, 2.0, 2.0, 2.0, 4.0, 8.0);

vec3 FXAA311(vec3 color) {
	float edgeThresholdMin = 0.03125;
	float edgeThresholdMax = 0.125;
	float subpixelQuality = 0.41;
	int iterations = 8;
	
	//vec2 pixelSize = 1.0 / viewSize;
	
	float lumaCenter = getLuma(color);
	float lumaDown  = getLuma(textureLod(COLOR_SAMPLER, uv + vec2( 0.0, -1.0) * pixelSize, 0.0).rgb);
	float lumaUp    = getLuma(textureLod(COLOR_SAMPLER, uv + vec2( 0.0,  1.0) * pixelSize, 0.0).rgb);
	float lumaLeft  = getLuma(textureLod(COLOR_SAMPLER, uv + vec2(-1.0,  0.0) * pixelSize, 0.0).rgb);
	float lumaRight = getLuma(textureLod(COLOR_SAMPLER, uv + vec2( 1.0,  0.0) * pixelSize, 0.0).rgb);
	
	float lumaMin = min(lumaCenter, min(min(lumaDown, lumaUp), min(lumaLeft, lumaRight)));
	float lumaMax = max(lumaCenter, max(max(lumaDown, lumaUp), max(lumaLeft, lumaRight)));
	
	float lumaRange = lumaMax - lumaMin;
	
	//if (lumaRange > max(edgeThresholdMin, lumaMax * edgeThresholdMax)) {  //No Threshold applied
		float lumaDownLeft  = getLuma(textureLod(COLOR_SAMPLER, uv + vec2(-1.0, -1.0) * pixelSize, 0.0).rgb);
		float lumaUpRight   = getLuma(textureLod(COLOR_SAMPLER, uv + vec2( 1.0,  1.0) * pixelSize, 0.0).rgb);
		float lumaUpLeft    = getLuma(textureLod(COLOR_SAMPLER, uv + vec2(-1.0,  1.0) * pixelSize, 0.0).rgb);
		float lumaDownRight = getLuma(textureLod(COLOR_SAMPLER, uv + vec2( 1.0, -1.0) * pixelSize, 0.0).rgb);
		
		float lumaDownUp    = lumaDown + lumaUp;
		float lumaLeftRight = lumaLeft + lumaRight;
		
		float lumaLeftCorners  = lumaDownLeft  + lumaUpLeft;
		float lumaDownCorners  = lumaDownLeft  + lumaDownRight;
		float lumaRightCorners = lumaDownRight + lumaUpRight;
		float lumaUpCorners    = lumaUpRight   + lumaUpLeft;
		
		float edgeHorizontal = abs(-2.0 * lumaLeft   + lumaLeftCorners ) +
							   abs(-2.0 * lumaCenter + lumaDownUp      ) * 2.0 +
							   abs(-2.0 * lumaRight  + lumaRightCorners);
		float edgeVertical   = abs(-2.0 * lumaUp     + lumaUpCorners   ) +
							   abs(-2.0 * lumaCenter + lumaLeftRight   ) * 2.0 +
							   abs(-2.0 * lumaDown   + lumaDownCorners );
		
		bool isHorizontal = (edgeHorizontal >= edgeVertical);		
		
		float luma1 = isHorizontal ? lumaDown : lumaLeft;
		float luma2 = isHorizontal ? lumaUp : lumaRight;
		float gradient1 = luma1 - lumaCenter;
		float gradient2 = luma2 - lumaCenter;
		
		bool is1Steepest = abs(gradient1) >= abs(gradient2);
		float gradientScaled = 0.25 * max(abs(gradient1), abs(gradient2));
		
		float stepLength = isHorizontal ? pixelSize.y : pixelSize.x;

		float lumaLocalAverage = 0.0;

		if (is1Steepest) {
			stepLength = - stepLength;
			lumaLocalAverage = 0.5 * (luma1 + lumaCenter);
		} else {
			lumaLocalAverage = 0.5 * (luma2 + lumaCenter);
		}
		
		vec2 currentUv = uv;
		if (isHorizontal) {
			currentUv.y += stepLength * 0.5;
		} else {
			currentUv.x += stepLength * 0.5;
		}
		
		vec2 offset = isHorizontal ? vec2(pixelSize.x, 0.0) : vec2(0.0, pixelSize.y);
		
		vec2 uv1 = currentUv - offset;
		vec2 uv2 = currentUv + offset;

		float lumaEnd1 = getLuma(textureLod(COLOR_SAMPLER, uv1, 0.0).rgb);
		float lumaEnd2 = getLuma(textureLod(COLOR_SAMPLER, uv2, 0.0).rgb);
		lumaEnd1 -= lumaLocalAverage;
		lumaEnd2 -= lumaLocalAverage;
		
		bool reached1 = abs(lumaEnd1) >= gradientScaled;
		bool reached2 = abs(lumaEnd2) >= gradientScaled;
		bool reachedBoth = reached1 && reached2;
		
		if (!reached1) {
			uv1 -= offset;
		}
		if (!reached2) {
			uv2 += offset;
		}
		
		if (!reachedBoth) {
			for(int i = 2; i < iterations; i++) {
				if (!reached1) {
					lumaEnd1 = getLuma(textureLod(COLOR_SAMPLER, uv1, 0.0).rgb);
					lumaEnd1 = lumaEnd1 - lumaLocalAverage;
				}
				if (!reached2) {
					lumaEnd2 = getLuma(textureLod(COLOR_SAMPLER, uv2, 0.0).rgb);
					lumaEnd2 = lumaEnd2 - lumaLocalAverage;
				}
				
				reached1 = abs(lumaEnd1) >= gradientScaled;
				reached2 = abs(lumaEnd2) >= gradientScaled;
				reachedBoth = reached1 && reached2;

            /*
				if (!reached1) {
					uv1 -= offset * quality[i];
				}
				if (!reached2) {
					uv2 += offset * quality[i];
				}
            */
				if (!reached1) {
					uv1 -= offset;
				}
				if (!reached2) {
					uv2 += offset;
				}
				
				if (reachedBoth) break;
			}
		}
		
		float distance1 = isHorizontal ? (uv.x - uv1.x) : (uv.y - uv1.y);
		float distance2 = isHorizontal ? (uv2.x - uv.x) : (uv2.y - uv.y);

		bool isDirection1 = distance1 < distance2;
		float distanceFinal = min(distance1, distance2);

		float edgeThickness = (distance1 + distance2);

		float pixelOffset = - distanceFinal / edgeThickness + 0.5;
		
		bool isLumaCenterSmaller = lumaCenter < lumaLocalAverage;

		bool correctVariation = ((isDirection1 ? lumaEnd1 : lumaEnd2) < 0.0) != isLumaCenterSmaller;

		float finalOffset = correctVariation ? pixelOffset : 0.0;
		
		float lumaAverage = (1.0 / 12.0) * (2.0 * (lumaDownUp + lumaLeftRight) + lumaLeftCorners + lumaRightCorners);
		float subPixelOffset1 = clamp(abs(lumaAverage - lumaCenter) / lumaRange, 0.0, 1.0);
		float subPixelOffset2 = (-2.0 * subPixelOffset1 + 3.0) * subPixelOffset1 * subPixelOffset1;
		float subPixelOffsetFinal = subPixelOffset2 * subPixelOffset2 * subpixelQuality;

		finalOffset = max(finalOffset, subPixelOffsetFinal);
		
		
		// Compute the final UV coordinates.
		vec2 finalUv = uv;
		if (isHorizontal) {
			finalUv.y += finalOffset * stepLength;
		} else {
			finalUv.x += finalOffset * stepLength;
		}

		color = textureLod(COLOR_SAMPLER, finalUv, 0.0).rgb;
	//}

	return color;
}

vec3 Reinhard(vec3 HDR){
	return HDR / (1.0 + getLuma(HDR));
}
vec3 InverseReinhard(vec3 SDR){
	return SDR / max(1.0 - getLuma(SDR), 1e-10);
}

void main() {
    SceneColor   = textureLod(COLOR_SAMPLER, uv, 0);

    float exposure = max(texture(colortex2, vec2(0.0)).a, 1e-8);

    #ifdef TAAU_FXAA_PostPass
    SceneColor.rgb = FXAA311(SceneColor.rgb);
    #endif

    SceneColor.rgb = InverseReinhard(SceneColor.rgb) / exposure;
}