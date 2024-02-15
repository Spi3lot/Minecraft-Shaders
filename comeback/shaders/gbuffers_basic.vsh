#version 460

out vec4 texcoord;
out vec4 color;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

const float radius = 20.0;

void main() {
    texcoord = gl_MultiTexCoord0;
    color = gl_Color;

    vec4 vertex = gl_Vertex;
    vec4 view = modelViewMatrix * gl_Vertex;
    float dist = view.z;
    vertex.y -= dist * dist / radius;
    gl_Position = projectionMatrix * (modelViewMatrix * vertex);
}
