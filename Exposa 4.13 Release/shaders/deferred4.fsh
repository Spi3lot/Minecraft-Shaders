#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable

#define volumetricResolution 2.0 //[1.0 1.5 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0 13.0 14.0 15.0 16.0]
#define volumetricTAAU
#define volumetricLowEdge 300.0 //[100.0 200.0 300.0 400.0 500.0 600.0 700.0 800.0 900.0 1000.0]
#define volumetricHighEdge 700.0 //[100.0 200.0 300.0 400.0 500.0 600.0 700.0 800.0 900.0 1000.0 1100.0 1200.0 1300.0 1400.0 1500.0 1600.0 1700.0 1800.0 1900.0 2000.0]

uniform sampler2D colortex0;
uniform sampler2D colortex4;
uniform sampler2D colortex12;

in vec2 texcoord;

/* RENDERTARGETS: 0,4,12 */
layout(location = 0) out vec4 colortex0Out;
layout(location = 1) out vec4 colortex4Out;
layout(location = 2) out vec4 colortex12Out;

#include "/lib/includes.glsl"

float getBlendFactor(vec2 velo) {
    return exp(-length(velo)) * 0.3 + 0.6;
}

bool getCloudsMaskFactor(vec3 worldPos)
{
    bool belowClouds = cameraPosition.y<(volumetricLowEdge*0.5+volumetricHighEdge*0.5);

	if(belowClouds) return !terrainMask;

	return true;
}

void main() {
	vec3 viewSpaceCoord = viewSpacePos(texcoord, depth);

	vec3 prevCoord = toPrevScreenPos(texcoord,depth1);

	vec3 color = texture2D(colortex0, texcoord).rgb;

	vec3 worldPos = worldSpacePos(texcoord, depth);

	vec4 clouds = texture2D(colortex4, texcoord*rcp(volumetricResolution));

	#ifdef volumetricTAAU
	vec4 tempClouds = texture2D(colortex12, texcoord);

	tempClouds = neighbourhoodClampingClouds(colortex4, rcp(volumetricResolution), clouds, tempClouds);

	float factor = 0.95;

	vec2 velocity = (texcoord-prevCoord.xy);
	velocity *= vec2(viewWidth,viewHeight);

	factor *= getBlendFactor(velocity);

	clouds.rgb = mix(clouds.rgb,tempClouds.rgb,factor);
	clouds.a = mix(clouds.a,tempClouds.a,factor);
	#endif
	
	if(getCloudsMaskFactor(worldPos)) color = mix(color, clouds.rgb, clouds.a);
	
	colortex0Out = vec4(color, 1.0);
	colortex4Out = clouds;
	colortex12Out = clouds;
}
