#version 330 compatibility

#include "lib/Common.inc"
#include "lib/Uniforms.inc"


in vec3 vaNormal;

out vec4 glcolor;
out vec4 glvertex;

out mat4 modelView;

out vec4 texcoord;
out vec4 lmcoord;

out vec3 normalAbsolute;
out vec3 normal;
out vec4 viewPos;


void main() {
    texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    lmcoord = gl_TextureMatrix[1] * gl_MultiTexCoord1;

    glcolor = gl_Color;
    glvertex = gl_Vertex;
    glvertex.xz *= rotate(frameTimeCounter);

    modelView = gl_ModelViewMatrix;

    normalAbsolute = vaNormal;  // + texture(normals, texcoord.st).rgb;
    normal = (modelView * normal.xyzz).xyz;
    viewPos = modelView * glvertex;  // vertex in camera space

    //viewPos.xz *= 2;

    gl_Position = gl_ProjectionMatrix * viewPos;
}
