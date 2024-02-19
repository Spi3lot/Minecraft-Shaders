float RTAO(vec3 normal, vec3 viewPos, vec3 screenPos) {
    float avg = 0.0;
    
    int samples = 1;

    if(clamp01(screenPos) == screenPos) {
        
        vec2 randNoise = vec2(randF(), randF());
        for(int i = 0; i < samples; i++) {

            vec3 hemiSphereDir =  cosineWeightedHemisphereSample(normal, randNoise);

            bool rtHit = rayTrace(0.05, 32, viewPos, randF(), hemiSphereDir, screenPos, 1.0, false);

            if(!rtHit) avg += 1.0*rcp(float(samples)); //if hit sky
        }
    }

    return avg;
}

