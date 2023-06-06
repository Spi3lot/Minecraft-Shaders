#version 120


# define MAX 50.0


varying vec4 texcoord;


uniform float viewWidth;
uniform float viewHeight;
uniform float aspectRatio;

uniform vec3 shadowLightPosition;


uniform sampler2D gcolor;
uniform sampler2D shadowcolor;


void main() {
	vec2 uv = texcoord.st;

	vec2 border = vec2(0.25);
	border.y = border.y * aspectRatio;

	bool map = all(lessThan(uv, border));
	vec4 color = map ? texture2D(shadowcolor, 1.0 - (uv / (3.0 * border) + 1.0/3.0).yx) : texture2D(gcolor, uv);

	gl_FragColor = map ? (color == vec4(1) ? texture2D(gcolor, uv) : color) : color;
}
