#version 330 compatibility


in vec3 vaNormal;
out vec3 normal;


void main() {
    gl_Position = ftransform();
    normal = vaNormal;
}
