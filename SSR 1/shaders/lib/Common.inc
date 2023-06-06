#define getNormal(toDifferentiate) normalize(cross(dFdx(toDifferentiate), dFdy(toDifferentiate)))

float percentage(float edge0, float edge1, float x) {
    return (x - edge0) / (edge1 - edge0);
}

vec3 percentage(vec3 e0, vec3 e1, vec3 v) {
    return vec3(percentage(e0.x, e1.x, v.x), percentage(e0.y, e1.y, v.y), percentage(e0.z, e1.z, v.z));
}

vec4 percentage(vec4 e0, vec4 e1, vec4 v) {
    return vec4(percentage(e0.x, e1.x, v.x), percentage(e0.y, e1.y, v.y), percentage(e0.z, e1.z, v.z), percentage(e0.w, e1.w, v.w));
}

float linearstep(float edge0, float edge1, float x) {
    return clamp(percentage(edge0, edge1, x), 0.0, 1.0);
}

float mixClamp(float a0, float a1, float x) {
    return clamp(mix(a0, a1, x), a0, a1);
}

float map(float x, vec2 from, vec2 to) {
    float t = percentage(from.x, from.y, x);
    return mix(to.x, to.y, t);
}

float smap(float x, vec2 from, vec2 to) {
    float t = smoothstep(from.x, from.y, x);
    return mix(to.x, to.y, t);
}

float lmap(float x, vec2 from, vec2 to) {
    float t = linearstep(from.x, from.y, x);
    return mix(to.x, to.y, t);
    //return mixClamp(to.x, to.y, t);
}


mat2 rotate(float angle) {
    float c = cos(angle);
    float s = sin(angle);

    return mat2( c, -s,
                 s, c );
}


int bitSign(int n, int i) {
    int bit = (n & (1 << i)) >> i;  // 0 or 1
    return (1 - bit) * 2 - 1;  // -1 or 1
}

vec4 compressRay(vec3 ray) {
    int sgn = (int(ray.x < 0) << 2) | (int(ray.y < 0) << 1) | (int(ray.z < 0) << 0);
    return vec4(abs(ray), sgn);
}

vec3 decompressRay(vec4 compressedRay) {
    vec3 ray = compressedRay.xyz;
    int sgn = int(compressedRay.w);

    ray.x *= bitSign(sgn, 2);
    ray.y *= bitSign(sgn, 1);
    ray.z *= bitSign(sgn, 0);

    return ray;
}

float linearizeDepth(float near, float far, float depth) {
    return (near * far) / (depth * (near - far) + far);
}


float getDepthNonLinear(float near, float far, float z) {
    return (far + near) / (far - near) + (2 * far * near) / (z * (far - near));
}

float getZNonLinear(float near, float far, float depth) {
    return (2 * far * near) / (depth * (far - near) - far - near);
}


float roundify(float dotProduct, float LIGHT_MULTIPLIER, float LIGHT_THRESHOLD) {
    return smap(dotProduct, vec2(LIGHT_THRESHOLD, 1.0), vec2(1.0, LIGHT_MULTIPLIER));
}

vec4 lit(vec4 col, vec4 light, vec4 viewPos, vec3 normal, vec3 shadowLightPosition, float LIGHT_MULTIPLIER, float LIGHT_THRESHOLD) {
    // Vectors and scalars for lighting effects, reflections, ...
    vec3 rd = normalize(viewPos.xyz);
    vec3 reflected = reflect(rd, normal);
    vec3 lightVector = normalize(shadowLightPosition - viewPos.xyz);

    float rd_dot_light = dot(rd, lightVector);
    float reflected_dot_light = dot(reflected, lightVector);

    float lightStrength = smap(rd_dot_light, vec2(-1.0, 1.0), vec2(1.0, LIGHT_MULTIPLIER));
    float lightSourceCircle = roundify(rd_dot_light, LIGHT_MULTIPLIER, LIGHT_THRESHOLD);
    float lightReflection = roundify(reflected_dot_light, LIGHT_MULTIPLIER, LIGHT_THRESHOLD);

    float t = smoothstep(LIGHT_THRESHOLD, 1.0, reflected_dot_light);
    //t += lightSourceCircle;

    if (col.a > 0.0)
        col += t;  // Leaves and so on look bad (without the if statement)
    else
        col.rgb += t;

    // Using calculated variables to create effects
    float noEffectOnAlpha = lightSourceCircle * lightReflection;  // lightReflection removes reflection inside fluids
    light *= lightStrength * vec4(vec3(noEffectOnAlpha), 1.0);

    return col * light;
}
