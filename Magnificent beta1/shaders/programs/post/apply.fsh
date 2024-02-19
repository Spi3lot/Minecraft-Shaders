layout(location = 0) out vec3 color;

#include "/lib/universal/universal.glsl"

uniform sampler2D colortex2;

in vec2 textureCoordinate;

/* DRAWBUFFERS:0 */
void main() {
    color = texture(colortex2, textureCoordinate).rgb;
}