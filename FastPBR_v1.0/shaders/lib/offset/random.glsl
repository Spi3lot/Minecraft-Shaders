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

/*
    This offset thing is from spectrum as well, and zombye has it from here:
    http://extremelearning.com.au/unreasonable-effectiveness-of-quasirandom-sequences/
*/
vec2 R2(float n) {
	const float s0 = 0.5;
	const vec2 alpha = 1.0 / vec2(rho, rho * rho);
	return fract(s0 + n * alpha);
}