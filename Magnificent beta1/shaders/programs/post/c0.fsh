layout(location = 0) out vec3 color;

#include "/lib/universal/universal.glsl"

uniform sampler2D colortex0;

in vec2 textureCoordinate;

/* DRAWBUFFERS:0 */
void main() {
    color = texture(colortex0, textureCoordinate).rgb;
}