#version 330 compatibility

#include "lib/Uniforms.inc"


in vec4 texcoord;
in vec4 lmcoord;

in mat4 modelView;
in vec4 glcolor;
in vec4 glvertex;
in vec4 viewPos;
in vec4 lightViewPos;


void main() {
    // Writes to shadowcolor0 and shadowcolor1
	vec4 color = texture2D(texture, texcoord.st);// glcolor;
    // gl_FragColor = color;
    gl_FragColor = vec4(lightViewPos);
}
