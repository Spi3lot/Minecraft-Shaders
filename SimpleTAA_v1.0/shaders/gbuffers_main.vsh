varying vec3 sceneLocation;

varying vec2 lmcoord;
varying vec2 uv;
varying vec4 glcolor;

uniform vec2 taaOffset;

uniform mat4 gbufferModelViewInverse;

#ifdef gTERRAIN
    attribute vec2 mc_Entity;
#endif

void main() {
	gl_Position     = gl_ModelViewMatrix * gl_Vertex;
    sceneLocation   = gl_Position.xyz;
    gl_Position     = gl_ProjectionMatrix * gl_Position;
    gl_Position.xy += taaOffset * gl_Position.w;

	uv = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

    #ifndef MC_OLD_LIGHTING
        #ifndef noOLDLIGHT
        #ifdef gTERRAIN
        bool doOldLighting  = int(mc_Entity.x) != 1000;
            //doOldLighting   = doOldLighting && lmcoord.x < (15.0 / 16.0);
        if (doOldLighting) {
        #endif

        vec3 faceDirection  = gl_NormalMatrix * gl_Normal;
            faceDirection   = mat3(gbufferModelViewInverse) * faceDirection;

        float brightness    = mix(0.8, 0.6, abs(faceDirection.x));
            brightness      = mix(brightness, faceDirection.y > 0.0 ? 1.0 : 0.5, abs(faceDirection.y));

        glcolor.rgb *= clamp(brightness, 0.5, 1.0);

        #ifdef gTERRAIN
        }
        #endif
        #endif
    #endif
}