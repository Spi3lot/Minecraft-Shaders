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

/* RENDERTARGETS: 2, 3 */
out vec3 outColor2;
out vec4 outColor3;


void main() {
    vec4 col = fs_in.glcolor * texture2D(texture, fs_in.texcoord.st);
    vec4 light = texture2D(lightmap, fs_in.lmcoord.st);
    vec4 viewPos = fs_in.viewPos;  // viewPos.z is always negative WTF WHY

    vec3 normal = getNormal(viewPos.xyz);
    gl_FragColor = lit(col, light, viewPos, normal, shadowLightPosition, LIGHT_MULTIPLIER, LIGHT_THRESHOLD);

    vec3 viewRay = percentage(vec3(near), vec3(far), viewPos.xyz);

    outColor2 = normal;
    outColor3 = compressRay(viewRay);

    //outColor3 = 0.5 + 0.5 * percentage(vec4(near), vec4(far), viewPos);
}
