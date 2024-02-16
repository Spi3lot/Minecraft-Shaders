#version 330 compatibility


in vec4 texcoord;

uniform sampler2D texture;
uniform sampler2D shadow;


void main() {
    //gl_FragColor = texture2D(texture, texcoord.st);
    // gl_FragColor = vec4(length(texture2D(shadowcolor0, texcoord.st))/10,0,0,1);
    gl_FragColor = texture2D(shadow, texcoord.st);
    // gl_FragColor = vec4(vec3(length(texture2D(colortex7, texcoord.st))), 1.0);
    // gl_FragColor = texture2D(colortex7, texcoord.st);
}
