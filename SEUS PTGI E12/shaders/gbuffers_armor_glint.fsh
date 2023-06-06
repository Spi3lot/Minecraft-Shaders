#version 330 compatibility


in vec4 color;
in vec4 texcoord;
in vec3 worldPos;

#include "lib/Uniforms.inc"
#include "lib/Common.inc"


void main() 
{
	vec4 albedo = color;
	albedo.a = 1.0;

	// albedo *= pow(texture2D(colortex0, texcoord.xy * 1.0 + FRAME_TIME * 0.3), vec4(2.2));
	albedo *= texture2D(colortex0, texcoord.xy * 1.0 + FRAME_TIME * 0.03);

	albedo.rgb = pow(albedo.rgb, vec3(2.2));

	// albedo.rgb = vec3(1.0, 0.0, 0.0);
	// albedo.a = 1.0;

	// albedo.rgb *= 0.5 - abs(simplex3d(worldPos.xyz * 4.0 + FRAME_TIME)) * 1.0;


	gl_FragData[0] = albedo;
}
/* DRAWBUFFERS:0 */
