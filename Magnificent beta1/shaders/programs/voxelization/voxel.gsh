#define VOXELIZATION_PASS

uniform vec3 cameraPosition;

#include "/lib/universal/universal.glsl"

#include "/lib/voxel/constants.glsl"

layout (triangles) in;
layout (points, max_vertices = 1) out;

uniform sampler2D tex;

uniform mat4 shadowModelViewInverse;

const bool colortex0MipmapEnabled = true;

flat in vec4[] vertTangent;
in vec3[] tint;
in vec3[] scenePosition;
in vec3[] vertNormal;
in vec3[] midBlock;
in vec2[] midTexCoordinate;
in vec2[] textureCoordinate;
in float[] cantBeVoxelized;
in int[] blockId;

float max2(vec2 x) {
    return max(x.x, x.y);
}

float max3(float x, float y, float z) {
    return max(x, max(y, z));
}
float max3(vec3 x) {
    return max(x.x, max(x.y, x.z));
}
float min3(float x, float y, float z) {
    return min(x, min(y, z));
}
float min3(vec3 x) {
    return min(x.x, min(x.y, x.z));
}
float mean(vec3 x) {
    return (x.x + x.y + x.z) * rcp(3.0);
}

#include "/lib/voxel/voxelization.glsl"

out vec4[2] voxel;

vec3 findQuadCenter() {
    vec3 m;
    m.xy = (midTexCoordinate[0] - textureCoordinate[2]) * inverse(mat2(
        textureCoordinate[0].x - textureCoordinate[2].x, textureCoordinate[1].x - textureCoordinate[2].x,
        textureCoordinate[0].y - textureCoordinate[2].y, textureCoordinate[1].y - textureCoordinate[2].y
    ));
    m.z = 1.0 - m.x - m.y;

    return mat3(gl_in[0].gl_Position.xyz, gl_in[1].gl_Position.xyz, gl_in[2].gl_Position.xyz) * m;
}

vec3 determineVoxelLocation() {
    vec3 tmp = gl_in[0].gl_Position.xyz + midBlock[0] / 64.0;

    tmp = mat3(gl_ModelViewMatrix) * tmp + gl_ModelViewMatrix[3].xyz;
    tmp = mat3(shadowModelViewInverse) * tmp + shadowModelViewInverse[3].xyz;
    tmp = sceneSpaceToVoxelSpace(tmp);

    return floor(tmp);
}

void main() {
    if (cantBeVoxelized[0] > 0.5) return;

    vec3 pos = findQuadCenter();
         pos = transMAD(gl_ModelViewMatrix, pos);
         pos = transMAD(shadowModelViewInverse, pos);

    ivec3 voxelIndex = ivec3(determineVoxelLocation());
    vec4 p2d = vec4(((getVoxelStoragePos(voxelIndex) + 0.5) / float(SHADOW_RESOLUTION)) * 2.0 - 1.0, vertNormal[0].y * -0.25 + 0.5, 1.0);

    if(!isInVoxelizationVolume(voxelIndex)) {
        return;
    }

    float id = blockId[0];

    ivec2 atlasResolution = textureSize(tex, 0);
    vec2 atlasAspectCorrect = vec2(1.0, float(atlasResolution.x) / float(atlasResolution.y));
    float tileSize   = maxof(abs(textureCoordinate[0] - midTexCoordinate[0]) / atlasAspectCorrect) / maxof(abs(scenePosition[0] - scenePosition[1]));
    vec2  tileOffset = round((midTexCoordinate[0] - tileSize * atlasAspectCorrect) * atlasResolution);
            tileSize   = round(2.0 * tileSize * atlasResolution.x);
            tileOffset = round(tileOffset / tileSize);

    vec4 data0 = vec4(textureLod(tex, textureCoordinate[0], 0).rgb * tint[0].rgb, 1.0 - (id / 255.0));
    vec4 data1 = saturate(vec4(0.0));

    gl_Position = p2d; voxel[0] = data0; voxel[1] = data1;
    gl_PointSize = 1.0;
    EmitVertex();
    EndPrimitive();
}