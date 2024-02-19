#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable

#define TAA
#define MBlur
#define MBlurStrength 1.0 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5]

uniform sampler2D colortex0;

in vec2 texcoord;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec3 colortex0Out;

#include "/lib/includes.glsl"


vec3 MBlurFunction(in vec3 scolor, in float blueDither) {
    vec3 blurredCol = vec3(0.0);

	#ifdef TAA
	blueDither = fractDither(blueDither);
	#endif

    vec2 pixel = rcp(vec2(viewWidth, viewHeight));

    vec2 previousPos = toPrevScreenPos(texcoord, 1.0).xy;
	vec2 velocity = abs(texcoord - previousPos);

	velocity *= rcp(1.5+length(velocity))*MBlurStrength*0.02;

	int samples = 5;
		
	vec2 tcoord = texcoord-velocity*blueDither;

	for (int i = 0; i < samples; ++i){
        tcoord += velocity;
		blurredCol += textureLod(colortex0, clamp(tcoord,pixel,1.0-pixel), 0).rgb;
	}

	blurredCol *= rcp(float(samples));

	return blurredCol;
}

void main() {

	vec3 color = texelFetchShort(colortex0).rgb;
	float blueDither = blueNoiseSample(texcoord, 1.0, vec2(0.0));

	#ifdef MBlur
	color = MBlurFunction(color, blueDither);
	#endif

	colortex0Out = color;
}