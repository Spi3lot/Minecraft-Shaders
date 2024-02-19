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

vec3 toLinear(vec3 x){
    vec3 temp = mix(x / 12.92, pow(.947867 * x + .0521327, vec3(2.4)), step(0.04045, x));
    return max(temp, 0.0);
}

vec3 LinearToSRGB(vec3 x){
    return mix(x * 12.92, clamp16F(pow(x, vec3(1./2.4)) * 1.055 - 0.055), step(0.0031308, x));
}

const mat3 CM_sRGB_XYZ = mat3(
	0.4124564, 0.3575761, 0.1804375,
	0.2126729, 0.7151522, 0.0721750,
	0.0193339, 0.1191920, 0.9503041
);

const mat3 CM_XYZ_sRGB = mat3(
	 3.2409699419, -1.5373831776, -0.4986107603,
	-0.9692436363,  1.8759675015,  0.0415550574,
	 0.0556300797, -0.2039769589,  1.0569715142
);

// Rec2020
const mat3 CM_XYZ_2020 = mat3(
	 1.7166084, -0.3556621, -0.2533601,
	-0.6666829,  1.6164776,  0.0157685,
	 0.0176422, -0.0427763,  0.94222867	
);
const mat3 CM_2020_XYZ = mat3(
	0.6369736, 0.1446172, 0.1688585,
	0.2627066, 0.6779996, 0.0592938,
	0.0000000, 0.0280728, 1.0608437
);

const mat3 CM_sRGB_2020 = (CM_sRGB_XYZ) * CM_XYZ_2020;

const mat3 CM_2020_sRGB = (CM_2020_XYZ) * CM_XYZ_sRGB;

vec3 LinearToRec2020(in vec3 x) {
    return x * CM_sRGB_2020;
}

void convertToPipelineColor(inout vec3 x) {
    x   = toLinear(x) * CM_sRGB_2020;
    return;
}
void convertToPipelineAlbedo(inout vec3 x) {
    x   = toLinear(x) * CM_sRGB_2020;
    return;
}
void convertToDisplayColor(inout vec3 x) {
    x   = LinearToSRGB(x * CM_2020_sRGB);
    return;
}
