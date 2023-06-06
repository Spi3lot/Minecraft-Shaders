#version 330 compatibility

/*
 _______ _________ _______  _______  _
(  ____ \\__   __/(  ___  )(  ____ )( )
| (    \/   ) (   | (   ) || (    )|| |
| (_____    | |   | |   | || (____)|| |
(_____  )   | |   | |   | ||  _____)| |
      ) |   | |   | |   | || (      (_)
/\____) |   | |   | (___) || )       _
\_______)   )_(   (_______)|/       (_)

Do not modify this code until you have read the LICENSE.txt contained in the root directory of this shaderpack!

*/

/////////////////////////CONFIGURABLE VARIABLES////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////CONFIGURABLE VARIABLES////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



/////////////////////////END OF CONFIGURABLE VARIABLES/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////END OF CONFIGURABLE VARIABLES/////////////////////////////////////////////////////////////////////////////////////////////////////////////











const int 		shadowMapResolution 	= 4096;
const float 	shadowDistance 			= 120.0; // Shadow distance. Set lower if you prefer nicer close shadows. Set higher if you prefer nicer distant shadows. [80.0 120.0 180.0 240.0]
const float 	shadowIntervalSize 		= 1.0f;
const bool 		shadowHardwareFiltering0 = true;

const bool 		shadowtexMipmap = true;
const bool 		shadowtex1Mipmap = false;
const bool 		shadowtex1Nearest = false;
const bool 		shadowcolor0Mipmap = false;
const bool 		shadowcolor0Nearest = false;
const bool 		shadowcolor1Mipmap = false;
const bool 		shadowcolor1Nearest = false;

const float shadowDistanceRenderMul = 1.0f;

const int 		RGB8 					= 0;
const int 		RGBA8 					= 0;
const int 		RGBA16 					= 0;
const int 		RGBA16F 				= 0;
const int 		RGBA32F 				= 0;
const int 		RG16 					= 0;
const int 		RGB16 					= 0;
const int 		R11F_G11F_B10F 			= 0;
const int 		colortex0Format 			= RGB8;
const int 		colortex1Format 			= RGBA16;
const int 		colortex2Format 			= RGBA16;
const int 		colortex3Format 			= RGBA16;
const int 		colortex4Format 			= RGBA16F;
const int 		colortex5Format 			= RGBA32F;
const int 		colortex6Format 			= RGBA16F;
const int 		colortex7Format 			= RGBA16;


const int 		superSamplingLevel 		= 0;

const float		sunPathRotation 		= -40.0f;

const int 		noiseTextureResolution  = 64;

const float 	ambientOcclusionLevel 	= 0.06f;


const bool colortex7Clear = false;

const float wetnessHalflife = 100.0;
const float drynessHalflife = 100.0;




in vec4 texcoord;

in vec3 lightVector;
in vec3 worldLightVector;
in vec3 worldSunVector;

in float timeMidnight;

in vec3 colorSunlight;
in vec3 colorSkylight;
in vec3 colorSkyUp;
in vec3 colorTorchlight;

in vec4 skySHR;
in vec4 skySHG;
in vec4 skySHB;









#include "lib/Uniforms.inc"
#include "lib/Common.inc"
#include "lib/Materials.inc"



/////////////////////////FUNCTIONS/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////FUNCTIONS/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// vec4 GetViewPosition(in vec2 coord, in float depth) 
// {	
// 	vec2 tcoord = coord;
// 	TemporalJitterProjPosInv01(tcoord);

// 	vec4 fragposition = gbufferProjectionInverse * vec4(tcoord.s * 2.0f - 1.0f, tcoord.t * 2.0f - 1.0f, 2.0f * depth - 1.0f, 1.0f);
// 		 fragposition /= fragposition.w;

	
// 	return fragposition;
// }




/////////////////////////STRUCTS///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////STRUCTS///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


#include "lib/GBufferData.inc"






/////////////////////////STRUCT FUNCTIONS//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////STRUCT FUNCTIONS//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////










vec3 WorldPosToShadowProjPosBias(vec3 worldPos, vec3 worldNormal, out float dist, out float distortFactor)
{
	vec3 sn = normalize((shadowModelView * vec4(worldNormal.xyz, 0.0)).xyz) * vec3(1, 1, -1);

	vec4 sp = (shadowModelView * vec4(worldPos, 1.0));
	sp = shadowProjection * sp;
	sp /= sp.w;

	dist = sqrt(sp.x * sp.x + sp.y * sp.y);
	distortFactor = (1.0f - SHADOW_MAP_BIAS) + dist * SHADOW_MAP_BIAS;

	sp.xyz += sn * 0.002 * distortFactor;
	sp.xy *= 0.95f / distortFactor;
	sp.z = mix(sp.z, 0.5, 0.8);
	sp = sp * 0.5f + 0.5f;		//Transform from shadow space to shadow map coordinates


	//move to quadrant
	sp.xy *= 0.5;
	sp.xy += 0.5;

	return sp.xyz;
}

vec3 CalculateSunlightVisibility(vec4 screenSpacePosition, MaterialMask zmecwWmFca, vec3 worldGeoNormal) {				//Calculates shadows
	// if (rainStrength >= 0.99f)
		// return vec3(1.0f);



	//if (shadingStruct.directionect > 0.0f) {
		float distance = sqrt(  screenSpacePosition.x * screenSpacePosition.x 	//Get surface distance in meters
							  + screenSpacePosition.y * screenSpacePosition.y
							  + screenSpacePosition.z * screenSpacePosition.z);

		vec4 ssp = screenSpacePosition;

		// if (isEyeInWater > 0.5)
		// {
		// 	ssp.xy *= 0.82;
		// }

		vec3 worldPos = (gbufferModelViewInverse * ssp).xyz;

		// worldPos += worldGeoNormal * 0.04;

		if (zmecwWmFca.grass > 0.5)
		{
			worldGeoNormal.xyz = vec3(0, 1, 0);
		}


		float dist;
		float distortFactor;
		vec3 shadowProjPos = WorldPosToShadowProjPosBias(worldPos.xyz, worldGeoNormal, dist, distortFactor);

		// float fademult = 0.15f;
			// shadowMult = clamp((shadowDistance * 1.4f * fademult) - (distance * fademult), 0.0f, 1.0f);	//Calculate shadowMult to fade shadows out

		float shadowMult = 1.0;

		float shading = 0.0;
		vec3 result = vec3(0.0);

		if (shadowMult > 0.0) 
		{

			float diffthresh = dist * 1.0f + 0.10f;
				  diffthresh *= 2.0f / (shadowMapResolution / 2048.0f);
			// diffthresh = 0.0;
				  //diffthresh /= shadingStruct.directionect + 0.1f;


			// shadowProjPos.xyz += shadowNormal * 0.0004 * (dist + 0.5);




			float vpsSpread = 0.105 / distortFactor;

			float avgDepth = 0.0;
			float minDepth = 11.0;
			int c;

			for (int i = -1; i <= 1; i++)
			{
				for (int j = -1; j <= 1; j++)
				{
					vec2 lookupCoord = shadowProjPos.xy + (vec2(i, j) / shadowMapResolution) * 8.0 * vpsSpread;
					//avgDepth += pow(texture2DLod(shadowtex1, lookupCoord, 2).x, 4.1);
					float depthSample = texture2DLod(shadowtex1, lookupCoord, 2).x;
					minDepth = min(minDepth, depthSample);
					avgDepth += pow(min(max(0.0, shadowProjPos.z - depthSample) * 1.0, 0.025), 2.0);
					c++;
				}
			}

			avgDepth /= c;
			avgDepth = pow(avgDepth, 1.0 / 2.0);

			// float penumbraSize = min(abs(shadowProjPos.z - minDepth), 0.15);
			float penumbraSize = avgDepth;

			//if (zmecwWmFca.leaves > 0.5)
			//{
				//penumbraSize = 0.02;
			//}

			int count = 0;
			float spread = penumbraSize * 0.055 * vpsSpread + 0.55 / shadowMapResolution;


			vec3 noise = BlueNoiseTemporal(texcoord.st);

			diffthresh *= 0.5 + avgDepth * 50.0;
			// diffthresh *= 20.0;



			const int latSamples = 5;
			const int lonSamples = 5;

			// shadowProjPos.xyz += shadowNormal * diffthresh * 0.001;
			// shadowProjPos.xyz += shadowNormal * diffthresh * 0.001;

			float dfs = 0.00022 * dist + (noise.z * 0.00005) + 0.00002 + avgDepth * 0.012;

			for (int i = 0; i < 25; i++)
			{
				float fi = float(i + noise.x) * 0.1;
				float r = float(i + noise.x) * 3.14159265 * 2.0 * 1.61;

				vec2 radialPos = vec2(cos(r), sin(r));
				vec2 coordOffset = radialPos * spread * sqrt(fi) * 2.0;

				
				// shading += shadow2DLod(shadowtex0, vec3(shadowProjPos.st + coordOffset, shadowProjPos.z - 0.0012f * diffthresh - (noise.z * 0.00005)), 0).x;
				shading += shadow2DLod(shadowtex0, vec3(shadowProjPos.st + coordOffset, shadowProjPos.z - dfs), 0).x;
				count += 1;
			}
			shading /= count;

			shading = saturate(shading * (1.0 + avgDepth 
					* 5.0 
					* (1.0 / (abs(dot(worldGeoNormal, worldLightVector)) + 0.001))
					));

			result = vec3(shading);


			// stained glass shadow
			{
				float stainedGlassShadow = shadow2DLod(shadowtex0, vec3(shadowProjPos.st - vec2(0.5, 0.0), shadowProjPos.z - 0.0012 * diffthresh), 2).x;
				vec3 stainedGlassColor = texture2DLod(shadowcolor, vec2(shadowProjPos.st - vec2(0.5, 0.0)), 2).rgb;
				stainedGlassColor *= stainedGlassColor;
				result = mix(result, result * stainedGlassColor, vec3(1.0 - stainedGlassShadow));

				// result = mix(result, vec3(0.0), vec3(1.0 - stainedGlassShadow));
			}

			// CAUSTICS
			// water shadow (caustics)
			{
				// float waterDepth = abs(texture2DLod(shadowcolor1, shadowProjPos.st - vec2(0.0, 0.5), 4).x * 256.0 - (worldPos.y + cameraPosition.y));
				float waterDepth = abs(texture2DLod(shadowcolor1, shadowProjPos.st - vec2(0.0, 0.5), 3).x * 256.0 - (worldPos.y + cameraPosition.y));

				// float caustics = GetCausticsDeferred(worldPos, waterDepth);
				vec3 caustics = vec3(0.0);
				caustics.r = GetCausticsDeferred(worldPos, 										worldLightVector, waterDepth);
				// caustics.g = GetCausticsDeferred(worldPos + vec3(0.003 * waterDepth, 0.0, 0.0), worldLightVector, waterDepth);
				// caustics.b = GetCausticsDeferred(worldPos + vec3(0.006 * waterDepth, 0.0, 0.0), worldLightVector, waterDepth);
				caustics.g = caustics.r;
				caustics.b = caustics.r;

				float waterShadow = shadow2DLod(shadowtex0, vec3(shadowProjPos.st - vec2(0.0, 0.5), shadowProjPos.z - 0.0012 * diffthresh - noise.z * 0.0001), 3).x;
				result = mix(result, 
					// result * caustics * exp(-GetWaterAbsorption() * waterDepth), 
					result * caustics, 
					vec3(1.0 - waterShadow));
			}
		}



		result = mix(vec3(1.0), result, shadowMult);





		return result;
	//} else {
	//	return vec3(0.0f);
	//}
}


vec3 SubsurfaceScatteringSunlight(vec3 worldNormal, vec3 worldPos, vec3 albedo)
{
	vec4 shadowProjPos = shadowModelView * vec4(worldPos.xyz, 1.0);	//Transform from world space to shadow space
	shadowProjPos = shadowProjection * shadowProjPos;
	shadowProjPos /= shadowProjPos.w;

	float dist = sqrt(shadowProjPos.x * shadowProjPos.x + shadowProjPos.y * shadowProjPos.y);
	float distortFactor = (1.0f - SHADOW_MAP_BIAS) + dist * SHADOW_MAP_BIAS;
	shadowProjPos.xy *= 0.95f / distortFactor;
	shadowProjPos.z = mix(shadowProjPos.z, 0.5, 0.8);
	shadowProjPos = shadowProjPos * 0.5f + 0.5f;		//Transform from shadow space to shadow map coordinates

	//move to quadrant
	shadowProjPos.xy *= 0.5;
	shadowProjPos.xy += 0.5;

	float subsurfaceDepth = 0.0;
	float depthThresh = 0.0005;
	float weights = 0.0;

	vec2 dither = BlueNoiseTemporal(texcoord.st).xy - 0.5;

	for (int i = -1; i <= 1; i++)
	{
		for (int j = -1; j <= 1; j++)
		{
			vec2 coordOffset = vec2(i + dither.x, j + dither.y) * 0.001;
			subsurfaceDepth += max(0.0, (shadowProjPos.z - texture2DLod(shadowtex1, shadowProjPos.xy + coordOffset, 0).x) / depthThresh);
			weights += 1.0;
		}
	}

	subsurfaceDepth /= weights;

	// subsurfaceDepth = exp(-subsurfaceDepth * 10.0);

	vec3 subsurfaceColor = 1.0 - (normalize(albedo.rgb + 0.000001) * 0.3);
	// vec3 subsurfaceColor = 1.0 - (albedo.rgb * 0.5);
	// vec3 subsurfaceColor = 1.0 - (albedo.rgb * 0.8);
	// vec3 subsurfaceColor = 1.0 - vec3(0.7, 0.5, 0.1);
	vec3 sss = exp(-subsurfaceDepth * subsurfaceColor * 6.0) * (1.0 - subsurfaceColor);

	return sss * 24.0 * colorSunlight;
}


float ScreenSpaceShadow(vec3 origin, vec3 normal, MaterialMask zmecwWmFca)
{
	if (zmecwWmFca.sky > 0.5)
	{
		return 1.0;
	}

	if (isEyeInWater > 0.5)
	{
		origin.xy /= 0.82;
	}

	vec3 viewDir = normalize(origin.xyz);


	float nearCutoff = 0.50;
	float traceBias = 0.015;


	//Prevent self-intersection issues
	float viewDirDiff = dot(fwidth(viewDir), vec3(0.333333));


	vec3 rayPos = origin;
	vec3 rayDir = lightVector * 0.01;
	rayDir *= viewDirDiff * 2000.001;
	rayDir *= -origin.z * 0.28 + nearCutoff;


	rayPos += rayDir * -origin.z * 0.000017 * traceBias;



	float randomness = rand(texcoord.st + sin(frameTimeCounter)).x;

	rayPos += rayDir * randomness;



	float zThickness = 0.025 * -origin.z;

	float shadow = 1.0;

	float numSamplesf = 64.0;
	//numSamplesf /= -origin.z * 0.125 + nearCutoff;

	int numSamples = int(numSamplesf);


	float shadowStrength = 0.9;

	if (zmecwWmFca.grass > 0.5)
	{
		shadowStrength = 0.6;
		zThickness *= 2.0;
	}
	if (zmecwWmFca.leaves > 0.5)
	{
		shadowStrength = 0.4;
	}

	// shadowStrength = pow(shadowStrength, exp2(-length(origin) * 0.05));

	// vec3 prevRayProjPos = ProjectBack(rayPos);

	for (int i = 0; i < 6; i++)
	{
		float fi = float(i) / float(12);

		rayPos += rayDir;

		vec2 rayProjPos = ProjectBack(rayPos).xy;


		TemporalJitterProjPos01(rayProjPos);




		// vec2 pixelPos = floor(rayProjPos.xy * vec2(viewWidth, viewHeight));
		// vec2 pixelPosPrev = floor(prevRayProjPos.xy * vec2(viewWidth, viewHeight));
		// if (pixelPos.x == pixelPosPrev.x || pixelPos.y == pixelPosPrev.y)
		// {
		// 	continue;
		// }

		// prevRayProjPos = rayProjPos;

		/*
		float sampleDepth = GetDepthLinear(rayProjPos.xy);

		float depthDiff = -rayPos.z - sampleDepth;
		*/

		vec3 samplePos = GetViewPositionNoJitter(rayProjPos.xy, GetDepth(rayProjPos.xy)).xyz;

		float depthDiff = samplePos.z - rayPos.z - 0.02 * -origin.z * traceBias;

		if (depthDiff > 0.0 && depthDiff < zThickness)
		{
			shadow *= 1.0 - shadowStrength;
		}
	}

	return shadow;
}


float OrenNayar(vec3 normal, vec3 eyeDir, vec3 lightDir)
{
	const float PI = 3.14159;
	const float roughness = 0.55;

	// interpolating normals will change the length of the normal, so renormalize the normal.



	// normal = normalize(normal + surface.lightVector * pow(clamp(dot(eyeDir, surface.lightVector), 0.0, 1.0), 5.0) * 0.5);

	// normal = normalize(normal + eyeDir * clamp(dot(normal, eyeDir), 0.0f, 1.0f));

	// calculate intermediary values
	float NdotL = dot(normal, lightDir);
	float NdotV = dot(normal, eyeDir);

	float angleVN = acos(NdotV);
	float angleLN = acos(NdotL);

	float alpha = max(angleVN, angleLN);
	float beta = min(angleVN, angleLN);
	float gamma = dot(eyeDir - normal * dot(eyeDir, normal), lightDir - normal * dot(lightDir, normal));

	float roughnessSquared = roughness * roughness;

	// calculate A and B
	float A = 1.0 - 0.5 * (roughnessSquared / (roughnessSquared + 0.57));

	float B = 0.45 * (roughnessSquared / (roughnessSquared + 0.09));

	float C = sin(alpha) * tan(beta);

	// put it all together
	float L1 = max(0.0, NdotL) * (A + B * max(0.0, gamma) * C);

	//return max(0.0f, surface.NdotL * 0.99f + 0.01f);
	return clamp(L1, 0.0f, 1.0f);
}





float GetCoverage(in float coverage, in float density, in float clouds)
{
	clouds = clamp(clouds - (1.0f - coverage), 0.0f, 1.0f -density) / (1.0f - density);
		clouds = max(0.0f, clouds * 1.1f - 0.1f);
	 clouds = clouds = clouds * clouds * (3.0f - 2.0f * clouds);
	 // clouds = pow(clouds, 1.0f);
	return clouds;
}

float   CalculateSunglow(vec3 npos, vec3 lightVector) {

	float curve = 4.0f;

	vec3 halfVector2 = normalize(-lightVector + npos);
	float factor = 1.0f - dot(halfVector2, npos);

	return factor * factor * factor * factor;
}

float G1V(float dotNV, float k)
{
	return 1.0 / (dotNV * (1.0 - k) + k);
}

vec3 SpecularGGX(vec3 N, vec3 V, vec3 L, float roughness, float F0)
{
	float alpha = roughness * roughness;

	vec3 H = normalize(V + L);

	float dotNL = saturate(dot(N, L));
	float dotNV = saturate(dot(N, V));
	float dotNH = saturate(dot(N, H));
	float dotLH = saturate(dot(L, H));

	float F, D, vis;

	float alphaSqr = alpha * alpha;
	float pi = 3.14159265359;
	float denom = dotNH * dotNH * (alphaSqr - 1.0) + 1.0;
	D = alphaSqr / (pi * denom * denom);

	float dotLH5 = pow(1.0f - dotLH, 5.0);
	F = F0 + (1.0 - F0) * dotLH5;

	float k = alpha / 2.0;
	vis = G1V(dotNL, k) * G1V(dotNV, k);

	vec3 specular = vec3(dotNL * D * F * vis) * colorSunlight;

	//specular = vec3(0.1);
	#ifndef PHYSICALLY_BASED_MAX_ROUGHNESS
	specular *= saturate(pow(1.0 - roughness, 0.7) * 2.0);
	#endif


	return specular;
}




 int f(float v)
 {
   return int(floor(v));
 }
 int t(int v)
 {
   return v-f(mod(float(v),2.))-0;
 }
 int d(int v)
 {
   return v-f(mod(float(v),2.))-1;
 }
 int d()
 {
   ivec2 v=ivec2(viewWidth,viewHeight);
   int x=v.x*v.y;
   return t(f(floor(pow(float(x),.333333))));
 }
 int f()
 {
   ivec2 v=ivec2(2048,2048);
   int x=v.x*v.y;
   return d(f(floor(pow(float(x),.333333))));
 }
 vec3 n(vec2 v)
 {
   ivec2 f=ivec2(viewWidth,viewHeight);
   int x=f.x*f.y,z=d();
   ivec2 n=ivec2(v.x*f.x,v.y*f.y);
   float y=float(n.y/z),i=float(int(n.x+mod(f.x*y,z))/z);
   i+=floor(f.x*y/z);
   vec3 m=vec3(0.,0.,i);
   m.x=mod(n.x+mod(f.x*y,z),z);
   m.y=mod(n.y,z);
   m.xyz=floor(m.xyz);
   m/=z;
   m.xyz=m.xzy;
   return m;
 }
 vec2 v(vec3 v)
 {
   ivec2 f=ivec2(viewWidth,viewHeight);
   int x=d();
   vec3 i=v.xzy*x;
   i=floor(i+1e-05);
   float z=i.z;
   vec2 n;
   n.x=mod(i.x+z*x,f.x);
   float s=i.x+z*x;
   n.y=i.y+floor(s/f.x)*x;
   n+=.5;
   n/=f;
   return n;
 }
 vec3 x(vec2 v)
 {
   vec2 i=v;
   i.xy/=.5;
   ivec2 m=ivec2(2048,2048);
   int x=m.x*m.y,z=f();
   ivec2 n=ivec2(i.x*m.x,i.y*m.y);
   float y=float(n.y/z),r=float(int(n.x+mod(m.x*y,z))/z);
   r+=floor(m.x*y/z);
   vec3 s=vec3(0.,0.,r);
   s.x=mod(n.x+mod(m.x*y,z),z);
   s.y=mod(n.y,z);
   s.xyz=floor(s.xyz);
   s/=z;
   s.xyz=s.xzy;
   return s;
 }
 vec2 d(vec3 v,int z)
 {
   v=clamp(v,vec3(0.),vec3(1.));
   vec2 m=vec2(2048,2048);
   vec3 i=v.xzy*z;
   i=floor(i+1e-05);
   float x=i.z;
   vec2 f;
   f.x=mod(i.x+x*z,m.x);
   float s=i.x+x*z;
   f.y=i.y+floor(s/m.x)*z;
   f+=.5;
   f/=m;
   f.xy*=.5;
   return f;
 }
 vec3 f(vec3 v,int z)
 {
   return v*=1./z,v=v+vec3(.5),v=clamp(v,vec3(0.),vec3(1.)),v;
 }
 vec3 n(vec3 v,int z)
 {
   return v*=1./z,v=v+vec3(.5),v;
 }
 vec3 m(vec3 v)
 {
   int m=f();
   v=v-vec3(.5);
   v*=m;
   return v;
 }
 vec3 s(vec3 v)
 {
   int x=d();
   v*=1./x;
   v=v+vec3(.5);
   v=clamp(v,vec3(0.),vec3(1.));
   return v;
 }
 vec3 r(vec3 v)
 {
   int m=d();
   v=v-vec3(.5);
   v*=m;
   return v;
 }
 vec3 m()
 {
   vec3 v=cameraPosition.xyz+.5,i=previousCameraPosition.xyz+.5,x=floor(v-.0001),z=floor(i-.0001);
   return x-z;
 }
 vec3 p(vec3 v)
 {
   vec4 i=vec4(v,1.);
   i=shadowModelView*i;
   i=shadowProjection*i;
   i/=i.w;
   float x=sqrt(i.x*i.x+i.y*i.y),z=1.f-SHADOW_MAP_BIAS+x*SHADOW_MAP_BIAS;
   i.xy*=.95f/z;
   i.z=mix(i.z,.5,.8);
   i=i*.5f+.5f;
   i.xy*=.5;
   i.xy+=.5;
   return i.xyz;
 }
 vec3 d(vec3 v,vec3 i,vec2 f,vec2 n,vec4 s,vec4 m,inout float x,out vec2 z)
 {
   bool r=fract(v.x*2.)>.01&&fract(v.x*2.)<.99||fract(v.y*2.)>.01&&fract(v.y*2.)<.99||fract(v.z*2.)>.01&&fract(v.z*2.)<.99;
   r=!r;
   if(m.x==8||m.x==9||m.x==79||m.x<1.||!r||m.x==20.||m.x==171.||min(abs(i.x),abs(i.z))>.2)
     x=1.;
   if(m.x==50.||m.x==76.)
     {
       x=0.;
       if(i.y<.5)
         x=1.;
     }
   if(m.x==51)
     x=0.;
   if(m.x>255)
     x=0.;
   vec3 y,c;
   if(i.x>.5)
     y=vec3(0.,0.,-1.),c=vec3(0.,-1.,0.);
   else
      if(i.x<-.5)
       y=vec3(0.,0.,1.),c=vec3(0.,-1.,0.);
     else
        if(i.y>.5)
         y=vec3(1.,0.,0.),c=vec3(0.,0.,1.);
       else
          if(i.y<-.5)
           y=vec3(1.,0.,0.),c=vec3(0.,0.,-1.);
         else
            if(i.z>.5)
             y=vec3(1.,0.,0.),c=vec3(0.,-1.,0.);
           else
              if(i.z<-.5)
               y=vec3(-1.,0.,0.),c=vec3(0.,-1.,0.);
   z=clamp((f.xy-n.xy)*100000.,vec2(0.),vec2(1.));
   float t=.15,w=.15;
   if(m.x==10.||m.x==11.)
     {
       if(abs(i.y)<.01&&r||i.y>.99)
         t=.1,w=.1,x=0.;
       else
          x=1.;
     }
   if(m.x==51)
     t=.5,w=.1;
   if(m.x==76)
     t=.2,w=.2;
   if(m.x-255.+39.>=103.&&m.x-255.+39.<=113.)
     w=.025,t=.025;
   y=normalize(s.xyz);
   c=normalize(cross(y,i.xyz)*sign(s.w));
   vec3 o=v.xyz+mix(y*t,-y*t,vec3(z.x));
   o.xyz+=mix(c*t,-c*t,vec3(z.y));
   o.xyz-=i.xyz*w;
   return o;
 }struct qconKIZlZt{vec3 pnOlPKItYq;vec3 pnOlPKItYqOrigin;vec3 WsbjjPghQe;vec3 InIGjfhCoM;vec3 aeHOcnbAiW;vec3 zmecwWmFca;};
 qconKIZlZt e(Ray v)
 {
   qconKIZlZt i;
   i.pnOlPKItYq=floor(v.origin);
   i.pnOlPKItYqOrigin=i.pnOlPKItYq;
   i.WsbjjPghQe=abs(vec3(length(v.direction))/(v.direction+1e-07));
   i.InIGjfhCoM=sign(v.direction);
   i.aeHOcnbAiW=(sign(v.direction)*(i.pnOlPKItYq-v.origin)+sign(v.direction)*.5+.5)*i.WsbjjPghQe;
   i.zmecwWmFca=vec3(0.);
   return i;
 }
 void h(inout qconKIZlZt v)
 {
   v.zmecwWmFca=step(v.aeHOcnbAiW.xyz,v.aeHOcnbAiW.yzx)*step(v.aeHOcnbAiW.xyz,v.aeHOcnbAiW.zxy),v.aeHOcnbAiW+=v.zmecwWmFca*v.WsbjjPghQe,v.pnOlPKItYq+=v.zmecwWmFca*v.InIGjfhCoM;
 }
 void d(in Ray v,in vec3 i[2],out float f,out float z)
 {
   float x,y,r,n;
   f=(i[v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   z=(i[1-v.sign[0]].x-v.origin.x)*v.inv_direction.x;
   x=(i[v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   y=(i[1-v.sign[1]].y-v.origin.y)*v.inv_direction.y;
   r=(i[v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   n=(i[1-v.sign[2]].z-v.origin.z)*v.inv_direction.z;
   f=max(max(f,x),r);
   z=min(min(z,y),n);
 }
 vec3 d(const vec3 v,const vec3 i,vec3 z)
 {
   const float x=1e-05;
   vec3 y=(i+v)*.5,n=(i-v)*.5,m=z-y,f=vec3(0.);
   f+=vec3(sign(m.x),0.,0.)*step(abs(abs(m.x)-n.x),x);
   f+=vec3(0.,sign(m.y),0.)*step(abs(abs(m.y)-n.y),x);
   f+=vec3(0.,0.,sign(m.z))*step(abs(abs(m.z)-n.z),x);
   return normalize(f);
 }
 bool e(const vec3 v,const vec3 i,Ray m,out vec2 f)
 {
   vec3 z=m.inv_direction*(v-m.origin),x=m.inv_direction*(i-m.origin),n=min(x,z),s=max(x,z);
   vec2 r=max(n.xx,n.yz);
   float y=max(r.x,r.y);
   r=min(s.xx,s.yz);
   float c=min(r.x,r.y);
   f.x=y;
   f.y=c;
   return c>max(y,0.);
 }
 bool d(const vec3 v,const vec3 i,Ray m,inout float x,inout vec3 z)
 {
   vec3 y=m.inv_direction*(v-1e-05-m.origin),s=m.inv_direction*(i+1e-05-m.origin),n=min(s,y),f=max(s,y);
   vec2 r=max(n.xx,n.yz);
   float t=max(r.x,r.y);
   r=min(f.xx,f.yz);
   float c=min(r.x,r.y);
   bool a=c>max(t,0.)&&max(t,0.)<x;
   if(a)
     z=d(v-1e-05,i+1e-05,m.origin+m.direction*t),x=t;
   return a;
 }
 vec3 e(vec3 v,vec3 i,vec3 z,vec3 x,int y)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 m=p(v);
   float n=.5;
   vec3 f=vec3(1.)*shadow2DLod(shadowtex0,vec3(m.xy,m.z-.0006*n),2).x;
   f*=saturate(dot(i,z));
   {
     vec4 s=texture2DLod(shadowcolor1,m.xy-vec2(0.,.5),4);
     float r=abs(s.x*256.-(v.y+cameraPosition.y)),c=GetCausticsComposite(v,i,r),t=shadow2DLod(shadowtex0,vec3(m.xy-vec2(0.,.5),m.z+1e-06),4).x;
     f=mix(f,f*c,1.-t);
   }
   f=TintUnderwaterDepth(f);
   return f*(1.-rainStrength);
 }
 vec3 f(vec3 v,vec3 i,vec3 z,vec3 x,int y)
 {
   if(rainStrength>.99)
     return vec3(0.);
   vec3 f=m(v),n=p(f+z*.99);
   float t=.5;
   vec3 r=vec3(1.)*shadow2DLod(shadowtex0,vec3(n.xy,n.z-.0006*t),3).x;
   r*=saturate(dot(i,z));
   r=TintUnderwaterDepth(r);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float s=shadow2DLod(shadowtex0,vec3(n.xy-vec2(.5,0.),n.z-.0006*t),3).x;
   vec3 c=texture2DLod(shadowcolor,vec2(n.xy-vec2(.5,0.)),3).xyz;
   c*=c;
   r=mix(r,r*c,vec3(1.-s));
   #endif
   return r*(1.-rainStrength);
 }
 vec3 h(vec3 v,vec3 i,vec3 z,vec3 x,int y)
 {
   if(rainStrength>.99)
     return vec3(0.);
   v+=1.;
   v-=Fract01(cameraPosition+.5);
   vec3 m=p(v);
   float n=.5;
   vec3 f=vec3(1.)*shadow2DLod(shadowtex0,vec3(m.xy,m.z-.0006*n),2).x;
   f*=saturate(dot(i,z));
   f=TintUnderwaterDepth(f);
   #ifdef GI_SUNLIGHT_STAINED_GLASS_TINT
   float r=shadow2DLod(shadowtex0,vec3(m.xy-vec2(.5,0.),m.z-.0006*n),3).x;
   vec3 s=texture2DLod(shadowcolor,vec2(m.xy-vec2(.5,0.)),3).xyz;
   s*=s;
   f=mix(f,f*s,vec3(1.-r));
   #endif
   return f*(1.-rainStrength);
 }struct DADTHOtuFY{float GFxtWSLmhV;float OGZTEviGjn;float TBAojABNgn;float TGVjqUPLfE;vec3 lZygmXBJpl;};
 vec4 w(DADTHOtuFY v)
 {
   vec4 i;
   v.lZygmXBJpl=max(vec3(0.),v.lZygmXBJpl);
   i.x=v.GFxtWSLmhV;
   v.lZygmXBJpl=pow(v.lZygmXBJpl,vec3(.125));
   i.y=PackTwo16BitTo32Bit(v.lZygmXBJpl.x,v.TBAojABNgn);
   i.z=PackTwo16BitTo32Bit(v.lZygmXBJpl.y,v.TGVjqUPLfE);
   i.w=PackTwo16BitTo32Bit(v.lZygmXBJpl.z,v.OGZTEviGjn);
   return i;
 }
 DADTHOtuFY i(vec4 v)
 {
   DADTHOtuFY i;
   vec2 m=UnpackTwo16BitFrom32Bit(v.y),n=UnpackTwo16BitFrom32Bit(v.z),f=UnpackTwo16BitFrom32Bit(v.w);
   i.GFxtWSLmhV=v.x;
   i.TBAojABNgn=m.y;
   i.TGVjqUPLfE=n.y;
   i.OGZTEviGjn=f.y;
   i.lZygmXBJpl=pow(vec3(m.x,n.x,f.x),vec3(8.));
   return i;
 }
 DADTHOtuFY c(vec2 v)
 {
   vec2 x=1./vec2(viewWidth,viewHeight),z=vec2(viewWidth,viewHeight);
   v=(floor(v*z)+.5)*x;
   return i(texture2DLod(colortex5,v,0));
 }
 float c(float v,float z)
 {
   float x=1.;
   #ifdef FULL_RT_REFLECTIONS
   x=clamp(pow(v,.125)+z,0.,1.);
   #else
   x=clamp(v*10.-7.,0.,1.);
   #endif
   return x;
 }
 bool c(vec3 v,float z,Ray i,bool x,inout float f,inout vec3 n)
 {
   bool m=false,r=false;
   #if RAYTRACE_GEOMETRY_QUALITY==0
   if(x)
     return false;
   if(z>=67.)
     return false;
   r=d(v,v+vec3(1.,1.,1.),i,f,n);
   m=r;
   #else
   if(z<40.)
     return r=d(v,v+vec3(1.,1.,1.),i,f,n),r;
   if(z==40.||z==41.||z>=43.&&z<=54.)
     {
       float y=.5;
       if(z==41.)
         y=.9375;
       r=d(v+vec3(0.,0.,0.),v+vec3(1.,y,1.),i,f,n);
       m=m||r;
     }
   if(z==42.||z>=55.&&z<=66.)
     r=d(v+vec3(0.,.5,0.),v+vec3(1.,1.,1.),i,f,n),m=m||r;
   if(z==43.||z==46.||z==47.||z==52.||z==53.||z==54.||z==55.||z==58.||z==59.||z==64.||z==65.||z==66.)
     {
       float y=.5;
       if(z==55.||z==58.||z==59.||z==64.||z==65.||z==66.)
         y=0.;
       r=d(v+vec3(0.,y,0.),v+vec3(.5,.5+y,.5),i,f,n);
       m=m||r;
     }
   if(z==43.||z==45.||z==48.||z==51.||z==53.||z==54.||z==55.||z==57.||z==60.||z==63.||z==65.||z==66.)
     {
       float y=.5;
       if(z==55.||z==57.||z==60.||z==63.||z==65.||z==66.)
         y=0.;
       r=d(v+vec3(.5,y,0.),v+vec3(1.,.5+y,.5),i,f,n);
       m=m||r;
     }
   if(z==44.||z==45.||z==49.||z==51.||z==52.||z==54.||z==56.||z==57.||z==61.||z==63.||z==64.||z==66.)
     {
       float y=.5;
       if(z==56.||z==57.||z==61.||z==63.||z==64.||z==66.)
         y=0.;
       r=d(v+vec3(.5,y,.5),v+vec3(1.,.5+y,1.),i,f,n);
       m=m||r;
     }
   if(z==44.||z==46.||z==50.||z==51.||z==52.||z==53.||z==56.||z==58.||z==62.||z==63.||z==64.||z==65.)
     {
       float y=.5;
       if(z==56.||z==58.||z==62.||z==63.||z==64.||z==65.)
         y=0.;
       r=d(v+vec3(0.,y,.5),v+vec3(.5,.5+y,1.),i,f,n);
       m=m||r;
     }
   if(z>=67.&&z<=82.)
     r=d(v+vec3(6.,0.,6.)/16.,v+vec3(10.,16.,10.)/16.,i,f,n),m=m||r;
   if(z==68.||z==69.||z==70.||z==72.||z==73.||z==74.||z==76.||z==77.||z==78.||z==80.||z==81.||z==82.)
     {
       float y=8.,s=8.;
       if(z==68.||z==70.||z==72.||z==74.||z==76.||z==78.||z==80.||z==82.)
         y=0.;
       if(z==69.||z==70.||z==73.||z==74.||z==77.||z==78.||z==81.||z==82.)
         s=16.;
       r=d(v+vec3(y,6.,7.)/16.,v+vec3(s,9.,9.)/16.,i,f,n);
       m=m||r;
       r=d(v+vec3(y,12.,7.)/16.,v+vec3(s,15.,9.)/16.,i,f,n);
       m=m||r;
     }
   if(z>=71.&&z<=82.)
     {
       float y=8.,t=8.;
       if(z>=71.&&z<=74.||z>=79.&&z<=82.)
         t=16.;
       if(z>=75.&&z<=82.)
         y=0.;
       r=d(v+vec3(7.,6.,y)/16.,v+vec3(9.,9.,t)/16.,i,f,n);
       m=m||r;
       r=d(v+vec3(7.,12.,y)/16.,v+vec3(9.,15.,t)/16.,i,f,n);
       m=m||r;
     }
   #if RAYTRACE_GEOMETRY_QUALITY==2
   if(z>=83.&&z<=86.)
     {
       vec3 y=vec3(0),c=vec3(0);
       if(z==83.)
         y=vec3(0,0,0),c=vec3(16,16,3);
       if(z==84.)
         y=vec3(0,0,13),c=vec3(16,16,16);
       if(z==86.)
         y=vec3(0,0,0),c=vec3(3,16,16);
       if(z==85.)
         y=vec3(13,0,0),c=vec3(16,16,16);
       r=d(v+y/16.,v+c/16.,i,f,n);
       m=m||r;
     }
   if(z>=87.&&z<=102.)
     {
       vec3 y=vec3(0.),c=vec3(1.);
       if(z>=87.&&z<=94.)
         {
           float s=0.;
           if(z>=91.&&z<=94.)
             s=13.;
           y=vec3(0.,s,0.)/16.;
           c=vec3(16.,s+3.,16.)/16.;
         }
       if(z>=95.&&z<=98.)
         {
           float t=13.;
           if(z==97.||z==98.)
             t=0.;
           y=vec3(0.,0.,t)/16.;
           c=vec3(16.,16.,t+3.)/16.;
         }
       if(z>=99.&&z<=102.)
         {
           float s=13.;
           if(z==99.||z==100.)
             s=0.;
           y=vec3(s,0.,0.)/16.;
           c=vec3(s+3.,16.,16.)/16.;
         }
       r=d(v+y,v+c,i,f,n);
       m=m||r;
     }
   if(z>=103.&&z<=113.)
     {
       vec3 y=vec3(0.),s=vec3(1.);
       if(z>=103.&&z<=110.)
         {
           float c=float(z)-float(103.)+1.;
           s.y=c*2./16.;
         }
       if(z==111.)
         s.y=.0625;
       if(z==112.)
         y=vec3(1.,0.,1.)/16.,s=vec3(15.,1.,15.)/16.;
       if(z==113.)
         y=vec3(1.,0.,1.)/16.,s=vec3(15.,.5,15.)/16.;
       r=d(v+y,v+s,i,f,n);
       m=m||r;
     }
   #endif
   #endif
   return m;
 }
 vec3 a(vec3 v)
 {
   float z=fract(frameCounter*.0123456);
   int i=f(),y=d();
   vec3 x=BlueNoiseTemporal(texcoord.xy).xyz,r=BlueNoiseTemporal(texcoord.xy+.1).xyz,n=v,m=Fract01(cameraPosition.xyz+.5)+vec3(0.,1.7,0.),c=m;
   m=f(m,i);
   Ray s=MakeRay(m*i-vec3(1.),n);
   vec3 t=vec3(1.),w=vec3(0.);
   for(int e=0;e<1;e++)
     {
       vec3 a=vec3(floor(s.origin)),l=abs(vec3(length(s.direction))/(s.direction+.0001)),o=sign(s.direction),p=(sign(s.direction)*(a-s.origin)+sign(s.direction)*.5+.5)*l,Y;
       vec4 T=vec4(0.);
       vec3 h=vec3(0.);
       float G=.5;
       for(int q=0;q<190;q++)
         {
           h=a/float(i);
           vec2 R=d(h,i);
           T=texture2DLod(shadowcolor,R,0);
           if(abs(T.w*255.-130.)<.5)
             w+=.06125*t*colorTorchlight*G;
           else
             {
               if(T.w*255.<254.f&&q!=0)
                 {
                   break;
                 }
             }
           Y=step(p.xyz,p.yzx)*step(p.xyz,p.zxy);
           p+=Y*l;
           a+=Y*o;
           G=1.;
         }
       w+=T.xyz;
     }
   w*=1.;
   return w;
 }
 vec3 a(vec3 i,vec3 z)
 {
   i+=Fract01(cameraPosition.xyz+.5)-.5;
   vec3 y=s(i+z*.1),x=c(v(y)).lZygmXBJpl;
   return x;
 }
 vec3 a(vec2 v,vec3 i,float y,vec3 z)
 {
   vec3 x=texture2DLod(colortex6,v,0).xyz;
   return x;
 }
 void main()
 {
   GBufferData v=GetGBufferData();
   MaterialMask z=CalculateMasks(v.materialID);
   vec4 i=GetViewPosition(texcoord.xy,v.depth),y=gbufferModelViewInverse*vec4(i.xyz,1.),m=gbufferModelViewInverse*vec4(i.xyz,0.);
   vec3 x=normalize(i.xyz),n=normalize(m.xyz),f=normalize((gbufferModelViewInverse*vec4(v.normal,0.)).xyz),r=normalize((gbufferModelViewInverse*vec4(v.geoNormal,0.)).xyz);
   float s=length(i.xyz);
   vec3 t=vec3(0.);
   if(z.grass>.5)
     f=vec3(0.,1.,0.);
   vec3 w=a(texcoord.xy,v.normal,v.depth,i.xyz)*10.,e=w*v.albedo.xyz;
   const float h=75.;
   if(s>h)
     {
       vec3 p=FromSH(skySHR,skySHG,skySHB,f);
       p*=v.mcLightmap.y;
       vec3 R=p*v.albedo.xyz*4.5;
       const float G=3.7;
       R+=v.mcLightmap.x*colorTorchlight*v.albedo.xyz*.025*G;
       vec3 T=normalize(v.albedo.xyz+.0001)*pow(length(v.albedo.xyz),1.)*colorSunlight*.13*v.mcLightmap.y;
       R+=T*v.albedo.xyz*5.;
       float l=.3;
       e=mix(e,R,vec3(saturate(s*l-h*l)));
     }
   t.xyz=e;
   #ifdef HELD_LIGHT
   {
     float G=float(heldBlockLightValue+heldBlockLightValue2)/16.,l=OrenNayar(f,-n,-n),p=1./(dot(m.xyz,m.xyz)+.3);
     t+=v.albedo.xyz*G*p*l*colorTorchlight*.3;
   }
   #endif
   #ifdef VISUALIZE_DANGEROUS_LIGHT_LEVEL
   {
     float p=BlockLightTorchLinear(v.mcLightmap.x)*16.;
     p=p;
     t.x+=p<=6.75?1.:0.;
   }
   #endif
   float G=24.*(1.-sqrt(wetness)),p=dot(f,worldLightVector),l=OrenNayar(f,-n,worldLightVector);
   if(z.leaves>.5)
     l=mix(l,.5,.5);
   if(z.grass>.5)
     v.metalness=0.;
   vec3 Y=CalculateSunlightVisibility(i,z,r);
   #ifdef SUNLIGHT_LEAK_FIX
   float T=saturate(v.mcLightmap.y*100.);
   if(isEyeInWater<1)
     Y*=T;
   #endif
   if(isEyeInWater<1)
     Y*=ScreenSpaceShadow(i.xyz,v.normal.xyz,z);
   t+=TintUnderwaterDepth(DoNightEyeAtNight(l*v.albedo.xyz*Y*G*colorSunlight,timeMidnight));
   vec3 R=SpecularGGX(f,-n,worldLightVector,1.-v.smoothness,v.metalness*.98+.02)*G*Y;
   R*=mix(vec3(1.),v.albedo.xyz,vec3(v.metalness));
   R*=mix(1.,.5,z.grass);
   if(isEyeInWater<.5)
     t*=1.-c(v.smoothness,v.metalness)*v.metalness,t+=DoNightEyeAtNight(R,timeMidnight);
   if(z.sky>.5||v.depth>1.)
     {
       vec3 o=n.xyz;
       if(isEyeInWater>0)
         o.xyz=refract(o.xyz,vec3(0.,-1.,0.),1.2533);
       vec3 q=SkyShading(o.xyz,worldSunVector.xyz,rainStrength);
       t=q;
       vec3 d=AtmosphereAbsorption(o.xyz,AtmosphereExtent);
       t+=v.albedo.xyz*d*.5;
       t+=RenderSunDisc(o,worldSunVector,colorSunlight)*d*2000.;
       CloudPlane(t,-o,worldLightVector,worldSunVector,colorSunlight,colorSkyUp,q,timeMidnight,true);
     }
   if(z.glowstone>.5)
     t.xyz+=v.albedo.xyz*GI_LIGHT_BLOCK_INTENSITY;
   if(z.torch>.5)
     t.xyz+=v.albedo.xyz*pow(length(v.albedo.xyz),2.)*.5*GI_LIGHT_TORCH_INTENSITY;
   if(z.lava>.5)
     t+=v.albedo.xyz*.75*GI_LIGHT_BLOCK_INTENSITY;
   if(z.fire>.5)
     t+=v.albedo.xyz*3.*GI_LIGHT_TORCH_INTENSITY;
   if(z.litFurnace>.5)
     {
       float d=saturate(v.albedo.x-(v.albedo.y+v.albedo.z)*.5-.2);
       t+=v.albedo.xyz*d*2.*GI_LIGHT_TORCH_INTENSITY*vec3(2.,.35,.025);
     }
   float q=0.;
   t*=.001;
   t=LinearToGamma(t);
   t+=rand(texcoord.xy+sin(frameTimeCounter))*(1./65535.);
   gl_FragData[0]=vec4(t.xyz,1.);
 };




/* DRAWBUFFERS:3 */
