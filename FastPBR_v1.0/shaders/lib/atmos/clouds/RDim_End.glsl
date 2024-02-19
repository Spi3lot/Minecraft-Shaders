#define REnd_Sky_VC_Altitude 4e2        //[4e2 6e2 8e2 10e2 12e2 14e2 16e2 18e2 20e2]
#define REnd_Sky_VC_Depth 2e3           //[4e2 6e2 8e2 10e2 15e2 2e3 3e3 4e3]
#define REnd_Sky_VC_Samples 60          //[50 55 60 65 70 75 80 85 90 95 100]
#define REnd_Sky_VC_ClipDistance 4e4    //[2e5 3e5 4e5 5e5 6e5 7e5 8e5 9e5 10e5]
#define REnd_Sky_VC_CoverageBias 0.0    //[-0.5 -0.4 -0.3 -0.2 -0.1 0.0 0.1 0.2 0.3 0.4 0.5]

const vec2 REnd_Sky_VolumeLimits = vec2(REnd_Sky_VC_Altitude, REnd_Sky_VC_Altitude + REnd_Sky_VC_Depth);

#define REnd_Sky_PC_Altitude 10e3       //[5e3 6e3 7e3 8e3 9e3 10e3 12e3 14e3 16e3 18e3 20e3]
#define REnd_Sky_PC_Depth 2e3           //[1e3 2e3 3e3 4e3]
#define REnd_Sky_PC_CoverageBias 0.0    //[-0.5 -0.4 -0.3 -0.2 -0.1 0.0 0.1 0.2 0.3 0.4 0.5]

const vec2 REnd_Sky_PlanarBounds = vec2(REnd_Sky_PC_Altitude, REnd_Sky_PC_Altitude + REnd_Sky_PC_Depth);
const float REnd_Sky_PlanarElevation = REnd_Sky_PC_Altitude + REnd_Sky_PC_Depth * 0.2;


#ifdef freezeAtmosAnim
    const float REnd_Sky_CloudTime   = float(atmosAnimOffset) * 0.2;
#else
        float REnd_Sky_CloudTime     = frameTimeCounter * 0.2;
#endif

float estimateEnergy(float ratio) {
    return ratio / (1.0 - ratio);
}

uniform vec3 volumeCloudData;

float cloudPhase(float cosTheta, vec3 asymmetry) {
    float x = mieHG(cosTheta, asymmetry.x);
    float y = mieHG(cosTheta, -asymmetry.y) * volumeCloudData.z;
    float z = mieCS(cosTheta, asymmetry.z);

    return 0.7 * x + 0.2 * y + 0.1 * z;
}
float cloudPhaseSky(float cosTheta, vec3 asymmetry) {
    float x = mieHG(cosTheta, asymmetry.x);
    float y = mieHG(cosTheta, -asymmetry.y);

    return 0.75 * x + 0.25 * y;
}

float REnd_Sky_VC_Shape(vec3 Position) {
    float Altitude = Position.y;

    float Elevation = (Altitude - REnd_Sky_VC_Altitude) / REnd_Sky_VC_Depth;

    vec4 ErosionFade = vec4(1.0 - sstep(Elevation, 0.0, 0.22),  //EL
                            sstep(Elevation, 0.19, 1.0),        //ER
                            sstep(Elevation, 0.0, 0.1),         //FL
                            1.0 - sstep(Elevation, 0.6, 1.0));  //FR

    vec3 WindOffset = vec3(REnd_Sky_CloudTime, 0.0, REnd_Sky_CloudTime * 0.6);

        Position *= 1.5e-3;
        Position += WindOffset * 0.3;

    float CoverageBias = 0.35 - REnd_Sky_VC_CoverageBias * 0.1;

    float Coverage = mix(Noise2D(Position.xz * 0.026).b, Noise2D(Position.xz * 0.046).b, 0.5);
        Coverage = (Coverage - CoverageBias) / (1.0 - saturate(CoverageBias));
        Coverage = (Coverage * ErosionFade.z * ErosionFade.w) - ErosionFade.x * 0.26 - ErosionFade.y * 0.65;
        Coverage = saturate(Coverage * 1.05);

    if (Coverage <= 0.0) return 0.0;

    float WF = sstep(Elevation, 0.0, 0.33) * 0.5 + 0.5;

    float Density = 0.001 + sstep(Elevation, 0.0, 0.2) * 0.1;
        Density += sstep(Elevation, 0.1, 0.45) * 0.4;
        Density += sstep(Elevation, 0.2, 0.60) * 0.8;
        Density += sstep(Elevation, 0.3, 0.85) * 0.9;
        Density /= 0.001 + 0.1 + 0.4 + 0.8 + 0.9;

    float Shape = Coverage;
    float Hardness = sqrt(sstep(Elevation, 0.26, 0.64));

        Position.xy += Shape * 1.0;

    float N1 = Value3D(Position * 6.0 - WindOffset.zyx * 8.0) * 0.3 * WF;
        Shape -= N1; Position -= N1 * 1.0;
        Shape -= Value3D(Position * 24.0 + WindOffset.zyx * 10.8) * 0.13 * sqrt(1.0 - saturate(Shape));
        //Shape -= Value3D(Position * 96.0) * 0.06 * sqrt(1.0 - saturate(Shape));
        Shape = saturate(Shape);
        Shape = 1.0 - pow(1.0 - Shape, 2.0);

    return max0(Shape * Density * volumeCloudData.y);
}

float REnd_Sky_VC_DirLightOD(vec3 Position, const uint Steps, float Noise) {
    const vec2 ExpParams = vec2(22.2, 2.0);

    float CurrStep = ExpParams.x;
    float PrevStep = ExpParams.x;

    float Density = 0.0;

    Position += cloudLightDir * Noise * CurrStep;

    for (uint i = 0; i < Steps; ++i, Position += cloudLightDir * CurrStep) {
        Position += cloudLightDir * Noise * (CurrStep - PrevStep);

        if (Position.y > REnd_Sky_VolumeLimits.y || Position.y < REnd_Sky_VolumeLimits.x) continue;

        PrevStep = CurrStep;
        CurrStep *= ExpParams.y;

        float Sample = REnd_Sky_VC_Shape(Position);
        if (Sample <= 0.0) continue;

        Density += Sample * PrevStep;
    }

    return Density;
}
float REnd_Sky_VC_AmbLightOD(vec3 Position, const uint Steps, float Noise) {
    const vec3 Direction = vec3(0, 1, 0);

    float StepSize = (REnd_Sky_VC_Depth / float(Steps));
        StepSize *= 1.0 - linStep(Position.y, REnd_Sky_VolumeLimits.x, REnd_Sky_VolumeLimits.y) * 0.9;

        Position += cloudLightDir * Noise * StepSize;

    float Density = 0.0;

    for (uint i = 0; i < Steps; ++i, Position += cloudLightDir * StepSize) {
        if (Position.y > REnd_Sky_VolumeLimits.y || Position.y < REnd_Sky_VolumeLimits.x) continue;

        float Sample = REnd_Sky_VC_Shape(Position);
        if (Sample <= 0.0) continue;

        Density += Sample * StepSize;
    }

    return Density;
}

vec2 Noise2DCubic(sampler2D tex, vec2 pos) {
        pos        *= 256.0;
    ivec2 location  = ivec2(floor(pos));

    vec2 samples[4]    = vec2[4](
        texelFetch(tex, location                 & 255, 0).xy, texelFetch(tex, (location + ivec2(1, 0)) & 255, 0).xy,
        texelFetch(tex, (location + ivec2(0, 1)) & 255, 0).xy, texelFetch(tex, (location + ivec2(1, 1)) & 255, 0).xy
    );

    vec2 weights    = cubeSmooth(fract(pos));


    return mix(
        mix(samples[0], samples[1], weights.x),
        mix(samples[2], samples[3], weights.x), weights.y
    );
}

uniform vec2 volumeCirrusData;

float REnd_Sky_PC_Shape(vec3 Position) {
    float Altitude = Position.y;

    float Elevation = (Altitude - REnd_Sky_PC_Altitude) / REnd_Sky_PC_Depth;

    vec4 ErosionFade = vec4(1.0 - sstep(Elevation, 0.0, 0.19),  //EL
                            sstep(Elevation, 0.22, 1.0),        //ER
                            sstep(Elevation, 0.0, 0.2),         //FL
                            1.0 - sstep(Elevation, 0.6, 1.0));  //FR

    vec3 WindOffset = vec3(REnd_Sky_CloudTime, 0.0, REnd_Sky_CloudTime * 0.4);

        Position.xz /= 1.0 + distance(cameraPosition.xz, Position.xz) * 0.000004;
        Position *= 15e-5;
        Position += WindOffset * 0.1;

    float CoverageBias = 0.2 - REnd_Sky_PC_CoverageBias * 0.1;

        Position.xz += Noise2DCubic(noisetex, Position.xz * 0.004).xy * 2.3;
        Position.x *= 0.8;

    float Coverage = Noise2D(Position.xz * 0.026).b;
        Coverage = (Coverage - CoverageBias) / (1.0 - saturate(CoverageBias));
        Coverage = (Coverage * ErosionFade.z * ErosionFade.w) - ErosionFade.x * 0.3 - ErosionFade.y * 0.75;
        Coverage = saturate(Coverage);

    if (Coverage <= 0.0) return 0.0;

    float Shape = Coverage;

        Position.xy += Shape * 1.2;

    float N1 = Value3D(Position * 6.0 + WindOffset.zyx * 3.0) * 0.25;
        Shape -= N1; Position -= N1;
        Shape -= Value3D(Position * 48.0 * vec3(0.4, 1.0, 1.0) - WindOffset * 64) * 0.07 * sqrt(1.0 - saturate(Shape));
        Shape -= Value3D(Position * 256.0 * vec3(2.0, 1.0, 0.2)) * 0.03;
        Shape = max0(Shape);
        Shape = sqr(Shape);

    return max0(Shape * volumeCirrusData.y);
}

float REnd_Sky_PC_LightOD(vec3 Position, vec3 Direction, const uint Steps, float Noise) {

    float StepSize = (REnd_Sky_PC_Depth / float(Steps));
        StepSize *= 1.0 - linStep(Position.y, REnd_Sky_PlanarBounds.x, REnd_Sky_PlanarBounds.y) * 0.9 * max0(Direction.y);

        Position += cloudLightDir * Noise * StepSize;

    float Density = 0.0;

    for (uint i = 0; i < Steps; ++i, Position += cloudLightDir * StepSize) {
        if (Position.y > REnd_Sky_PlanarBounds.y || Position.y < REnd_Sky_PlanarBounds.x) continue;

        float Sample = REnd_Sky_PC_Shape(Position);
        if (Sample <= 0.0) continue;

        Density += Sample * StepSize;
    }

    return Density;
}

float EstimateEnergy(float Ratio) {
    return Ratio / (1.0 - Ratio);
}