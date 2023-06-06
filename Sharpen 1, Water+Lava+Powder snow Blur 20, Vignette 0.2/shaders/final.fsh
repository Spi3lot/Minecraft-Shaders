#version 120

#define TWO_PI 6.28318530718

#define QUALITY 5
#define DIRECTIONS 50
// #define BLUR (isEyeInWater > 0)  // sharpen if false
// #define INTENSITY 1.0 + float(BLUR) * 19.0

#define VIGNETTE 0.2
#define SQRT_2 1.41421356237


varying vec4 texcoord;

uniform float viewWidth;
uniform float viewHeight;
uniform int isEyeInWater, hideGUI;

uniform sampler2D gcolor;


bool blur = (isEyeInWater > 0);  // sharpen if false
float intensity = 1.0 + float(blur) * 19.0;


void main() {
	// Get the location of the current pixel on the screen.
	// uv.x ranges from 0 on the left to 1 on the right.
	// uv.y ranges from 0 at the top to 1 at the bottom.
	// Change the numbers to grab values from other parts of the screen.
	vec2 uv = texcoord.st;  // (asin(texcoord.st * 2.0 - 1.0) / 3.1415926535 + 1.0) / 2.0;
	
	// Get the color of the pixel pointed to by the uv variable.
	// color.r is red, color.g is green, color.b is blue, all values from 0 to 1.
	vec4 color = texture2D(gcolor, uv);

	vec2 R = intensity / vec2(viewWidth, viewHeight);

	
    // Gaussian Blur
	if (blur) {
        for (int i = 1; i <= QUALITY; i++) {
            vec2 r = R * float(i) / float(QUALITY);

            for (int d = 0; d < DIRECTIONS; d++) {
                float angle = TWO_PI * float(d) / float(DIRECTIONS);

                color.rgb += texture2D(
                    gcolor,
                    uv + r * vec2(cos(angle), sin(angle))
                ).rgb;
            }
        }

        int totalIterations = QUALITY * DIRECTIONS;
        color.rgb /= float(totalIterations);
    }
    // Sharpen
    else {
        color *= 4.0 + 1.0;
        vec2 v = vec2(1, 0);

        // Hard coded for better performance and accuracy
        color.rgb -= texture2D(gcolor, uv + R * v.xy).rgb;
        color.rgb -= texture2D(gcolor, uv + R * v.yx).rgb;
        color.rgb -= texture2D(gcolor, uv + R * -v.xy).rgb;
        color.rgb -= texture2D(gcolor, uv + R * -v.yx).rgb;
    }

    // Vignette
    if (hideGUI == 0)
        color.rgb *= smoothstep(1.0, 0.0, VIGNETTE * SQRT_2 * length(uv - 0.5));  // * sqrt(2) because max length of uv-0.5 is sqrt(0.5) -> sqrt(0.5)*sqrt(2) = 1

	// Here's where we tell Minecraft what color we want this pixel.
	gl_FragColor = color;
}
