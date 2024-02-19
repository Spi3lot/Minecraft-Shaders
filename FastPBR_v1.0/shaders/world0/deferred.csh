#version 430

layout(local_size_x = 8, local_size_y = 8) in;
const vec2 workGroupsRender = vec2(0.25, 0.25);

#define RSSBO_ENABLE_COLOR
#include "/lib/head.glsl"

layout(rgba16f) writeonly uniform image2D colorimg5;

uniform sampler2D colortex3, colortex4, depthtex2;

uniform sampler2D noisetex;

uniform int frameCounter, worldTime;

uniform float eyeAltitude, frameTimeCounter, wetness, worldAnimTime;

uniform vec2 viewSize, pixelSize, taaOffset;

uniform vec3 cloudLightDir, cameraPosition;

uniform mat4 gbufferModelView, gbufferModelViewInverse;
uniform mat4 gbufferProjection, gbufferProjectionInverse;

#define FUTIL_D3X3
#include "/lib/fUtil.glsl"

#include "/lib/util/transforms.glsl"
#include "/lib/frag/noise.glsl"
#include "/lib/atmos/phase.glsl"
#include "/lib/atmos/project.glsl"

#include "/lib/util/bicubic.glsl"

#define gl_FragCoord gl_GlobalInvocationID

#include "/lib/frag/bluenoise.glsl"
#include "/lib/frag/gradnoise.glsl"

#include "/lib/atmos/clouds/common.glsl"

vec4 RSKY_CloudSystem(vec3 WorldDirection, float Dither, float Noise, vec3 SkyColor) {
    if (WorldDirection.y < 0.0) return vec4(0,0,0,1);

    vec3 DirectColor = RColorTable.CloudDirectLight;
    vec3 AmbientColor = RColorTable.CloudSkylight * pi;
    float vDotL = dot(WorldDirection, cloudLightDir);

    vec4 Result = vec4(0,0,0,1);

    #ifdef RSKY_VC_Enabled
    {

    mat2x3 VolumeBounds = mat2x3(WorldDirection * ((RSKY_VolumeLimits.x - eyeAltitude) / WorldDirection.y),
                                 WorldDirection * ((RSKY_VolumeLimits.y - eyeAltitude) / WorldDirection.y));

    const float BaseStep = RSKY_VC_Depth / (float(RSKY_VC_Samples));
    float StepLength = length((VolumeBounds[0] - VolumeBounds[1]) / float(RSKY_VC_Samples));
    float StepCoeff = 0.45 + clamp((StepLength / BaseStep) - 1.1, 0.0, 3.0) * 0.5;
    uint StepCount = uint(float(RSKY_VC_Samples) * StepCoeff);

    vec3 RStep = (VolumeBounds[1] - VolumeBounds[0]) / StepCount;
    vec3 RPosition = RStep * Dither + VolumeBounds[0] + cameraPosition;
    float RLength = length(RStep);

    const float SigmaT = 0.1;

    float OpticalDepth = 0.0;

    for (uint I = 0; I < StepCount; ++I, RPosition += RStep) {
        if (Result.a < 0.01) break;
        if (RPosition.y > RSKY_VolumeLimits.y || RPosition.y < RSKY_VolumeLimits.x) continue;

        float SampleDistance = distance(RPosition, cameraPosition);
        if (SampleDistance > RSKY_VC_ClipDistance) continue;

        float Density = RSKY_VC_Shape(RPosition);
        if (Density <= 0.0) continue;

        float StepOpticalDepth = Density * SigmaT * RLength;
        float StepTransmittance = exp(-StepOpticalDepth);
        float ScatterIntegral = (1.0 - StepTransmittance) / SigmaT;

        vec3 StepScattering = vec3(0);

        vec2 LightExtinction = vec2(RSKY_VC_DirLightOD(RPosition, 6, Noise),
                                    RSKY_VC_AmbLightOD(RPosition, 4, Noise));

        const float Albedo = 0.83;
        const float ScatterMult = 1.0;

        #if 1

        float AvgTransmittance = exp(-((tau / SigmaT) * Density));
        float BounceEstimate = EstimateEnergy(Albedo * (1.0 - AvgTransmittance));
        float BaseScatter = Albedo * (1.0 - StepTransmittance);
        vec3 PhaseG = pow(vec3(0.5, 0.35, 0.9), vec3((1.0 + (LightExtinction.x + Density * RLength) * SigmaT)));

        float DirScatterScale = pow(1.0 + 1.5 * LightExtinction.x * SigmaT, -1.0 / 1.0) * BounceEstimate;
        float AmbScatterScale = pow(1.0 + 1.5 * LightExtinction.y * SigmaT, -1.0 / 1.0) * BounceEstimate;

            StepScattering.xy = BaseScatter * vec2(cloudPhase(vDotL, PhaseG) * DirScatterScale,
                                                   cloudPhaseSky(WorldDirection.y, PhaseG * vec3(1,1,0.5)) * AmbScatterScale);


        #else

        for (uint j = 0; j < 8; ++j) {
            float n     = float(j);
            float p     = pow(0.5, n);
            float td    = SigmaT * p;

            //scatterEnergy      += p;

            float AvgTransmittance  = exp(-20.0 * Density * p);
            float BounceEstimate    = 1.0 + EstimateEnergy(Albedo * (1.0 - AvgTransmittance));

            vec2 scattering     = pow(1.0 + ScatterMult * LightExtinction * td, vec2(-1.0 / ScatterMult)) * BounceEstimate;
            vec3 asymmetry      = pow(vec3(0.5, 0.35, 0.9), vec3((1.0 + (LightExtinction.x + Density * RLength) * td)));
            vec3 asymmetrySky   = pow(vec3(0.5, 0.35, 0.9), vec3((1.0 + (LightExtinction.y + Density * RLength) * td)));

            StepScattering.xy += scattering * vec2(cloudPhase(vDotL, asymmetry), cloudPhaseSky(WorldDirection.y, asymmetrySky)) * p;
        }

        StepScattering *= Albedo * (1.0 - StepTransmittance);

        #endif

        vec3 SkyFade = exp(-SampleDistance * 3.5e-5 * vec3(0.83, 0.89, 1.0));
            SkyFade = mix(SkyFade, vec3(0), sstep(SampleDistance, RSKY_VC_ClipDistance * 0.7, RSKY_VC_ClipDistance));
            StepScattering = DirectColor * StepScattering.x + AmbientColor * StepScattering.y;
            StepScattering = mix(SkyColor * SigmaT * ScatterIntegral, StepScattering, SkyFade);

        OpticalDepth += StepOpticalDepth;

        Result = vec4((StepScattering * Result.a) + Result.rgb, Result.a * StepTransmittance);
    }

    Result.a = linStep(Result.a, 0.01, 1.0);
    }
    #endif

    #ifdef RSKY_PC_Enabled
    if (Result.a > 0.0) {

    mat2x3 VolumeBounds = mat2x3(WorldDirection * ((RSKY_PlanarBounds.x - eyeAltitude) / WorldDirection.y) + cameraPosition,
                                 WorldDirection * ((RSKY_PlanarBounds.y - eyeAltitude) / WorldDirection.y) + cameraPosition);

    float RLength = distance(VolumeBounds[0], VolumeBounds[1]);
    vec3 RPosition = WorldDirection * ((RSKY_PlanarElevation - eyeAltitude) / WorldDirection.y) + cameraPosition;

    const float SigmaT = 0.01;
    float SampleDistance = distance(RPosition, cameraPosition);
    float Density = RSKY_PC_Shape(RPosition) * rpi;
    float StepOpticalDepth = Density * SigmaT * RLength;
    float StepTransmittance = exp(-StepOpticalDepth);
    float ScatterIntegral = (1.0 - StepTransmittance) / SigmaT;

    vec3 StepScattering = vec3(0);

    vec2 LightExtinction = vec2(RSKY_PC_LightOD(mix(RPosition, VolumeBounds[0], max0(cloudLightDir.y)), cloudLightDir, 5, Noise),
                                RSKY_PC_LightOD(VolumeBounds[0], vec3(0,1,0), 4, Noise)) * pi;

    const float Albedo = 0.9;
    const float ScatterMult = 1.0;


    float AvgTransmittance = exp(-((2.0 / SigmaT) * Density));
    float BounceEstimate = EstimateEnergy(Albedo * (1.0 - AvgTransmittance));
    float BaseScatter = Albedo * (1.0 - StepTransmittance);
    vec3 PhaseG = pow(vec3(0.6, 0.35, 0.9), vec3((1.0 + (LightExtinction.x + Density * RLength) * SigmaT * rpi)) * vec3(1, 1, 0.25));

    float DirScatterScale = pow(1.0 + 1.5 * LightExtinction.x * SigmaT, -1.0 / 1.0) * BounceEstimate;
    float AmbScatterScale = pow(1.0 + 1.5 * LightExtinction.y * SigmaT, -1.0 / 1.0) * BounceEstimate * rpi;

        StepScattering.xy = BaseScatter * vec2(cloudPhase(vDotL, PhaseG) * DirScatterScale,
                                                cloudPhaseSky(WorldDirection.y, PhaseG * vec3(1,1,0.5)) * AmbScatterScale);

    vec3 SkyFade = exp(-SampleDistance * 3e-5 * vec3(0.83, 0.89, 1.0));
        SkyFade = mix(SkyFade, vec3(0), sstep(SampleDistance, RSKY_VC_ClipDistance * 0.7, RSKY_VC_ClipDistance));
        StepScattering = DirectColor * StepScattering.x + AmbientColor * StepScattering.y;
        StepScattering = mix(SkyColor * SigmaT * ScatterIntegral, StepScattering, SkyFade);

    Result = vec4((StepScattering * Result.a) + Result.rgb, Result.a * StepTransmittance);

    }
    #endif

    return Result;
}

#define PATTERN_SIZE 4

const ivec2 CheckerboardOffset4[4]  = ivec2[4] (
    ivec2(0, 0),
    ivec2(1, 1),
    ivec2(0, 1),
    ivec2(1, 0)
);

const ivec2 CheckerboardOffset16[16]  = ivec2[16] (
    ivec2(1, 1),
    ivec2(2, 2),
    ivec2(2, 1),
    ivec2(1, 2),
    ivec2(3, 3),
    ivec2(3, 0),
    ivec2(0, 0),
    ivec2(0, 3),
    ivec2(3, 2),
    ivec2(1, 0),
    ivec2(0, 2),
    ivec2(2, 3),
    ivec2(3, 1),
    ivec2(2, 0),
    ivec2(0, 1),
    ivec2(1, 3)
);

float ditherBluenoiseCheckerboard(vec2 offset) {
    ivec2 UV = ivec2(gl_FragCoord.xy + offset);
    float noise = texelFetch(noisetex, UV & 255, 0).a;

        noise   = fract(noise+float(floor(frameCounter/PATTERN_SIZE))/pi*2);

    return noise;
}
float ditherGradNoiseCheckerboard(vec2 offset){
    return fract(52.9829189*fract(0.06711056*(gl_FragCoord.x + offset.x) + 0.00583715*(gl_FragCoord.y + offset.y) + 0.00623715 * (float(floor(frameCounter/PATTERN_SIZE)) * 0.31)));
}

void main() {
    ivec2 UV = ivec2(gl_GlobalInvocationID.xy);
    vec2 uv = (gl_GlobalInvocationID.xy + 0.5) / (viewSize * workGroupsRender.x);

    bool IsSky = depthMax3x3(depthtex2, uv * ResolutionScale, (pixelSize / workGroupsRender.x)) >= 1.0;

    int FrameIndex = (frameCounter) % PATTERN_SIZE;
    ivec2 FrameOffset = CheckerboardOffset4[FrameIndex];

    if (IsSky) {
        uv = uv + FrameOffset * pixelSize * 2.0;
        vec3 ScenePosition = viewToSceneSpace(screenToViewSpace(vec3(uv, 1.0), false));
        vec3 WorldDirection = normalize(ScenePosition);

        vec3 Skybox = textureBicubic(colortex3, projectSky(WorldDirection, 0)).rgb;

        vec4 Clouds = RSKY_CloudSystem(WorldDirection, ditherBluenoiseCheckerboard(FrameOffset), ditherGradNoiseCheckerboard(FrameOffset), Skybox);


        imageStore(colorimg5, UV, clamp16F(Clouds));
    } else {
        imageStore(colorimg5, UV, vec4(0,0,0,1));
    }
}