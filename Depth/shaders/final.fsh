#define TWO_PI 6.28318530718

#define QUALITY 5
#define DIRECTIONS 50


varying vec4 texcoord;


uniform float viewWidth;
uniform float viewHeight;
uniform float aspectRatio;


uniform sampler2D gcolor;
uniform sampler2D depthtex0;


void main() {
	vec2 uv = texcoord.st;
	vec4 color = texture2D(gcolor, uv);

	float intensity = 2.0 * texture2D(depthtex0, uv);
	vec2 R = intensity / vec2(viewWidth, viewHeight);

	for (int i = 1; i <= QUALITY; i++) {
        vec2 r = R * float(i) / float(QUALITY);

        for (int d = 0; d < DIRECTIONS; d++) {
            float angle = TWO_PI * float(d) / float(DIRECTIONS);

            color.rgb += texture2D(
                gcolor, uv + r * vec2(cos(angle), sin(angle))
        	).rgb;
        }
    }

    int totalIterations = QUALITY * DIRECTIONS;
    color.rgb /= float(totalIterations);

	gl_FragColor = color;
}
