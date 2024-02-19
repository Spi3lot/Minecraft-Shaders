#version 120

#include "/lib/head.glsl"

uniform sampler2D texture;

uniform float far;
uniform float viewHeight;
uniform float viewWidth;

uniform vec3 fogColor;
uniform vec3 skyColor;

uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;

varying vec3 sceneLocation;

varying vec2 uv;
varying vec4 glcolor;

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz);
	return mix(sqr(skyColor), sqr(fogColor), exp(-max(upDot, 0.0) * 6.28));
}

void main() {
	vec4 color = texture2D(texture, uv) * glcolor;

    vec4 pos    = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0, 1.0, 1.0);
        pos     = gbufferProjectionInverse * pos;
    color.rgb   = mix(sqr(color.rgb), calcSkyColor(normalize(pos.xyz)), getFogAlpha(length(sceneLocation) * 0.5, far));

/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}