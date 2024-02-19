/*
====================================================================================================

    Copyright (C) 2023 RRe36

    All Rights Reserved unless otherwise explicitly stated.


    By downloading this you have agreed to the license and terms of use.
    These can be found inside the included license-file
    or here: https://rre36.com/copyright-license

    Violating these terms may be penalized with actions according to the Digital Millennium
    Copyright Act (DMCA), the Information Society Directive and/or similar laws
    depending on your country.

====================================================================================================
*/

layout (local_size_x = 8, local_size_y = 4) in;

const vec2 workGroupsRender = vec2(0.5, 0.5);

layout (rgba16f) writeonly uniform image2D colorimg5;

#include "/lib/head.glsl"
#include "/lib/util/encoders.glsl"

#if AMBIENT_LIGHT_MODE == 2
layout (rgba16f) writeonly uniform image2D colorimg12;
layout (rgba16f) writeonly uniform image2D colorimg13;
#endif

uniform sampler2D depthtex0, colortex0, colortex1;
#if AMBIENT_LIGHT_MODE == 2
uniform sampler2D colortex7, colortex10;
#endif

uniform sampler2D noisetex;

uniform int frameCounter;

uniform float aspectRatio;
uniform float far, near;

uniform vec2 pixelSize, viewSize, taaOffset;

uniform vec3 cameraPosition, previousCameraPosition;

uniform mat4 gbufferModelView, gbufferModelViewInverse;
uniform mat4 gbufferProjection, gbufferProjectionInverse;
uniform mat4 gbufferPreviousProjection, gbufferPreviousModelView;

#define FUTIL_LINDEPTH
#include "/lib/fUtil.glsl"

#define gl_FragCoord gl_GlobalInvocationID

#include "/lib/frag/bluenoise.glsl"
#include "/lib/frag/gradnoise.glsl"

/*
    SSAO based on BSL Shaders by Capt Tatsu with permission
*/

vec2 offsetDist(float x) {
	float n = fract(x * 8.0) * pi;
    return vec2(cos(n), sin(n)) * x;
}

float getSSAO(sampler2D depthtex, float depth, vec2 coord, float dither) {
    const uint steps = 4;
    const float baseRadius = 1.0;

    bool hand       = depth < 0.56;
        depth       = depthLinear(depth);

    float currStep  = 0.2 * dither + 0.2;
	float fovScale  = gbufferProjection[1][1] / 1.37;
	float distScale = max((far - near) * depth + near, 5.0);
	vec2 scale      = baseRadius * vec2(1.0 / aspectRatio, 1.0) * fovScale / distScale;

    float ao = 0.0;

    const float maxOcclusionDist    = pi;
    const float anibleedExp         = 0.71;

    for (uint i = 0; i < steps; ++i) {
		vec2 offset = offsetDist(currStep) * scale;
		float mult  = (0.7 / baseRadius) * (far - near) * (hand ? 1024.0 : 1.0);

		float sampleDepth = depthLinear(texture(depthtex, (coord + offset) * ResolutionScale).r);
		float sample0 = (depth - sampleDepth) * mult;
        float antiBleed = 1.0 - rcp(1.0 + max0(distance(sampleDepth, depth) * far - maxOcclusionDist) * anibleedExp);
		float angle = mix(clamp(0.5 - sample0, 0.0, 1.0), 0.5, antiBleed);
		float dist  = mix(clamp(0.25 * sample0 - 1.0, 0.0, 1.0), 0.5, antiBleed);

		sampleDepth = depthLinear(texture(depthtex, (coord - offset) * ResolutionScale).r);
		sample0     = (depth - sampleDepth) * mult;
        antiBleed   = 1.0 - rcp(1.0 + max0(distance(sampleDepth, depth) * far - maxOcclusionDist) * anibleedExp);
        angle      += mix(clamp(0.5 - sample0, 0.0, 1.0), 0.5, antiBleed);
        dist       += mix(clamp(0.25 * sample0 - 1.0, 0.0, 1.0), 0.5, antiBleed);
		
		ao         += (clamp(angle + dist, 0.0, 1.0));
		currStep   += 0.2;
    }
	ao *= 1.0 / float(steps);
	
	return sqrt(saturate(ao)) * 0.98 + 0.02;
}

#include "/lib/util/transforms.glsl"


vec3 genUnitVector(vec2 p) {
    p.x *= tau; p.y = p.y * 2.0 - 1.0;
    return vec3(sincos(p.x) * sqrt(1.0 - p.y * p.y), p.y);
}
vec3 GenerateCosineVectorSafe(vec3 vector, vec2 xy) {
	// Apparently this is actually this simple.
	// http://www.amietia.com/lambertnotangent.html
	// (cosine lobe around vector = lambertian BRDF)
	// This one deals with ther rare case where cosineVector == (0,0,0)
	// Can just normalize it instead if you are sure that won't be a problem
	vec3 cosineVector = vector + genUnitVector(xy);
	float lenSq = dot(cosineVector, cosineVector);
	return lenSq > 0.0 ? cosineVector * inversesqrt(lenSq) : vector;
}

#define HBIL_SLICES 1
#define HBIL_HORIZON_SAMPLES 4
#define HBIL_RADIUS 2.0

float FastAcos(float X) {
	float A = ((((0.0464619 * abs(X)) + -0.201877) * abs(X)) + 1.57018) * sqrt(1.0 - abs(X));

	return X >= 0 ? A : pi - A;
}
vec2 FastAcos(vec2 X) { return vec2(FastAcos(X.x), FastAcos(X.y)); }

float IntegrateHorizon(vec2 SliceNormal, vec2 CosTheta) {
    vec2 Theta = FastAcos(CosTheta);
    vec2 SinTheta = sqrt(1.0 - sqr(CosTheta));

    return dot(SliceNormal, vec2(Theta.y - Theta.x + SinTheta.x * CosTheta.x - SinTheta.y * CosTheta.y, sqr(CosTheta.x) - sqr(CosTheta.y))) * 0.5;
}

vec4 HorizonSearch(inout float CosTheta, vec3 ScreenPosition, vec3 ViewPosition, vec3 ViewSlice, vec3 ViewDir, vec2 SliceNormal, float Radius, float Dither) {
    float StepSize = Radius / float(HBIL_HORIZON_SAMPLES);
    vec2 RayStep = (viewToScreenSpace(ViewPosition + ViewSlice * StepSize) - ScreenPosition).xy;
    vec2 RayPosition = ScreenPosition.xy + maxOf(pixelSize) * normalize(RayStep) * 2.0;

    vec4 Irradiance = vec4(0);

    for (uint i = 0; i < HBIL_HORIZON_SAMPLES; ++i, RayPosition += RayStep) {
        vec2 SamplePosition = RayPosition + RayStep * Dither;
        if (saturate(SamplePosition) != SamplePosition) continue;
        float DepthSample = texelFetch(depthtex0, ivec2(SamplePosition * viewSize - 0.5), 0).x;

        if (DepthSample == ScreenPosition.z || DepthSample >= 1.0 || DepthSample < 0.58) continue;

        vec3 PositionDelta = screenToViewSpace(vec3(SamplePosition, DepthSample)) - ViewPosition;
        float DeltaLength = dotSelf(PositionDelta);
        float CurrCosTheta = dot(ViewDir, PositionDelta) * inversesqrt(DeltaLength);

        if (CurrCosTheta <= CosTheta) continue;

        float Falloff = saturate(1.0 / (1.0 + abs(DeltaLength) / tau));

        vec3 Radiance = texelFetch(colortex0, ivec2(saturate(SamplePosition) * viewSize - 0.5), 0).rgb * Falloff;

        Irradiance += IntegrateHorizon(SliceNormal, vec2(CurrCosTheta, CosTheta)) * vec4(Radiance, 1.0);

        CosTheta = CurrCosTheta;
        //RayStep *= euler;
    }

    Irradiance.rgb *= pi;

    return max0(Irradiance);
}

vec2 ditherBluenoise2() {
    ivec2 uv = ivec2(gl_FragCoord.xy);
    float noise = texelFetch(noisetex, uv & 255, 0).a;

    return abs(sincos(fract(noise+float(frameCounter) / pi)));
}


vec4 GetHBIL(sampler2D depthtex, vec3 ScreenPosition, vec3 ViewPosition, vec3 SceneNormal) {
    vec3 ViewNormal = mat3(gbufferModelView) * SceneNormal;

    vec4 Irradiance = vec4(0);
    float Radius = HBIL_RADIUS;

    vec3 ViewDir = ViewPosition / -length(ViewPosition);
    mat3 LocalCameraSpace = mat3(0);
        LocalCameraSpace[0] = normalize(cross(vec3(0, 1, 0), ViewDir));
        LocalCameraSpace[1] = cross(ViewDir, LocalCameraSpace[0]);
        LocalCameraSpace[2] = ViewDir;

    vec2 Dither = vec2(ditherBluenoise(), ditherGradNoiseTemporal());

    for (uint i = 0; i < HBIL_SLICES; ++i) {
        float SliceAngle = (i + Dither.x) * (pi / float(HBIL_SLICES));
        vec3 SlicePlane = vec3(cos(SliceAngle), sin(SliceAngle), 0.0);
        vec3 ViewSlice = LocalCameraSpace * SlicePlane;

        mat2x3 SliceToView = mat2x3(ViewSlice, ViewDir);

        vec2 SliceNormal = ViewNormal * SliceToView;

        float T = (-SliceNormal.x / SliceNormal.y);
        vec2 CosTheta = T * inversesqrt(1.0 + sqr(T)) * vec2(1, -1);

        Irradiance += HorizonSearch(CosTheta.x, ScreenPosition, ViewPosition, ViewSlice, ViewDir, SliceNormal, Radius, Dither.y);
        Irradiance += HorizonSearch(CosTheta.x, ScreenPosition, ViewPosition, -ViewSlice, ViewDir, SliceNormal * vec2(-1, 1), Radius, Dither.y);
    }

    return max0(Irradiance) / float(HBIL_SLICES);
}

/* ------ reprojection ----- */
vec3 reproject(vec3 sceneSpace, bool hand) {
    vec3 prevScreenPos = hand ? vec3(0.0) : cameraPosition - previousCameraPosition;
    prevScreenPos = sceneSpace + prevScreenPos;
    prevScreenPos = transMAD(gbufferPreviousModelView, prevScreenPos);
    prevScreenPos = transMAD(gbufferPreviousProjection, prevScreenPos) * (0.5 / -prevScreenPos.z) + 0.5;
    //prevScreenPos.xy += previousTaaOffset * 0.5 * pixelSize;

    return prevScreenPos;
}

#define MaxFrames 256.0

void main() {
    ivec2 UV = ivec2(gl_GlobalInvocationID.xy);
    vec2 uv  = (vec2(UV) + 0.5) * pixelSize;

    ivec2 ViewPixel = ivec2(gl_GlobalInvocationID.xy * 2.0);
    vec2 ViewUV = (uv * 2.0) / ResolutionScale;

    float sceneDepth    = texelFetch(depthtex0, ViewPixel, 0).x;

    vec4 Irradiance = vec4(0,0,0,1);
    vec4 HistoryOut = vec4(0);

    #if AMBIENT_LIGHT_MODE != 0
    if (landMask(sceneDepth) && saturate(ViewUV) == ViewUV) {
        
        #if AMBIENT_LIGHT_MODE == 1
        Irradiance.a  = getSSAO(depthtex0, sceneDepth, saturate(ViewUV), ditherBluenoise());
        #endif

        #if AMBIENT_LIGHT_MODE == 2
        vec3 ScreenPosition = vec3(ViewUV, sceneDepth);
        vec3 ViewPosition = screenToViewSpace(ScreenPosition, false);
        vec3 SceneNormal = decodeNormal(texelFetch(colortex1, ViewPixel, 0).xy);

        vec4 CurrentIrradiance = GetHBIL(depthtex0, ScreenPosition, ViewPosition, SceneNormal);
        CurrentIrradiance.a = saturate(1.0 - CurrentIrradiance.a);

        vec3 ScenePosition = viewToSceneSpace(ViewPosition);
        float CurrentDistance = length(ScenePosition);

        vec3 Reprojection = reproject(ScenePosition, false);
            //Reprojection.xy += taaOffset;
        bool Offscreen = saturate(Reprojection.xy) != Reprojection.xy;
        Reprojection.xy *= ResolutionScale * 0.5;
        vec4 HistoryData = texture(colortex10, Reprojection.xy);

        HistoryOut.y = CurrentDistance;

        vec3 CameraMovement = mat3(gbufferModelView) * (cameraPosition - previousCameraPosition);

        if (Offscreen) {
            Irradiance = CurrentIrradiance;
            HistoryOut.x = 1;
        } else {
            vec4 HistoryIrradiance = vec4(0,0,0,0);
            vec4 HistoryData_R = vec4(0);

            ivec2 ReprojectedPixel = ivec2(floor(Reprojection.xy * viewSize - vec2(0.5)));
            vec2 Subpixel = fract(Reprojection.xy * viewSize - vec2(0.5) - ReprojectedPixel);

            const ivec2 Offsets[4] = ivec2[4](
                ivec2(0, 0),
                ivec2(1, 0),
                ivec2(0, 1),
                ivec2(1, 1)
            );

            float Weights[4]     = float[4](
                (1.0 - Subpixel.x) * (1.0 - Subpixel.y),
                Subpixel.x         * (1.0 - Subpixel.y),
                (1.0 - Subpixel.x) * Subpixel.y,
                Subpixel.x         * Subpixel.y
            );

            float SumWeight = 0.0;
            
            for (uint i = 0; i < 4; ++i) {
                ivec2 UV            = ReprojectedPixel + Offsets[i];

                float DepthDelta    = distance((texelFetch(colortex10, UV, 0).y), CurrentDistance) - abs(CameraMovement.z);
                bool DepthRejection = (DepthDelta / abs(CurrentDistance)) < 0.1;

                if (DepthRejection) {
                    HistoryIrradiance += clamp16F(texelFetch(colortex7, UV, 0)) * Weights[i];
                    HistoryData_R += clamp16F(texelFetch(colortex10, UV, 0)) * Weights[i];
                    SumWeight += Weights[i];
                }
            }

            if (SumWeight > 1e-3) {
                HistoryIrradiance /= SumWeight;
                HistoryData_R /= SumWeight;

                float Framecount = min(HistoryData_R.x + 1.0, MaxFrames);
                float Alpha = saturate(max(0.025, 1.0 / Framecount));

                Irradiance = mix(HistoryIrradiance, CurrentIrradiance, Alpha);
                HistoryOut.x = Framecount;
            } else {
                Irradiance = CurrentIrradiance;
                HistoryOut.x = 1;
            }
            
        }
        Irradiance.a = saturate(Irradiance.a);
        #endif
    }
    #endif

    imageStore(colorimg5, UV, (Irradiance));

    #if AMBIENT_LIGHT_MODE == 2
    imageStore(colorimg12, UV, (Irradiance));
    imageStore(colorimg13, UV, (HistoryOut));
    #endif
}