#version 330 compatibility


in vec4 viewPos;


void main() {
    gl_FragColor = viewPos;
}
