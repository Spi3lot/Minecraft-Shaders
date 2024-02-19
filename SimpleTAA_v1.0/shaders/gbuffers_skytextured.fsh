#version 120

#include "/lib/head.glsl"

uniform sampler2D texture;

varying vec2 uv;
varying vec4 glcolor;

void main() {
	vec4 color = texture2D(texture, uv) * glcolor;
        color.rgb = sqr(color.rgb);
        //color.a  = sqr(color.a);
        //color.rgb *= normalizeSafe(color.rgb) * 1.25;

/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}