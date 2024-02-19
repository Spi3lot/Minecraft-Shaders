#version 430 compatibility
#extension GL_ARB_explicit_attrib_location : enable

#define SPSamples 512 //[1 2 4 6 8 16 32 64 128 256 512 1024 2048 4096]
//#define SteepParallax
// #define directionalLMaps

uniform sampler2D tex;
uniform sampler2D lightmap;
uniform sampler2D normals;
uniform sampler2D specular;

uniform mat4 gbufferModelView;

uniform vec3 shadowLightPosition;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 viewPos;
in vec4 tint;

flat in vec4 textureBounds;
flat in vec3 normal;
flat in mat3 tbn;

flat in float id;

/* RENDERTARGETS: 0,1,2,3,10 */

#include "/lib/includes.glsl"

bool rayMarchPOMHeightfield(const in int samples, in vec3 texcoordInput, inout vec3 tangentDir, out vec3 ParallaxPos, in vec2 dfdxData, in vec2 dfdyData) {

	ParallaxPos = texcoordInput; //Setting it to origin before the bananas

    vec2 tTextureSize = textureBounds.zw - textureBounds.xy;

    const float layerDepth    = rcp(samples);

    vec2  traceVector    = (-tangentDir.xy / tangentDir.z) / 0.55 * tTextureSize * 0.1;

    tangentDir = vec3(traceVector * layerDepth, -layerDepth);

	ParallaxPos += tangentDir*randF();

	for(int i = 0; i < samples; i++) {

        // if(clamp01(ParallaxPos) != ParallaxPos) return false;

		ParallaxPos += tangentDir;
		
        // if(clamp01(ParallaxPos) != ParallaxPos) return false;

		ParallaxPos.xy = mod(ParallaxPos.xy - textureBounds.xy , tTextureSize) + textureBounds.xy;

		float sampledHeightfield = textureGrad(normals, ParallaxPos.xy, dfdxData, dfdyData).a;

        bool depthCheck = ParallaxPos.z < sampledHeightfield;
		
		if(depthCheck) {
			// ParallaxPos.xy = mod(ParallaxPos.xy - textureBounds.xy , tTextureSize) + textureBounds.xy;
			return true;
		}

	}

	return false;
}




void main() {
	// #ifdef ParallaxOcclusionMapping
	vec3 normalizedAtlasCoord = vec3(texcoord, 1.0);
	vec2 dfdxAtlasCoord = dFdx(texcoord);
	vec2 dfdyAtlasCoord = dFdy(texcoord);
	vec3 ParallaxPos;
	vec3 tangentDir = normalize(normalize(viewPos.xyz) * tbn);
	
	bool POMHit;

	#ifdef SteepParallax
	POMHit = rayMarchPOMHeightfield(SPSamples, normalizedAtlasCoord, tangentDir, ParallaxPos, dfdxAtlasCoord, dfdyAtlasCoord);
	#endif

	vec2 coord = texcoord;
	
	#ifdef SteepParallax
	if(POMHit) coord = ParallaxPos.xy;
	#endif

	vec3 shadowsParallaxPos;

	vec3 shadowsTangentDir = normalize(normalize(shadowLightPosition)*tbn);

	// shadowsTangentDir.z = -shadowsTangentDir.z;

	vec3 visibilityPos = ParallaxPos;

	// if(POMHit) visibilityPos -= tangentDir;

	// const int ShadowSamples = 512;

	// bool ShadowsPOMHit = rayMarchPOMHeightfield(ShadowSamples, visibilityPos, shadowsTangentDir, shadowsParallaxPos);

	// if(mod(ParallaxPos.xy - textureBounds.xy , abs(textureBounds.zw - textureBounds.xy)) + textureBounds.xy != ParallaxPos.xy) ;
	
	vec4 color = textureGrad(tex, coord, dfdxAtlasCoord, dfdyAtlasCoord);
	color.rgb *= tint.rgb;
	float lmapY = texture(lightmap, lmcoord).y;
	// color.rgb *= lmapY;
	color.rgb = pow(color.rgb, vec3(2.2));

	vec3 normalCol = textureGrad(normals, coord, dfdxAtlasCoord, dfdyAtlasCoord).rgb*2.0-1.0;

	float normalAO = normalCol.z;

    normalCol.z = sqrt(1.0-dot(normalCol.xy, normalCol.xy));
	
	normalCol = tbn*normalCol;

    vec4 specularTex = textureGrad(specular, coord, dfdxAtlasCoord, dfdyAtlasCoord);

    specularTex.r = pow2(1.0 - specularTex.r); //Convert the perceptual smoothness to linear roughness
	
	specularTex.g *= 255;

	vec2 outLMCoord = lmcoord;

	#ifdef directionalLMaps
	vec3 dFdViewposX = dFdx(viewPos.xyz);
	vec3 dFdViewposY = dFdy(viewPos.xyz);
	vec2 dFdTorch = vec2(dFdx(outLMCoord.r), dFdy(outLMCoord.r));
	
	vec3 torchLightDir = dFdViewposX * dFdTorch.x + dFdViewposY * dFdTorch.y;
	if(length(dFdTorch) > 1e-6) {
		outLMCoord.r *= clamp(dot(normalize(torchLightDir), normalCol.rgb) + 0.8, 0.0, 1.0) * 0.8 + 0.2;
	}
	else {
		outLMCoord.r *= clamp(dot(tbn * vec3(0.0, 0.0, 1.0), normal), 0.0, 1.0);
	}

	outLMCoord.rg = clamp(outLMCoord.rg, 1.0/32.0, 31.0/32.0);
	#endif

	// if(mod(ParallaxPos.xy - textureBounds.xy , abs(textureBounds.zw - textureBounds.xy)) + textureBounds.xy != ParallaxPos.xy) color.a = 0.0;
	
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(normalCol, normalAO);
	gl_FragData[2] = vec4(outLMCoord, 0.0, 1.0);
	gl_FragData[3] = vec4(normal.xy*0.5+0.5, id/65535,tint.a);
	gl_FragData[4] = specularTex;
}
