#ifndef ResolutionScale
    #define ResolutionScale 1.0          //[0.25 0.5 0.75 1.0]
#endif

vec2 ViewProjectionDownscaling(vec2 Position) {
    return Position * ResolutionScale - (1-ResolutionScale);
    //Position = (Position * 0.5 + 0.5) * ResolutionScale;
    //return Position * 2.0 - 1.0;
}

void VertexDownscaling(inout vec4 glPosition) {
    glPosition.xy = ViewProjectionDownscaling(glPosition.xy / glPosition.w) * glPosition.w;
}
void VertexDownscaling(inout vec4 glPosition, inout vec2 uv) {
    glPosition.xy = ViewProjectionDownscaling((glPosition.xy / glPosition.w)) * glPosition.w;
    glPosition.xy = ((glPosition.xy * 0.5 + 0.5) * 1.01) * 2.0 - 1.0;
    uv *= ResolutionScale * 1.01;
}

#ifndef VERTEX_STAGE
bool InsideDownscaleViewport() {
    return clamp(gl_FragCoord.xy, vec2(-1), ceil(viewSize * ResolutionScale) + vec2(1)) == gl_FragCoord.xy;
}
bool OutsideDownscaleViewport() {
    return clamp(gl_FragCoord.xy, vec2(-1), ceil(viewSize * ResolutionScale) + vec2(1)) != gl_FragCoord.xy;
}
#endif