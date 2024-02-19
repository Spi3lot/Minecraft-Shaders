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
const vec3 waterExtinctionCoeff     = vec3(8e-2, 4e-2, 4e-2);
const vec3 waterScatterCoeff        = vec3(3e-2);*/
/*
const vec3 waterExtinctionCoeff     = vec3(8e-2, 5e-2, 3e-2);
const vec3 waterScatterCoeff        = vec3(3e-2);
*/

#define waterCoeffRed 10         //[1 2 3 4 5 6 7 8 9 10]
#define waterCoeffGreen 3       //[1 2 3 4 5 6 7 8 9 10]
#define waterCoeffBlue 2        //[1 2 3 4 5 6 7 8 9 10]
#define waterCoeffScatter 3     //[1 2 3 4 5 6 7 8 9 10]

const vec3 waterExtinctionCoeff     = vec3(waterCoeffRed, waterCoeffGreen, waterCoeffBlue) * 1e-2;
const vec3 waterScatterCoeff        = vec3(waterCoeffScatter) * 1e-2;

const vec3 waterAttenCoeff          = (waterExtinctionCoeff + waterScatterCoeff) * 4.0;
const vec3 waterAbsorbCoeff         = (waterExtinctionCoeff + waterScatterCoeff);