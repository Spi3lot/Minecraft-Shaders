#version 330 compatibility


uniform sampler2D lightmap;
uniform sampler2D texture;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;


void main() {
	vec4 color = glcolor * texture2D(texture, texcoord);
	color *= texture2D(lightmap, lmcoord);

/* DRAWBUFFERS:0 */
	gl_FragColor = color; //gcolor
}