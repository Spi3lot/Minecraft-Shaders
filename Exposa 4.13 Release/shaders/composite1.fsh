#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable

uniform sampler2D colortex5;
uniform sampler2D colortex6;

in vec2 texcoord;


/* DRAWBUFFERS:56 */
layout(location = 0) out float colortex5Out; //RTAO
layout(location = 1) out vec4 colortex6Out; //PreviousFrameRTAO

#include "/lib/includes.glsl"
// #include "/lib/shadows.glsl"
// #include "/lib/sky.glsl"
// #include "/lib/rtao.glsl"

void main() {
	vec3 prevCoord = toPrevScreenPos(texcoord,depth1);

	vec4 prevRTAOBuffer = texture2D(colortex6, prevCoord.xy);
	prevRTAOBuffer.g ++;


	float RTAO = texture2D(colortex5,texcoord*0.5).x;
	float prevRTAO = prevRTAOBuffer.x;

	float invDepth = 1.0-depth1;
    float sampledPreviousDepth = 1.0-prevRTAOBuffer.a;

	float depthWeight  = -abs(lind(depth1) - lind(sampledPreviousDepth));

	prevRTAOBuffer.g *= float(clamp01(prevCoord.xy) == prevCoord.xy);
	prevRTAOBuffer *= sqrt(exp(depthWeight));

	float factor = 1.0 - (1.0 / max(prevRTAOBuffer.g, 1.0));
    // factor *= float(clamp01(prevCoord.xy) == prevCoord.xy);
	// factor *= exp(depthWeight);

	RTAO = mix(RTAO,prevRTAO,factor);
	// RTAO *= normalAO;

	colortex5Out = RTAO*normalAO;
	colortex6Out = vec4(RTAO,vec2(prevRTAOBuffer.g, 1.0),invDepth);
}
