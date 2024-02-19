float bayer2  (vec2 c) { c = 0.5 * floor(c); return fract(1.5 * fract(c.y) + c.x); }
float bayer4  (vec2 c) { return 0.25 * bayer2 (0.5 * c) + bayer2(c); }
float bayer8  (vec2 c) { return 0.25 * bayer4 (0.5 * c) + bayer2(c); }
float bayer16 (vec2 c) { return 0.25 * bayer8 (0.5 * c) + bayer2(c); }
float bayer32 (vec2 c) { return 0.25 * bayer16(0.5 * c) + bayer2(c); }
float bayer64 (vec2 c) { return 0.25 * bayer32(0.5 * c) + bayer2(c); }
float bayer128(vec2 c) { return 0.25 * bayer64(0.5 * c) + bayer2(c); }