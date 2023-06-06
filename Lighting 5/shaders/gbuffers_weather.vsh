#version 330 compatibility

#include "lib/Common.inc"
#include "lib/Uniforms.inc"


out vec4 glcolor;
out vec4 glvertex;
out mat4 modelView;
out vec4 texcoord;
out vec4 lmcoord;
out vec4 viewPos;


void main() {
    texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    lmcoord = gl_TextureMatrix[1] * gl_MultiTexCoord1;

    glcolor = gl_Color;
    glvertex = gl_Vertex;
    glvertex.xz *= rotate(frameTimeCounter * 2.0);

    modelView = gl_ModelViewMatrix;
    viewPos = modelView * glvertex;  // vertex in camera space

    //viewPos.xz /= length(cos(viewPos.xz));


    gl_Position = gl_ProjectionMatrix * viewPos;
}
