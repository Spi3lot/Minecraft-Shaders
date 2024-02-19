#include "/lib/time.glsl"

#define skyR 0.15 //[0.1 0.11 0.12 0.13 01.4 0.15 0.16 0.17 0.18 0.19 0.2 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.3 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.4 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.5 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.6 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.7 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.8 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.9 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.0]
#define skyG 0.27 //[0.1 0.11 0.12 0.13 01.4 0.15 0.16 0.17 0.18 0.19 0.2 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.3 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.4 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.5 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.6 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.7 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.8 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.9 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.0]
#define skyB 0.62 //[0.1 0.11 0.12 0.13 01.4 0.15 0.16 0.17 0.18 0.19 0.2 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.3 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.4 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.5 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.6 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.7 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.8 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.9 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.0]


/*
const int colortex5Format = R8;
const int colortex6Format = RGBA16F;
const bool colortex6Clear = false;
const int colortex7Format = RGB16;
const bool colortex7Clear = false;
const int colortex12Format = RGBA16F;
const bool colortex12Clear = false;
const int colortex3Format = RGBA16;
const int colortex0Format = RGB16;
const int colortex1Format = RGBA16_SNORM;
const int colortex15Format = RGBA8;
const int colortex4Format = RGBA16;
const int colortex9Format = RGBA16;
const int colortex10Format = RGBA16F;
const bool colortex1MipmapEnabled = true;
const bool colortex0MipmapEnabled = true;
const bool colortex9MipmapEnabled = true;
const bool colortex4MipmapEnabled = true;
const bool nosietexMipmapEnabled = true;
const int colortex2Format = RGB16;
const int shadowtex0Format = RGBA8;
const int shadowcolor0Format = RGB16F;
const int shadowcolor1Format = RGB8;
*/

//colortex5 = RTAO
//colortex6 = RTAO accumulation
//colortex7 = TAA
//colortex3 = ID
//colortex8  = LUTS
//colortex4 = clouds
//colortex15 = rain
//colortex11 = lens flare tex
//colortex12 = clouds temporal previous color
//colortex9 = sky
//colortex10 = specular data

uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex10;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform ivec2 eyeBrightnessSmooth;

uniform vec3 sunPosition;
uniform vec3 moonPosition;

uniform float frameTimeCounter;
uniform float viewWidth;
uniform float viewHeight;
uniform float rainStrength;

uniform int worldTime;

int blockID = int(texelFetch(colortex3, ivec2(gl_FragCoord.xy),0).b*65535);

bool waterMask = blockID == 8 || blockID == 9;
bool foliageMask = blockID == 1194;
bool iceMask = blockID == 1193;
bool particleMask = blockID == 1192;
bool glassMask = blockID == 1191;
bool lightMask = blockID == 1190;

const float PI = radians(180.);
const float TAU = 2*PI;
const float goldenRatio = 1.6180339;

const int noiseTextureResolution = 128;

float depth = texelFetch(depthtex0, ivec2(gl_FragCoord.xy),0).x;
float depth1 = texelFetch(depthtex1, ivec2(gl_FragCoord.xy),0).x;

bool terrainMask = depth<1.0;

vec3 normalCol = texelFetch(colortex1, ivec2(gl_FragCoord.xy),0).rgb;

float normalAO = texelFetch(colortex1, ivec2(gl_FragCoord.xy),0).a;

// vec3 normalCol = textureLod(colortex1, texcoord,0).rgb;

vec2 flatNormalColXY = texelFetch(colortex3, ivec2(gl_FragCoord.xy),0).rg*2.0-1.0;
float flatNormalColZ = sqrt(1.0-dot(flatNormalColXY, flatNormalColXY));
vec3 flatNormalCol = vec3(flatNormalColXY,flatNormalColZ);

vec3 lightVector = vec3(sunPosition*times.sunrise + sunPosition*times.noon + sunPosition * times.sunset + moonPosition * times.night);

const vec3 constShadowColor = vec3(0.10,0.19,0.26);

vec3 constSkyColor = mix(vec3(skyR,skyG,skyB),vec3(0.1),rainStrength);
vec3 constSkyNightColor = constSkyColor*0.1;

vec2 lightMap = texelFetch(colortex2, ivec2(gl_FragCoord.xy),0).xy;
vec2 lightMapPow3 = lightMap*lightMap*lightMap;

float PW = 1.0 / viewWidth;
float PH = 1.0 / viewHeight;

float eyeBrightnessMult = eyeBrightnessSmooth.y*(1.0/240.0);

float pow2EyeBrightnessMult = eyeBrightnessMult*eyeBrightnessMult;

vec4 specularTex = texelFetch(colortex10, ivec2(gl_FragCoord.xy),0);
float roughness = specularTex.r; //Convert the perceptual smoothness to linear roughness
float reflectance = specularTex.g*(1.0/255); //AKA f0


vec3 endLightPos = vec3(sin(worldTime*(1.0/24000.0)), cos(worldTime*(1.0/24000.0)), 1.0);
vec3 endLightColor = vec3(0.15,0.025,0.15);