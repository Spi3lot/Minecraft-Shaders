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



vec4 textureBicubic(sampler2D sampler, vec2 uv) {
	vec2 res = textureSize(sampler, 0);

	uv = uv * res - 0.5;

	vec2 f = fract(uv);
	uv -= f;

	vec2 ff = f * f;
	vec4 w0;
	vec4 w1;
	w0.xz = 1 - f; w0.xz *= w0.xz * w0.xz;
	w1.yw = ff * f;
	w1.xz = 3 * w1.yw + 4 - 6 * ff;
	w0.yw = 6 - w1.xz - w1.yw - w0.xz;

	vec4 s = w0 + w1;
	vec4 c = uv.xxyy + vec2(-0.5, 1.5).xyxy + w1 / s;
	c /= res.xxyy;

	vec2 m = s.xz / (s.xz + s.yw);
	return mix(
		mix(textureLod(sampler, c.yw, 0), textureLod(sampler, c.xw, 0), m.x),
		mix(textureLod(sampler, c.yz, 0), textureLod(sampler, c.xz, 0), m.x),
		m.y);
}

vec4 textureBicubicLod(sampler2D sampler, vec2 uv, int lod) {
	vec2 res = textureSize(sampler, lod);

	uv = uv * res - 0.5;

	vec2 f = fract(uv);
	uv -= f;

	vec2 ff = f * f;
	vec4 w0;
	vec4 w1;
	w0.xz = 1 - f; w0.xz *= w0.xz * w0.xz;
	w1.yw = ff * f;
	w1.xz = 3 * w1.yw + 4 - 6 * ff;
	w0.yw = 6 - w1.xz - w1.yw - w0.xz;

	vec4 s = w0 + w1;
	vec4 c = uv.xxyy + vec2(-0.5, 1.5).xyxy + w1 / s;
	c /= res.xxyy;

	vec2 m = s.xz / (s.xz + s.yw);
	return mix(
		mix(textureLod(sampler, c.yw, lod), textureLod(sampler, c.xw, lod), m.x),
		mix(textureLod(sampler, c.yz, lod), textureLod(sampler, c.xz, lod), m.x),
		m.y);
}