#version 430

layout(local_size_x = 4, local_size_y = 1) in;
const ivec3 workGroups = ivec3(1, 1, 1);

#define RSSBO_ENABLE_COLOR
#include "/lib/head.glsl"
#include "/lib/util/colorspace.glsl"

uniform vec3 sunDir, moonDir, cloudLightDir;
uniform vec3 fogColor;

void main() {
    uint Index = uint(gl_GlobalInvocationID.x);

    switch (Index) {
        case 0:
            vec3 Illuminance = netherSkylightColor;
                Illuminance = mix(Illuminance, LinearToRec2020(normalize(toLinear(fogColor))), 0.9);

            RColorTable.Skylight = Illuminance;
            RColorTable.CloudDirectLight = Illuminance;
            RColorTable.AtmosIlluminance = Illuminance;

        case 1:
            RColorTable.Blocklight = RColor_Lightmap * blocklightIllum * blocklightBaseMult * pi;
    }

}