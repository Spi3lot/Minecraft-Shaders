#version 120

#define LINE_THICKNESS 1.00  //The stroke weight of the black border drawn at edges. Unit: Pixels [0.25 0.50 0.75 1.00 1.25 1.50 1.75 2.00 2.25 2.50 2.75 3.00 3.25 3.50 3.75 4.00 4.25 4.50 4.75 5.00 5.25 5.50 5.75 6.00 6.25 6.50 6.75 7.00 7.25 7.50 7.75 8.00 8.25 8.50 8.75 9.00 9.25 9.50 9.75 10.00 10.25 10.50 10.75 11.00 11.25 11.50 11.75 12.00 12.25 12.50 12.75 13.00 13.25 13.50 13.75 14.00 14.25 14.50 14.75 15.00 15.25 15.50 15.75 16.00 16.25 16.50 16.75 17.00 17.25 17.50 17.75 18.00 18.25 18.50 18.75 19.00 19.25 19.50 19.75 20.00]
#define STEP_SIZE 1.00  //Determines how big the steps are for detecting edges. The smaller the steps, the better the quality. To avoid weird looking borders, this should always be less than or equal to LINE_THICKNESS. Unit: Pixels (and the worse the performance) [LINE_THICKNESS 0.25 0.50 0.75 1.00 1.25 1.50 1.75 2.00 2.25 2.50 2.75 3.00 3.25 3.50 3.75 4.00 4.25 4.50 4.75 5.00 5.25 5.50 5.75 6.00 6.25 6.50 6.75 7.00 7.25 7.50 7.75 8.00 8.25 8.50 8.75 9.00 9.25 9.50 9.75 10.00 10.25 10.50 10.75 11.00 11.25 11.50 11.75 12.00 12.25 12.50 12.75 13.00 13.25 13.50 13.75 14.00 14.25 14.50 14.75 15.00 15.25 15.50 15.75 16.00 16.25 16.50 16.75 17.00 17.25 17.50 17.75 18.00 18.25 18.50 18.75 19.00 19.25 19.50 19.75 20.00]
#define EDGE_DETECTION_SENSITIVITY 36  //Determines how sensitive the edge detection algorithm is. The larger, the more is considered an edge which means there will be more borders. Unit: 1.0 / length(pixelDifference) [1 4 9 16 25 36 49 64 81 100 121 144 169 196 225 256 289 324 361 400 441 484 529 576 625 676 729 784 841 900 961 1024]
//OLD DESCRIPTION (without reciprocal): Determines how big the pixel color difference to adjacent pixels must be to be considered an edge


uniform sampler2D gcolor;
varying vec4 texcoord;


float isEdge(vec2 uv) {
	float dx = dFdx(uv.x);
	float dy = dFdy(uv.y);

	vec3 col = texture2D(gcolor, uv).rgb;
	vec3 diff = vec3(0.0);
	int loopCount = 0;

	for (float factorY = -LINE_THICKNESS; factorY <= LINE_THICKNESS; factorY += STEP_SIZE)
		for (float factorX = -LINE_THICKNESS * 0.5; factorX <= LINE_THICKNESS * 0.5; factorX += STEP_SIZE, loopCount++)
			diff += (col - texture2D(gcolor, uv + vec2(factorX * dx, factorY * dy)).rgb);


	diff /= loopCount;

// More efficient version of expression below (swapped sides because of reciprocal)
	return step(inversesqrt(dot(diff, diff)), EDGE_DETECTION_SENSITIVITY);
	//return step(1.0 / EDGE_DETECTION_SENSITIVITY, length(diff));

	//return length(diff);  // AntiAliasing kind of
}


void main() {
	vec2 uv = texcoord.st;
	vec4 col = texture2D(gcolor, uv);

	float edge = isEdge(uv);

	gl_FragColor = (1.0 - edge) * col;
}
