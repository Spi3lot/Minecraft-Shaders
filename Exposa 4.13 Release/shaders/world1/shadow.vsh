#version 150 compatibility

#define VSHPROGRAM
// #define FoliageMovement 0.1 //[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5]



in vec4 at_tangent;
in vec3 mc_Entity;

uniform mat4 shadowModelViewInverse;
// uniform mat4 shadowModelView;
uniform float rainStrength;
uniform float frameTimeCounter;

// attribute vec4 mc_Entity;

out vec2 texcoord;
out vec3 shadowWorldPos;
out vec4 color;

flat out mat3 tbn;

// varying vec3 normal;
// varying vec3 shadowviewpos;
// varying vec3 binormal;
// varying vec3 tangent;

#include "/lib/spaces.glsl"

void main() {
    vec4 pos = gl_Vertex;
    
    texcoord = gl_MultiTexCoord0.xy;
    
    color = gl_Color;

    vec3 shadowViewPos = (gl_ModelViewMatrix * pos).xyz;

	vec3 shadowWorldPos = (shadowModelViewInverse * gl_ModelViewMatrix * pos).xyz + cameraPosition;

    float id = mc_Entity.x;
    
    if(id == 1194) {
	    shadowWorldPos.x += sin(shadowWorldPos.x+frameTimeCounter*0.25)*0.15*(1.0+rainStrength);
	    shadowWorldPos.z += cos(shadowWorldPos.z+frameTimeCounter*0.25)*0.15*(1.0+rainStrength);
    }

    pos.xyz = (shadowModelView * gl_ModelViewMatrixInverse * vec4(shadowWorldPos - cameraPosition, 1.0)).xyz;

    gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * pos);

	gl_Position.xyz = shadowVSHDistortion(gl_Position.xyz);

	vec3 normal      = normalize(gl_NormalMatrix*gl_Normal);

    vec3 tangent = normalize(gl_NormalMatrix*at_tangent.xyz);
    vec3 biNormal = normalize(gl_NormalMatrix*cross(at_tangent.xyz, gl_Normal.xyz)*at_tangent.w);

        tbn     = mat3(tangent.x, biNormal.x, normal.x,
                    tangent.y, biNormal.y, normal.y,
                    tangent.z, biNormal.z, normal.z);

}
