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

const mat3 CT_XYZ_AP1 = mat3(
	 1.6410233797, -0.3248032942, -0.2364246952,
	-0.6636628587,  1.6153315917,  0.0167563477,
	 0.0117218943, -0.0082844420,  0.9883948585
);
const mat3 CT_XYZ_sRGB = mat3(
	 3.2409699419, -1.5373831776, -0.4986107603,
	-0.9692436363,  1.8759675015,  0.0415550574,
	 0.0556300797, -0.2039769589,  1.0569715142
);

const mat3 CT_sRGB_XYZ = mat3(
	0.4124564, 0.3575761, 0.1804375,
	0.2126729, 0.7151522, 0.0721750,
	0.0193339, 0.1191920, 0.9503041
);
const mat3 CT_XYZ_2020 = mat3(
	 1.7166084, -0.3556621, -0.2533601,
	-0.6666829,  1.6164776,  0.0157685,
	 0.0176422, -0.0427763,  0.94222867	
);

const mat3 CT_sRGB_2020 = (CT_sRGB_XYZ) * CT_XYZ_2020;

const vec3 lumacoeffRec709  = vec3(0.2125, 0.7154, 0.0721);
const vec3 lumacoeffRec2020 = vec3(0.2627066, 0.6779996, 0.0592938);
const vec3 lumacoeffAP1     = vec3(0.2722287168, 0.6740817658, 0.0536895174);

const float pi      = radians(180.0);
const float sqrPi   = pi * pi;
const float halfPi  = pi / 2.0;
const float rpi     = 1.0 / pi;
const float pi4     = pi * 4.0;
const float tau     = radians(360.0);
const float phi     = sqrt(5.0) * 0.5 + 0.5;
const float goldenAngle = tau / phi / pi;
const float goldenRatio = (1.0 + sqrt(5.0)) / 2.0;
const float rLog2   = 1.0/log(2.0);
const float rLog10  = 1.0 / log(10.0);
const float sqrt2   = sqrt(2.0);
const float sqrt3   = sqrt(3.0);
const float euler   = 2.718281828459045;                    // euler's number
const float rho     = 1.32471795724474602596090885447809;   // plastic constant
const vec4 torroidalShift = vec4(goldenRatio, rho, sqrt2, sqrt3);

const float sunPathRotation     = -30.0;    //[-90.0 -80.0 -70.0 -60.0 -50.0 -40.0 -35.0 -30.0 -25.0 -20.0 -15.0 -10.0 -5.0 0.0 5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 50.0 60.0 70.0 80.0 90.0]

const float wetnessHalflife = 260.0;
const float drynessHalflife = 100.0;
const float eyeBrightnessHalflife = 5.0;
