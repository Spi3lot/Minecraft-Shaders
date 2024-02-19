#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable

uniform sampler2D tex;
uniform sampler2D lightmap;
// uniform sampler2D normals;

in vec2 lmcoord;
in vec2 texcoord;
// in vec4 tint;

// flat in vec3 normal;
// flat in mat3 tbn;

// flat in float id;

/* RENDERTARGETS: 0,15 */

#include "/lib/includes.glsl"

void main() {
	vec2 lMapTex = texture(lightmap, lmcoord).xy;
	// vec4 color = texture(tex, texcoord);
    vec4 color = vec4(0.5, 0.5, 0.6, texture(tex, texcoord).a);
	color.rgb *= lMapTex.y;
	color.rgb *= 0.5*times.sunrise + 1.0*times.noon + 0.5*times.sunset + 0.25*times.night;
	color.rgb = pow(color.rgb, vec3(2.2));
	color.a = floor(clamp01(color.a*1.5));
	color.a *= rainStrength;

	// vec3 normalCol = texture(normals, texcoord).rgb*2.0-1.0;
    // normalCol.z = sqrt(1.0-dot(normalCol.xy, normalCol.xy));
	// normalCol *= tbn;

	gl_FragData[0] = color;
	gl_FragData[1] = vec4(color.a);

}
