#version 330 compatibility

#include "lib/Uniforms.inc"


in vec3 mc_Entity;

out VS_OUT {
    vec3 entity;
    vec4 glcolor;
    vec4 glvertex;
    vec4 texcoord;
    vec4 lmcoord;
    mat4 modelView;
    vec4 viewPos;
} vs_out;


void main() {

    vs_out.texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    vs_out.lmcoord = gl_TextureMatrix[1] * gl_MultiTexCoord1;

    vs_out.glcolor = gl_Color;
    vs_out.glvertex = gl_Vertex;
    vs_out.entity = mc_Entity;

    vs_out.modelView = gl_ModelViewMatrix;
    vs_out.viewPos = vs_out.modelView * vs_out.glvertex;
    
    gl_Position = gl_ProjectionMatrix * vs_out.viewPos;
}
