
#ifndef DIM
vec3 simpleFog(vec3 scene, float d, vec3 color) {
    float density   = d * 3e-5 * fogDensityMult * fogAirScale.x;

    float transmittance = expf(-density);

    return scene * transmittance + color * density;
}
#else
vec3 simpleFog(vec3 scene, float d, vec3 color) {
    float density   = d * 6e-3;

    float transmittance = expf(-density);

    return mix(color, scene, transmittance);
}
#endif


vec3 waterFog(vec3 scene, float d, vec3 color) {
    float density   = max(0.0, d) * waterDensity;

    vec3 transmittance = expf(-waterAttenCoeff * density);

    vec3 scatter    = 1.0-exp(-density * waterScatterCoeff);
        scatter    *= max(expf(-waterAttenCoeff * density), expf(-waterAttenCoeff * pi));

    return scene * transmittance + scatter * color * rcp(pi);
}
vec3 lavaFog(vec3 scene, float d) {
    float density   = max(0.0, d);

    float transmittance = expf(-1.0 * density);

    return mix(vec3(1.0, 0.3, 0.02), scene, transmittance);
}