vec4 inPos = gl_Vertex;
vec4 inTexCoord = gl_MultiTexCoord0;

#include "/lib/universal/universal.glsl"

out vec2 textureCoordinate;

void main() {
    gl_Position = vec4(inPos.xy * 2.0 - 1.0, 0.0, 1.0);

    textureCoordinate = inTexCoord.xy;
}
