#version 330 compatibility

#include "lib/Uniforms.inc"


in vec3 mc_Entity;
out vec3 entity;

out vec4 glcolor;
out vec4 glvertex;
out vec4 texcoord;
out vec4 lmcoord;
out vec2 shadowcoord;
out float depthExpected;
out mat4 modelView;
out vec4 viewPos;


float interpolate(float a0, float a1, float x)
{
    if (x < 0.0) return a0;
    if (x > 1.0) return a1;
    return (a1 - a0) * x + a0;
    //return (a1 - a0) * (3.0 - x * 2.0) * x * x + a0; // Alternative: Kubische Interpolation mit dem Polynom 3 * x^2 - 2 * x^3
    //return (a1 - a0) * ((x * (x * 6.0 - 15.0) + 10.0) * x * x * x) + a0; // Alternative:  Interpolation mit dem Polynom 6 * x^5 - 15 * x^4 + 10 * x^3
}

vec2 randomGradient(int ix, int iy)
{
    const int w = 8 * 4;
    const int s = w / 2;
    int a = ix, b = iy;
    a *= 3284157443;
    b ^= a << s | a >> w - s;
    b *= 1911520717;
    a ^= b << s | b >> w - s;
    a *= 2048419325;
    float random = a * (3.14159265 / ~(~0 >> 1)); // Erzeugt eine Zufallszahl im Intervall [0, 2 * Pi]
    vec2 v;
    v.x = sin(random);
    v.y = cos(random);
    return v;
}

// Diese Funktion berechnet das Skalarprodukt des Abstandsvektors und den Gradientenvektoren
float dotGridGradient(int ix, int iy, float x, float y)
{
    // Bestimmt den Gradienten der ganzzahligen Koordinaten
    vec2 gradient = randomGradient(ix, iy);
    // Berechnet den Abstandsvektor
    float dx = x - ix;
    float dy = y - iy;
    return dot(vec2(dx, dy), gradient); // Skalarprodukt
}

// Diese Funktion berechnet das Perlin noise für die Koordinaten x, y
float perlin(float x, float y)
{
    // Bestimmt die Koordinaten der vier Ecken der Gitterzelle
    int x0 = int(floor(x));
    int x1 = x0 + 1;
    int y0 = int(floor(y));
    int y1 = y0 + 1;
    // Bestimmt die Gewichte für die Interpolation
    float sx = x - x0;
    float sy = y - y0;
    // Interpoliert zwischen den Gradienten der vier Ecken
    float n0, n1, ix0, ix1, value;
    n0 = dotGridGradient(x0, y0, x, y);
    n1 = dotGridGradient(x1, y0, x, y);
    ix0 = interpolate(n0, n1, sx);
    n0 = dotGridGradient(x0, y1, x, y);
    n1 = dotGridGradient(x1, y1, x, y);
    ix1 = interpolate(n0, n1, sx);
    return interpolate(ix0, ix1, sy); // Gibt den Wert der Funktion für das Perlin noise zurück
}

void main() {
    texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    lmcoord = gl_TextureMatrix[1] * gl_MultiTexCoord1;

    glcolor = gl_Color;
    glvertex = gl_Vertex;

    //if (mc_Entity.x == 9) {
    //    glvertex.y -= 0.0*perlin(glvertex.x + frameTimeCounter, glvertex.z);
    //}

    modelView = gl_ModelViewMatrix;

    entity = mc_Entity;
    viewPos = modelView * glvertex;  // vertex in camera space
    depthExpected = distance(viewPos.xyz, shadowLightPosition) / 255.0;

    // Shadows
    vec4 lightViewPos = shadowModelView * (gbufferModelViewInverse * viewPos);  // Vertex position relative to the light source
    vec4 lightViewPosProjected = shadowProjection * lightViewPos;
    shadowcoord = lightViewPosProjected.st * 0.5 + 0.5;
    //float depthExpected = 0.44 * percentage(near, far, distance(viewPos.xyz, shadowLightPosition));  // Distance from light source to vertex
    //float depthExpected = percentage(near, far, viewPos.z - lightViewPos.z);  // Distance from light source to vertex
    //float depthExpected = linearizeDepth(near, far, viewPos.z - shadowLightPosition.z);

    // Same as uniform vec3 cameraPosition i think (except vec3 and vec4)
    //vec4 playerPos = gbufferModelViewInverse * viewPos;  // vertex in world space (gbufferModelViewInverse = only viewInverse matrix, name is wrong)

    //float dist = length(viewPos.xz);
    //viewPos.y += 0.01 * dist * dist;

    gl_Position = gl_ProjectionMatrix * viewPos;
}
