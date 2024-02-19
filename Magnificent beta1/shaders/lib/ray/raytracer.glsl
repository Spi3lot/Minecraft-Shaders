#if !defined RAYTRACER
#define RAYTRACER
    float ascribeDepth(in float depth, in float amount) {
        depth = screenSpaceToViewSpace(depth, gbufferProjectionInverse);
        depth *= 1.0 + amount;
        return viewSpaceToScreenSpace(depth, gbufferProjection);
    }

    bool raytraceIntersection(vec3 start, vec3 direction, out vec3 position, cFloat qualityConstant, cFloat refinements) {
        position   = start;

        start = screenSpaceToViewSpace(start, gbufferProjectionInverse);

        direction *= -start.z;
        direction  = viewSpaceToScreenSpace(direction + start, gbufferProjection) - position;

        vec3 increment = direction * minof((step(0.0, direction) - position) / direction);
        float quality = qualityConstant + (bayer128(gl_FragCoord.st) * 32.0);
            quality = ceil(quality * fLength(increment));
        increment /= quality;

        vec3 startPosition = position;

        float ascribeAmount = 5.0 * length(increment.xy * vec2(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y));

        float difference;
        bool  intersected = false;
        for (float i = 0.0; i <= quality && !intersected && position.p < 1.0; i++) {
            position = startPosition + increment * i;
            if (floor(position.st) != vec2(0.0)) break;
            float depth = texelFetch(depthtex1, ivec2(position.st * viewSize), 0).r;
            difference  = depth - position.p;
            intersected = (position.p - abs(increment.p)) < ascribeDepth(depth, ascribeAmount) && position.p > depth;
        }

        intersected = intersected && (difference + position.p) < 1.0 && position.p > 0.0;

        if (intersected && refinements > 0.0) {
            for (float i = 0.0; i < refinements; i++) {
                increment *= 0.5;
                position  += texelFetch(depthtex1, ivec2(position.st * viewSize), 0).r - position.p < 0.0 ? -increment : increment;
            }
        }
        if(!intersected) {
            return false;
        }

        return intersected;
    }
#endif