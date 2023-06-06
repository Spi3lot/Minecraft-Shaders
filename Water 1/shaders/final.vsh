#version 330 compatibility


out vec4 texcoord;
out vec4 lmcoord;


void main() {
    texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    lmcoord = gl_TextureMatrix[1] * gl_MultiTexCoord1;
    
    gl_Position = ftransform();
}
