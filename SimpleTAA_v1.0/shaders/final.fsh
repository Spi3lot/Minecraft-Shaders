#version 120

#include "/lib/head.glsl"

/*
const int colortex0Format   = R11F_G11F_B10F;
const int colortex1Format   = R11F_G11F_B10F;

const bool colortex1Clear   = false;
*/

#define INFO 0

uniform sampler2D colortex0;

varying vec2 uv;

#define screenBitdepth 8   //[1 2 4 6 8]

vec3 ditherImage(vec3 color) {
    const int bits  = int(pow(2, screenBitdepth));

    vec3 cDither    = color;
        cDither    *= bits;
        cDither    += bayer16(gl_FragCoord.xy);

    return floor(cDither) / bits;
}

void main() {
	vec3 sceneColor = sqrt(texture2D(colortex0, uv).rgb);

	gl_FragColor = vec4(ditherImage(sceneColor), 1.0);
}