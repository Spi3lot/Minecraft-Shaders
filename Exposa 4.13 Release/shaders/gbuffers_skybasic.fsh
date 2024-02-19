#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable

uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;

in vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.

/* DRAWBUFFERS:0 */
void main() {

	gl_FragData[0] = vec4(vec3(starData*starData.a), 1.0);
}
