#ifndef DIRT_RAMP4_INCLUDED
#define DIRT_RAMP4_INCLUDED

// 4-key color ramp for Shader Graph Custom Function node (File mode, Name: DirtRamp4).
// t       : 0-1 lookup value (e.g. texture R after Remap)
// C0..C3  : ramp colors at positions 0, K1, K2, 1
// K1, K2  : positions of the middle keys (keep 0 < K1 < K2 < 1)
void DirtRamp4_float(float t,
    float3 C0, float3 C1, float3 C2, float3 C3,
    float K1, float K2,
    out float3 Color)
{
    // Guard against bad slider values (divide by zero / out-of-order keys)
    K1 = clamp(K1, 0.001, 0.998);
    K2 = clamp(K2, K1 + 0.001, 0.999);

    Color = lerp(C0, C1, saturate(t / K1));
    Color = lerp(Color, C2, saturate((t - K1) / (K2 - K1)));
    Color = lerp(Color, C3, saturate((t - K2) / (1.0 - K2)));
}

#endif
