#version 460

in vec4 texcoord;
in vec4 color;
uniform sampler2D colortex0;

void main() {
    vec2 uv = texcoord.st;
    gl_FragColor = color * texture(colortex0, uv);
}
