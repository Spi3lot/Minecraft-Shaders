#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable

uniform sampler2D tex;
uniform sampler2D lightmap;
uniform sampler2D normals;
uniform sampler2D specular;

uniform int entityId;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 tint;

flat in vec3 normal;
flat in mat3 tbn;

flat in float id;

/* RENDERTARGETS:0,1,2,3,10,15 */

#include "/lib/includes.glsl"

void main() {
	vec4 color = texture(tex, texcoord);
	color *= tint;
	color.rgb *= texture(lightmap, lmcoord).y;

	color.rgb = pow(color.rgb, vec3(2.2));
	
	if(entityId == 1194) color.a = 1.0;
	if(entityId == 1194) color.rgb = vec3(1.0);

	vec3 normalCol = texture(normals, texcoord).rgb*2.0-1.0;

	float normalAO = normalCol.z;

    normalCol.z = sqrt(1.0-dot(normalCol.xy, normalCol.xy));

	normalCol *= tbn;

    vec4 specularTex = texture(specular, texcoord);

    specularTex.r = pow2(1.0 - specularTex.r); //Convert the perceptual smoothness to linear roughness
	
	specularTex.g *= 255;

	gl_FragData[0] = color;
	gl_FragData[1] = vec4(normalCol, normalAO);
	gl_FragData[2] = vec4(lmcoord.xy, 0.0, 1.0);
	gl_FragData[3] = vec4(normal.xy*0.5+0.5, id/65535, tint.a);
	gl_FragData[4] = specularTex;
	gl_FragData[5] = vec4(float(entityId == 1194));
}
