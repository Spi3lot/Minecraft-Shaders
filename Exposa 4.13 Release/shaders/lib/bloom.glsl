#define bloomThreshold 1.6 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define bloomStrength 0.005 //[0.001 0.002 0.003 0.004 0.005 0.006 0.007 0.008 0.009 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.15 0.2 0.25 0.3 0.4 0.5]

vec3 bloomTile(float lod, vec2 offset){
	vec4 bloom = vec4(0.0);
	vec4 temp = vec4(0.0);
	float scale = pow(2.0,lod);
	vec2 tcoord = (texcoord-offset)*scale;
	float padding = 0.005*scale;

	if (tcoord.s > -padding && tcoord.t > -padding && tcoord.s < 1.0+padding && tcoord.t < 1.0+padding){
		for (int i = 0; i < 10; i++) {
			for (int j = 0; j < 10; j++) {
			float wg = clamp(1.0-length(vec2(i-2,j-2))*0.28,0.0,1.0);
			wg = wg*wg*5.0;
			vec2 tcoord2 = (texcoord-offset+vec2(i-2,j-2)*PW*vec2(1.0,aspectRatio))*scale;
			if (wg > 0){
				temp.rgb = ((texture(colortex0, tcoord2).rgb)-(bloomThreshold*(1.0/lod)))*wg;
				bloom.rgb += max(temp.rgb*wg, 0.0);
				}
			}
		}
		bloom /= 49;
	}

	return pow(bloom.rgb/128.0,vec3(0.25));
}

vec3 lengthBloom(vec3 x){
	return pow2(x)*128.0;
}

vec3 getBloom(vec3 color, vec2 coord, vec2 offset, float divider){
	vec3 blur1 = lengthBloom(texture2D(colortex1,coord/divider + offset).rgb);
	// vec3 blur2 = lengthBloom(texture2D(colortex1,coord/pow(2.0,3.0) + vec2(0.0,0.26)).rgb);
	// vec3 blur3 = lengthBloom(texture2D(colortex1,coord/pow(2.0,4.0) + vec2(0.135,0.26)).rgb);
	// vec3 blur4 = lengthBloom(texture2D(colortex1,coord/pow(2.0,5.0) + vec2(0.2075,0.26)).rgb);
	// vec3 blur5 = lengthBloom(texture2D(colortex1,coord/pow(2.0,6.0) + vec2(0.235,0.3325)).rgb);
	// vec3 blur6 = lengthBloom(texture2D(colortex1,coord/pow(2.0,7.0) + vec2(0.360625,0.3325)).rgb);
	// vec3 blur7 = lengthBloom(texture2D(colortex1,coord/pow(2.0,8.0) + vec2(0.3784375,0.3325)).rgb);

	vec3 blur = blur1;
	
	return blur*bloomStrength;
}