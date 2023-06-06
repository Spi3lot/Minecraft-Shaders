#version 330 compatibility

#include "lib/Uniforms.inc"


in vec4 texcoord;


void main() {
    gl_FragColor = texture2D(texture, texcoord.st);
    //gl_FragColor = vec4(length(texture2D(shadowcolor0, texcoord.st))/10,0,0,1);
    // gl_FragColor = vec4(texture2D(shadowcolor, texcoord.st).rgb/100, 1.0);
    //gl_FragColor = texture2D(shadowcolor, texcoord.st);
    //gl_FragColor = vec4(vec3(length(texture2D(colortex7, texcoord.st))), 1.0);
    //gl_FragColor = texture2D(colortex7, texcoord.st);
}
