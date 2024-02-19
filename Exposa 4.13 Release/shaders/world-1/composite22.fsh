#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable

#define TAA

// uniform sampler2D depthtex0;
uniform sampler2D colortex0;
uniform sampler2D colortex7;

in vec2 texcoord;

/* DRAWBUFFERS:07 */
layout(location = 0) out vec3 colortex0Out;
layout(location = 1) out vec3 colortex7Out;

#include "/lib/includes.glsl"

float getBlendFactor(vec2 velo) {
    return exp(-length(velo)) * 0.3 + 0.6;
}

void main() {
	vec3 prevCoord = toPrevScreenPos(texcoord,depth1);

	vec3 color = texelFetchShort(colortex0).rgb;
	vec3 tempColor = texelFetch(colortex7, ivec2(prevCoord.xy*vec2(viewWidth, viewHeight)), 0).rgb;
	// vec3 tempColor = texture(colortex7, prevCoord.xy).rgb;
	// vec3 tempColor = texelFetchShort(colortex7).rgb;

	tempColor = neighbourhoodClamping(colortex0,color,tempColor);

	float factor = 0.9999;

	vec2 velocity = texcoord-prevCoord.xy;
	velocity *= vec2(viewWidth,viewHeight);

	factor *= getBlendFactor(velocity);

	// float depthWeight  = -abs(lind(depth1) - lind(sampledPreviousDepth));
	#ifdef TAA
	color = mix(color,tempColor,factor);
	#endif
	// color = flatNormalCol;

	// colortex0Out = vec3(lind(texelFetchShort(depthtex0).x));
	colortex0Out = color;
	colortex7Out = color;
}
