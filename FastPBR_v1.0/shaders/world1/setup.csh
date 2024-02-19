#version 430

layout(local_size_x = 8, local_size_y = 1) in;
const ivec3 workGroups = ivec3(1, 1, 1);

#define RSSBO_ENABLE_COLOR
#include "/lib/head.glsl"

#define END_SUN_MULT vec3(0.7, 0.5, 1.0) * 0.3

void main() {
    uint Index = uint(gl_GlobalInvocationID.x);

    switch (Index) {
        case 0:
            vec3 Illuminance = endSkylightColor * 0.25;

            RColorTable.Skylight = Illuminance;
            RColorTable.CloudDirectLight = Illuminance;
            RColorTable.AtmosIlluminance = Illuminance;

        case 1:
            RColorTable.Sunlight = endSunlightColor * 0.66;
            RColorTable.DirectLight = endSunlightColor * 0.66;

        case 2:
            RColorTable.Blocklight = RColor_Lightmap * blocklightIllum * blocklightBaseMult;

        case 3:
            RColorTable.CloudDirectLight = endSunlightColor * vec3(1.0, 1.4, 1.4);
    }

}