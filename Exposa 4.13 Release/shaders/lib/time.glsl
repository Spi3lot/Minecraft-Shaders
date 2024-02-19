uniform float sunAngle;

// uniform int worldTime;

float timeVal = sunAngle;

// float worldTimeVal = float(worldTime);

// float timeDivision = 1.0/24000.;

struct Time{
    float sunrise;
    float noon;
    float sunset;
    float night;
};

Time times = Time(((clamp(timeVal, 0.96, 1.00)-0.96) / 0.04 + 1-(clamp(timeVal, 0.02, 0.15)-0.02) / 0.13),((clamp(timeVal, 0.02, 0.15)-0.02) / 0.13   - (clamp(timeVal, 0.35, 0.48)-0.35) / 0.13),((clamp(timeVal, 0.35, 0.48)-0.35) / 0.13   - (clamp(timeVal, 0.50, 0.53)-0.50) / 0.03),((clamp(timeVal, 0.50, 0.53)-0.50) / 0.03   - (clamp(timeVal, 0.96, 1.00)-0.96) / 0.03));
// times.sunrise = ((clamp(timeVal, 0.96, 1.00)-0.96) / 0.04 + 1-(clamp(timeVal, 0.02, 0.15)-0.02) / 0.13);
// times.noon = Time((clamp(timeVal, 0.02, 0.15)-0.02) / 0.13   - (clamp(timeVal, 0.35, 0.48)-0.35) / 0.13);
// times.sunset = Time((clamp(timeVal, 0.35, 0.48)-0.35) / 0.13   - (clamp(timeVal, 0.50, 0.53)-0.50) / 0.03);
// times.night = Time((clamp(timeVal, 0.50, 0.53)-0.50) / 0.03   - (clamp(timeVal, 0.96, 1.00)-0.96) / 0.03);

// Time times = Time(float(clamp(worldTime, 23500, 23999)-23500)*timeDivision, float(clamp(worldTime, 0, 11999))*timeDivision, float(clamp(worldTime, 12000, 12999)-12000)*timeDivision, float(clamp(worldTime, 13000, 23499)-13000)*timeDivision);