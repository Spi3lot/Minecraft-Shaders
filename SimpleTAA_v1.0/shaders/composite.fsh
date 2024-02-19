#version 120

#include "/lib/head.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex1;

uniform sampler2D depthtex0;

uniform float viewWidth;
uniform float viewHeight;

uniform vec2 viewSize, pixelSize;
uniform vec2 taaOffset;

uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

uniform mat4 gbufferPreviousProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferModelViewInverse;

varying vec2 uv;

//Temporal Reprojection based on Chocapic13's approach
vec2 taaReprojection(vec2 uv, float depth) {
    vec4 frag       = gbufferProjectionInverse*vec4(vec3(uv, depth)*2.0-1.0, 1.0);
        frag       /= frag.w;
        frag        = gbufferModelViewInverse*frag;

    vec4 prevPos    = frag + vec4(cameraPosition-previousCameraPosition, 0.0)*float(depth > 0.56);
        prevPos     = gbufferPreviousModelView*prevPos;
        prevPos     = gbufferPreviousProjection*prevPos;
    
    return prevPos.xy/prevPos.w*0.5+0.5;
}

vec4 textureCatmullRom(sampler2D tex, vec2 uv) {   //~5fps
    vec2 res    = ivec2(viewSize);

    vec2 coord  = uv*res;
    vec2 coord1 = floor(coord - 0.5) + 0.5;

    vec2 f      = coord-coord1;

    vec2 w0     = f * (-0.5 + f * (1.0 - (0.5 * f)));
    vec2 w1     = 1.0 + sqr(f) * (-2.5 + (1.5 * f));
    vec2 w2     = f * (0.5 + f * (2.0 - (1.5 * f)));
    vec2 w3     = sqr(f) * (-0.5 + (0.5 * f));

    vec2 w12    = w1+w2;
    vec2 delta12 = w2 * rcp(w12);

    vec2 uv0    = (coord1 - vec2(1.0)) * pixelSize;
    vec2 uv3    = (coord1 + vec2(1.0)) * pixelSize;
    vec2 uv12   = (coord1 + delta12) * pixelSize;

    vec4 col    = vec4(0.0);
        col    += texture2D(tex, vec2(uv0.x, uv0.y), 0)*w0.x*w0.y;
        col    += texture2D(tex, vec2(uv12.x, uv0.y), 0)*w12.x*w0.y;
        col    += texture2D(tex, vec2(uv3.x, uv0.y), 0)*w3.x*w0.y;

        col    += texture2D(tex, vec2(uv0.x, uv12.y), 0)*w0.x*w12.y;
        col    += texture2D(tex, vec2(uv12.x, uv12.y), 0)*w12.x*w12.y;
        col    += texture2D(tex, vec2(uv3.x, uv12.y), 0)*w3.x*w12.y;

        col    += texture2D(tex, vec2(uv0.x, uv3.y), 0)*w0.x*w3.y;
        col    += texture2D(tex, vec2(uv12.x, uv3.y), 0)*w12.x*w3.y;
        col    += texture2D(tex, vec2(uv3.x, uv3.y), 0)*w3.x*w3.y;

    return clamp(col, 0.0, 65535.0);
}

vec3 applyTAA(float depth, vec3 sceneColor) {
    vec2 taaCoord       = taaReprojection(uv, depth);
    vec2 viewport       = 1.0 / vec2(viewWidth, viewHeight);

        sceneColor      = textureCatmullRom(colortex0, uv - taaOffset * 0.5).rgb;
    vec3 taaCol         = textureCatmullRom(colortex1, taaCoord).rgb;
        taaCol          = saturate(taaCol);

    vec3 coltl      = texture2D(colortex0, uv + vec2(-1.0,-1.0) * viewport).rgb;
	vec3 coltm      = texture2D(colortex0, uv + vec2( 0.0,-1.0) * viewport).rgb;
	vec3 coltr      = texture2D(colortex0, uv + vec2( 1.0,-1.0) * viewport).rgb;
	vec3 colml      = texture2D(colortex0, uv + vec2(-1.0, 0.0) * viewport).rgb;
	vec3 colmr      = texture2D(colortex0, uv + vec2( 1.0, 0.0) * viewport).rgb;
	vec3 colbl      = texture2D(colortex0, uv + vec2(-1.0, 1.0) * viewport).rgb;
	vec3 colbm      = texture2D(colortex0, uv + vec2( 0.0, 1.0) * viewport).rgb;
	vec3 colbr      = texture2D(colortex0, uv + vec2( 1.0, 1.0) * viewport).rgb;

	vec3 minCol     = min(sceneColor,min(min(min(coltl,coltm),min(coltr,colml)),min(min(colmr,colbl),min(colbm,colbr))));
	vec3 maxCol     = max(sceneColor,max(max(max(coltl,coltm),max(coltr,colml)),max(max(colmr,colbl),max(colbm,colbr))));

        taaCol      = clamp(taaCol, minCol, maxCol);

    float taaMix    = float(taaCoord.x>0.0 && taaCoord.x<1.0 && taaCoord.y>0.0 && taaCoord.y<1.0);

    vec2 velocity   = (uv - taaCoord) / viewport;

        taaMix     *= clamp(1.0-sqrt(length(velocity))/1.999, 0.0, 1.0)*0.35+0.6;

    return saturate(mix(sceneColor, taaCol, taaMix));
}

void main() {
	vec3 sceneColor = texture2D(colortex0, uv).rgb;

    float sceneDepth = texture2D(depthtex0, uv).x;

    sceneColor  = applyTAA(sceneDepth, sceneColor);
    sceneColor  = ditherR11G11B10(sceneColor);

    /* DRAWBUFFERS:01 */
	gl_FragData[0] = saturate(vec4(sceneColor, 1.0));
    gl_FragData[1] = saturate(vec4(sceneColor, 1.0));
}