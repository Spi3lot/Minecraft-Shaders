#version 460

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

void main() {
    gl_Position = projectionMatrix * (modelViewMatrix * gl_Vertex);
}
