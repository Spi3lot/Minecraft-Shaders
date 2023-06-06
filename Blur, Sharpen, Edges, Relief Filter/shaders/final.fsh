#version 120

#define TWO_PI 6.28318530718

#define QUALITY 5
#define DIRECTIONS 50

#define INTENSITY 1

#define MODE -2


varying vec4 texcoord;

uniform float viewWidth;
uniform float viewHeight;
uniform int isEyeInWater;

uniform sampler2D gcolor;


void main() {
	// Get the location of the current pixel on the screen.
	// uv.x ranges from 0 on the left to 1 on the right.
	// uv.y ranges from 0 at the top to 1 at the bottom.
	// Change the numbers to grab values from other parts of the screen.
	vec2 uv = texcoord.st;  // (asin(texcoord.st * 2.0 - 1.0) / 3.1415926535 + 1.0) / 2.0;
	
	// Get the color of the pixel pointed to by the uv variable.
	// color.r is red, color.g is green, color.b is blue, all values from 0 to 1.
	vec4 color = texture2D(gcolor, uv);

	// You can do whatever you want to the color. Here we're inverting it.
	//color.rgb = 1.0 - color.rgb;
	
	vec2 R = INTENSITY / vec2(viewWidth, viewHeight);
    vec3 v = vec3(1, 0, -1);

    switch (MODE) {
        // Relief Filter
        case -2:
            // Hard coded for better performance and accuracy
            color.rgb += 1.0 * texture2D(gcolor, uv + R * v.xy).rgb;
            color.rgb += 2.0 * texture2D(gcolor, uv + R * v.xz).rgb;
            color.rgb += -1.0 * texture2D(gcolor, uv + R * v.yx).rgb;
            // Leaving out v.yy because it is a vec2(0, 0), which would be the center and we don't want that
            color.rgb += 1.0 * texture2D(gcolor, uv + R * v.yz).rgb;
            color.rgb += -2.0 * texture2D(gcolor, uv + R * v.zx).rgb;
            color.rgb += -1.0 * texture2D(gcolor, uv + R * v.zy).rgb;
            break;

        // Laplace Filter (edges)
        case -1:
            color *= -4.0;

            // Hard coded for better performance and accuracy
            color.rgb += texture2D(gcolor, uv + R * v.xy).rgb;
            color.rgb += texture2D(gcolor, uv + R * v.yx).rgb;
            color.rgb += texture2D(gcolor, uv + R * v.zy).rgb;
            color.rgb += texture2D(gcolor, uv + R * v.yz).rgb;
            break;

        // Sharpen
        case 0:
            color *= 4.0 + 1.0;

            // Hard coded for better performance and accuracy
            color.rgb -= texture2D(gcolor, uv + R * v.xy).rgb;
            color.rgb -= texture2D(gcolor, uv + R * v.yx).rgb;
            color.rgb -= texture2D(gcolor, uv + R * v.zy).rgb;
            color.rgb -= texture2D(gcolor, uv + R * v.yz).rgb;
            break;

        // Gaussian Blur
        case 1:
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
    }

	// Here's where we tell Minecraft what color we want this pixel.
	gl_FragColor = color;// * smoothstep(0.8, 0, length(uv - 0.5));
}
