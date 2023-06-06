#define getNormal(toDifferentiate) normalize(cross(dFdx(toDifferentiate), dFdy(toDifferentiate)))

float percentage(float edge0, float edge1, float x) {
    return (x - edge0) / (edge1 - edge0);
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
    float noEffectOnAlpha = lightSourceCircle * 1;  // lightReflection removes reflection inside fluids
    light *= lightStrength * vec4(vec3(noEffectOnAlpha), 1.0);

    return col * light;
}
