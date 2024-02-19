#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable

#define lensFlare
#define lensFlareBlurSamples 5 //[1 2 3 4 5 6 7 8 9 10]
#define ghostFlareSpacingMult 0.6 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.5 1.6 1.7 1.8 1.9 2.0]
#define haloFlareSpacingMult 0.20 //[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20]
#define lensFlareSamples 3 //[1 2 3 4 5 6 7 8 9 10]
#define lensFlareThreshold 0.19 //[0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30]
#define lensFlareStrength 0.005 //[0.001 0.002 0.003 0.004 0.005 0.006 0.007 0.008 0.009 0.010 0.020 0.030 0.040 0.050]

uniform sampler2D colortex11;
uniform sampler2D colortex0;

in vec2 texcoord;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec3 colortex0Out;

#include "/lib/includes.glsl"

vec3 lensFlareSampling(sampler2D smpTex, vec2 coords)
{
	const int sampleRad = lensFlareBlurSamples;

	vec3 sampleOutput = vec3(0.0);

	for(int x = -sampleRad; x < sampleRad; x++)
	{
		for(int y = -sampleRad; y < sampleRad; y++)
		{
			sampleOutput += textureLod(smpTex, coords + vec2(x,y) * rcp(vec2(viewWidth, viewHeight)), 4.0).rgb;
		}
	}

	sampleOutput *= rcp(pow2(sampleRad));

	return sampleOutput;
}

vec3 lensFlareCalc()
{
	vec2 flippedCoord = vec2(1.0) - texcoord;
	vec3 ret = vec3(0.0);

	vec2 ghostPreCoord = (vec2(0.5) - flippedCoord) * ghostFlareSpacingMult;
	vec2 haloPreCoord = normalize((vec2(0.5) - flippedCoord)) * haloFlareSpacingMult;
	

	vec3 lensTexPre = texture2D(colortex11, texcoord).rgb;

	for (int i = 0; i < lensFlareSamples; i++) 
	{

		vec2 sampleCoord = ((flippedCoord) + ghostPreCoord * vec2(i));

		if( i % 2 == 0) {
			sampleCoord = ((flippedCoord) + haloPreCoord * vec2(i));
		}

		ivec2 scaledLensCoord = ivec2(sampleCoord * vec2(viewWidth,viewHeight));

		vec3 lensColor = lensFlareSampling(colortex0, sampleCoord);
		
		int lensBlockID = int(texelFetch(colortex3, scaledLensCoord,0).b*65535);
		int lensBlockIDoff1 = int(texelFetch(colortex3, scaledLensCoord + 1,0).b*65535);
		int lensBlockIDoff2 = int(texelFetch(colortex3, scaledLensCoord + 2,0).b*65535);
		int lensBlockIDoff3 = int(texelFetch(colortex3, scaledLensCoord - 1,0).b*65535);
		int lensBlockIDoff4 = int(texelFetch(colortex3, scaledLensCoord - 2,0).b*65535);

		float lensMask = float(lensBlockID == 1190) + float(lensBlockIDoff1 == 1190) + float(lensBlockIDoff2 == 1190) + float(lensBlockIDoff3 == 1190) + float(lensBlockIDoff4 == 1190);
		// lensMask += smoothstep(0.02, 0.1001, distance((vec3(sampleCoord, textureLod(depthtex0, sampleCoord, 2.0).x)), (screenSpacePos(sunPosition))))*10.;
		lensColor *= lensMask * max0(luminance(lensColor) - lensFlareThreshold)*5.;
		if(i % 2 == 0) {
			lensColor *= pow(1.0 - (length(vec2(0.5) - fract(sampleCoord)) * rcp(0.70710678118)), 5.0);
		}
		vec3 lensTexGhost = lensTexPre * texture2D(colortex11, sampleCoord).rgb;
		ret += lensColor*lensTexGhost*lensFlareStrength;
	}

	return ret;
}

void main() {
	// vec3 screenSpaceCoord = vec3(texcoord*2.0, 1.0);
	// screenSpaceCoord.z = texelFetch(depthtex0, ivec2(gl_FragCoord.xy*2.0),0).x;
	// vec3 viewSpaceCoord = viewSpacePos(screenSpaceCoord.xy,screenSpaceCoord.z);
	// vec3 downScaledNormals = texelFetch(colortex1, ivec2(gl_FragCoord.xy*2.0),0).rgb*2.0-1.0;
	
	vec3 color = texelFetchShort(colortex0).rgb;

	#ifdef lensFlare
	color += lensFlareCalc();
	#endif

	colortex0Out = color;
}