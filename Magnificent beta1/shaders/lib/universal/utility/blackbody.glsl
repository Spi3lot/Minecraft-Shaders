vec3 plancks(in float t, in vec3 lambda) {
    cFloat h = 6.63e-16;
    cFloat c = 3.0e17;
    cFloat k = 1.38e-5;
    vec3 p1 = (2.0*h*pow(c, 2.0)) / pow(lambda, vec3(5.0));
    vec3 p2 = exp(h*c/(lambda*k*t))-vec3(1);
    return (p1 / p2) * pow(1e9, 2.0);
}

vec3 blackbody(in float t) {
    vec3 xyz = vec3(0.0);

    /*
    for (float w = 390.0; w < 830.0; w += 1.0)
    {
        vec3 wl = vec3(w);
        vec3 rgb = plancks(t, wl);
        xyz = rgb.r * spectrumToXYZ(wl.x) + xyz;
        xyz = rgb.g * spectrumToXYZ(wl.y) + xyz;
        xyz = rgb.b * spectrumToXYZ(wl.z) + xyz;
    }
    */

    vec3 rgb = plancks(t, vec3(680.0, 550.0, 440.0));
         rgb = rgb / max(rgb.x, max(rgb.y, rgb.z));

    return rgb;
}