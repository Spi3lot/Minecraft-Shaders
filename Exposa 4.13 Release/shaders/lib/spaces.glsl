// #define pixelShadows
// #define shadowPixelAmount 8 //[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 32 64]

const float shadowDistance = 128.0; //[64.0 128.0 256.0 512.0 1024.0]
const int shadowMapResolution = 2048; //[1024 1732 2048 3766 4096]

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferPreviousProjection;
// uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferPreviousModelView;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

vec3 viewSpacePos(in vec2 coord, in float depth) {
    vec3 youShallBecomeVIEWSPACECOORD = vec3(coord,depth)*2.0-1.0;

    return (youShallBecomeVIEWSPACECOORD*vec3(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].z) + gbufferProjectionInverse[3].xyz) / (youShallBecomeVIEWSPACECOORD.z * gbufferProjectionInverse[2].w + gbufferProjectionInverse[3].w);
}

vec3 screenSpacePos(in vec3 coord) {
    vec3 screenspace = (coord*vec3(gbufferProjection[0].x,gbufferProjection[1].y,gbufferProjection[2].z) + gbufferProjection[3].xyz) / (coord.z * gbufferProjection[2].w + gbufferProjection[3].w);

    return screenspace*0.5+0.5;
}

// vec3 screenSpacePosFromWorld(in vec3 coord, in bool cameraPositionAdded) {
//     vec3 viewPos = coord;
//     if(cameraPositionAdded) viewPos -= cameraPosition;
//     viewPos -= gbufferModelViewInverse[3].xyz;
//     viewPos = mat3(gbufferModelView)*viewPos;
//     vec3 screenspace = (viewPos*vec3(gbufferProjection[0].x,gbufferProjection[1].y,gbufferProjection[2].z) + gbufferProjection[3].xyz) / (viewPos.z * gbufferProjection[2].w + gbufferProjection[3].w);

//     return screenspace*0.5+0.5;
// }

vec3 worldSpacePos(in vec2 coord, in float depth) {
    vec3 WorldSpacePos = mat3(gbufferModelViewInverse)*viewSpacePos(coord, depth)+gbufferModelViewInverse[3].xyz;

    return WorldSpacePos + cameraPosition;
}

#define SHADOW_MAP_BIAS 0.85

// vec3 normalss = texelFetch(colortex3, ivec2(gl_FragCoord.xy),0).rgb;
// normalss.b = sqrt(1.0-dot(normalss.xy, normalss.xy));
// //float bias = SHADOW_MAP_BIAS - (clamp(dot(normalize(sunPosition), normalss),0.0,1.0));
float shadowBiasMult = log2(max(4.0, shadowDistance - shadowMapResolution * 0.125)) * 0.15;

vec2 getMultipliedShadowPos(in vec2 pos) {
    return pos*abs(pos)*1.357225;
}

float distortFactor(vec2 position) {
    vec2 multipliedShadowPos = getMultipliedShadowPos(position);
    float dist = pow(dot(multipliedShadowPos, multipliedShadowPos), 0.25);
    float distFac = (1.0 - SHADOW_MAP_BIAS) + dist * SHADOW_MAP_BIAS;
    return distFac;
}

vec2 distortShadow(vec2 position) {
    float distFactor = distortFactor(position);
    return position / distFactor*0.92;
}


#ifndef VSHPROGRAM //Irrelevant for code viewers
vec3 shadowSpacePos(in vec2 coord, in float depth, in vec3 lightVec, in float offsetVal, in vec3 underneathNormal, bool toDistort) {
    vec3 worldSpacePos = worldSpacePos(coord, depth);
    // WorldSpacePos = floor(WorldSpacePos*shadowPixelAmount)/shadowPixelAmount //Possible future feature for nice pixel shadows;

    worldSpacePos -= cameraPosition;
    
    worldSpacePos += mat3(gbufferModelViewInverse)*normalize(lightVec)*offsetVal; //Offset that reduces acne

    vec3 shadowPos = vec3(shadowProjection[0].x, shadowProjection[1].y, shadowProjection[2].z) * (mat3(shadowModelView) * worldSpacePos.xyz + shadowModelView[3].xyz) + shadowProjection[3].xyz;

    shadowPos += vec3(shadowProjection[0].x, shadowProjection[1].y, shadowProjection[2].z) * (mat3(shadowModelView) * underneathNormal) * distortFactor(shadowPos.xy) * shadowBiasMult; //Normal offset to reduce flickering

    if(toDistort) {
        shadowPos.xy = distortShadow(shadowPos.xy);
    } //Apply distortion to shadows if is requested by the function call

    return shadowPos;
}
#endif

vec3 ShadowNDC(vec3 PlayerPos) {
    vec3 shadowView = mat3(shadowModelView)*PlayerPos + shadowModelView[3].xyz;
    return (shadowView*vec3(shadowProjection[0].x, shadowProjection[1].y, shadowProjection[2].z) + shadowProjection[3].xyz) / (shadowView.z * shadowProjection[2].w + shadowProjection[3].w);
}

vec3 shadowVSHDistortion(inout vec3 pos) {
    pos.xy = distortShadow(pos.xy);
    return pos;
}

vec3 toPrevScreenPos(vec2 currScreenPos, float depth){ //code by eldeston and chocapic13
    vec3 currViewPos = vec3(vec3(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].z) * (vec3(currScreenPos,depth) * 2.0 - 1.0) + gbufferProjectionInverse[3].xyz);
    currViewPos /= (gbufferProjectionInverse[2].w * (depth * 2.0 - 1.0) + gbufferProjectionInverse[3].w);
    vec3 currFeetPlayerPos = mat3(gbufferModelViewInverse) * currViewPos + gbufferModelViewInverse[3].xyz;

    vec3 prevFeetPlayerPos = depth > 0.56 ? currFeetPlayerPos + cameraPosition - previousCameraPosition : currFeetPlayerPos;
    vec3 prevViewPos = mat3(gbufferPreviousModelView) * prevFeetPlayerPos + gbufferPreviousModelView[3].xyz;
    vec3 finalPos = vec3(gbufferPreviousProjection[0].x, gbufferPreviousProjection[1].y,gbufferPreviousProjection[2].z) * prevViewPos + gbufferPreviousProjection[3].xyz;
    return (finalPos / -prevViewPos.z) * 0.5 + 0.5;
}