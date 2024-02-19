#define FLOOD_FILL

layout(location = 0) out vec4 lightPropagationVolume;
layout(location = 1) out vec4 lpvSky;

/* DRAWBUFFERS:45 */

#include "/lib/universal/universal.glsl"

uniform sampler2D gaux1;
uniform sampler2D gaux2;
uniform sampler2D shadowtex0;
uniform sampler2D shadowcolor0;

uniform vec3 cameraPosition, previousCameraPosition;

uniform vec2 viewSize;

uniform float frameTimeCounter;

const bool gaux1Clear = false;
const bool gaux2Clear = false;
const bool gaux3Clear = false;
const bool gaux4Clear = false;

#include "/lib/voxel/constants.glsl"
#include "/lib/voxel/voxelization.glsl"
#include "/lib/voxel/lpv/functions.glsl"
#include "/lib/voxel/lpv/functionsSL.glsl"

vec3 getEmission(in ivec3 voxelIndex) {
    vec4[2] voxel = readVoxelData(voxelIndex);
	if(voxel[0].a <= 0.0) return vec3(0.0);
    int id = int(floor(voxel[0].a * 255.0 + 0.5) - 1.0);

    bool emissive = 
    id == 1  ||
    id == 2  ||
    id == 3  ||
    id == 4  ||
    id == 5  ||
    id == 6  ||
    id == 7  ||
    id == 8  ||
    id == 10 ||
    id == 11 ||
    id == 12 ||
    id == 13 ||
    id == 14 ||
    id == 15 ||
    id == 16 ||
    id == 17;

    float brightness = 0.0;
    if(id == 1) brightness = 60.0;
    if(id == 2) brightness = 25.0;
    if(id == 3) brightness = 10.0;
    if(id == 4) brightness = 10.0;
    if(id == 5) brightness = 4.00;
    if(id == 6) brightness = 10.00;
    if(id == 10) brightness = 10.0;
    if(id == 11) brightness = 10.0;
    if(id == 12) brightness = 5.00;
    if(id == 13) brightness = 20.0;
    if(id == 14) brightness = 15.0;
    if(id == 15) brightness = 20.0;
    if(id == 16) brightness = 10.0;
    if(id == 17) brightness = 10.0;

    vec3 lightColor = voxel[0].rgb;
    if(id == 1) lightColor = vec3(0.2, 0.8, 1.0) * .5;
    if(id == 2) lightColor = vec3(1.0, 0.7, 0.4);
    if(id == 3) lightColor = vec3(0.7, 0.5, 0.9) * 1.1;
	if(id == 4) lightColor = vec3(1.00, 0.60, 0.30);
	if(id == 5) lightColor = vec3(1.00, 0.30, 0.10);
	if(id == 6) lightColor = vec3(1.00, 0.40, 0.20);
	if(id == 11) lightColor = vec3(1.00, 0.60, 0.30);
	if(id == 12) lightColor = vec3(0.1, 0.8, 1.0);
	if(id == 13) lightColor = vec3(1.0, 0.5, 0.2);
	if(id == 14) lightColor = vec3(1.0, 0.6, 0.4);
	if(id == 15) lightColor = vec3(0.6, 0.7, 1.0);
	if(id == 16) lightColor = vec3(1.0, 0.2, 0.1);
	if(id == 17) lightColor = vec3(0.8, 0.4, 0.0);

    return emissive ? srgbToLinear(lightColor) * brightness : vec3(0.0);
}

vec3 calculateLPVPropagation(in ivec3 lpvIndex) {
    vec3 propagation = vec3(0.0);
    int id = getVoxelID(lpvIndex);
    ivec3 voxelPosition = lpvSpaceToVoxelSpace(lpvIndex);

    bool transparent = id == 9 || id == 20;

    vec3 voxelColor = transparent ? readVoxelData(voxelPosition)[0].rgb : vec3(1.0);

    const vec3[6] directions =  vec3[6](vec3(0,0,1), vec3(0,0,-1), vec3(1,0,0), vec3(-1,0,0), vec3(0,1,0), vec3(0,-1,0));
    for(int i = 0; i < 6; ++i) {
        vec3 light = getLight(lpvIndex + ivec3(directions[i]));

        propagation += light / 6.0;
    }

    return propagation * srgbToLinear(voxelColor);
}

vec3 calculateLPVSkyPropagation(in ivec3 lpvIndex, inout bool isSky) {
    vec3 propagation = vec3(0.0);
    int id = getVoxelID(lpvIndex + ivec3(0, 1, 0));
    ivec3 voxelPosition = lpvSpaceToVoxelSpace(lpvIndex) + ivec3(0, 1, 0);

    bool transparent = id == 9 || id == 20 || id == 90;

    vec3 voxelColor = transparent ? readVoxelData(voxelPosition)[0].rgb : vec3(1.0);
    if(id == 90) {
        voxelColor = vec3(0.9);
    }

    ivec3 lpvIndexIsSky = lpvIndex + ivec3(0, 1, 0);
          lpvIndexIsSky += ivec3(floor(cameraPosition * lpvDetail) - floor(previousCameraPosition * lpvDetail));

    ivec2 storagePosition = getLPVStoragePosSky(lpvIndexIsSky);
    bool isInVolume = isInPropagationVolumeSky(lpvIndexIsSky);

    isSky = false;
    if(!isInVolume) {
        isSky = true;
    } else if(texelFetch(gaux2, storagePosition, 0).a > 0.9 && isInVolume && !transparent) {
        isSky = true;
    }

    const vec3[6] directions =  vec3[6](vec3(0,0,1), vec3(0,0,-1), vec3(1,0,0), vec3(-1,0,0), vec3(0,1,0), vec3(0,-1,0));
    for(int i = 0; i < 6; ++i) {
        vec3 light = getSkyLight(lpvIndex + ivec3(directions[i]));

        propagation += light / 6.0;
    }

    if(isSky) {
        propagation = vec3(1.0) * srgbToLinear(voxelColor);
    }

    return propagation * srgbToLinear(voxelColor);
}

void main() {
    initializeLpvVariables();
    initializeLpvVariablesSky();

    ivec3 lpvIndex = lpvStoragePosToLPVIndex(ivec2(gl_FragCoord.st));
    ivec3 voxelIndex = lpvSpaceToVoxelSpace(lpvIndex);

    int id = getVoxelID(lpvIndex);

    bool transparent = id != 9 && id != 20 && id != 90;

    vec3 propagated = transparent && getVoxelOccupancy(voxelIndex) ? vec3(0.0) : calculateLPVPropagation(lpvIndex);
    vec3 emission   = getEmission(voxelIndex);

    lightPropagationVolume.rgb = propagated + emission;
    lightPropagationVolume.a = 1.0;

    ivec3 lpvIndexSky = lpvStoragePosToLPVIndexSky(ivec2(gl_FragCoord.st));
    ivec3 voxelIndexSky = lpvSpaceToVoxelSpace(lpvIndexSky);

    int idSky = getVoxelID(lpvIndexSky);

    bool transparentSky = idSky != 9 && idSky != 20 && idSky != 90;

    bool isSky = false;
    vec3 propagatedSky = transparentSky && getVoxelOccupancy(voxelIndexSky) ? vec3(0.0) : calculateLPVSkyPropagation(lpvIndexSky, isSky);

    lpvSky.rgb = propagatedSky;
    lpvSky.a = float(isSky);
}