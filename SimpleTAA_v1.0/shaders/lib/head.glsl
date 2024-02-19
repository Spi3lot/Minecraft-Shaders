#define fogStart 0.2    //[0.0 0.2 0.4 0.6 0.8]
#define fogExponent 1.0 //[0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0]

/* --- MOTIONBLUR --- */
#define motionblurToggle
#define motionblurSamples 8     //[4 6 8 10 12 14 16 18 20]
#define motionblurScale 1.0     //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

#include "util/const.glsl"
#include "util/macros.glsl"
#include "util/functions.glsl"

float bayer2  (vec2 c) { c = 0.5 * floor(c); return fract(1.5 * fract(c.y) + c.x); }
float bayer4  (vec2 c) { return 0.25 * bayer2 (0.5 * c) + bayer2(c); }
float bayer8  (vec2 c) { return 0.25 * bayer4 (0.5 * c) + bayer2(c); }
float bayer16 (vec2 c) { return 0.25 * bayer8 (0.5 * c) + bayer2(c); }

float ditherGradNoise(){
    return fract(52.9829189*fract(0.06711056*gl_FragCoord.x + 0.00583715*gl_FragCoord.y));
}

vec3 ditherR11G11B10(vec3 color) {
    float dither = ditherGradNoise();
	const vec3 mantissaBits = vec3(6, 6, 5);
	vec3 exponent = floor(log2(color));
	return color + dither * exp2(-mantissaBits) * exp2(exponent);
}

uniform int isEyeInWater;

float getFogAlpha(float sceneDistance, float far) {
    if (isEyeInWater == 1) sceneDistance *= 4.0;
    if (isEyeInWater == 2) sceneDistance *= 64.0;
	float dist 	= max0(sceneDistance / far - fogStart) / (1.0 - fogStart);
		dist 	= dist * 2.0;

    //return 1.0 - exp2(-dist * fogExponent);

    return pow(sstep(dist, 0.0, 0.99), fogExponent);
}