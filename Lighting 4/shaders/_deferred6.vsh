#version 330 compatibility


out vec4 viewPos;


void main() {
    gl_Position = ftransform();
    viewPos = gl_ModelViewMatrix * gl_Vertex;
}
