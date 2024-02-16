#version 330 compatibility

#include "lib/Uniforms.inc"


out vec4 texcoord;
out vec4 lmcoord;

out mat4 modelView;
out vec4 glcolor;
out vec4 glvertex;
out vec4 viewPos;
out vec4 lightViewPos;


void main() {
    texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    lmcoord = gl_TextureMatrix[1] * gl_MultiTexCoord1;

    modelView = gl_ModelViewMatrix;
    glcolor = gl_Color;
    glvertex = gl_Vertex;

    // shadowModelView is probably an identity matrix and i think modelView is too
    viewPos = modelView * glvertex;
    lightViewPos = shadowModelView * glvertex;

    gl_Position = ftransform();//shadowProjection * lightViewPos;

    // Does kind of the same thing but then I can't pass the variables to the fragment shader!
    // gl_Position = ftransform();
}
