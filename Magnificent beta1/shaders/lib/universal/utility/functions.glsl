float square(in float x) {
    return _square(x);
}
int square(in int x) {
    return _square(x);
}
vec2 square(in vec2 x) {
    return _square(x);
}
vec3 square(in vec3 x) {
    return _square(x);
}
vec4 square(in vec4 x) {
    return _square(x);
}

float cube(in float x) {
    return _cube(x);
}
int cube(in int x) {
    return _cube(x);
}
vec2 cube(in vec2 x) {
    return _cube(x);
}
vec3 cube(in vec3 x) {
    return _cube(x);
}
vec4 cube(in vec4 x) {
    return _cube(x);
}

float pow5(in float x) {
    return _pow5(x);
}
int pow5(in int x) {
    return _pow5(x);
}
vec2 pow5(in vec2 x) {
    return _pow5(x);
}
vec3 pow5(in vec3 x) {
    return _pow5(x);
}
vec4 pow5(in vec4 x) {
    return _pow5(x);
}

float saturate(in float x) {
    return _saturate(x);
}
int saturate(in int x) {
    return _saturateInt(x);
}
vec2 saturate(in vec2 x) {
    return _saturate(x);
}
vec3 saturate(in vec3 x) {
    return _saturate(x);
}
vec4 saturate(in vec4 x) {
    return _saturate(x);
}

float rcp(in float x) {
    return _rcp(x);
}
vec2 rcp(in vec2 x) {
    return _rcp(x);
}
vec3 rcp(in vec3 x) {
    return _rcp(x);
}
vec4 rcp(in vec4 x) {
    return _rcp(x);
}

float log10(in float x) {
    return _log10(x, 10.0);
}

int log10(in int x) {
    return int(_log10(x, 10.0));
}

vec2 log10(in vec2 x) {
    return _log10(x, 10.0);
}

vec3 log10(in vec3 x) {
    return _log10(x, 10.0);
}

vec4 log10(in vec4 x) {
    return _log10(x, 10.0);
}

float linearstep(in float x, float low, float high) {
    float data = x;
    float mapped = (data-low)/(high-low);

    return saturate(mapped);
}

vec2 linearstep(in vec2 x, float low, float high) {
    vec2 data = x;
    vec2 mapped = (data-low)/(high-low);

    return saturate(mapped);
}

vec3 linearstep(in vec3 x, float low, float high) {
    vec3 data = x;
    vec3 mapped = (data-low)/(high-low);

    return saturate(mapped);
}

vec4 linearstep(in vec4 x, float low, float high) {
    vec4 data = x;
    vec4 mapped = (data-low)/(high-low);

    return saturate(mapped);
}

float minof(vec2 x) { return min(x.x, x.y); }
float minof(vec3 x) { return min(min(x.x, x.y), x.z); }
float minof(vec4 x) { x.xy = min(x.xy, x.zw); return min(x.x, x.y); }

float maxof(vec2 x) { return max(x.x, x.y); }
float maxof(vec3 x) { return max(max(x.x, x.y), x.z); }
float maxof(vec4 x) { x.xy = max(x.xy, x.zw); return max(x.x, x.y); }

float max0(float x) { return max(0.0, x); }

vec2 sincos(float x) { return vec2(sin(x), cos(x)); }

vec2 circleMap(in float index, in float count) {
    float goldenAngle = tau / ((sqrt(5.0) * 0.5 + 0.5) + 1.0);
    return vec2(cos(index * goldenAngle), sin(index * goldenAngle)) * sqrt(index / count);
}

vec2 circleMap(in float point) {
    return vec2(cos(point), sin(point));
}

vec2 spiralPoint(float angle, float scale) {
	return vec2(sin(angle), cos(angle)) * pow(angle / scale, 1.0 / (sqrt(5.0) * 0.5 + 0.5));
}

vec3 genUnitVector(vec2 hash) {
    hash.x *= tau; hash.y = hash.y * 2.0 - 1.0;
    return vec3(vec2(sin(hash.x), cos(hash.x)) * sqrt(1.0 - hash.y * hash.y), hash.y);
}

vec3 genCosineVector(vec3 vector, vec2 xy) {
    vec3 dir = genUnitVector(xy);

    return fNormalize(vector + dir);
}

float linearToSrgb(float linear){
    float SRGBLo = linear * 12.92;
    float SRGBHi = (pow(abs(linear), 1.0/2.4) * 1.055) - 0.055;
    float SRGB = mix(SRGBHi, SRGBLo, step(linear, 0.0031308));
    return SRGB;
}

float srgbToLinear(float color) {
    float linearRGBLo = color / 12.92;
    float linearRGBHi = pow((color + 0.055) / 1.055, 2.4);
    float linearRGB = mix(linearRGBHi, linearRGBLo, step(color, 0.04045));
    return linearRGB;
}

vec3 linearToSrgb(vec3 linear) {
    vec3 SRGBLo = linear * 12.92;
    vec3 SRGBHi = (pow(abs(linear), vec3(1.0/2.4)) * 1.055) - 0.055;
    vec3 SRGB = mix(SRGBHi, SRGBLo, step(linear, vec3(0.0031308)));
    return SRGB;
}

vec3 srgbToLinear(vec3 color) {
    vec3 linearRGBLo = color / 12.92;
    vec3 linearRGBHi = pow((color + 0.055) / 1.055, vec3(2.4));
    vec3 linearRGB = mix(linearRGBHi, linearRGBLo, step(color, vec3(0.04045)));
    return linearRGB;
}

vec4 textureBicubic(in sampler2D sampler, vec2 coordinate) {
    vec2 res = textureSize(sampler, 0);

    coordinate = coordinate * res - 0.5;

    vec2 f = fract(coordinate);
    coordinate -= f;

    vec2 ff = f * f;
    vec2 w0_1;
	vec2 w0_2;
    vec2 w1_1;
	vec2 w1_2;
    w0_1 = 1 - f; w0_1 *= w0_1 * w0_1;
    w1_2 = ff * f;
    w1_1 = 3 * w1_2 + 4 - 6 * ff;
    w0_2 = 6 - w1_1 - w1_2 - w0_1;

    vec2 s1 = w0_1 + w1_1;
	vec2 s2 = w0_2 + w1_2;
	vec2 cLo = coordinate.xy + vec2(-0.5) + w1_1 / s1;
	vec2 cHi = coordinate.xy + vec2(1.5) + w1_2 / s2;

    vec2 m = s1 / (s1 + s2);
    return mix(
        mix(textureLod(sampler, vec2(cLo.x, cLo.y), 0), textureLod(sampler, vec2(cHi.x, cLo.y), 0), m.x),
        mix(textureLod(sampler, vec2(cLo.x, cHi.y), 0), textureLod(sampler, vec2(cHi.x, cHi.y), 0), m.x),
        m.y);
}

// The following code is licensed under the MIT license: https://gist.github.com/TheRealMJP/bc503b0b87b643d3505d41eab8b332ae
vec4 textureCatmullRom(in sampler2D tex, vec2 uv) {
    vec2 texSize = textureSize(tex, 0);
    // We're going to sample a a 4x4 grid of texels surrounding the target UV coordinate. We'll do this by rounding
    // down the sample location to get the exact center of our "starting" texel. The starting texel will be at
    // location [1, 1] in the grid, where [0, 0] is the top left corner.
    vec2 samplePos = uv * texSize;
    vec2 texPos1 = floor(samplePos - 0.5) + 0.5;

    // Compute the fractional offset from our starting texel to our original sample location, which we'll
    // feed into the Catmull-Rom spline function to get our filter weights.
    vec2 f = samplePos - texPos1;

    // Compute the Catmull-Rom weights using the fractional offset that we calculated earlier.
    // These equations are pre-expanded based on our knowledge of where the texels will be located,
    // which lets us avoid having to evaluate a piece-wise function.
    vec2 w0 = f * ( -0.5 + f * (1.0 - 0.5*f));
    vec2 w1 = 1.0 + f * f * (-2.5 + 1.5*f);
    vec2 w2 = f * ( 0.5 + f * (2.0 - 1.5*f) );
    vec2 w3 = f * f * (-0.5 + 0.5 * f);
    
    // Work out weighting factors and sampling offsets that will let us use bilinear filtering to
    // simultaneously evaluate the middle 2 samples from the 4x4 grid.
    vec2 w12 = w1 + w2;
    vec2 offset12 = w2 / (w1 + w2);

    // Compute the final UV coordinates we'll use for sampling the texture
    vec2 texPos0 = texPos1 - vec2(1.0);
    vec2 texPos3 = texPos1 + vec2(2.0);
    vec2 texPos12 = texPos1 + offset12;

    texPos0 /= texSize;
    texPos3 /= texSize;
    texPos12 /= texSize;

    vec4 result = vec4(0.0);
    result += texture(tex, vec2(texPos0.x,  texPos0.y)) * w0.x * w0.y;
    result += texture(tex, vec2(texPos12.x, texPos0.y)) * w12.x * w0.y;
    result += texture(tex, vec2(texPos3.x,  texPos0.y)) * w3.x * w0.y;

    result += texture(tex, vec2(texPos0.x,  texPos12.y)) * w0.x * w12.y;
    result += texture(tex, vec2(texPos12.x, texPos12.y)) * w12.x * w12.y;
    result += texture(tex, vec2(texPos3.x,  texPos12.y)) * w3.x * w12.y;

    result += texture(tex, vec2(texPos0.x,  texPos3.y)) * w0.x * w3.y;
    result += texture(tex, vec2(texPos12.x, texPos3.y)) * w12.x * w3.y;
    result += texture(tex, vec2(texPos3.x,  texPos3.y)) * w3.x * w3.y;

    return result;
}
//End of MIT code