#version 330 compatibility

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

    modelView = gl_ModelViewMatrix;

    normalAbsolute = vaNormal;  // + texture(normals, texcoord.st).rgb;
    normal = (modelView * normalAbsolute.xyzz).xyz;
    viewPos = modelView * glvertex;  // vertex in camera space



    // Same as uniform vec3 cameraPosition i think (except vec3 and vec4)
    //vec4 playerPos = gbufferModelViewInverse * viewPos;  // vertex in world space (gbufferModelViewInverse = only viewInverse matrix, name is wrong)

    //float dist = length(viewPos.xz);
    //viewPos.y += 0.01 * dist * dist;

    gl_Position = gl_ProjectionMatrix * viewPos;
}
