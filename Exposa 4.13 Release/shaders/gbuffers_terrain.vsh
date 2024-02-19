#version 150 compatibility

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;

uniform float frameTimeCounter;
uniform float rainStrength;

in vec4 at_tangent;
in vec3 mc_Entity;

attribute vec2 mc_midTexCoord;

flat out vec4 textureBounds;
flat out vec3 normal;
flat out mat3 tbn;
flat out float id;
out vec2 lmcoord;
out vec2 texcoord;
out vec4 viewPos;
out vec4 tint;

#include "/lib/vshjitter.glsl"

void main() {
    vec4 pos = gl_Vertex;

	vec3 worldPos = (gbufferModelViewInverse * gl_ModelViewMatrix * pos).xyz + cameraPosition;

    id = mc_Entity.x;
    
    if(id == 1194) {
	    worldPos.x += sin(worldPos.x+frameTimeCounter*0.25)*0.15*(1.0+rainStrength);
	    worldPos.z += cos(worldPos.z+frameTimeCounter*0.25)*0.15*(1.0+rainStrength);
    }

    pos.xyz = (gbufferModelView * gl_ModelViewMatrixInverse * vec4(worldPos - cameraPosition, 1.0)).xyz;

    viewPos = (gl_ModelViewMatrix * pos);

    gl_Position = gl_ProjectionMatrix * viewPos;
	texcoord    = gl_MultiTexCoord0.xy;
	lmcoord     = gl_MultiTexCoord2.xy * (1.0 / 256.0) + (1.0 / 32.0);
	tint        = gl_Color;
	normal      = normalize(gl_NormalMatrix*gl_Normal);

    vec3 tangent = normalize(gl_NormalMatrix*at_tangent.xyz);
    vec3 biTangent = normalize(cross(tangent, normal)*at_tangent.w);

        tbn     = mat3(tangent, biTangent, normal);

    vec2 textureRadius = abs(texcoord - mc_midTexCoord);

    textureBounds = vec4(mc_midTexCoord - textureRadius, mc_midTexCoord + textureRadius);

    #ifdef TAA
    gl_Position.xy = taaJitter(gl_Position.xy, gl_Position.w);
    #endif
}
