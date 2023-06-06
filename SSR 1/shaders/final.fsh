#version 330 compatibility

#include "lib/Common.inc"
#include "lib/Uniforms.inc"

#define RAYMARCH_STEP_SIZE 0.1


in vec4 texcoord;
in vec4 lmcoord;


vec3 decompressView(vec4 compressedDepth) {
    vec3 depth = decompressRay(compressedDepth);
    return mix(vec3(near), vec3(far), depth);
}


void main() {
    vec4 col = texture2D(texture, texcoord.st);

    vec3 normal = texture2D(colortex2, texcoord.st).xyz;
    vec4 depth = texture2D(colortex3, texcoord.st);
    //depth = depth * 2.0 - 1.0;

    vec3 ro = decompressView(depth);
    vec3 rd = normalize(ro);
    rd = reflect(rd, normal);

    float totalDist = 0.0;
    vec4 reflectedColor;

    for (int i = 0; i < 20; i++) {
        vec3 pos = ro + rd * totalDist;
        vec4 screenCoord = gbufferProjection * vec4(pos, 1.0);
        vec4 eyeDepth = texture2D(colortex3, screenCoord.st);
        //eyeDepth = eyeDepth * 2.0 - 1.0;

        vec3 eyePos = decompressView(eyeDepth);
        float eyeDistance = length(eyePos.z);

    	if (length(pos.z) > eyeDistance) {
    		reflectedColor = texture2D(texture, screenCoord.st);
    		break;
    	}  

    	totalDist += RAYMARCH_STEP_SIZE;
    }

    //gl_FragColor = col;
    //gl_FragColor = vec4(normal, 1.0);
    //gl_FragColor = vec4(length(depth.xyz));
    //gl_FragColor = vec4(abs(ro), 1.0);
    //gl_FragColor = vec4(int(depth.w) & 1);  // should be black all the time because z should never be negative ever - see gbuffers_basic.vsh
    gl_FragColor = mix(col, reflectedColor, 0.25);
    //gl_FragColor = max(col, reflectedColor);
    //gl_FragColor = min(col, reflectedColor);
}

/*
#version 330 compatibility

#include "lib/Uniforms.inc"

#define EPSILON 1.0


in vec4 texcoord;
in vec4 lmcoord;


float distToClosestVertex(vec3 p) {
    vec2 view = vec2(viewWidth, viewHeight);
    float minDist = 1e20;

    for (int j = 0; j < view.y; j += 50)
        for (int i = 0; i < view.x; i += 50) {
            vec3 vertexPos = texture2D(colortex3, vec2(i, j) / view).xyz;
            float dist = distance(p, vertexPos);

            if (dist < minDist)
                minDist = dist; 
        }

    return minDist;
}


void main() {
    vec4 col = texture2D(texture, texcoord.st);
    
    vec3 normal = texture2D(colortex2, texcoord.st).xyz;
    vec4 depth = texture2D(colortex3, texcoord.st);

    vec3 ro = mix(vec3(near), vec3(far), depth.xyz);
    vec3 rd = normalize(ro);
    rd = reflect(rd, normal);

    vec4 reflectedColor;

    for (int i = 0; i < 20; i++) {
        float dist = distToClosestVertex(ro);

        if (dist <= EPSILON) {
            vec4 screenCoord = gbufferProjection * vec4(ro.xyz, 1.0);
            reflectedColor = texture2D(texture, screenCoord.xy);
            break;
        }

        ro += rd * dist;
    }
    
    //gl_FragColor = min(col, reflectedColor);
    //gl_FragColor = mix(col, reflectedColor, 0.5);
    gl_FragColor = col;
}
*/