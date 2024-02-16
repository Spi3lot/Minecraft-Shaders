#version 460

out vec4 texcoord;
out vec4 color;

const float radius = 25.0;

void main() {
    texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    color = gl_Color;
    vec4 vertex = gl_Vertex;
    vec4 view = gl_ModelViewMatrix * vertex;
    vertex.y -= vertex.x * vertex.x / radius;

//    float dist = length(vertex.xz) / radius;

//    if (dist < 1.0) {
//        vertex.y += radius * (1.0 - sqrt(1.0 - dist * dist));
//    } /*else {
//        vertex.x -= 2.0 * mod(vertex.x, radius);
//        vertex.y += radius * (1.0 + sqrt(1.0 - (dist - 2.0) * (dist - 2.0)));
//        vertex.z -= 2.0 * mod(vertex.z, radius);
//    }*/

    gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * vertex);
}
