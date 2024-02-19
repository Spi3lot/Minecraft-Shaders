#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable

#define colorR 0.1 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define colorG 0.3 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define colorB 0.2 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define colorA 0.1 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
uniform sampler2D tex;
uniform sampler2D lightmap;
uniform sampler2D normals;

in vec2 lmcoord;
in vec2 texcoord;
in vec3 worldPos;
in vec4 tint;

flat in vec3 normal;
flat in mat3 tbn;

flat in float id;

/* DRAWBUFFERS:013 */

#include "/lib/includes.glsl"

void main() {
	// if(id == 1193) discard;
	vec4 color = texture2D(tex, texcoord) * vec4(tint.rgb, 1.0);
	color.rgb *= texture2D(lightmap, lmcoord).y;
	color.rgb = pow(color.rgb, vec3(2.2));

	vec3 normalCol = texture2D(normals, texcoord).rgb*2.0-1.0;
    normalCol.z = sqrt(1.0-dot(normalCol.xy, normalCol.xy));
	normalCol *= tbn;

	if(id == 8.0 || id == 9.0) {
		normalCol = (waterN(worldPos)*tbn);
		color = vec4(vec3(colorR, colorG, colorB)*1.5, colorA);
	}
		
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(normalCol,1.0);
	gl_FragData[2] = vec4(normal.xy*0.5+0.5,id/65535,1.0);
}
