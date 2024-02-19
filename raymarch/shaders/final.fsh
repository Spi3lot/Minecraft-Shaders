#version 460

uniform float viewWidth;
uniform float viewHeight;
uniform vec3 cameraPosition;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D colortex0;
const int maxSteps = 100;
const float epsilon = 0.001;

float sdSphere(vec3 p, float r) {
    return length(p) - r;
}

float sdBoxFrame(vec3 p, vec3 b, float e) {
    p = abs(p) - b;
    vec3 q = abs(p + e) - e;
    return min(min(
    length(max(vec3(p.x, q.y, q.z), 0.0)) + min(max(p.x, max(q.y, q.z)), 0.0),
    length(max(vec3(q.x, p.y, q.z), 0.0)) + min(max(q.x, max(p.y, q.z)), 0.0)),
    length(max(vec3(q.x, q.y, p.z), 0.0)) + min(max(q.x, max(q.y, p.z)), 0.0)
    );
}

float map(vec3 p) {
    vec3 center = vec3(0, 100, 0);
    //return sdSphere(p - center, 10.0);
    return sdBoxFrame(p - center, vec3(10, 10, 10), 1.0);
}

vec3 normal(vec3 p) {
    vec2 e = vec2(epsilon, 0);

    return normalize(map(p) - vec3(map(p - e.xyy), map(p - e.yxy), map(p - e.yyx)));
}

float raymarch(vec3 ro, vec3 rd) {
    float t = 0.0;

    for (int i = 0; i < maxSteps; i++) {
        vec3 p = ro + rd * t;
        float d = map(p);
        t += d;

        if (d < epsilon) {
            return t;
        }
    }

    return 0.0;
}

void main() {
    vec2 resolution = vec2(viewWidth, viewHeight);
    vec2 uv = gl_FragCoord.xy / resolution;
    vec2 nv = uv * 2.0 - 1.0;

    mat3 gbufferModelViewInverseRotation = mat3(gbufferModelViewInverse);
    vec3 ro = cameraPosition;
    vec3 rd = normalize(gbufferModelViewInverseRotation * (gbufferProjectionInverse * vec4(nv, -1, 1)).xyz);

    float dist = raymarch(ro, rd);
    vec4 color = vec4(0);

    if (dist == 0.0) {
        color += texture(colortex0, uv);
    } else {
        vec3 p = ro + rd * dist;
        color += vec4(0.5 * (1.0 + normal(p)), 1.0);
    }

    gl_FragColor = color;
}
