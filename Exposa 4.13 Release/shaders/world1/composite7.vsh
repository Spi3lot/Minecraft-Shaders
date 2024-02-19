#version 150 compatibility




uniform vec3 sunPosition;
uniform vec3 moonPosition;




out vec2 texcoord;
flat out vec3 lightVec;

#include "/lib/time.glsl"

void main() {
	gl_Position = ftransform();
	texcoord    = gl_MultiTexCoord0.xy;
	lightVec = normalize(sunPosition*times.sunrise + sunPosition*times.noon + sunPosition * times.sunset + moonPosition * times.night);
	//     if (sunAngle < 0.5f) {
    //     lightVec = normalize(sunPosition);
    // } else {
    //     lightVec = normalize(moonPosition);
    // }
}
