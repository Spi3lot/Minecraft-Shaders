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

#include "/lib/head.glsl"

#if MODE==0
uniform vec2 viewSize, pixelSize;
#define VERTEX_STAGE
#include "/lib/downscaleTransform.glsl"

out vec4 tint;

uniform vec2 taaOffset;

in vec3 vaNormal;
in vec3 vaPosition;
in vec4 vaColor;

uniform mat4 modelViewMatrix, projectionMatrix;

vec4 GetLinePosition(vec3 Position) {
    const vec3 LineViewShrink = vec3((255.0 / 256.0), 0.0, 1.0);
    const mat4 LineViewScale = mat4(
        LineViewShrink.xyyy,
        LineViewShrink.yxyy,
        LineViewShrink.yyxy,
        LineViewShrink.yyyz
    );

    return projectionMatrix * LineViewScale * modelViewMatrix * vec4(Position, 1.0);
}
vec4 GetLineVertexPosition(int VertexID, vec3 NDC, vec2 Offset, float PosW) {
    int OffsetMult = int(gl_VertexID % 2 == 0) * 2 - 1;

    return vec4((NDC + vec3(Offset * OffsetMult, 0.0)) * PosW, PosW);
}

void main() {

    /*
        Mirrors "rendertype_lines"
    */

    vec4 Line_StartPos = GetLinePosition(vaPosition);
    vec4 Line_EndPos = GetLinePosition(vaPosition + vaNormal);

    vec3 NDC1 = Line_StartPos.xyz / Line_StartPos.w;
    vec3 NDC2 = Line_EndPos.xyz / Line_EndPos.w;

    vec2 LineScreenDirection = normalize((NDC2.xy - NDC1.xy) * viewSize);
    vec2 LineOffset = (min(0.0, sign(-LineScreenDirection.y)) * 2 + 1) * vec2(-LineScreenDirection.y, LineScreenDirection.x) * 2 * pixelSize;

    gl_Position = GetLineVertexPosition(gl_VertexID, NDC1, LineOffset, Line_StartPos.w);

    #ifdef taaEnabled
        gl_Position.xy += taaOffset * (gl_Position.w / ResolutionScale);
    #endif
    VertexDownscaling(gl_Position);

    tint = vaColor;
}
#else

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 sceneAlbedo;

#include "/lib/util/colorspace.glsl"

in vec4 tint;

void main() {
    vec4 sceneColor   = tint;
        sceneColor.a  = 1.0;

        convertToPipelineAlbedo(sceneColor.rgb);

    sceneAlbedo     = drawbufferClamp(sceneColor);
}
#endif