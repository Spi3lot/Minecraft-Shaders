#define TAA

uniform int frameCounter;
// uniform float frameTimeCounter;
uniform float viewWidth;
uniform float viewHeight;

vec2 jitter[8] = vec2[8](vec2( 0.125,-0.375),
							   vec2(-0.125, 0.375),
							   vec2( 0.625, 0.125),
							   vec2( 0.375,-0.625),
							   vec2(-0.625, 0.625),
							   vec2(-0.875,-0.125),
							   vec2( 0.375,-0.875),
							   vec2( 0.875, 0.875));
	
				
vec2 Rand2Jitter(vec2 p) {
    return fract(sin(vec2(dot(p, vec2(25.6, 35.7)), dot(p, vec2(16.2, 95.5))))*.005);
}

vec2 taaJitter(vec2 coord, float w){
	return jitter[int(mod(frameCounter,8.0))]*(w/vec2(viewWidth,viewHeight)) + coord;
}


// vec2 taaJitter(vec2 coord, float w){
// 	return Rand2Jitter(vec2(frameCounter))*(w/vec2(viewWidth,viewHeight)) + coord;
// }