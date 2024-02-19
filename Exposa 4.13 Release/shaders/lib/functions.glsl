#include "/lib/spaces.glsl"

#define ditherStrength 0.1 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.25 1.5 1.75 2.0]
#define rrSamples 1 //[1 2 3 4 5 6 7 8 9 10]
#define rrRayTracingSamples 32 //[16 32 64 128]

uniform sampler2D noisetex;
// uniform sampler2D colortex13;
uniform sampler2D colortex13;
uniform sampler3D colortex14;

uniform float near;
uniform float far;
uniform float aspectRatio;

uniform int frameCounter;

uniform vec3 upPosition;


#define rcp(x) (1.0/(x))


float clamp01(float x) {
    return clamp(x,0.0,1.0);
}

vec2 clamp01(vec2 x) {
    return clamp(x,0.0,1.0);
}

vec3 clamp01(vec3 x) {
    return clamp(x,0.0,1.0);
}

vec4 clamp01(vec4 x) {
    return clamp(x,0.0,1.0);
}


float lind(float depth) {
    return (near * far) / (depth * (near - far) + far);
}


int pow2(int x) {
    return x*x;
}

float pow2(float x) {
    return x*x;
}

vec2 pow2(vec2 x) {
    return x*x;
}

vec3 pow2(vec3 x) {
    return x*x;
}

vec4 pow2(vec4 x) {
    return x*x;
}


float luminance(vec3 color) {
    return dot(color, vec3(0.212, 0.7152, 0.072));
}

float max3(float x1, float x2, float x3) {
    return max(max(x1,x2),x3);
}

float min3(float x1, float x2, float x3) {
    return min(min(x1,x2),x3);
}

float max5(float x1, float x2, float x3, float x4, float x5) {
    return max(max(max(x1,x2),max(x3,x4)),x5);
}

float min5(float x1, float x2, float x3, float x4, float x5) {
    return min(min(min(x1,x2),min(x3,x4)),x5);
}

float max8(float x1, float x2, float x3, float x4, float x5, float x6, float x7, float x8) {
    return max(max5(x1,x2,x3,x4,x5),max3(x6,x7,x8));
}

float min8(float x1, float x2, float x3, float x4, float x5, float x6, float x7, float x8) {
    return min(min5(x1,x2,x3,x4,x5),min3(x6,x7,x8));
}

vec2 max3(vec2 x1, vec2 x2, vec2 x3) {
    return max(max(x1,x2),x3);
}

vec2 min3(vec2 x1, vec2 x2, vec2 x3) {
    return min(min(x1,x2),x3);
}

vec2 max5(vec2 x1, vec2 x2, vec2 x3, vec2 x4, vec2 x5) {
    return max(max(max(x1,x2),max(x3,x4)),x5);
}

vec2 min5(vec2 x1, vec2 x2, vec2 x3, vec2 x4, vec2 x5) {
    return min(min(min(x1,x2),min(x3,x4)),x5);
}

vec2 max8(vec2 x1, vec2 x2, vec2 x3, vec2 x4, vec2 x5, vec2 x6, vec2 x7, vec2 x8) {
    return max(max5(x1,x2,x3,x4,x5),max3(x6,x7,x8));
}

vec2 min8(vec2 x1, vec2 x2, vec2 x3, vec2 x4, vec2 x5, vec2 x6, vec2 x7, vec2 x8) {
    return min(min5(x1,x2,x3,x4,x5),min3(x6,x7,x8));
}

vec3 max3(vec3 x1, vec3 x2, vec3 x3) {
    return max(max(x1,x2),x3);
}

vec3 min3(vec3 x1, vec3 x2, vec3 x3) {
    return min(min(x1,x2),x3);
}

vec3 max5(vec3 x1, vec3 x2, vec3 x3, vec3 x4, vec3 x5) {
    return max(max(max(x1,x2),max(x3,x4)),x5);
}

vec3 min5(vec3 x1, vec3 x2, vec3 x3, vec3 x4, vec3 x5) {
    return min(min(min(x1,x2),min(x3,x4)),x5);
}

vec3 max8(vec3 x1, vec3 x2, vec3 x3, vec3 x4, vec3 x5, vec3 x6, vec3 x7, vec3 x8) {
    return max(max5(x1,x2,x3,x4,x5),max3(x6,x7,x8));
}

vec3 min8(vec3 x1, vec3 x2, vec3 x3, vec3 x4, vec3 x5, vec3 x6, vec3 x7, vec3 x8) {
    return min(min5(x1,x2,x3,x4,x5),min3(x6,x7,x8));
}

vec4 max3(vec4 x1, vec4 x2, vec4 x3) {
    return max(max(x1,x2),x3);
}

vec4 min3(vec4 x1, vec4 x2, vec4 x3) {
    return min(min(x1,x2),x3);
}

vec4 max5(vec4 x1, vec4 x2, vec4 x3, vec4 x4, vec4 x5) {
    return max(max(max(x1,x2),max(x3,x4)),x5);
}

vec4 min5(vec4 x1, vec4 x2, vec4 x3, vec4 x4, vec4 x5) {
    return min(min(min(x1,x2),min(x3,x4)),x5);
}

vec4 max8(vec4 x1, vec4 x2, vec4 x3, vec4 x4, vec4 x5, vec4 x6, vec4 x7, vec4 x8) {
    return max(max5(x1,x2,x3,x4,x5),max3(x6,x7,x8));
}

vec4 min8(vec4 x1, vec4 x2, vec4 x3, vec4 x4, vec4 x5, vec4 x6, vec4 x7, vec4 x8) {
    return min(min5(x1,x2,x3,x4,x5),min3(x6,x7,x8));
}

float minChannel(vec3 x) {
    return min(min(x.x,x.y),x.z);
}

float minChannel(vec2 x) {
    return min(x.x,x.y);
}

// float sum2(float x1, float x2) {
//     return x1+x2;
// }

// vec2 sum2(vec2 x1, vec2 x2) {
//     return x1+x2;
// }

// vec3 sum2(vec3 x1, vec3 x2) {
//     return x1+x2;
// }

// float sum3(float x1, float x2, float x3) {
//     return x1+x2+x3;
// }

// vec2 sum3(vec2 x1, vec2 x2, vec2 x3) {
//     return x1+x2+x3;
// }

// vec3 sum3(vec3 x1, vec3 x2, vec3 x3) {
//     return x1+x2+x3;
// }

// float sum4(float x1, float x2, float x3, float x4) {
//     return x1+x2+x3+x4;
// }

// vec2 sum4(vec2 x1, vec2 x2, vec2 x3, vec2 x4) {
//     return x1+x2+x3+x4;
// }

// vec3 sum4(vec3 x1, vec3 x2, vec3 x3, vec3 x4) {
//     return x1+x2+x3+x4;
// }


vec3 max0(vec3 x) {
    return max(x, vec3(0.0));
}

vec2 max0(vec2 x) {
    return max(x, vec2(0.0));
}

float max0(float x) {
    return max(x, float(0.0));
}


// float rcp(float x) {
//     return 1.0 / x;
// }

// vec2 rcp(vec2 x) {
//     return vec2(1.0) / x;
// }

// vec3 rcp(vec3 x) {
//     return vec3(1.0) / x;
// }


mat2 rotationMatrix(in vec2 coord) {
    float rotationAmount = texture2D(noisetex, coord * vec2(viewWidth / noiseTextureResolution, viewHeight / noiseTextureResolution)).r;
    return mat2(
        cos(rotationAmount), -sin(rotationAmount),
        sin(rotationAmount), cos(rotationAmount)
    );
}

mat2 rotationMatrix(float a) {
    float s = sin(a), c=cos(a);
    return mat2(c, -s, s, c);
}

mat3 tbnNormalTangent(vec3 normal, vec3 tangent) {
    vec3 bitangent = cross(normal, tangent);
    return mat3(tangent, bitangent, normal);
}

mat3 tbnNormal(vec3 normal) {
    vec3 tangent = normalize(cross(normal, vec3(0, 1, 1)));
    return tbnNormalTangent(normal, tangent);
}


float bayer2(in vec2 coord){
    coord = floor(coord);
    return fract( dot(coord, vec2(.5, coord.y * .75)) );
}

#define bayer4(coord)   (bayer2( .5*(coord))*.25+bayer2(coord))
#define bayer8(coord)   (bayer4( .5*(coord))*.25+bayer2(coord))
#define bayer16(coord)  (bayer8( .5*(coord))*.25+bayer2(coord))
#define bayer32(coord)  (bayer16(.5*(coord))*.25+bayer2(coord))
#define bayer64(coord)  (bayer32(.5*(coord))*.25+bayer2(coord))
#define bayer128(coord)  (bayer64(.5*(coord))*.25+bayer2(coord))


vec3 uniformSphereSample(vec2 hash) {
    hash.x *= TAU; hash.y = 2.0 * hash.y - 1.0;
    return vec3(vec2(sin(hash.x), cos(hash.x)) * sqrt(1.0 - hash.y * hash.y), hash.y);
}

vec3 uniformHemisphereSample(vec3 vector, vec2 hash) {
    vec3 dir = uniformSphereSample(hash);
    return dot(dir, vector) < 0.0 ? -dir : dir;
}

// https://amietia.com/lambertnotangent.html
vec3 cosineWeightedHemisphereSample(vec3 vector, vec2 hash) {
    vec3 dir = normalize(uniformSphereSample(hash) + vector);
    return dot(dir, vector) < 0.0 ? -dir : dir;
}

void pcg(inout uint seed) { //noise by https://www.pcg-random.org/
    uint state = seed * 747796405u + 2891336453u;
    uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    seed = (word >> 22u) ^ word;
}

uint rngState = 185730u * uint(frameCounter) + uint(gl_FragCoord.x + gl_FragCoord.y * viewWidth);
float randF() { pcg(rngState); return float(rngState) / float(0xffffffffu); }


vec3 binaryRF(in vec3 screenPos, in vec3 screenDir) {
    for(int i = 0; i < 4; i++) {
        float depth = texture2D(depthtex0, screenPos.xy).x;
        screenPos = screenPos + (screenDir * sign(depth-screenPos.z));
        screenDir *= 0.5; //reduce each sample for binary refinement
    }
    return screenPos;
}

vec2 Rand2(vec2 p) {
    return fract(sin(vec2(dot(p, vec2(25.6, 35.7)), dot(p, vec2(16.2, 95.5))))*.005);
}

bool rayTrace(float stepLength, int samples, vec3 viewPos, float dither, vec3 reflectedVector, inout vec3 reflectedScreenPos, float ditherMult, bool depthComparison) {//function by Tech, modified by me

    float stepSize = stepLength/samples;

    vec3 startPos = reflectedScreenPos;

    vec3 screenDirection = normalize(screenSpacePos(viewPos + reflectedVector) - reflectedScreenPos);

    if(stepLength < 1e-4) stepSize =  minChannel((sign(screenDirection) - reflectedScreenPos)*rcp(screenDirection)) * rcp(samples); //DDA

    screenDirection *= stepSize;

    reflectedScreenPos += dither*ditherMult * screenDirection;

    for (int i = 0; i < samples; i++) {
        reflectedScreenPos += screenDirection;

        if(clamp(reflectedScreenPos, 0.0, 1.0) != reflectedScreenPos) break;

        float reflectedDepth = textureLod(depthtex0, reflectedScreenPos.xy,0).x;

        bool depthCheck = reflectedScreenPos.z > reflectedDepth && !(reflectedDepth < 0.56);

        if(depthComparison) {
            depthCheck = reflectedScreenPos.z > reflectedDepth && !(reflectedDepth < 0.56) && reflectedDepth > startPos.z;
        }


        if(depthCheck)
        {


            // reflectedScreenPos = binaryRF(reflectedScreenPos,screenDirection);
            return true;

        }
        // reflectedScreenPos += screenDirection*stepSize;

    }

    return false;
}


bool rayTrace2(float stepLength, int samples, vec3 viewPos, float dither, vec3 reflectedVector, inout vec3 reflectedScreenPos, float ditherMult, bool depthComparison) {//function by Tech, modified by me

    float stepSize = stepLength/samples;

    vec3 screenDirection = normalize(reflectedVector) * -viewPos.z;


    // screenDirection += 0.1;

    reflectedScreenPos += dither*ditherMult * screenDirection;

    vec3 projectedCoord = vec3(0.0);

    for (int i = 0; i < samples; i++) {
        viewPos += (screenDirection*stepSize);
        // viewPos -= viewPos.z;

        projectedCoord = screenSpacePos(viewPos);

        float reflectedDepth = texture2D(depthtex1, projectedCoord.xy).x;

        bool depthCheck = projectedCoord.z > reflectedDepth;

        if(depthComparison) depthCheck = (screenDirection.z - (viewPos.z-reflectedDepth))<1.2;

        // if(clamp(projectedCoord, 0.0, 1.0) != projectedCoord) break;

        if(depthCheck)
        {
            // reflectedScreenPos = binaryRF(reflectedScreenPos,screenDirection);

            return true;

        }
        // reflectedScreenPos += screenDirection*stepSize;

        reflectedScreenPos = projectedCoord;
    }

    return true;
}


// const float gaussianWeight[25] = float[](
//    5.960464477539063e-8,
//    0.000001430511474609375,
//    0.000016450881958007812,
//    0.00012063980102539062,
//    0.0006333589553833008,
//    0.002533435821533203,
//    0.008022546768188477,
//    0.020629405975341797,
//    0.04383748769760132,
//    0.07793331146240234,
//    0.11689996719360352,
//    0.14878177642822266,
//    0.1611802577972412,
//    0.14878177642822266,
//    0.11689996719360352,
//    0.07793331146240234,
//    0.04383748769760132,
//    0.020629405975341797,
//    0.008022546768188477,
//    0.002533435821533203,
//    0.0006333589553833008,
//    0.00012063980102539062,
//    0.000016450881958007812,
//    0.000001430511474609375,
//    5.960464477539063e-8
// );

// vec3 basicGuassianBlur(sampler2D samplerTex, float scale) {
// 	int samples = int(gaussianWeight.length());
// 	vec3 blur = vec3(0.0);
// 	for(int x=-samples; x < samples; x++) {
// 	    for(int y=-samples; y < samples; y++) {
// 		// blur += texture2D(samplerTex, coordinates + vec2(x,y) * gaussianWeight[x]*gaussianWeight[y]*vec2(viewWidth,viewHeight),0).rgb;
//         blur += texelFetch(samplerTex, ivec2(gl_FragCoord.xy*scale) + ivec2(x,y),0).rgb*gaussianWeight[x+13]*gaussianWeight[y+13];
// 	    }
//     }

// 	return blur;
// }

float guassianWeight(float sigma, float x) {
    return exp(-pow2(x) / (2.0 * pow2(sigma)));
}

float linearDepth = lind(depth);
float linearDepth1 = lind(depth1);

float depthWeightedGuassianBlur(sampler2D samplerTex, float scale, sampler2D samplerDepth, float sigmaV, int size) {
    float g_sigmaV = 0.03 * pow2(sigmaV) + 0.001;

    float g_sigmaX = 3.0;
    float g_sigmaY = 3.0;

    const int samples = 4;

    float total = 0.0;
    float accum = 0.0;

    for (float x = -samples; x <= samples; x++) {
        float fx = guassianWeight(g_sigmaY, x);

        for (float y = -samples; y <= samples; y++) {
            float fy = guassianWeight(g_sigmaX, y);

            ivec2 coordOffset = size*ivec2(x, y);

            float sampleValue = texelFetch(samplerTex, ivec2(gl_FragCoord.xy*scale)+coordOffset, 0).x;

            float sampleDepth = texelFetch(samplerDepth, ivec2(gl_FragCoord.xy*scale)+coordOffset, 0).x;
            float sampleLinearDepth = lind(sampleDepth);
            float lindasd = lind(texelFetch(samplerDepth, ivec2(gl_FragCoord.xy*scale),0).x);

            float fv = exp(-abs(lindasd - sampleLinearDepth));

            float weight = fx*fy*fv;
            accum += weight * sampleValue;
            total += weight;
            // accum = fv;
        }
    }

    return accum/max(1e-5,total);
}


vec3 neighbourhoodClamping(sampler2D samplerTex, vec3 color, vec3 tempColor){
	vec3 coltl = texelFetch(samplerTex,ivec2(gl_FragCoord.xy)+ivec2(-1.0,-1.0),0).rgb;
	vec3 coltm = texelFetch(samplerTex,ivec2(gl_FragCoord.xy)+ivec2( 0.0,-1.0),0).rgb;
	vec3 coltr = texelFetch(samplerTex,ivec2(gl_FragCoord.xy)+ivec2( 1.0,-1.0),0).rgb;
	vec3 colml = texelFetch(samplerTex,ivec2(gl_FragCoord.xy)+ivec2(-1.0, 0.0),0).rgb;
	vec3 colmr = texelFetch(samplerTex,ivec2(gl_FragCoord.xy)+ivec2( 1.0, 0.0),0).rgb;
	vec3 colbl = texelFetch(samplerTex,ivec2(gl_FragCoord.xy)+ivec2(-1.0, 1.0),0).rgb;
	vec3 colbm = texelFetch(samplerTex,ivec2(gl_FragCoord.xy)+ivec2( 0.0, 1.0),0).rgb;
	vec3 colbr = texelFetch(samplerTex,ivec2(gl_FragCoord.xy)+ivec2( 1.0, 1.0),0).rgb;

	vec3 minclr = min(color,min8(coltl,coltm,coltr,colml,colmr,colbl,colbm,colbr));
	vec3 maxclr = max(color,max8(coltl,coltm,coltr,colml,colmr,colbl,colbm,colbr));

	return clamp(tempColor,minclr,maxclr);
}

vec4 neighbourhoodClampingClouds(sampler2D samplerTex, float res, vec4 color, vec4 tempColor){
	vec4 coltl = texelFetch(samplerTex,ivec2(gl_FragCoord.xy*res)+ivec2(-1.0,-1.0),0);
	vec4 coltm = texelFetch(samplerTex,ivec2(gl_FragCoord.xy*res)+ivec2( 0.0,-1.0),0);
	vec4 coltr = texelFetch(samplerTex,ivec2(gl_FragCoord.xy*res)+ivec2( 1.0,-1.0),0);
	vec4 colml = texelFetch(samplerTex,ivec2(gl_FragCoord.xy*res)+ivec2(-1.0, 0.0),0);
	vec4 colmr = texelFetch(samplerTex,ivec2(gl_FragCoord.xy*res)+ivec2( 1.0, 0.0),0);
	vec4 colbl = texelFetch(samplerTex,ivec2(gl_FragCoord.xy*res)+ivec2(-1.0, 1.0),0);
	vec4 colbm = texelFetch(samplerTex,ivec2(gl_FragCoord.xy*res)+ivec2( 0.0, 1.0),0);
	vec4 colbr = texelFetch(samplerTex,ivec2(gl_FragCoord.xy*res)+ivec2( 1.0, 1.0),0);

	vec4 minclr = min(color,min8(coltl,coltm,coltr,colml,colmr,colbl,colbm,colbr));
	vec4 maxclr = max(color,max8(coltl,coltm,coltr,colml,colmr,colbl,colbm,colbr));

	return clamp(tempColor,minclr,maxclr);
}


float fractDither(float dither) {
    return fract(dither + frameTimeCounter*14);
}

vec2 fractDither(vec2 dither) {
    return fract(dither + frameTimeCounter*14);
}


float noiseTexSample(in vec2 coord, in float size, in vec2 offset) {
    coord *= vec2(viewWidth, viewHeight);
    coord *= size;
    coord += offset;
    coord /= noiseTextureResolution;
    return texture2D(noisetex, coord).x;
}

float noiseTexSampleClouds(in vec2 coord, in float size, in vec2 offset) {
    coord *= size;
    coord += offset;
    coord /= 15;
    return texture2D(noisetex, coord).x;
}

float noiseTexSamplePudldes(in vec2 coord, in float size, in vec2 offset) {
    coord *= size;
    coord += offset;
    coord /= 15;
    return texture2DLod(noisetex, coord, 4.0).x;
}

float sixthSurgeNoiseSample(in vec3 pos, in float size) {
    pos *= size;
    return 1.0 - texture(colortex14, pos).x;
}

float blueNoiseSample(in vec2 coord, in float size, in vec2 offset) {
    coord *= vec2(viewWidth, viewHeight);
    coord *= size;
    coord += offset;
    coord /= noiseTextureResolution;
    return textureLod(colortex13, coord,0).x;
}

// vec2 noiseTexSample(in vec2 coord, in float size, in vec2 offset) {
//     coord *= vec2(viewWidth, viewHeight);
//     coord *= size;
//     coord += offset;
//     coord /= noiseTextureResolution;
//     return texture2D(noisetex, coord).xy;
// }


vec4 texelFetchShort(in sampler2D samplerTex) {
    return texelFetch(samplerTex, ivec2(gl_FragCoord.xy),0);
}


float waterH(vec3 wpos) {
    wpos.x += sin(wpos.x+frameTimeCounter*2.0)*0.25*(1.0+rainStrength);
	wpos.z += cos(wpos.z+frameTimeCounter*2.0)*0.25*(1.0+rainStrength);

	wpos.x += (frameTimeCounter*2.0)*0.25*(1.0+rainStrength);
	wpos.z += (frameTimeCounter*2.0)*0.25*(1.0+rainStrength);

    vec2 tick = vec2(0.0);

    float noise = noiseTexSampleClouds(wpos.xz, 0.42, tick);
        noise += noiseTexSampleClouds(wpos.xz, 0.6, tick*1.2)*0.25;
        // noise += noiseTexSampleClouds(rpos.xz, 1.4, tick*1.5)*0.125;
        // noise += noiseTexSampleClouds(rpos.xz, 1.6, tick*1.9)*0.0125;
        // noise += noiseTexSampleClouds(rpos.xz, 2.6, tick*3.9)*0.00125;

    return noise;
}

float waterH2(vec3 wpos) {
    float windAnim = frameTimeCounter*2.0;

    vec2 tick = vec2(windAnim, 0.0);

    vec3 rpos = wpos;
    // rpos.x *= 0.5;
    rpos.xz *= 0.1;

	// rpos.x += sin(rpos.x+frameTimeCounter)*0.125;
	// rpos.z += cos(rpos.z+frameTimeCounter)*0.125;
    float noise = noiseTexSample(rpos.xz, 0.2, tick);
        noise += noiseTexSample(rpos.xz, 0.4, tick)*0.025;
        noise += noiseTexSample(rpos.xz, 0.8, tick)*0.0125;
        noise += noiseTexSample(rpos.xz, 1.6, tick)*0.00125;
        noise += noiseTexSample(rpos.xz, 2.4, tick)*0.000125;

    return noise * 1.5;
}

float voronoiNoise(vec3 p) {
    p *= 0.075;
    p.z *= 0.25;
    float minDist = 1.0;
    // float noise = waterH(p);
    float divider = 0.9;
    float adder = 0.1;
    for(int i = 0; i < 5; i++) {
                vec2 offsetedPosition = p.xz + normalize(rotationMatrix(float(i)*5.)*vec2(-1.0, 0.5));
                offsetedPosition += adder;
                vec2 random = Rand2(offsetedPosition/divider);
                random = sin(6.28*random)*0.5+0.5;
                minDist = min(minDist, length(random));
                p += minDist*.2;
                divider *= 0.8;
                adder *= 5.5;
    }
    return max0(minDist*1.0);
}

#define waterBumpness 2.1

vec3 waterN(vec3 wpos) {

	wpos.x += sin(wpos.x+frameTimeCounter*2.0)*0.25*(1.0+rainStrength);
	wpos.z += cos(wpos.z+frameTimeCounter*2.0)*0.25*(1.0+rainStrength);

	wpos.x += (frameTimeCounter*2.0)*0.25*(1.0+rainStrength);
	wpos.z += (frameTimeCounter*2.0)*0.25*(1.0+rainStrength);


	float dist = 1.90;

    vec3 p1 = wpos + vec3(dist, 0., -dist);
    vec3 p2 = wpos + vec3(-dist, 0., dist);
    vec3 p3 = wpos + vec3(-dist, 0., -dist);

    float h1 = voronoiNoise(p1);
    float h2 = voronoiNoise(p2);
    float h3 = voronoiNoise(p3);

    vec3 waterNormal = normalize(cross(vec3(p2.xz - p1.xz, h2 - h1), vec3(p3.xz - p1.xz, h3 - h1)));
	// float bumpness = waterBumpness*lightMap.y;
    float bumpness = waterBumpness;
	waterNormal = waterNormal * bumpness + vec3(vec2(0.0), 1.0 - bumpness);

    return waterNormal;
}


#define getAngle(x) (0.07 / (pow2(x) + 0.07))


const float rcpLog10 = 1./log(10.0); //optimization purposes, doing a constant division is faster

float log10(float x) {
    return log(x) * rcpLog10; //multipication is faster than division
}


float luminance2(vec3 color) {
    return dot(color, vec3(0.1, 0.2, 0.2));
}


float lift(float x, float amount)
{
    return (1.0 + amount) * x / (amount * x + 1.0);
}

vec3 lift(vec3 x, float amount)
{
    return (1.0 + amount) * x / (amount * x + 1.0);
}

float xsqrtx(float x) {
    return x*sqrt(x);
}

float henyeyGreensteinPhase(float nu, float g) {
    float isotropicPhase = 0.25/PI;
    float gg = g * g;

    return (isotropicPhase - isotropicPhase * gg) / xsqrtx(1.0 + gg - 2.0 * g * nu);
}


float blackbodyRed(float temp) {
	
	float red = 0.0; 
	
	if ( temp <= 6600. ) {
		
		red = 1.;
	}
	else {
		temp = temp - 6000.;
		
		temp = temp / 100.;
		
		red = 1.29293618606274509804 * pow(temp, -0.1332047592);
		
		if (red < 0.) {
			red = 0.;
		}
		else if (red > 1.) {
			red = 1.;
		}
	}
	
	return red;
}

float blackbodyGreen(float temp) {
	
	float green = 0.0; 
	
	if ( temp <= 6600. ) {
		temp = temp / 100.;
		
		green = 0.39008157876901960784 * log(temp) - 0.63184144378862745098;
		
		if (green < 0.) {
			green = 0.;
		}
		else if (green > 1.) {
			green = 1.;
		}
	}
	else {
		temp = temp - 6000.;
		
		temp = temp / 100.;
	
		green = 1.12989086089529411765 * pow(temp, -0.0755148492);
		
		if (green < 0.) {
			green = 0.;
		}
		else if (green > 1.) {
			green = 1.;
		}
	}
	
	return green;
}

float blackbodyBlue(float temp) {
	
	float blue = 0.0;
	
	if ( temp <= 1900. ) {
		blue = 0.;
	}
	else if ( temp >= 6600.) {
		blue = 1.;
	}
	else {	
		temp = temp / 100.;
		
		blue = .00590528345530083 * pow(temp, 1.349167257362226); // R^2 of power curve fit: 0.9996
		blue = 0.54320678911019607843 * log(temp - 10.0) - 1.19625408914;
		
		if (blue < 0.) {
			blue = 0.;
		}
		else if (blue > 1.) {
			blue = 1.;
		}
	}
	
	return blue;
}

vec3 blackBodyColor(float temp) { //https://www.shadertoy.com/view/llsGDB
    return vec3(blackbodyRed(temp),blackbodyGreen(temp),blackbodyBlue(temp));
}


float cubeSmooth(float x) {
    return (x*x) * (3.0-2.0*x);
}


vec3 calcNormal(vec3 pos) {
    return normalize(cross(dFdx(pos), dFdy(pos)));
}


vec2 GetLinearCoords(const in vec2 texcoord, const in vec2 texSize, out vec2 uv[4]) {
    vec2 f = fract(texcoord * texSize);
    vec2 pixelSize = 1.0 / texSize;

    uv[0] = texcoord - f*pixelSize;
    uv[1] = uv[0] + vec2(1.0, 0.0)*pixelSize;
    uv[2] = uv[0] + vec2(0.0, 1.0)*pixelSize;
    uv[3] = uv[0] + vec2(1.0, 1.0)*pixelSize;

    return f;
}

vec2 GetLinearCoords(const in vec2 texcoordFull, out ivec2 uv[4]) {
    vec2 f = fract(texcoordFull);

    ivec2 iuv[4];
    iuv[0] = ivec2(texcoordFull - f);
    iuv[1] = iuv[0]+ivec2(1, 0);
    iuv[2] = iuv[0]+ivec2(0, 1);
    iuv[3] = iuv[0]+ivec2(1, 1);

    return f;
}

float LinearBlend4(const in vec4 samples, const in vec2 f) {
    float x1 = mix(samples[0], samples[1], f.x);
    float x2 = mix(samples[2], samples[3], f.x);
    return mix(x1, x2, f.y);
}

vec3 LinearBlend4(const in vec3 samples[4], const in vec2 f) {
    vec3 x1 = mix(samples[0], samples[1], f.x);
    vec3 x2 = mix(samples[2], samples[3], f.x);
    return mix(x1, x2, f.y);
}

vec3 TextureLodLinearRGB(const in sampler2D samplerTex, const in vec2 uv[4], const in int lod, const in vec2 f) { //Linear interpolation lod sampling code thanks to null!
    vec3 samples[4];
    samples[0] = textureLod(samplerTex, uv[0], lod).rgb;
    samples[1] = textureLod(samplerTex, uv[1], lod).rgb;
    samples[2] = textureLod(samplerTex, uv[2], lod).rgb;
    samples[3] = textureLod(samplerTex, uv[3], lod).rgb;
    return LinearBlend4(samples, f);
}


vec3 TextureLodLinearRGB(const in sampler2D samplerTex, const in vec2 texcoord, const in vec2 texSize, const in int lod) {
    vec2 uv[4];
    vec2 f = GetLinearCoords(texcoord, texSize, uv);
    return TextureLodLinearRGB(samplerTex, uv, lod, f);
}


// vec3 GGXVNDFS(vec3 fdir, vec2 s, float r) { //fdir is the direction s is the seed aka noise and r is the roughness
//     float a = pow(r, 2.); // the alpha
//     vec3 fn = vec3(a*fdir.xy,fdir.z);
//     fdir = normalize(fn);
//     float l = dot(fdir.yx,fdir.yx);
//     vec3 T1 = vec3(l > 0.0 ? vec2(-fdir.y, fdir.x) * inversesqrt(l) : vec2(1.0, 0.0), 0.0);
//     vec3 T2 = cross(T1, fdir);
//     float dither = sqrt(s.x);
//     float phi = 6.28 * s.y;
//     float t1 = dither * cos(phi);
//     float tmp = clamp(1.0-pow(t1,2.0),0.0,1.0);
//     float t2 = mix(sqrt(tmp), dither * sin(phi), 0.5+ 0.5 * fdir.z);
//     vec3 rh = (t1 * T1) + (t2 * T2) + sqrt(clamp(tmp - pow(t2, 2.0), 0.0, 1.0)) * fdir;
    
//     return normalize(vec3(a * rh.xy, rh.z));
// }

vec3 SampleVNDFGGX(
    vec3 viewerDirection, // Direction pointing towards the viewer, oriented such that +Z corresponds to the surface normal
    vec2 alpha, // Roughness parameter along X and Y of the distribution
    vec2 xy // Pair of uniformly distributed numbers in [0, 1)
) {
    // Transform viewer direction to the hemisphere configuration
    viewerDirection = normalize(vec3(alpha * viewerDirection.xy, viewerDirection.z));

    // Sample a reflection direction off the hemisphere
    const float tau = 6.2831853; // 2 * pi
    float phi = tau * xy.x;
    float cosTheta = (1.0 - xy.y) * (1.0 + viewerDirection.z) -viewerDirection.z;
    float sinTheta = sqrt(clamp(1.0 - cosTheta * cosTheta, 0.0, 1.0));
    vec3 reflected = vec3(vec2(cos(phi), sin(phi)) * sinTheta, cosTheta);

    // Evaluate halfway direction
    // This gives the normal on the hemisphere
    vec3 halfway = reflected + viewerDirection;

    // Transform the halfway direction back to hemiellispoid configuation
    // This gives the final sampled normal
    return normalize(vec3(alpha * halfway.xy, halfway.z));
}

vec3 fresnelDieletricConductor(vec3 eta, vec3 etaK, float cosTheta) {  
   float cosTheta2 = cosTheta * cosTheta;
   float sinTheta2 = 1.0 - cosTheta2;
   vec3 eta2  = eta * eta;
   vec3 etaK2 = etaK * etaK;

   vec3 t0   = eta2 - etaK2 - sinTheta2;
   vec3 a2b2 = sqrt(t0 * t0 + 4.0 * eta2 * etaK2);
   vec3 t1   = a2b2 + cosTheta2;
   vec3 a    = sqrt(0.5 * (a2b2 + t0));
   vec3 t2   = 2.0 * a * cosTheta;
   vec3 Rs   = (t1 - t2) / (t1 + t2);

   vec3 t3 = cosTheta2 * a2b2 + sinTheta2 * sinTheta2;
   vec3 t4 = t2 * sinTheta2;   
   vec3 Rp = Rs * (t3 - t4) / (t3 + t4);

   return clamp01((Rp + Rs) * 0.5);
}


float F0toIOR(float F0) {
    return (1.0 + sqrt(F0)) / (1.0 - sqrt(F0));
}

vec3 metalIOR[8] = vec3[8](
    vec3(2.9114, 2.9497, 2.5845), //iron
    vec3(0.18299,0.42108,1.3734), //gold
    vec3(1.3456,0.96521,0.61722), //aluminium
    vec3(3.1071,3.1812,2.320), //chrome
    vec3(0.27105,0.67693,1.3164), //copper
    vec3(1.91,1.83,1.44), //lead
    vec3(2.3757,2.0847,1.8453), //platinum
    vec3(0.15943,0.14512,0.13547) //silver
);
vec3 metalExCoEf[8] = vec3[8](
    vec3(3.0893, 2.9318, 2.767), //Iron
    vec3(3.4242, 2.3459, 1.7704), //Gold
    vec3(7.4746, 6.3995, 5.3031), //Aluminium
    vec3(3.3314, 3.3291, 3.135), //Chrome
    vec3(3.6092, 2.6248, 2.2921), //Copper
    vec3(3.51, 3.4, 3.18), //Lead
    vec3(4.2655, 3.7153, 3.1365), //Platinium
    vec3(3.9291, 3.19, 2.3808) //Silver
);

vec3 ssrRough(inout vec3 screenPos, vec3 fragPos, vec3 normal, float dither, float roughness, float f0, sampler2D sampleTex, out vec3 reflectedDir, out vec3 fresnel) { //Thanks to Belmu for providing me with proper importance sampled rough reflections! You can check out his work at https://www.patreon.com/Belmu and https://discord.gg/jjRrhpkH9e 
    vec3 ssr = vec3(0.0);

    mat3 tbn = tbnNormal(normal);

    float ndv = max0(dot(normal, normalize(fragPos)));

    #ifdef TAA
    dither = fractDither(dither);
    #endif
    
    vec3 IOR = vec3(F0toIOR(f0));

    vec3 exCoEf = vec3(0.5);

    for(int i = 0; i < 8; i++) {
        IOR = (specularTex.g == 230.0+float(i)) ? metalIOR[i] : IOR;
        exCoEf = (specularTex.g == 230.0+float(i)) ? metalExCoEf[i] : exCoEf;
    } //Setting metal IOR and coefficients according to LabPBR, loop done here because it is only used here

    for(int j=0; j<rrSamples; j++) {

        vec3 importanceSampling = tbn * SampleVNDFGGX(-normalize(fragPos), vec2(pow2(roughness)), vec2(randF(), randF())); //GGXVNDFS refers to sampling the GGX distribution of visible normals, this method allows for importance sampling

        reflectedDir = reflect(normalize(fragPos), importanceSampling);

        bool aHit = rayTrace(0.0, rrRayTracingSamples, fragPos, dither, reflectedDir, screenPos, 1.0, false); //Do the raytracing algorithm and check for a hit

        vec3 hitColor = clamp(textureLod(sampleTex, screenPos.xy, 0).rgb,1e-5,1.0); //Sample the reflected color


        if(!aHit) hitColor = vec3(0.0);
        
        if(dot(normal,reflectedDir)>0.0) {

            fresnel = fresnelDieletricConductor(IOR,exCoEf,dot(normal,-normalize(fragPos)));

            ssr += hitColor * fresnel;
            
        } else break;
    }
    return ssr*rcp(float(rrSamples));
}
