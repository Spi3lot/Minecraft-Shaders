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

vec3 screenToViewSpace(vec3 screenpos, mat4 projInv, const bool taaAware) {
    screenpos   = screenpos*2.0-1.0;

    #ifdef taaEnabled
        if (taaAware) screenpos.xy -= taaOffset / ResolutionScale;
    #endif

    vec3 viewpos    = vec3(vec2(projInv[0].x, projInv[1].y)*screenpos.xy + projInv[3].xy, projInv[3].z);
        viewpos    /= projInv[2].w*screenpos.z + projInv[3].w;
    
    return viewpos;
}
vec3 viewToScreenSpace(vec3 pos, mat4 projection, const bool taaAware) {
	vec3 screenPosition  = projMAD(projection, pos);
	     screenPosition /= -pos.z;

    #ifdef taaEnabled
        if (taaAware) screenPosition.xy += taaOffset / ResolutionScale;
    #endif

	return screenPosition * 0.5 + 0.5;
}

vec3 screenToViewSpace(vec3 screenpos, mat4 projInv)    { return screenToViewSpace(screenpos, projInv, true); }
vec3 screenToViewSpace(vec3 screenpos)                  { return screenToViewSpace(screenpos, gbufferProjectionInverse); }
vec3 screenToViewSpace(vec3 screenpos, const bool taaAware) { return screenToViewSpace(screenpos, gbufferProjectionInverse, taaAware); }

vec3 viewToScreenSpace(vec3 pos, const bool taaAware) { return viewToScreenSpace(pos, gbufferProjection, taaAware); }
vec3 viewToScreenSpace(vec3 pos) { return viewToScreenSpace(pos, gbufferProjection, true); }

#ifndef T_VIEWONLY
vec3 viewToSceneSpace(vec3 viewpos, mat4 mvInv) { return transMAD(mvInv, viewpos); }
vec3 viewToSceneSpace(vec3 viewpos) { return viewToSceneSpace(viewpos, gbufferModelViewInverse); }
#endif