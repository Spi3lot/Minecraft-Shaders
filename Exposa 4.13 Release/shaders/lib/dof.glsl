#define DOF
#define TAA

#define DOFStrength 0.5 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define DOFSamples 30 //[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50]
#define DOFPlaneMult 23.0 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.5 2.0 2.5 3.0 4.5 5.0 5.5 6.0 6.5 7.0 7.5 8.0 8.5 9.0 10.0 11.0 12.0 13.0 14.0 15.0 16.0 17.0 18.0 19.0 20.0 21.0 22.0 23.0]
uniform float centerDepthSmooth;

vec2 DOFfset[60] = vec2[60]  (  vec2( 0.0000, 0.2500 ),
									vec2( -0.2267, 0.1250 ),
									vec2( -0.2267, -0.1250 ),
									vec2( -0.0000, -0.2500 ),
									vec2( 0.2267, -0.1250 ),
									vec2( 0.2267, 0.1250 ),
									vec2( 0.0000, 0.5000 ),
									vec2( -0.2500, 0.4330 ),
									vec2( -0.4330, 0.2500 ),
									vec2( -0.5000, 0.0000 ),
									vec2( -0.4330, -0.2500 ),
									vec2( -0.2500, -0.4330 ),
									vec2( -0.0000, -0.5000 ),
									vec2( 0.2500, -0.4330 ),
									vec2( 0.4330, -0.2500 ),
									vec2( 0.5000, -0.0000 ),
									vec2( 0.4330, 0.2500 ),
									vec2( 0.2500, 0.4330 ),
									vec2( 0.0000, 0.7500 ),
									vec2( -0.2565, 0.7048 ),
									vec2( -0.4821, 0.5745 ),
									vec2( -0.51295, 0.3750 ),
									vec2( -0.7386, 0.1302 ),
									vec2( -0.7386, -0.1302 ),
									vec2( -0.51295, -0.3750 ),
									vec2( -0.4821, -0.5745 ),
									vec2( -0.2565, -0.7048 ),
									vec2( -0.0000, -0.7500 ),
									vec2( 0.2565, -0.7048 ),
									vec2( 0.4821, -0.5745 ),
									vec2( 0.51295, -0.3750 ),
									vec2( 0.7386, -0.1302 ),
									vec2( 0.7386, 0.1302 ),
									vec2( 0.51295, 0.3750 ),
									vec2( 0.4821, 0.5745 ),
									vec2( 0.2565, 0.7048 ),
									vec2( 0.0000, 1.0000 ),
									vec2( -0.2588, 0.9659 ),
									vec2( -0.5000, 0.8660 ),
									vec2( -0.7071, 0.7071 ),
									vec2( -0.8660, 0.5000 ),
									vec2( -0.9659, 0.2588 ),
									vec2( -1.0000, 0.0000 ),
									vec2( -0.9659, -0.2588 ),
									vec2( -0.8660, -0.5000 ),
									vec2( -0.7071, -0.7071 ),
									vec2( -0.5000, -0.8660 ),
									vec2( -0.2588, -0.9659 ),
									vec2( -0.0000, -1.0000 ),
									vec2( 0.2588, -0.9659 ),
									vec2( 0.5000, -0.8660 ),
									vec2( 0.7071, -0.7071 ),
									vec2( 0.8660, -0.5000 ),
									vec2( 0.9659, -0.2588 ),
									vec2( 1.0000, -0.0000 ),
									vec2( 0.9659, 0.2588 ),
									vec2( 0.8660, 0.5000 ),
									vec2( 0.7071, 0.7071 ),
									vec2( 0.5000, 0.8660 ),
									vec2( 0.2588, 0.9659 ));


float lindCustomNear(float depth, float nearVal) {
    return (nearVal * far) / (depth * (nearVal - far) + far);
}

vec3 DOFunction(vec3 scolor, float depth) {
	// int samples = 30;

	vec3 dof = vec3(0.0);

	float noncenter = abs(lindCustomNear(depth, DOFPlaneMult)-lindCustomNear(centerDepthSmooth, DOFPlaneMult))*DOFStrength;

	// if(depth == 1.0) noncenter = 1.0*DOFStrength;

	float blueDither = blueNoiseSample(texcoord.xy, 1.0, vec2(0.0));

	#ifdef TAA
	blueDither = fractDither(blueDither);
	#endif

	for(int i=0; i < DOFSamples; i++) {
		vec2 multiplier = noncenter*0.0000002*vec2(viewWidth,viewHeight)*vec2(1.0/aspectRatio,1.0*aspectRatio); 
		dof += textureLod(colortex0, texcoord + DOFfset[i]*multiplier,0).rgb;
	}

	dof /= float(DOFSamples);

	return dof;
}