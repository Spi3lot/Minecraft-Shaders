#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable

uniform sampler2D tex;


uniform vec3 shadowLightPosition;

// uniform mat4 gbufferModelViewInverse;

in vec2 texcoord;
in vec3 shadowWorldPos;
in vec4 color;

flat in mat3 tbn;

#include "/lib/includes.glsl"

/* DRAWBUFFERS:0 */
layout(location = 0) out vec3 shadowTex0Out;

// varying vec3 normal;
// varying vec3 shadowviewpos;
// varying vec3 shadowworldpos;
// varying vec3 binormal;
// varying vec3 tangent;

void main() {
    vec4 shadowColor = texture2D(tex, texcoord)*vec4(color.rgb,1.0);
    if(shadowColor.a<0.2) discard;

    // posxz.z *= 0.99;

	// posxz.x += sin(posxz.x+frameTimeCounter)*0.25;
	// posxz.z += cos(posxz.z+frameTimeCounter*0.5)*0.25;

    // shadowColor.rgb = clamp(vec3(height)*7,0.09,1.0);

    shadowTex0Out = shadowColor.rgb;

}
