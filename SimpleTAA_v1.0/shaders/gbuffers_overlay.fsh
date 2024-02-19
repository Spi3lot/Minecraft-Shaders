uniform sampler2D lightmap;
uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 uv;
varying vec4 glcolor;

void main() {
	vec4 color = texture2D(texture, uv) * glcolor;

    #ifdef gLIT
	color *= texture2D(lightmap, lmcoord);
    #endif

    color.rgb *= color.rgb;

/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}