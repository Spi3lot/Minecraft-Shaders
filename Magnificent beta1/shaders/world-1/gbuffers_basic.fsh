#version 400

layout(location=0) out vec4 outColor;

/* DRAWBUFFERS:0 */

flat in vec4 tint;

void main() {
    outColor = vec4(tint.rgb, 1.0);
}