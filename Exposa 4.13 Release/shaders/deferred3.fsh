#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable

#define volumetricClouds
#define volumetricAltitude 300.0 //[50.0 100.0 200.0 300.0 400.0 500.0 650.0 700.0 750.0 800.0 850.0 900.0]
#define volumetricThickness 300.0 //[50.0 100.0 200.0 300 400.0 500.0 650.0 700.0 750.0 800.0 850.0 900.0]
#define volumetirCoverage 1.0 //[0.001 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.30 0.45 0.50 0.55 0.60 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]
#define volumetricDensity 0.1 //[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1]
#define volumetricScatteringDensity 5.0 //[0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4.0 4.1 4.2 4.3 4.4 4.5 4.6 4.7 4.8 4.9 5.0]
#define volumetricSamples 30.0 //[6.0 7.0 8.0 9.0 10.0 11.0 12.0 13.0 14.0 15.0 16.0 17.0 18.0 19.0 20.0 21.0 22.0 23.0 24.0 25.0 26.0 27.0 28.0 29.0 30.0 35.0 40.0 45.0 50.0 55.0 60.0 70.0 80.0]
#define volumetricScatteringSamples 20 //[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40]
#define volumetricLowEdge 300.0 //[100.0 200.0 300.0 400.0 500.0 600.0 700.0 800.0 900.0 1000.0]
#define volumetricHighEdge 700.0 //[100.0 200.0 300.0 400.0 500.0 600.0 700.0 800.0 900.0 1000.0 1100.0 1200.0 1300.0 1400.0 1500.0 1600.0 1700.0 1800.0 1900.0 2000.0]
//#define volumetricBlockyClouds
#define volumetricResolution 2.0 //[1.0 1.5 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0 13.0 14.0 15.0 16.0]
#define altitude 100.0
#define thickness 400.0

#define TAA

uniform sampler2D colortex0;

uniform vec3 shadowLightPosition;

in vec2 texcoord;

/* DRAWBUFFERS:04 */
layout(location = 0) out vec4 colortex0Out;
layout(location = 1) out vec4 colortex4Out;

#include "/lib/includes.glsl"
// #include "/lib/vshjitter.glsl"
// #include "/lib/sky.glsl"

vec2 jitter[8] = vec2[8](vec2( 0.125,-0.375),
							   vec2(-0.125, 0.375),
							   vec2( 0.625, 0.125),
							   vec2( 0.375,-0.625),
							   vec2(-0.625, 0.625),
							   vec2(-0.875,-0.125),
							   vec2( 0.375,-0.875),
							   vec2( 0.875, 0.875));
				

vec2 taaJitter(vec2 coord, float w){
	return jitter[int(mod(frameCounter,8.0))]*(w/vec2(viewWidth,viewHeight)) + coord;
}


float cloudNoise(in vec3 pos, in float size, in vec2 wind) {

    vec3 tempPos = pos;

    #ifdef volumetricBlockyClouds
    tempPos = floor(tempPos*0.01)/0.01;
    #endif

    float noise = noiseTexSampleClouds(tempPos.xz, size, wind);

    noise -= smoothstep(0.2, 1.0, (pos.y - volumetricAltitude) / volumetricThickness ) * 0.4;

    float noiseMult = sqrt(clamp01(1.0 - volumetricDensity)); //This is so the noise is prevented from eating too much into the cloud going negative

    // noise += noiseTexSampleClouds(tempPos.xz, size*1.5, wind)*0.6*noiseMult;
    // noise += noiseTexSampleClouds(tempPos.xz, size*0.5, wind)*0.3*noiseMult;
    // noise += noiseTexSampleClouds(tempPos.xz, size*0.25, wind)*0.15*noiseMult;
    
    noise += sixthSurgeNoiseSample(tempPos, size)*0.6*noiseMult;

    noise += sixthSurgeNoiseSample(tempPos, size*0.5)*0.3*noiseMult;

    // noise += sixthSurgeNoiseSample(pos*2.0, size*3.0)*0.2*noiseMult;

    return noise;
}

float CloudShape2D(in vec3 pos) {
    float density = 0.9;
    float tick = frameTimeCounter;
    vec2 wind = vec2(tick)*0.09;

    float size = 0.0004;

    float hfade     = 1.0-smoothstep(altitude+thickness * 0.2, altitude+1, pos.y);
    float lfade     = smoothstep(altitude-thickness, altitude-1, pos.y);
    
    float noise = cloudNoise(pos, size, wind);
    // noise += 0.5;
    noise -= ( -0.7*rainStrength);

    noise   = max(noise, 0.0);  //we don't want negative noise values
    // noise   = cubeSmooth(noise);
    noise  *= hfade*lfade;          //apply fading

    return max(noise*density, 0.0);
}

float cloudShape(in vec3 pos) {
    vec2 wind = vec2(frameTimeCounter*0.03);

    float size = 0.0025;

	float fadeParameter = volumetricAltitude+volumetricThickness;
	float fadeParameter2 = volumetricAltitude+volumetricThickness*0.2;

    float highFade     = 1.0-smoothstep(fadeParameter2, fadeParameter, pos.y);
    float lowFade     = smoothstep(volumetricAltitude, fadeParameter2, pos.y);

    float noise = cloudNoise(pos, size, wind);

    noise -= (volumetirCoverage + -0.6*rainStrength);

    // noise   = cubeSmooth(noise);

    noise = max0(noise);
    
    noise *= highFade*lowFade;

    return max0(noise*volumetricDensity);
}

float cloudScatter(in vec3 pos, in vec3 lightPos, int samples) {
    vec3 direction   = normalize(mat3(gbufferModelViewInverse)*lightPos);

    float stepSize = volumetricThickness/samples;

    vec3 rayStep    = direction*stepSize;

    pos        += rayStep;

    float oD = 0.0;
    float coEff = 0.0;
    float scatter = 0.0;
    
    for (int i = 0; i<samples; i++) {
        oD += cloudShape(pos);

        pos    += rayStep;

        for (int j = 0; j<samples; j++) {
            coEff = pow(0.01, float(j));
            
            scatter += exp(-oD*volumetricScatteringDensity*stepSize * coEff) * coEff;
        }
    }

    // scatter *= 12.5*henyeyGreensteinPhase(dot(normalize(pos), direction),0.825);

    return clamp01(scatter*0.4*henyeyGreensteinPhase(dot(normalize(pos), direction),0.225));
}

float cloudScatterIntegral(float transmittance, const float coEff) {
    float a   = -1.0/coEff;
    return transmittance * a - a;
}

vec3 sunLitColor = vec3(0.9,0.2,0.09)*5.*times.sunrise + vec3(2.)*times.noon + vec3(0.9,0.2,0.09)*5.*times.sunset + vec3(0.15,0.3,0.9)*0.75*times.night;
vec3 nonLitColor = constSkyColor*0.05*times.sunrise + constSkyColor*0.1*times.noon + constSkyColor*0.025*times.sunset + constSkyNightColor*0.1*times.night;

vec4 volumetriClouds(inout vec3 worldPos, in float blueDither) {
	#ifdef TAA
    blueDither    = fractDither(blueDither);
	#endif

    float maxDist = 4500.0;

    float withinClouds    = smoothstep(volumetricLowEdge-20.0, volumetricLowEdge,cameraPosition.y) * (1.0-smoothstep(volumetricHighEdge, volumetricHighEdge+20.0,cameraPosition.y));

    bool belowClouds = cameraPosition.y<(volumetricLowEdge*0.5+volumetricHighEdge*0.5);
    bool notReflectedClouds = !((worldPos.y<0.0 && belowClouds) || (worldPos.y>0.0 && !belowClouds));

    vec3 belowPos     = worldPos*((volumetricLowEdge-cameraPosition.y)/worldPos.y)*float(notReflectedClouds);
    vec3 abovePos     = worldPos*((volumetricHighEdge-cameraPosition.y)/worldPos.y)*float(notReflectedClouds);

    // if(belowClouds && terrainMask) {
    //     belowPos = vec3(0.0);
    //     abovePos = vec3(0.0);
    // }

    vec3 startPos = belowPos;
    vec3 endPos = abovePos;

    vec3 lightDir = normalize(shadowLightPosition);

    if(!belowClouds) {
        startPos = abovePos;
        endPos = belowPos;
    }

    startPos    = mix(startPos, gbufferModelViewInverse[3].xyz, withinClouds);
    endPos    = mix(endPos, worldPos*maxDist, withinClouds);

    vec3 stepSize = (endPos-startPos)/volumetricSamples;

    vec3 cloudPos  = startPos + cameraPosition;

    cloudPos += stepSize*blueDither;

    float stepLength = length(stepSize);

    float scatter = 0.0;
    float transmittance = 1.0;
    float scatterIntensity = 2.0;
    float transmittanceFalloff = 0.5;
    float density = 20.5;
    float cloudFade = 1.0; //AKA fog

    for(int i = 0; i < int(volumetricSamples); i++, cloudPos += stepSize) {
        // cloudPos += stepSize;

        float cloudOpticalDepth = cloudShape(cloudPos)*stepLength*density;
        float distFromPlayer = distance(cloudPos, cameraPosition);

        if (transmittance<0.05) break;

        if (cloudPos.y > volumetricHighEdge || cloudPos.y<volumetricLowEdge) continue; 

        if (distFromPlayer>maxDist) break;

        if (cloudOpticalDepth<=0.0) continue;

        float stepTransmittance = exp2(-cloudOpticalDepth*transmittanceFalloff);

        float cloudPowder = 1.0-exp(-(cloudOpticalDepth/stepLength/density)*5.0)*0.8;

        scatter += cloudScatter(cloudPos , lightDir, volumetricScatteringSamples)*cloudPowder*cloudScatterIntegral(stepTransmittance, 1.11)*transmittance*scatterIntensity;

        transmittance *= stepTransmittance;
        
        cloudFade    = smoothstep(0.52, 1.0-(transmittance), distFromPlayer/maxDist*0.1);
        cloudFade += smoothstep(0.52, 1.0-(transmittance), distFromPlayer/maxDist*0.8);
    }

    worldPos = cloudPos;

    return vec4(max(nonLitColor * (1.0-transmittance) + sunLitColor * scatter, nonLitColor), clamp01(1.0-cloudFade));
}

// vec4 2DClouds(in vec3 worldPos, in float blueDither) {
//     bool cloudVisibilityCheck = (worldPos.y>=cameraPos.y && cameraPos.y<=height) || (worldPos.y<=cameraPos.y && cameraPos.y>=height);
//     vec3 cloudPos = 
// // }
// vec4 clouds_2D(in vec3 worldPos, in vec3 lightVec, in vec3 sunlight, bool isTerrain, in float height) {
//     float cloud     = 0.0;
//     float scatter   = 0.0;
//     bool visibility = false;
//     height    = altitude;

//     vec3 worldVec   = normalize(worldPos-cameraPosition);

//     //check if clouds are potentially visible
//     visibility = (worldPos.y>=cameraPosition.y && cameraPosition.y<=height) || 
//     (worldPos.y<=cameraPosition.y && cameraPosition.y>=height);
//     if (isTerrain) visibility = false;
    
//     vec3 rayPosition = vec3(0.0);

//     if (visibility) {
//         vec3 cloud_plane    = worldVec*((height-cameraPosition.y)/worldVec.y);
//         rayPosition    = cameraPosition+cloud_plane;

//         //sample cloud shape
//         float oD            = CloudShape2D(rayPosition);

//         //sample lighting only when there are clouds present on that pixel
//         if (oD>0.0) {
//             scatter = cloudScatter(rayPosition, lightVec, 1);
//         }

//         cloud              += oD;
//     }

//     vec3 color      = sunlight;
//     cloud           = clamp(cloud, 0.0, 1.0);

//     float dist = distance(rayPosition, cameraPosition);

//     float skyfade   = exp(-dist * 1e-4);
//     return vec4(color, cloud*skyfade);
// }

void main() {

	vec4 clouds = vec4(0.0);

	vec3 color = texelFetchShort(colortex0).rgb;

	vec2 cloudCoord = texcoord*volumetricResolution;

	if(clamp01(cloudCoord) == cloudCoord) {
		// #ifdef TAA
		// cloudCoord = taaJitter(cloudCoord, 1.0);
		// #endif

		float scaledDepth = texture(depthtex0, cloudCoord).x;

		vec3 viewSpaceCoord = viewSpacePos(cloudCoord, scaledDepth);

		vec3 worldSpaceCoord = worldSpacePos(cloudCoord, scaledDepth);

		sunLitColor = mix(sunLitColor, vec3(luminance(sunLitColor)), rainStrength);

        // clouds = clouds_2D(worldSpaceCoord, normalize(shadowLightPosition), sunLitColor, terrainMask, altitude);

        #ifdef volumetricClouds
        vec3 cloudsWorldPos = normalize(worldSpaceCoord-cameraPosition);
        vec4 volumeClouds = volumetriClouds(cloudsWorldPos, blueNoiseSample(texcoord, 1.0, vec2(0.0)));
		clouds = volumeClouds;
        #endif

		// color = mix(color, clouds.rgb, clouds.a);
	}

    // color = clouds.rgb;
    // color.x = clamp01(blueNoiseSample(texcoord, 1.0, vec2(1.0)));
    // color *= bayer16(gl_FragCoord.xy);
    // color = vec3(noiseTexSampleClouds(normalize(worldSpaceCoord-cameraPosition).xz, 50., vec2(0.0)));
    // color = vec3(cloudNoise(normalize(worldSpaceCoord-cameraPosition), 51.0, vec2(0.0)));

	colortex0Out = vec4(color, 1.0);
	colortex4Out = vec4(clouds);
}
