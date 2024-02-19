#version 430 compatibility
#extension GL_ARB_explicit_attrib_location : enable

uniform sampler2D tex;
uniform sampler2D lightmap;
uniform sampler2D normals;
uniform sampler2D specular;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 viewPos;
in vec4 tint;

flat in vec4 textureBounds;
flat in vec3 normal;
flat in mat3 tbn;

flat in float id;

/* RENDERTARGETS: 0,1,2,3,10 */

#include "/lib/includes.glsl"

void main() {

	vec2 coord = texcoord;

	vec4 color = texture(tex, coord);
	color.rgb *= tint.rgb;
	// color.rgb *= texture(lightmap, lmcoord).y;

	color.rgb = pow(color.rgb, vec3(2.2));

	vec3 normalCol = texture(normals, coord).rgb*2.0-1.0;

	float normalAO = normalCol.z;

    normalCol.z = sqrt(1.0-dot(normalCol.xy, normalCol.xy));

	normalCol *= tbn;

    vec4 specularTex = texture(specular, coord);

    specularTex.r = pow2(1.0 - specularTex.r); //Convert the perceptual smoothness to linear roughness
	
	specularTex.g *= 255;

	gl_FragData[0] = color;
	gl_FragData[1] = vec4(normalCol, normalAO);
	gl_FragData[2] = vec4(lmcoord.xy, 0.0, 1.0);
	gl_FragData[3] = vec4(normal.xy*0.5+0.5, id/65535,tint.a);
	gl_FragData[4] = specularTex;
}
