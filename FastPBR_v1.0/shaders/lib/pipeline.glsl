/*
const int colortex0Format   = RGBA16F;
const int colortex1Format   = RGBA16;
const int colortex2Format   = RGBA16F;
const int colortex3Format   = RGBA16F;
const int colortex4Format   = RGBA16F;
const int colortex5Format   = RGBA16F;
const int colortex6Format   = RGBA16;
const int colortex7Format   = RGBA16F;
const int colortex8Format   = RGBA16F;
const int colortex9Format   = RGBA16F;
const int colortex10Format  = RGBA16F;
const int colortex11Format  = RGBA16F;
const int colortex12Format  = RGBA16F;
const int colortex13Format  = RGBA16F;

const vec4 colortex0ClearColor = vec4(0.0, 0.0, 0.0, 1.0);
const vec4 colortex2ClearColor = vec4(0.0, 0.0, 0.0, 1.0);
const vec4 colortex3ClearColor = vec4(0.0, 0.0, 0.0, 0.0);
const vec4 colortex3ClearColor = vec4(0.0, 0.0, 0.0, 1.0);

const bool colortex2Clear   = false;
const bool colortex8Clear   = false;
const bool colortex9Clear   = false;
const bool colortex12Clear   = false;
const bool colortex13Clear   = false;

const int noiseTextureResolution = 256;

C0: SceneColor
    3x16 Scene Color        (full)

C1: GData01
    2x16 Scene Normals      (gbuffer -> composite)
    1x8  Sky Occlusion, Wetness (gbuffer -> composite)
    2x8  AO Data            (gbuffer -> deferred)

C2: Temporal Data
    3x16 TAA(U) Color          (full)
    1x16 Exposure           (full)

C3: Skybox
    4x16 Skybox Data        (full)
        256x128 Sky Atmosphere
        256x128 Sky Transmittance
        256x128 Sky Capture

C4: Lighting LUT

C5:

C6:

C7:

C8: TemporalAux

C9: Cloud History

C10: A

C11: B
*/