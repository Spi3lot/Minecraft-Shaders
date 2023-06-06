float percentage(float edge0, float edge1, float x) {
    return (x - edge0) / (edge1 - edge0);
}

float linearstep(float edge0, float edge1, float x) {
    return clamp(percentage(edge0, edge1, x), 0.0, 1.0);
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
    //return clamp(mix(to.x, to.y, t), to.x, to.y);
}

mat2 rotate(float angle) {
    float c = cos(angle);
    float s = sin(angle);

    return mat2(c, -s, s, c);
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
