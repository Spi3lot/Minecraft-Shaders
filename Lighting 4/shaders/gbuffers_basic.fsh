#version 330 compatibility

#include "lib/Common.inc"
#include "lib/Uniforms.inc"


#define LIGHT_MULTIPLIER sqrt(2.0)
#define LIGHT_THRESHOLD 0.98
const int shadowMapResolution = 1024;  // Resolution of the shadow map. Higher numbers mean more accurate shadows. [128 256 512 1024 2048 4096 8192 16384]


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
/* DRAWBUFFERS 789 */
out vec3 outColor7;  // gaux1
out vec4 outColor8;  // gaux2
out vec4 outColor9;  // gaux3


float roundify(float dotProduct) {
    return smap(dotProduct, vec2(LIGHT_THRESHOLD, 1.0), vec2(1.0, LIGHT_MULTIPLIER));
}


void main() {
    vec4 col = texture2D(texture, texcoord.st);
    vec4 light = texture2D(lightmap, lmcoord.st);

    // Vectors and scalars for lighting effects, reflections, ...
    vec3 rd = normalize(viewPos.xyz);
    vec3 reflected = reflect(rd, normal);
    vec3 lightVector = normalize(shadowLightPosition - viewPos.xyz);

    float rd_dot_light = dot(rd, lightVector);
    float reflected_dot_light = dot(reflected, lightVector);

    float lightStrength = smap(rd_dot_light, vec2(-1.0, 1.0), vec2(1.0, LIGHT_MULTIPLIER));
    float lightSourceCircle = roundify(rd_dot_light);
    float lightReflection = roundify(reflected_dot_light);

    // Shadows
    vec4 lightViewPos = shadowModelView * glvertex;  // Vertex position relative to the light source
    vec4 lightViewPosProjected = shadowProjection * lightViewPos;
    vec2 shadowcoord = lightViewPosProjected.st * 0.5 + 0.5;
    float depthExpected = linearizeDepth(near, far, viewPos.z - shadowLightPosition.z);
    //float depthExpected = percentage(distance(viewPos.xyz, shadowLightPosition), near, far);  // Distance from light source to vertex

    float depthActual = texture2D(shadow, shadowcoord).x;  // Distance from light source to the said vertex
    float illumination = (depthActual < depthExpected) ? 1.0 : 0.1;

    // Using calculated variables to create effects
    float t = smoothstep(LIGHT_THRESHOLD, 1.0, reflected_dot_light);
    col *= glcolor;
    col += t;  // Leaves and so on look bad
    //col += vec4(mix(col.rgb, vec3(1,1,1), t), 0.0);  // Nice leaves but unrealistic reflection water + higher overall brightness
    light *= lightStrength * vec4(vec3(/*depthActual * */lightSourceCircle/* * lightReflection*/), 1.0);

    //gl_FragColor = vec4(vec3(depthExpected)/10, 1.0);
    gl_FragColor = col * light;

    outColor7 = normalAbsolute;
    outColor8 = glvertex;
    outColor9 = viewPos;
}
