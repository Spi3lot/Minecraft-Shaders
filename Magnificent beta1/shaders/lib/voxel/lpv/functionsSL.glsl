const float aspectRatioSky = 1.0;
int pixelsSky;
int layersSky;
ivec3 lpvDiameterSky;

void initializeLpvVariablesSky() {
    pixelsSky = int(lpvSize.x * lpvSize.y);
    layersSky = int(pow(pixelsSky / (aspectRatioSky * aspectRatioSky), 1.0/3.0));
    lpvDiameterSky = ivec3(aspectRatioSky * layersSky, layersSky, aspectRatioSky * layersSky);
}

bool isInPropagationVolumeSky(ivec3 voxelIndex) {
	ivec3 maxBounds =  lpvDiameterSky / 2;
	ivec3 minBounds = -lpvDiameterSky / 2;
	return voxelIndex.x > minBounds.x && voxelIndex.y > minBounds.y && voxelIndex.z > minBounds.z
	    && voxelIndex.x < maxBounds.x && voxelIndex.y < maxBounds.y && voxelIndex.z < maxBounds.z;
}

ivec2 getLPVStoragePosSky(ivec3 voxelIndex) { // in pixels/texels
	voxelIndex += lpvDiameterSky / 2;
	int idx1D = voxelIndex.x * lpvDiameterSky.y * lpvDiameterSky.z + voxelIndex.y * lpvDiameterSky.z + voxelIndex.z;
	return ivec2(idx1D % int(lpvSize), idx1D / int(lpvSize));
}
ivec3 lpvStoragePosToLPVIndexSky(ivec2 storagePos) { // in pixels/texels
	int idx1D = storagePos.x + storagePos.y * int(lpvSize);
	ivec3 voxelIndex = (idx1D / ivec3(lpvDiameterSky.y * lpvDiameterSky.z, lpvDiameterSky.z, 1)) % lpvDiameterSky;
	voxelIndex -= lpvDiameterSky / 2;
	return voxelIndex;
}

vec3 getSkyLight(in ivec3 lpvIndex) {
    #if PROGRAM == PROPAGATION
        lpvIndex += ivec3(floor(cameraPosition * lpvDetail) - floor(previousCameraPosition * lpvDetail));
	#endif

	#ifdef WATER
        lpvIndex -= ivec3(floor(cameraPosition * lpvDetail) - floor(previousCameraPosition * lpvDetail));
	#endif
    if(!isInPropagationVolumeSky(lpvIndex)) return vec3(0.0);

    ivec2 storagePosition = getLPVStoragePosSky(lpvIndex);

    return texelFetch(gaux2, storagePosition, 0).rgb;
}