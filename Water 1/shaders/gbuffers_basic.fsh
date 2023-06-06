#version 330 compatibility

#include "lib/Common.inc"
#include "lib/Settings.inc"
#include "lib/Uniforms.inc"


in GS_OUT {
	vec3 entity;
    vec4 glcolor;
    vec4 glvertex;  // Unmodified vertex
    vec4 texcoord;
    vec4 lmcoord;
    mat4 modelView;
    vec4 viewPos;
} fs_in;


void main() {
    vec4 col = fs_in.glcolor * texture2D(texture, fs_in.texcoord.st);
    vec4 light = texture2D(lightmap, fs_in.lmcoord.st);
    
    vec3 normal = getNormal(fs_in.viewPos.xyz);
    gl_FragColor = lit(col, light, fs_in.viewPos, normal, shadowLightPosition, LIGHT_MULTIPLIER, LIGHT_THRESHOLD);
}
