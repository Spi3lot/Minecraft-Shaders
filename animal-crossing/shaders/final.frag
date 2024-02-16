void main() {
    vec3 p = vec3(0.0, 0.0, 0.0);
    vec3 d = normalize(vec3(view.x, view.y, view.z));
    float t = 0.0;
    for (int i = 0; i < 100; i++) {
        vec3 p = vec3(0.0, 0.0, 0.0) + d * t;
        float d = length(p) - radius;
        if (d < 0.0) {
            break;
        }
        t += d;
    }


    gl_FragColor = vec4(p, 1.0);
}