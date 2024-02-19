vec3 spectrumToXYZ(in float w) {
    float n = (w - 390.0) * (1.0 / 1.0);
    int i = int(n);
    if(i < 0 || i >= (830 - 390)) {
        return vec3(0.0);
    } else {
        int n0 = min(i-1, int(n));
        int n1 = min(i-1, n0 + 1);
        vec3 c0 = cie[n0];
        vec3 c1 = cie[n1];

        return mix(c0, c1, n);
    }
}

vec3 xyzToRGB(in vec3 xyz) {
    float r = dot(xyz, xyzToRGBMatrix[0]);
    float g = dot(xyz, xyzToRGBMatrix[1]);
    float b = dot(xyz, xyzToRGBMatrix[2]);
    return vec3(r, g, b);
}

vec3 rgbToXYZ(in vec3 rgb) {
    float x = dot(rgb, rgbToXYZMatrix[0]);
    float y = dot(rgb, rgbToXYZMatrix[1]);
    float z = dot(rgb, rgbToXYZMatrix[2]);
    return vec3(x, y, z);
}