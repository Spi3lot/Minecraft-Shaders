#version 330 compatibility

#include "lib/Common.inc"
#include "lib/Uniforms.inc"


#define LIGHT_MULTIPLIER sqrt(2.0)
#define LIGHT_THRESHOLD 0.98


in vec4 texcoord;
in vec4 lmcoord;

in vec4 glcolor;
in vec4 glvertex;

in mat4 modelView;

in vec3 normalAbsolute;
in vec3 normal;
in vec4 viewPos;


void main() {
    vec4 color = texture2D(texture, texcoord.st);
    vec4 light = texture2D(lightmap, lmcoord.st);

    color *= glcolor;
    gl_FragColor = color * light;
}
