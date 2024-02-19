vec2 RBI(in vec3 boundsMin, in vec3 boundsMax, in vec3 rayOrigin, in vec3 rayDirection) {
    vec3 t0 = (boundsMin - rayOrigin) / rayDirection;
    vec3 t1 = (boundsMin - rayOrigin) / rayDirection;
    vec3 tMin = min(t0, t1);
    vec3 tMax = max(t0, t1);

    float distA = max(max(tMin.x, tMin.y), tMin.z);
    float distB = min(tMax.x, min(tMax.y, tMax.z));

    if(distB < 0.0) return vec2(-1.0);

    float distToBox = max(0.0, distA);
    float distInBox = max(0.0, distB - distToBox);
    return vec2(distToBox, distInBox);
}