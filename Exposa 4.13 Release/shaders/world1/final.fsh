#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable

#define sharpening
#define sharpeningStrength 0.4 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define disableSharpeningForClouds

#define Saturation 1.2 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

#define Contrast 1.0 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

#define Vibrance 1.0 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

//#define chromaticAberration

#define chromaticAberrationStrength 0.005 //[0.001 0.002 0.003 0.004 0.005 0.006 0.007 0.008 0.009 0.01]

#define LUTS 0 //[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15]

uniform sampler2D colortex0;
uniform sampler2D colortex4;
uniform sampler2D colortex8;

in vec2 texcoord;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 colortex0Out;

#include "/lib/includes.glsl"

// Lottes 2016, "Advanced Techniques and Optimization of HDR Color Pipelines"
vec3 lottes(vec3 x) {
  const vec3 a = vec3(1.2);
  const vec3 d = vec3(1.0);
  const vec3 hdrMax = vec3(8.0);
  const vec3 midIn = vec3(0.088);
  const vec3 midOut = vec3(0.367);

  const vec3 b =
      (-pow(midIn, a) + pow(hdrMax, a) * midOut) /
      ((pow(hdrMax, a * d) - pow(midIn, a * d)) * midOut);
  const vec3 c =
      (pow(hdrMax, a * d) * pow(midIn, a) - pow(hdrMax, a) * pow(midIn, a * d) * midOut) /
      ((pow(hdrMax, a * d) - pow(midIn, a * d)) * midOut);

  return pow(x, a) / (pow(x, a * d) * b + c);
}

vec2 chromaticAberrationFunction() {
    float dist = distance(texcoord, vec2(0.5));
    float cas = chromaticAberrationStrength*dist;
    float r = texture2D(colortex0,texcoord.xy-vec2(cas,0)).r;
    float b = texture2D(colortex0,texcoord.xy+vec2(cas,0)).b;
    return vec2(r,b);
}

// float luminance(vec3 color) {
//     return dot(color, vec3(0.212, 0.7152, 0.722));
// }

vec3 vibranceFunction(vec3 color) { //Thanks to belmu for the code
    float minChannel       = min(min(color.r,color.g),color.b);
    float maxChannel       = max(max(color.r,color.g),color.b);
    float sat      = (1.0 - clamp(maxChannel - minChannel,0.0,1.0)) * (clamp(1.0 - maxChannel,0.0,1.0) * luminance(color)) * 5.0;
    vec3 lightValue = vec3((minChannel + maxChannel) * 0.5);

    return mix(color, mix(lightValue, color, Vibrance), sat); //diz = vibrance
    // return mix(color, lightValue, (1.0 - lightValue) * (1.0 - Vibrance) * 0.5 * Vibrance); // diz = negative vibrance
}

vec3 saturationFunction(vec3 scolor){
    float mixrgb = (scolor.r + scolor.g + scolor.b) / 3.5;
    float weight = (Saturation) + (1.0 - pow(1.0 - 1.0 * mixrgb, 2.0)) * 0.08;

    return max(mix(vec3(mixrgb), scolor, weight),1e-5);
}

vec3 contrastFunction(vec3 scolor) {
    vec3 l = log2(scolor + 1e-4);
    l = (l + 1.0)*Contrast - 1.0;
    return exp2(l)-1e-4;
}

vec3 contrastAdaptiveSharpening(vec3 color, sampler2D samplerTex) {
    vec3 off1 = texelFetch(samplerTex, ivec2(gl_FragCoord.xy) + ivec2(1.0, 0.0), 0).rgb;
    vec3 off2 = texelFetch(samplerTex, ivec2(gl_FragCoord.xy) + ivec2(0.0, 1.0), 0).rgb;
    vec3 off3 = texelFetch(samplerTex, ivec2(gl_FragCoord.xy) + ivec2(-1.0, 0.0), 0).rgb;
    vec3 off4 = texelFetch(samplerTex, ivec2(gl_FragCoord.xy) + ivec2(0.0, -1.0), 0).rgb;

    float off1Lum = luminance(off1);
    float off2Lum = luminance(off2);
    float off3Lum = luminance(off3);
    float off4Lum = luminance(off4);
    float colLum = luminance(color);

    float minOffLum = min5(off1Lum, off2Lum, off3Lum, off4Lum, colLum);
    float maxOffLum = max5(off1Lum, off2Lum, off3Lum, off4Lum, colLum);

    float sharpeningFactor = sqrt(min(1.0 - maxOffLum, minOffLum) / maxOffLum);
    sharpeningFactor *= mix(-0.125, -0.2, sharpeningStrength);

    float divisionFactor = 4.0 * sharpeningFactor + 1.0;

    return (sharpeningFactor * (off1 + off2 + off3 + off4) + color) / divisionFactor;

}

vec3 getLUT(vec3 color, sampler2D LUT) {
    // color = clamp(color,1e-5,1.0);
    
    const int sideLayerCount = 8;
    const int layerSize = 64;
    const int LUTRes = sideLayerCount * layerSize;
    const int amountOfLUTS = 15;
    const vec2 LUTResolution = vec2(512, 512 * amountOfLUTS);
    
    // Assuming CURRENT_LUT is the selected LUT
    vec2 currentLUTOffset = vec2(0, (LUTS-1) * LUTResolution);
    
    color *= (layerSize - 1); // Colors are [0,1], so this keeps them in the right range
    int blueLayer = int(color.b);
    
    vec2 lowerBlueTexcoord = vec2(
        blueLayer % sideLayerCount,
        blueLayer / sideLayerCount
    ) * layerSize + color.rg + currentLUTOffset;
    
    vec2 upperBlueTexcoord = vec2(
        (blueLayer + 1) % sideLayerCount,
        (blueLayer + 1) / sideLayerCount
    ) * layerSize + color.rg + currentLUTOffset;
    
    vec3 lowerColor = TextureLodLinearRGB(LUT, lowerBlueTexcoord/LUTResolution, LUTResolution, 0).rgb;
    vec3 upperColor = TextureLodLinearRGB(LUT, upperBlueTexcoord/LUTResolution, LUTResolution, 0).rgb;
    
    return mix(lowerColor, upperColor, fract(color.b));
}

// vec3 getLUT(vec3 color, sampler2D LUT) {
//     color = clamp(color,1e-5,1.0);
//     float amountOfLUTS = 15.; //how many LUTS are stored in the texture
//     float LUTile = 8.; //size of a single LUT tile
//     float LUTSize = 64.; //size of a single LUT
//     vec2 LUTResolution = vec2(512, 512*amountOfLUTS); //width of LUT texture, height of LUT texture
//     vec2 LUTResolutionINV = 1.0 / LUTResolution;
//     mat2 LUTGrid = mat2(
//         vec2(1.0, LUTResolutionINV.y * LUTResolution.x),
//         vec2(0.0, (LUTS - 1) * LUTResolutionINV.y * LUTResolution.x)
//     );
//     float LUTileINV = 1./LUTile;

//     // color.b *=LUTileINV;

//     vec2 offset = LUTileINV*vec2(int(color.b)/LUTile, int(color.b)/LUTile);
//     // color.g -= color.g*0.3;
//     // color.r *= 0.9;
//     vec3 LUT0 = textureLod(LUT, vec2(offset+(color.rg*LUTileINV))*LUTGrid[0]+LUTGrid[1],0).rgb;
    
//     return LUT0;
// }

void main() {
	vec3 color = texelFetchShort(colortex0).rgb;
    float cloudsAlpha = texelFetchShort(colortex4).a;

    #ifdef sharpening
        #ifdef disableSharpeningForClouds
        color.rgb = mix(contrastAdaptiveSharpening(color, colortex0), color, cloudsAlpha);
        #else
        color.rgb = contrastAdaptiveSharpening(color, colortex0);
        #endif
    #endif

    #ifdef chromaticAberration
    color.rb = chromaticAberrationFunction();
    #endif

    color = saturationFunction(color);
    color = contrastFunction(color);
    color = vibranceFunction(color);

	color = lottes(color);

	color.rgb = pow(color.rgb, vec3(1.0 / 2.2));

    #if LUTS > 0
    color.rgb = getLUT(color.rgb, colortex8);
    // color.rgb = vec3(texture(colortex8, texcoord).rgb);
    #endif
	// color.rgb = pow(color.rgb, vec3(1.0 / 2.2));

	colortex0Out = vec4(color, 1.0);
}
