vec4 CalculateSphericalHarmonics(vec3 xyz) {
	const vec2 freqW = vec2(0.5 * sqrt(1.0 / pi), sqrt(3.0 / (4.0 * pi)));
	return vec4(freqW.x, freqW.y * xyz.yzx);
}

mat4x3 CalculateSphericalHarmonicCoefficients(vec3 value, vec3 xyz) {
	vec4 harmonics = CalculateSphericalHarmonics(xyz);
	return mat4x3(value * harmonics.x, value * harmonics.y, value * harmonics.z, value * harmonics.w);
}
/*
vec3 ValueFromSphericalHarmonicCoefficients(mat4x3 SH, vec3 xyz) {
	vec4 harmonics = CalculateSphericalHarmonics(xyz);
	return coefficients[0] * harmonics.x + coefficients[1] * harmonics.y + coefficients[2] * harmonics.z + coefficients[3] * harmonics.w;
}*/

mat3x4 ConvertIrradiance(vec3 Color, vec3 Direction) {
    /*
    float L00    = 0.282095;
    float L1_1   = 0.488603 * Direction.y;
    float L10    = 0.488603 * Direction.z;
    float L11    = 0.488603 * Direction.x;

    return mat3x4(vec4(L11, L1_1, L10, L00) * Color.r,
                  vec4(L11, L1_1, L10, L00) * Color.g,
                  vec4(L11, L1_1, L10, L00) * Color.b);
            */       



    return transpose(CalculateSphericalHarmonicCoefficients(Color, Direction));
}

vec3 ProjectIrradiance(mat3x4 SH, vec3 Direction) {
    /*
    vec2 A        = vec2(pi, 1.0 / 0.488603);

    float L00    = 0.282095;
    float L1_1   = 0.488603 * Direction.y;
    float L10    = 0.488603 * Direction.z;
    float L11    = 0.488603 * Direction.x;

    vec3 C00    = vec3(SH[0].w, SH[1].w, SH[2].w);
    vec3 C1_1   = vec3(SH[0].y, SH[1].y, SH[2].y);
    vec3 C10    = vec3(SH[0].z, SH[1].z, SH[2].z);
    vec3 C11    = vec3(SH[0].x, SH[1].x, SH[2].x);*/

    //return C00 * pi;

    //return A.x*L00*C00 + A.y*L1_1*C1_1 + A.y*L10*C10 + A.y*L11*C11;
    
	vec4 harmonics = CalculateSphericalHarmonics(Direction);
    mat4x3 coefficients = transpose(SH);
	return (coefficients[0] * harmonics.x + coefficients[1] * harmonics.y + coefficients[2] * harmonics.z + coefficients[3] * harmonics.w);
}