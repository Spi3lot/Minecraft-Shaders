#version 330 compatibility


out vec4 glvertex;
out vec4 viewPos;


void main() {
    glvertex = gl_Vertex;
    viewPos = gl_ModelViewMatrix * glvertex;

    gl_Position = ftransform();
}
