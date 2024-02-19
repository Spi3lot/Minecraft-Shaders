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

out vec2 uv;

uniform vec2 bloomResolution;
uniform vec2 viewSize;

void main() {
    gl_Position = vec4(gl_Vertex.xy * 2.0 - 1.0, 0.0, 1.0);

    vec2 cres   = max(viewSize, bloomResolution);

    
    #if pass == 0
        gl_Position.xy = (gl_Position.xy*0.5+0.5)*0.52/cres*bloomResolution*2.0-1.0+vec2(0.0, 0.49);
    #elif pass == 1
        //gl_Position.xy = (gl_Position.xy*0.5+0.5)*0.26/cres*bloomResolution*2.0-1.0;
    #endif
    

    uv = gl_MultiTexCoord0.xy;
}