#version 150 compatibility



uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;

uniform float frameTimeCounter;
uniform float rainStrength;

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

// mat2 rotationMatrix(float a) {
//     float s = sin(a), c=cos(a);
//     return mat2(c, -s, s, c);
// }

// vec2 Rand2(vec2 p) {
//     return fract(sin(vec2(dot(p, vec2(25.6, 35.7)), dot(p, vec2(16.2, 95.5))))*.005);
// }

// float PI = radians(180.0);

// float voronoiNoise(vec3 p) {
//     p *= 0.05;
//     p.z *= 0.25;
//     float minDist = 1.0;
//     // float noise = waterH(p);
//     float divider = 1.2;
//     float adder = 0.01;
//     for(int i = 0; i < 8; i++) {
//                 vec2 offsetedPosition = p.xz + normalize(rotationMatrix(float(i)*1.)*vec2(1.0, -1.0));
//                 offsetedPosition += adder;
//                 vec2 random = Rand2(offsetedPosition/divider);
//                 random = sin(2*PI*random)*0.5+0.5;
//                 minDist = smoothstep(0.0,1.08,min(minDist, length(random)));
//                 p += minDist*0.0018;
//                 divider *= 0.5;
//                 adder *= 2;
//     }
//     return clamp(minDist,0.0,1.0);
// }

void main() {
    vec4 pos = gl_Vertex;

	worldPos = (gbufferModelViewInverse * gl_ModelViewMatrix * pos).xyz + cameraPosition;

	id = mc_Entity.x;

    if(id == 8.0 || id == 9.0) {
        // vec3 newPos = worldPos.xyz;
	    // worldPos.y += sin(worldPos.x+frameTimeCounter*0.1)*0.25*(1.0+rainStrength);
	    // worldPos.y += sin(worldPos.z+frameTimeCounter*0.1)*0.25*(1.0+rainStrength);
	    // newPos.z += cos(newPos.z+frameTimeCounter*0.1)*0.25*(1.0+rainStrength);
        // float hoho = voronoiNoise(newPos);
        // worldPos.y += hoho*hoho*hoho*hoho*hoho*hoho*hoho*hoho*hoho*hoho*hoho*hoho*hoho*hoho*hoho*hoho*20;

    }

    pos.xyz = (gbufferModelView * gl_ModelViewMatrixInverse * vec4(worldPos - cameraPosition, 1.0)).xyz;

    gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * pos);
    
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

}
