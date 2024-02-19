#version 120

uniform vec3 fogColor;

void main() {
    /*DRAWBUFFERS:0*/
    gl_FragData[0] = vec4(fogColor * fogColor, 1.0);
}