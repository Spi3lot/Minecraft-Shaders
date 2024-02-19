bool isInVoxelizationVolume(ivec3 voxelIndex) {
	const int xzRadiusBlocks = SHADOW_RESOLUTION / 32;
	const ivec3 lo = ivec3(-xzRadiusBlocks    ,   0,-xzRadiusBlocks    );
	const ivec3 hi = ivec3( xzRadiusBlocks - 1, 255, xzRadiusBlocks - 1);

	return clamp(voxelIndex, lo, hi) == voxelIndex;
}

vec3 sceneSpaceToVoxelSpace(vec3 scenePosition) {
	scenePosition.xz += fract(cameraPosition.xz);
	scenePosition.y  += cameraPosition.y;
	return scenePosition;
}
vec3 worldSpaceToVoxelSpace(vec3 worldPosition) {
	worldPosition.xz -= floor(cameraPosition.xz);
	return worldPosition;
}

ivec2 getVoxelStoragePos(ivec3 voxelIndex) { // in pixels/texels
    const int radius = SHADOW_RESOLUTION / 16;

    ivec2 tileIdx = ivec2(voxelIndex.y & 15, voxelIndex.y >> 4);
    ivec2 position = voxelIndex.xz + radius * tileIdx;

    return position + (radius / 2);
}

#if defined FLOOD_FILL
uniform sampler2D shadowcolor1;

vec4[2] readVoxelData(ivec3 voxelPosition) {
	// Dunno why a -1 is needed here, but it is.
	ivec2 storagePos = getVoxelStoragePos(voxelPosition);

	vec4[2] voxel = vec4[2](texelFetch(shadowcolor0, storagePos, 0), texelFetch(shadowcolor1, storagePos, 0));

	voxel[0].a = 1.0 - voxel[0].a; // for convenience. TODO: add functions that get/set values in the voxel so this will be completely unnecessary

	return voxel;
}
#endif
