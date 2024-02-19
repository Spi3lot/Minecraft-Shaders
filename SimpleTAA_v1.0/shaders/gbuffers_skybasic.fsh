#version 120

#include "/lib/head.glsl"

uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;

varying vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.

varying vec4 tint;

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz);
	return mix(sqr(skyColor), sqr(fogColor), exp(-max(upDot, 0.0) * 6.28));
}

void main() {
	vec3 color;
	if (starData.a > 0.5) {
		color = starData.rgb;
	} else {
		vec4 pos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0, 1.0, 1.0);
		pos = gbufferProjectionInverse * pos;
		color = calcSkyColor(normalize(pos.xyz));

        if (tint.a < 0.99 && starData.a < 0.5) color = mix(color, tint.rgb, sqr(tint.a));
	}

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(ditherR11G11B10(color), 1.0); //gcolor
}