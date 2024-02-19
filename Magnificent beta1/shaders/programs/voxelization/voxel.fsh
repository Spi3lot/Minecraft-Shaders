in vec4[2] voxel;

#ifndef MC_GL_RENDERER_RADEON
    layout (location = 0) out vec4 shadowcolor0;
    layout (location = 1) out vec4 shadowcolor1;
#endif

#ifdef MC_GL_RENDERER_RADEON
    vec4 shadowcolor0;
    vec4 shadowcolor1;
#endif

void main() {
	shadowcolor0 = voxel[0];
	shadowcolor1 = voxel[1];

    #ifdef MC_GL_RENDERER_RADEON
        gl_FragData[0] = shadowcolor0;
        gl_FragData[1] = shadowcolor1;
    #endif
}