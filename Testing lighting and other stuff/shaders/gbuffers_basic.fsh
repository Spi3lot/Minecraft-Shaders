#version 330 compatibility

#include "lib/Uniforms.inc"


in vec4 texcoord;
in vec4 lmcoord;

in vec4 glcolor;


void main() {
    /* Affects the sky for some reason */
	vec4 col = texture2D(gcolor, texcoord.st);
	vec4 light = texture2D(lightmap, lmcoord.st);
	
	gl_FragColor = col * glcolor * light;
    //gl_FragColor = vec4(0.0)  // Same result
    /* */
}
