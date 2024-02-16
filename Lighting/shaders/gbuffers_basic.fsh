#version 330 compatibility

#include "lib/Common.inc"
#include "lib/Uniforms.inc"


#define LIGHT_MULTIPLIER sqrt(2.0)
#define LIGHT_THRESHOLD 0.98


in vec4 texcoord;
in vec4 lmcoord;

in vec4 glcolor;
in vec4 glvertex;

in mat4 modelView;

in vec3 normalAbsolute;
in vec3 normal;
in vec4 viewPos;

// Writes to buffers 1 and 2 (gdepth and gnormal)
// Default is vec4 but vectors of smaller dimensions seem to work as well
out float outColor1;
out vec3 outColor2;

float roundify(float dotProduct) {
    return smap(dotProduct, vec2(LIGHT_THRESHOLD, 1.0), vec2(1.0, LIGHT_MULTIPLIER));
}


void main() {
    vec4 col = texture2D(texture, texcoord.st);
    vec4 light = texture2D(lightmap, lmcoord.st);
    float depth = length(viewPos.xyz);

    vec3 rd = normalize(viewPos.xyz);
    vec3 reflected = reflect(rd, normal);
    vec3 lightVector = normalize(shadowLightPosition - viewPos.xyz);

    float rd_dot_light = dot(rd, lightVector);
    float reflected_dot_light = dot(reflected, lightVector);

    float lightStrength = smap(rd_dot_light, vec2(-1.0, 1.0), vec2(1.0, LIGHT_MULTIPLIER));
    float lightSourceCircle = roundify(rd_dot_light);
    float lightReflection = roundify(reflected_dot_light);

    //gl_FragColor = vec4(vec3(step(0.9,reflected_dot_light)), 1.0);
    //gl_FragColor = vec4(vec3(normal), 1.0);
    col *= glcolor;
    col += smoothstep(LIGHT_THRESHOLD, 1.0, reflected_dot_light);
    light *= lightStrength * vec4(vec3(lightSourceCircle/* * lightReflection*/), 1.0);

    gl_FragColor = col * light;

    outColor1 = depth;
    outColor2 = normalAbsolute;
}
