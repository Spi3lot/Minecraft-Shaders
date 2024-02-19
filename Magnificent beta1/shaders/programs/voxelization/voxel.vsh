#define attribute in
attribute vec4 mc_Entity;
attribute vec2 mc_midTexCoord;
attribute vec4 at_tangent;
attribute vec3 at_midBlock;

uniform mat4 shadowModelViewInverse;

flat out vec4 vertTangent;
out vec3 tint;
out vec3 scenePosition;
out vec3 vertNormal;
out vec3 midBlock;
out vec2 midTexCoordinate;
out vec2 textureCoordinate;
out float cantBeVoxelized;
out int blockId;

void main() {
    gl_Position = gl_Vertex;

	//scenePosition = (shadowModelViewInverse * gl_Position).xyz;

    vertNormal = normalize(mat3(shadowModelViewInverse) * gl_NormalMatrix * gl_Normal);
	vertTangent = at_tangent;

    cantBeVoxelized = 0.0;
    if (mc_Entity.x == 1059 || mc_Entity.x == 1010 || mc_Entity.x == 0) cantBeVoxelized = 1.0;

    blockId = 0;
    if (mc_Entity.x == 1000) blockId = 1;
    if (mc_Entity.x == 1001) blockId = 2;
    if (mc_Entity.x == 1002) blockId = 3;
    if (mc_Entity.x == 1003) blockId = 4;
    if (mc_Entity.x == 1004) blockId = 5;
    if (mc_Entity.x == 1005) blockId = 6;
    if (mc_Entity.x == 1006) blockId = 7;
    if (mc_Entity.x == 1007) blockId = 8;
    if (mc_Entity.x == 1008) blockId = 9;
    if (mc_Entity.x == 1009) blockId = 10;
    if (mc_Entity.x == 1011) blockId = 11;
    if (mc_Entity.x == 1012) blockId = 12;
    if (mc_Entity.x == 1013) blockId = 13;
    if (mc_Entity.x == 1014) blockId = 14;
    if (mc_Entity.x == 1015) blockId = 15;
    if (mc_Entity.x == 1016) blockId = 16;
    if (mc_Entity.x == 1017) blockId = 17;
    if (mc_Entity.x == 1020) blockId = 20;
    if (mc_Entity.x == 1060) blockId = 90;
    blockId += 1;

    midBlock = at_midBlock;
	tint = gl_Color.rgb;
	textureCoordinate = gl_MultiTexCoord0.xy;
	midTexCoordinate = mc_midTexCoord;
}
