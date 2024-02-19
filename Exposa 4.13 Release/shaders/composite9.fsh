#version 430 compatibility
#extension GL_ARB_explicit_attrib_location : enable

#define TAA
#define VL
#define VLStrength 0.5 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4.0]
#define VLSpread 0.45 //[0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
#define VLtransmittanceMult 1.0 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4.0]
uniform sampler2D colortex0;
uniform sampler2D colortex4;
uniform sampler2D shadowcolor0;
uniform sampler2DShadow shadowtex1;
uniform sampler2DShadow shadowtex0;

uniform int isEyeInWater;
uniform float blindness;

uniform vec3 shadowLightPosition;

in vec2 texcoord;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec3 colortex0Out;

#include "/lib/includes.glsl"

vec3 getVL(float dither, vec3 worldPos) {

    vec3 vl = vec3(0.0);

	vec3 VLColor = blackBodyColor(3500.);
	VLColor = mix(VLColor, vec3(0.5),rainStrength);
	// VLColor *= constSkyColor;

	float strength = VLStrength*(3.*times.sunrise + 3.*times.noon + 3.*times.sunset + 0.*times.night);

	float phaseSpread = 0.25*times.sunrise + 0.25*times.noon + 0.25*times.sunset + 0.5*times.night;

	float transmittance = 1.0;

	vec3 VLColorMix = (VLColor*times.sunrise+constSkyColor*times.noon+VLColor*times.sunset+VLColor*0.5*times.night);
	
	if(isEyeInWater == 1) VLColorMix *= vec3(0.5, 0.7, 1.0);
    
    #ifdef TAA
    dither    = fract(dither + frameTimeCounter*16);
    #endif

    int skySamples = 12; //also can be named as steps
    int waterSamples = 4; //also can be named as steps
	if(waterMask || isEyeInWater == 1) skySamples = waterSamples;
    vec3 start = vec3(0.,0.,0.); //the position of the camera in player space
    vec3 end = worldPos-cameraPosition; //player space
    vec3 startPos = ShadowNDC(start);
    vec3 endPos = ShadowNDC(end);
    vec3 increment = (endPos-startPos)/(skySamples+1);
    vec3 currentPos = startPos;
	currentPos += increment*dither;
    float shadowCheck = 0.0;
		for(int i = 0; i <skySamples; i++) {
				currentPos += increment;

				transmittance *= exp(VLtransmittanceMult*0.000575*-lind(depth)*rcp(skySamples+1));

				vec3 shadowDistorted = vec3(distortShadow(currentPos.xy),currentPos.z)*0.5+0.5;

				float shadowMapDepth = texture(shadowtex1, shadowDistorted).x;

				float transparentShadowMapDepth = texture(shadowtex0, shadowDistorted).x;

				if(abs(shadowMapDepth-transparentShadowMapDepth)>=1e-5 && !waterMask && isEyeInWater == 0) VLColorMix = texture(shadowcolor0, shadowDistorted.xy).rgb;

				shadowCheck += (depth1 < 1.0 ? float((shadowDistorted.x-shadowMapDepth)>=1e-5) : 0.0);
			}
	vl = (mix(VLColorMix,vl,shadowCheck/float(skySamples)))*clamp01(length(end-start)/far);
	
	vl *= strength*henyeyGreensteinPhase(dot(normalize(viewSpacePos(texcoord,depth1)),normalize(shadowLightPosition)), VLSpread)*transmittance;
	return vl;
}

void main() {
	vec3 color = texelFetchShort(colortex0).rgb;
	vec3 worldPos = worldSpacePos(texcoord, depth1);
	float blueDither = blueNoiseSample(texcoord, 1.0, vec2(0.0));
	vec3 VLColor = vec3(1.0,1.0,0.2);
	// if(!terrainMask) color *= 0.0;
	#ifdef VL
	vec3 VF = getVL(blueDither, worldPos);
	color += VF;
	#endif
	colortex0Out = color;
}
