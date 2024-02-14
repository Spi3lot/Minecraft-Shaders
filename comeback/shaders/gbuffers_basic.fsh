#version 460

uniform sampler2D colortex0;
in vec4 texcoord;
in vec4 color;

void main() {
    vec2 uv = texcoord.st;
    gl_FragColor = color * texture(colortex0, uv);
}
