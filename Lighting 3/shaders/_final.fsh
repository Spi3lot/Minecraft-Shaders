#version 330 compatibility


in vec4 texcoord;

uniform sampler2D gnormal;


void main() {
    gl_FragColor = texture2D(gnormal, texcoord.st);
}
