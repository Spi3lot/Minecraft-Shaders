#version 330 compatibility

#include "lib/Common.inc"
#include "lib/Uniforms.inc"


#define LIGHT_MULTIPLIER sqrt(2.0)
#define LIGHT_THRESHOLD 0.98
const int shadowMapResolution = 1024;  // Resolution of the shadow map. Higher numbers mean more accurate shadows. [128 256 512 1024 2048 4096 8192 16384]


in vec4 texcoord;
in vec4 lmcoord;
in vec2 shadowcoord;
in float depthExpected;
in vec4 glcolor;
in vec4 glvertex;
in mat4 modelView;
in vec4 viewPos;
in vec3 entity;

// Writes to buffers 1 and 2 (gdepth and gnormal)
// Default is vec4 but vectors of smaller dimensions seem to work as well
/* DRAWBUFFERS 789 */
out vec3 outColor7;  // gaux1 (colortex7)
out vec4 outColor8;  // gaux2 (colortex8)
out vec4 outColor9;  // gaux3 (colortex9)


float roundify(float dotProduct) {
    return smap(dotProduct, vec2(LIGHT_THRESHOLD, 1.0), vec2(1.0, LIGHT_MULTIPLIER));
}


void main() {
    vec4 col = glcolor * texture2D(texture, texcoord.st);
    vec4 light = texture2D(lightmap, lmcoord.st);

    bool isWater = (entity.x == 9);
    
    //vec3 toDifferentiate = (isWater) ? vec3(glvertex.x + frameTimeCounter, glvertex.y, glvertex.z) : viewPos.xyz;
    vec3 toDifferentiate = viewPos.xyz;
    vec3 normal = normalize(cross(dFdx(toDifferentiate), dFdy(toDifferentiate)));

    // Vectors and scalars for lighting effects, reflections, ...
    vec3 rd = normalize(viewPos.xyz);
    vec3 reflected = reflect(rd, normal);
    vec3 lightVector = normalize(shadowLightPosition - viewPos.xyz);

    float rd_dot_light = dot(rd, lightVector);
    float reflected_dot_light = dot(reflected, lightVector);

    float lightStrength = smap(rd_dot_light, vec2(-1.0, 1.0), vec2(1.0, LIGHT_MULTIPLIER));
    float lightSourceCircle = roundify(rd_dot_light);
    float lightReflection = roundify(reflected_dot_light);

    float depthActual = texture2D(shadowcolor, shadowcoord).x;  // Distance from light source to the said vertex
    float illuminationFactor = (isWater) ? 1.0 : smoothstep(depthActual, depthActual - 0.01, depthExpected);
    float illumination = mix(0.5, 1.0, illuminationFactor);

    float t = illuminationFactor * smoothstep(LIGHT_THRESHOLD, 1.0, reflected_dot_light);
    
    if (col.a > 0.0)
        col += t;  // Leaves and so on look bad (without the if statement)
    else
        col.rgb += t;

    //col += vec4(mix(col.rgb, vec3(1,1,1), t), 0.0);  // Nice leaves but unrealistic reflection water + higher overall brightness

    // Using calculated variables to create effects
    light *= lightStrength * vec4(vec3(illumination * lightSourceCircle/* * lightReflection*/), 1.0);

    //gl_FragColor = vec4(vec3(depthExpected), 1.0);
    //gl_FragColor = vec4(10*vec3(abs(depthExpected*0.45-depthActual)), 1.0);
    //gl_FragColor = col * vec4(vec3(illumination), 1.0);
    gl_FragColor = col * light;

    outColor7 = normal;
    outColor8 = glvertex;
    outColor9 = viewPos;
}
