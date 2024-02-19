vec2 RSI(vec3 pos, vec3 dir, float radius) {
    radius = square(radius);
    float posDotDir = dot(pos, dir);
    float endDist = posDotDir*posDotDir + radius - dot(pos, pos);

    if(endDist < 0.0) return vec2(-1.0);

    endDist = sqrt(endDist);
    vec2 ret = -posDotDir + vec2(-endDist, endDist);

    return ret;
}