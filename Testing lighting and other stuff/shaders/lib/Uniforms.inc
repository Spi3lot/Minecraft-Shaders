uniform vec3 shadowLightPosition;
uniform vec3 upPosition;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferPreviousProjection;
uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;
uniform mat4 textureMatrix;


uniform sampler2D gcolor;
uniform sampler2D gdepthtex;
uniform sampler2D gnormal;
uniform sampler2D gaux1;

uniform sampler2D lightmap;
uniform sampler2D normals;
uniform sampler2D specular;
uniform sampler2D shadow;
uniform sampler2D shadowcolor;
uniform sampler2D watershadow;


uniform float viewWidth;
uniform float viewHeight;
uniform float aspectRatio;

uniform float near;
uniform float far;