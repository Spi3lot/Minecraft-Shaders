#define sunIllumMult 1.0    //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define moonIllumMult 1.0   //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

#define airRayleighMult 1.0 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.2 2.4 2.6 2.8 3.0 3.5 4.0 4.5 5.0]
#define airMieMult 1.0      //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.2 2.4 2.6 2.8 3.0 3.5 4.0 4.5 5.0]
#define airOzoneMult 1.0    //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.2 2.4 2.6 2.8 3.0 3.5 4.0 4.5 5.0]

//#define alternateOzoneDistribution

const float planetRad   = 6371e3;
const float atmosDepth  = 110e3;
const float atmosRad    = planetRad + atmosDepth;

const float ozonePeakAlt = 3e4;
const float ozoneFalloff = 6e3;
const float rOzoneFalloff = 1.0 / ozoneFalloff;
const float ozoneFalloffTop = 18e3;
const float rOzoneFalloffTop = 1.0 / ozoneFalloffTop;

const float airMieG         = 0.82;

const vec3 airRayleighCoeff = vec3(7.86356559e-06, 1.141e-05, 3.15e-05) * airRayleighMult * vec3(rayleighRedMult, rayleighGreenMult, rayleighBlueMult);   //628 574 466
const vec3 airMieCoeff      = vec3(8.8e-6) * airMieMult * vec3(mieRedMult, mieGreenMult, mieBlueMult);
const vec3 airOzoneCoeff    = vec3(2.7397388e-07, 3.19e-07, 4.62066377e-08) * airOzoneMult * 2.4 * vec3(ozoneRedMult, ozoneGreenMult, ozoneBlueMult);

const vec2 scaleHeight      = vec2(9.0e3, 2.25e3);
const vec2 rScaleHeight     = 1.0 / scaleHeight;
const vec2 planetScale      = planetRad * rScaleHeight;

const vec2 illuminanceFalloff = vec2(16e3, 2e3) * tau;

const vec3 sunIllum         = vec3(1.0, 0.975, 0.955) * 32.0 * sunIllumMult * vec3(sunlightRedMult, sunlightGreenMult, sunlightBlueMult);
const vec3 moonIllum        = vec3(0.8, 0.85, 1.0) * 0.05 * moonIllumMult * vec3(moonlightRedMult, moonlightGreenMult, moonlightBlueMult);

const mat2x3 airScatterMat  = mat2x3(airRayleighCoeff, airMieCoeff);
const mat3x3 airExtinctMat  = mat3x3(airRayleighCoeff, airMieCoeff * 1.11, airOzoneCoeff);

const mat2x3 fogScatterMat  = mat2x3(airRayleighCoeff, airMieCoeff);
const mat2x3 fogExtinctMat  = mat2x3(airRayleighCoeff, airMieCoeff * 1.1);

const vec2 fogFalloffScale  = 1.0 / vec2(8e1, 4e1);
const vec2 fogAirScale      = vec2(6e1, 4e1);