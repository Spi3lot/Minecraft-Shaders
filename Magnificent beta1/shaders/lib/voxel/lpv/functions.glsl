const float aspectRatio = 1.5;
int pixels;
int layers;
ivec3 lpvDiameter;

#define LPV_DETAIL 1 //[1 2 4 8 16 32]

const int lpvDetail = LPV_DETAIL;

void initializeLpvVariables() {
    pixels = int(lpvSize.x * lpvSize.y);
    layers = int(pow(pixels / (aspectRatio * aspectRatio), 1.0/3.0));
    lpvDiameter = ivec3(aspectRatio * layers, layers, aspectRatio * layers);
}

bool isInPropagationVolume(ivec3 voxelIndex) {
	ivec3 maxBounds =  lpvDiameter / 2;
	ivec3 minBounds = -lpvDiameter / 2;
	return voxelIndex.x > minBounds.x && voxelIndex.y > minBounds.y && voxelIndex.z > minBounds.z
	    && voxelIndex.x < maxBounds.x && voxelIndex.y < maxBounds.y && voxelIndex.z < maxBounds.z;
}

vec3 sceneSpaceToLPVSpace(vec3 scenePosition) {
	scenePosition -= 0.5 / lpvDetail;
	scenePosition += fract(cameraPosition * lpvDetail) / lpvDetail;
	return scenePosition;
}

vec3 LPVSpaceToSceneSpace(in vec3 lpvPos) {
  lpvPos += 0.5 / lpvDetail;
  lpvPos -= fract(cameraPosition * lpvDetail) / lpvDetail;
  return lpvPos;
}

ivec2 getLPVStoragePos(ivec3 voxelIndex) { // in pixels/texels
	voxelIndex += lpvDiameter / 2;
	int idx1D = voxelIndex.x * lpvDiameter.y * lpvDiameter.z + voxelIndex.y * lpvDiameter.z + voxelIndex.z;
	return ivec2(idx1D % int(lpvSize), idx1D / int(lpvSize));
}
ivec3 lpvStoragePosToLPVIndex(ivec2 storagePos) { // in pixels/texels
	int idx1D = storagePos.x + storagePos.y * int(lpvSize);
	ivec3 voxelIndex = (idx1D / ivec3(lpvDiameter.y * lpvDiameter.z, lpvDiameter.z, 1)) % lpvDiameter;
	voxelIndex -= lpvDiameter / 2;
	return voxelIndex;
}

ivec3 lpvSpaceToVoxelSpace(ivec3 lpvIndex) {
	if(lpvDetail > 1) {
		lpvIndex += ivec3(floor(cameraPosition * lpvDetail)) % lpvDetail;
		lpvIndex += clamp(lpvIndex, -1, 0) * (lpvDetail - 1);
		lpvIndex = lpvIndex / lpvDetail;
	}
	lpvIndex.y += int(floor(cameraPosition.y));
	return lpvIndex;
}

vec3 getLight(in ivec3 lpvIndex) {
    #if PROGRAM == PROPAGATION
        lpvIndex += ivec3(floor(cameraPosition * lpvDetail) - floor(previousCameraPosition * lpvDetail));
	#endif

	#ifdef WATER
        lpvIndex -= ivec3(floor(cameraPosition * lpvDetail) - floor(previousCameraPosition * lpvDetail));
	#endif
    if(!isInPropagationVolume(lpvIndex)) return vec3(0.0);

    ivec2 storagePosition = getLPVStoragePos(lpvIndex);

    return texelFetch(gaux1, storagePosition, 0).rgb;
}

bool getVoxelOccupancy(ivec3 voxelIndex) {
	vec4[2] voxel = readVoxelData(voxelIndex);
	return voxel[0].a > 0.0;
}

bool getVoxelOccupancy(vec3 voxelPosition) {
	ivec3 voxelIndex = lpvSpaceToVoxelSpace(ivec3(voxelPosition));
	return getVoxelOccupancy(voxelIndex);
}

float getVoxelOcclusion(ivec3 voxelIndex) {
	return float(!getVoxelOccupancy(voxelIndex));
}

int getVoxelID(vec3 lpvPosition) {
	ivec3 voxelIndex = lpvSpaceToVoxelSpace(ivec3(lpvPosition));
	vec4[2] voxel = readVoxelData(voxelIndex);
	return int(floor(voxel[0].a * 255.0 + 0.5) - 1.0);
}