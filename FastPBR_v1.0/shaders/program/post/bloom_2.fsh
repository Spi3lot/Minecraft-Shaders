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

/* RENDERTARGETS: 5 */
layout(location = 0) out vec4 bloomData;

#include "/lib/head.glsl"

//bloom downsampling method based on chocapic13's shaders
//merge and upsample blurs

uniform sampler2D colortex5;
uniform sampler2D colortex4;

uniform vec2 bloomResolution;
uniform vec2 pixelSize;
uniform vec2 viewSize;

in vec2 uv;

#include "/lib/util/bicubic.glsl"

void main() {
	//if (clamp(uv, -0.003, 1.003) != uv) discard;
    vec2 tcoord     = (gl_FragCoord.xy*2.0+0.5)*pixelSize;
    vec2 rscale     = bloomResolution/max(viewSize, bloomResolution);
	bloomData       = vec4(vec3(0), texelFetch(colortex5, ivec2(gl_FragCoord.xy), 0).a);

    #ifdef bloomEnabled

	vec2 c 	= uv*max(viewSize, bloomResolution) * rcp(bloomResolution * 0.5);

	if (clamp(c, -pixelSize, 1.0 + pixelSize) == c) {
		bloomData.rgb  += textureBicubic(colortex5, (tcoord+vec2(0.0, 0.5))/2.0).rgb / 4.0;    //1:4

        bloomData.rgb  += textureBicubic(colortex5, tcoord/4.0).rgb / 4.0;    //1:8

        bloomData.rgb  += textureBicubic(colortex5, tcoord/8.0+vec2(0.25*rscale.x+2.0*pixelSize.x, 0.0)).rgb / 4.0;   //1:16

        bloomData.rgb  += textureBicubic(colortex5, tcoord/16.0+vec2(0.375*rscale.x+4.0*pixelSize.x, 0.0)).rgb / 4.0;   //1:32

        bloomData.rgb  += textureBicubic(colortex5, tcoord/32.0+vec2(0.4375*rscale.x+6.0*pixelSize.x, 0.0)).rgb / 4.0;   //1:64

        bloomData.rgb  += textureBicubic(colortex5, tcoord/64.0+vec2(0.46875*rscale.x+8.0*pixelSize.x, 0.0)).rgb / 4.0;   //1:128

        bloomData.rgb  += textureBicubic(colortex5, tcoord/128.0+vec2(0.484375*rscale.x+10.0*pixelSize.x, 0.0)).rgb / 4.0;   //1:256

		bloomData.rgb  /= 7.0;

		//blur 		= texture(colortex5, gl_FragCoord.xy*pixelSize).rgb;
	}

    bloomData   = clamp16F(bloomData);

    #endif
}