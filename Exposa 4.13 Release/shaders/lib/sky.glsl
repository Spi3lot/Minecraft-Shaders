const float zenithOffset = 0.055;
const float multiScatterPhase = 0.0;
const float density = 0.03;

float anisotropicIntensity = 5.05;

vec3 skyColorRain = vec3(0.2) * times.sunrise + vec3(0.51) * times.noon + vec3(0.2) * times.sunset + vec3(0.05) * times.night;

vec3 skyColor = mix(vec3(0.39, 0.57, 1.0) * (1.0 + anisotropicIntensity), skyColorRain, rainStrength); 
// vec3 skyColor = vec3(1.0);

#define zenithDensity(x) density / pow(max(x - zenithOffset, 0.35e-2), 0.75)


vec3 skyAbsorption(vec3 x, float y){
	return exp2(x * -y);
}

float sunPoint(vec3 p, vec3 lightDir){
	return smoothstep(0.02, 0.001, distance(p, lightDir))*10.;
}

float rayleigMultiplier(vec3 p, vec3 lightDir){
	return 1.0 + pow(1.0 - clamp01(distance(p, lightDir)), 2.0) * PI * 0.5;
}

float getMie(vec3 p, vec3 lightDir){
	float disk = clamp01(1.0 - pow(distance(p, lightDir), 0.1));
	disk += clamp01(1.0 - pow(distance(p, lightDir), 6.9))*0.1;
	return disk*disk*(3.0 - 2.0 * disk) * 2.0 * PI;
}

vec3 atmosphericScattering(vec3 dir, vec3 lightDir){
		
	float zenith = zenithDensity(dir.y+0.06);
	float sunPointDistMult =  clamp01(length(max(lightDir.y + multiScatterPhase, 0.0)));
	
	float rayleighMult = rayleigMultiplier(dir, lightDir);
	
	vec3 absorption = skyAbsorption(skyColor, zenith);
    vec3 sunAbsorption = skyAbsorption(skyColor, zenithDensity(lightDir.y + multiScatterPhase));
	vec3 sky = skyColor * zenith * rayleighMult*4.;
	vec3 sun = sunPoint(dir, lightDir) * absorption;
	vec3 mie = getMie(dir, lightDir) * sunAbsorption*vec3(0.5,0.6,0.7);
	
	vec3 totalSky = mix(sky * absorption, sky / sqrt(sky * sky + 2.0), sunPointDistMult);
         totalSky += mie;
	     totalSky *= sunAbsorption * 0.5 + 0.5 * length(sunAbsorption);
	
	return totalSky;
}

// vec3 atmosphericScatteringNoSun(vec3 dir, vec3 lightDir){
		
// 	float zenith = zenithDensity(dir.y);
// 	float sunPointDistMult =  clamp01(length(max(lightDir.y + multiScatterPhase, 0.0)));
	
// 	float rayleighMult = rayleigMultiplier(dir, lightDir);
	
// 	vec3 absorption = skyAbsorption(skyColor, zenith);
//     vec3 sunAbsorption = skyAbsorption(skyColor, zenithDensity(lightDir.y + multiScatterPhase));
// 	vec3 sky = skyColor * zenith * rayleighMult;
// 	vec3 mie = getMie(dir, lightDir) * sunAbsorption*vec3(0.5,0.6,0.7);
	
// 	vec3 totalSky = mix(sky * absorption, sky / sqrt(sky * sky + 2.0), sunPointDistMult);
//          totalSky += mie;
// 	     totalSky *= sunAbsorption * 0.5 + 0.5 * length(sunAbsorption);
	
// 	return totalSky;
// }
