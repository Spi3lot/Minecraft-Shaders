#include "/lib/head.glsl"

uniform sampler2D lightmap;

#ifdef gTEXTURED
uniform sampler2D texture;
#endif

uniform float far;

uniform vec2 viewSize;

uniform vec3 fogColor;
uniform vec3 skyColor;

#ifdef gENTITY
uniform vec4 entityColor;
#endif

uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;

varying vec3 sceneLocation;

varying vec2 lmcoord;
varying vec2 uv;
varying vec4 glcolor;

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz);
	return mix(sqr(skyColor), sqr(fogColor), exp(-max(upDot, 0.0) * 6.28));
}

void main() {
    #ifdef gTEXTURED
	vec4 color = texture2D(texture, uv) * glcolor;
    #else
    vec4 color  = glcolor;
    #endif

    #ifdef gENTITY
        color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
    #endif

        color.rgb = sqr(color.rgb);
	    color.rgb *= sqr(texture2D(lightmap, lmcoord).rgb);

    vec4 pos    = vec4(gl_FragCoord.xy / viewSize * 2.0 - 1.0, 1.0, 1.0);
        pos     = gbufferProjectionInverse * pos;
    color.rgb   = mix((color.rgb), isEyeInWater == 2 ? sqr(fogColor) : calcSkyColor(normalize(pos.xyz)), getFogAlpha(length(sceneLocation), far));

    color.rgb   = ditherR11G11B10(color.rgb);

/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}