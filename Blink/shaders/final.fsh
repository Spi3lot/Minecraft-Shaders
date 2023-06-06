#version 120

// BLINK_MODE 1 -> Vignette Blink
//            2 -> y-only Blink
#define BLINK_MODE 2

#define DELAY_SEC 4.0
#define BLINK_DURATION_SEC 0.25  // Eyes are fully closed at 'BLINK_DURATION_SEC' / 2


const float delay_ticks = DELAY_SEC * 20.0;
const float blinkDuration_ticks = BLINK_DURATION_SEC * 5;  // only 5 because 20/2 = 10 -> takes twice as long for blink start and end combined and 10/2 = 5 -> min(abs(...), abs(...)) can only have a maximum of .../2

varying vec4 texcoord;


uniform float frameTimeCounter;
int worldTime = int(frameTimeCounter * 20.0);

uniform sampler2D gcolor;


void main() {
    // Get the location of the current pixel on the screen.
    // uv.x ranges from 0 on the left to 1 on the right.
    // uv.y ranges from 0 at the bottom to 1 at the top.
    // Change the numbers to grab values from other parts of the screen.
    vec2 uv = texcoord.st;
    
    // Get the color of the pixel pointed to by the uv variable.
    // color.r is red, color.g is green, color.b is blue, all values from 0 to 1.
    vec4 color = texture2D(gcolor, uv);
    
    // 'blink' variable:
    // 0... eyes fully closed
    // >0 && <1... smoothstep (Hermite) interpolation between fully closed and fully opened
    // 1... eyes fully opened
    // Can get > 1 though. Everything > 1 also means eyes fully opened

    // Eyes close instantly, opening takes 'BLINK_DURATION_SEC' seconds
    //float blink = mod(worldTime, delay_ticks) / blinkDuration_ticks;

    // Eyes closing and opening take the same amount of time (both take 'BLINK_DURATION_SEC' / 2 seconds so 'BLINK_DURATION_SEC' seconds in total)
    // min(abs(...), abs(...)) distance (difference) to the nearest multiple of 'delay_ticks' in worldTime.
    // Since it is the distance to the *nearest* multiple of 'delay_ticks', it can only get as big as 'delay_ticks'/2 -> so here is the second halving (10/2 = 5)
    int div = int(worldTime / delay_ticks);
    float blink = min(abs(worldTime - div * delay_ticks), abs(worldTime - (div+1) * delay_ticks)) / blinkDuration_ticks;

    // Here's where we tell Minecraft what color we want this pixel.

    // Vignette Blink
    #if BLINK_MODE == 1
    gl_FragColor = color * smoothstep(blink, 0.0, length(uv - 0.5));

    // y-only Blink
    #elif BLINK_MODE == 2
    gl_FragColor = color * smoothstep(blink, 0.0, abs(uv.y * 2.0 - 1.0));

    #endif
}
