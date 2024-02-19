#version 150 compatibility
#define TAA

uniform mat4 gbufferModelViewInverse;

uniform vec3 cameraPosition;

in vec4 at_tangent;
in vec3 mc_Entity;

flat out vec3 normal;
flat out mat3 tbn;
flat out float id;
out vec2 lmcoord;
out vec2 texcoord;
out vec3 worldPos;
out vec4 tint;

#include "/lib/vshjitter.glsl"

void main() {
	gl_Position = ftransform();

	texcoord    = gl_MultiTexCoord0.xy;
	lmcoord     = gl_MultiTexCoord2.xy * (1.0 / 256.0) + (1.0 / 32.0);
	tint        = gl_Color;
	normal      = normalize(gl_NormalMatrix*gl_Normal);

    vec3 tangent = normalize(gl_NormalMatrix*at_tangent.xyz);
    vec3 biNormal = normalize(gl_NormalMatrix*cross(at_tangent.xyz, gl_Normal.xyz)*at_tangent.w);

        tbn     = mat3(tangent.x, biNormal.x, normal.x,
                    tangent.y, biNormal.y, normal.y,
                    tangent.z, biNormal.z, normal.z);

    #ifdef TAA
    gl_Position.xy = taaJitter(gl_Position.xy, gl_Position.w);
    #endif

	worldPos = mat3(gbufferModelViewInverse) * (gl_ModelViewMatrix * gl_Vertex).xyz + gbufferModelViewInverse[3].xyz;

    id = mc_Entity.x;
}
