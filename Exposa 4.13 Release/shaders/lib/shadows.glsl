uniform sampler2DShadow shadowtex0;
uniform sampler2DShadow shadowtex1;

uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;

uniform int isEyeInWater;

const float sunPathRotation = -25.0;
const bool shadowHardwareFiltering = true;

#define foliageSSSAmount 2.5 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4.0 4.1 4.2 4.3 4.4 4.5 4.6 4.7 4.8 4.9 5.0 10.0 15.0]

// const vec2[33] shadowSamples = vec2[33] (
//     vec2(0.3834438f, -0.8365879f),
//     vec2(0.2538637f, -0.589553f),
//     vec2(0.6399639f, -0.6070346f),
//     vec2(0.1431894f, -0.8152663f),
//     vec2(0.5930731f, -0.7948953f),
//     vec2(0.6914624f, -0.3480401f),
//     vec2(0.4279022f, -0.4768359f),
//     vec2(0.8242062f, -0.508942f),
//     vec2(0.01053669f, -0.4866286f),
//     vec2(-0.1108985f, -0.7414401f),
//     vec2(0.03328848f, -0.9812139f),
//     vec2(-0.2678958f, -0.3206359f),
//     vec2(0.25712f, -0.229964f),
//     vec2(-0.02783006f, -0.2600488f),
//     vec2(-0.2917352f, -0.6411636f),
//     vec2(-0.4032183f, -0.8573055f),
//     vec2(-0.6612689f, -0.7354062f),
//     vec2(-0.5676314f, -0.5411444f),
//     vec2(-0.2168807f, -0.9072415f),
//     vec2(-0.5580572f, -0.09704394f),
//     vec2(-0.5138885f, -0.3027371f),
//     vec2(-0.1932104f, -0.09702744f),
//     vec2(-0.3822881f, -0.01384046f),
//     vec2(0.8748599f, -0.1630837f),
//     vec2(-0.522255f, 0.2585554f),
//     vec2(-0.749154f, -0.08459146f),
//     vec2(-0.749154f, -0.08459146f),
//     vec2(-0.6647733f, 0.129063f),
//     vec2(-0.8998289f, -0.2349087f),
//     vec2(-0.8098084f, -0.5461301f),
//     vec2(0.5121568f, 0.00675085f),
//     vec2(0.1070659f, -0.05260961f),
//     vec2(0.3009415f, 0.1365128f)
// );

// const vec2[64] shadowSamples = vec2[64] (
//     vec2(0.3834438f, -0.8365879f),
//     vec2(0.2538637f, -0.589553f),
//     vec2(0.6399639f, -0.6070346f),
//     vec2(0.1431894f, -0.8152663f),
//     vec2(0.5930731f, -0.7948953f),
//     vec2(0.6914624f, -0.3480401f),
//     vec2(0.4279022f, -0.4768359f),
//     vec2(0.8242062f, -0.508942f),
//     vec2(0.01053669f, -0.4866286f),
//     vec2(-0.1108985f, -0.7414401f),
//     vec2(0.03328848f, -0.9812139f),
//     vec2(-0.2678958f, -0.3206359f),
//     vec2(0.25712f, -0.229964f),
//     vec2(-0.02783006f, -0.2600488f),
//     vec2(-0.2917352f, -0.6411636f),
//     vec2(-0.4032183f, -0.8573055f),
//     vec2(-0.6612689f, -0.7354062f),
//     vec2(-0.5676314f, -0.5411444f),
//     vec2(-0.2168807f, -0.9072415f),
//     vec2(-0.5580572f, -0.09704394f),
//     vec2(-0.5138885f, -0.3027371f),
//     vec2(-0.1932104f, -0.09702744f),
//     vec2(-0.3822881f, -0.01384046f),
//     vec2(0.8748599f, -0.1630837f),
//     vec2(-0.522255f, 0.2585554f),
//     vec2(-0.749154f, -0.08459146f),
//     vec2(-0.749154f, -0.08459146f),
//     vec2(-0.6647733f, 0.129063f),
//     vec2(-0.8998289f, -0.2349087f),
//     vec2(-0.8098084f, -0.5461301f),
//     vec2(0.5121568f, 0.00675085f),
//     vec2(0.1070659f, -0.05260961f),
//     vec2(0.3009415f, 0.1365128f),
//     vec2(0.5151741f, -0.1867349f),
//     vec2(-0.9284627f, -0.007728597f),
//     vec2(-0.2198475f, 0.3018067f),
//     vec2(-0.07589716f, 0.09244914f),
//     vec2(0.721417f, 0.01370876f),
//     vec2(0.6517887f, 0.1998482f),
//     vec2(0.4209776f, 0.3226621f),
//     vec2(0.9295521f, 0.1595292f),
//     vec2(0.8101555f, 0.3356059f),
//     vec2(0.6216043f, 0.4737987f),
//     vec2(-0.7957394f, 0.4460461f),
//     vec2(-0.578917f, 0.5065681f),
//     vec2(-0.3760341f, 0.4722787f),
//     vec2(0.1558616f, 0.3765588f),
//     vec2(0.4568439f, 0.655364f),
//     vec2(0.08923677f, 0.1941438f),
//     vec2(0.1930917f, 0.5782562f),
//     vec2(-0.07713082f, 0.5275764f),
//     vec2(0.4766026f, 0.8639814f),
//     vec2(-0.7173501f, 0.6784452f),
//     vec2(-0.8751968f, 0.2121847f),
//     vec2(0.8041916f, 0.5765353f),
//     vec2(0.2870654f, 0.9436792f),
//     vec2(0.6502987f, 0.7152798f),
//     vec2(-0.2637711f, 0.7050315f),
//     vec2(-0.03864802f, 0.7925433f),
//     vec2(-0.1051485f, 0.9776039f),
//     vec2(-0.3079708f, 0.9433341f),
//     vec2(-0.5206522f, 0.6986488f),
//     vec2(0.08988898f, 0.9506541f),
//     vec2(0.2821491f, 0.7465457f)
// );

const vec2[20] shadowSamples = vec2[20] (
vec2( 0.3979892083422313f, -0.5604627084529596f ),
vec2( 0.8601683710649567f, -0.09517621659409037f ),
vec2( 0.39054670973632466f, -0.04883636864682017f ),
vec2( 0.9125496439293274f, -0.5251696984535735f ),
vec2( 0.14365044162579366f, -0.8414145355729092f ),

vec2( -0.3979892083422313f, 0.5604627084529596f ),
vec2( -0.8601683710649567f, 0.09517621659409037f ),
vec2( -0.39054670973632466f, 0.04883636864682017f ),
vec2( -0.9125496439293274f, 0.5251696984535735f ),
vec2( -0.14365044162579366f, 0.8414145355729092f ),

vec2( -0.3979892083422313f, -0.5604627084529596f ),
vec2( -0.8601683710649567f, -0.09517621659409037f ),
vec2( -0.39054670973632466f, -0.04883636864682017f ),
vec2( -0.9125496439293274f, -0.5251696984535735f ),
vec2( -0.14365044162579366f, -0.8414145355729092f ),

vec2( 0.3979892083422313f, 0.5604627084529596f ),
vec2( 0.8601683710649567f, 0.09517621659409037f ),
vec2( 0.39054670973632466f, 0.04883636864682017f ),
vec2( 0.9125496439293274f, 0.5251696984535735f ),
vec2( 0.14365044162579366f, 0.8414145355729092f )
);

const float shadowSizeRCPOffset = 1.0/shadowMapResolution;

// float getPenumbraWidth(in vec3 shadowCoord, mat2 rotationMat, out float dBlocker) {
//     float dFragment = shadowCoord.z; //distance from pixel to light
//     float penumbra = 0.0;
    
//     float lightSize  = 12.0;

//     float searchSize = lightSize*0.05;
//     // searchSize = 1.0;
    
//     for (int i = 0; i < shadowSamples.length(); i++) {
//         float angle = 2.4 * i + float(rotationMat) * 6.28;
//         vec3 shadowOffset = vec3(cos(angle), sin(angle), cos(angle)+sin(angle)) *  (1.0 / (shadowSamples.length()));
//         // vec2 shadowOffset = shadowSamples[i] * rotationMat;
//         // vec3 shadowOffset3D = vec3(shadowOffset,sin(shadowOffset.x*shadowOffset.y));
//         shadowOffset *= searchSize*shadowSizeRCPOffset;
//         vec3 sampleCoord = shadowCoord + shadowOffset;
//         dBlocker += texture(shadowtex0, vec3(sampleCoord)).x;
//         // penumbra += max(0.0, (dFragment - dBlocker)) * lightSize / shadowSamples.length();
//       }

// 		dBlocker *= rcp(shadowSamples.length());
// 		penumbra = (dFragment - dBlocker) * lightSize;

//     return penumbra;
// }


void shadows(in vec3 shadowCoord, in mat2 rotationMatrix, in bool waterMask, inout float shadow, inout vec3 shadowsColored) {
    vec4 tempColor = vec4(0.0);

    for (int i = 0; i < shadowSamples.length(); i++) {
        vec2 shadowOffset = shadowSamples[i];
        shadowOffset *= rotationMatrix;
        shadowOffset *= shadowSizeRCPOffset;
        if(foliageMask) shadowOffset *= foliageSSSAmount;

        vec3 offsetedPos = vec3(shadowCoord.xy + shadowOffset, shadowCoord.z);

        // vec3 distortedPos = shadowVSHDistortion(shadowCoord)*0.5+0.5; //Apply distortion after applying offset

        float shadow0Sample = texture2D(shadowtex0, offsetedPos);
        float shadow1Sample = texture2D(shadowtex1, offsetedPos);

        bool shadowMask = abs(shadow1Sample-shadow0Sample)>0.1;

        bool tempMask = isEyeInWater == 0 && !waterMask;
        shadow += shadow1Sample;

        if (shadowMask) {
            if (tempMask) tempColor += texture2D(shadowcolor0, offsetedPos.xy) + 0.7;

        } else tempColor.rgb += vec3(1.0);

    }

    tempColor /= shadowSamples.length();
    shadow /= shadowSamples.length();

    shadowsColored = mix(shadowsColored, tempColor.rgb*tempColor.rgb, sqrt(tempColor.a));
}
