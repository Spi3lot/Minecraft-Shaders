#version 460

out vec4 texcoord;
out vec4 color;

void main() {
    texcoord = gl_MultiTexCoord0;
    color = gl_Color;

    vec4 vertex = gl_Vertex;
    vec4 view = gl_ModelViewMatrix * gl_Vertex;
    vertex.y -= length(view.yz);
    gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * vertex);
}
