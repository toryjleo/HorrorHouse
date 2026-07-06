#ifndef HORRORHOUSE_SDF_CGINC
#define HORRORHOUSE_SDF_CGINC

// Signed distance helpers return negative values inside a surface, zero on the
// surface, and positive values outside. Most functions expect p in the shape's
// local space unless they accept explicit world-space endpoints or centers.

// Sphere centered at center with the given radius.
float sdSphere(float3 p, float3 center, float radius)
{
    return length(p - center) - radius;
}

// Capsule swept from endpoint a to endpoint b with radius r.
float sdCapsule(float3 p, float3 a, float3 b, float r)
{
    float3 ab = b - a;
    float3 ap = p - a;

    float t = clamp(dot(ap, ab) / dot(ab, ab), 0.0, 1.0);
    float3 c = a + ab * t;
    return length(p - c) - r;
}

// Finite cylinder between endpoint a and endpoint b with radius r.
float sdCylinder(float3 p, float3 a, float3 b, float r)
{
    float3 ab = b - a;
    float3 ap = p - a;

    float t = dot(ap, ab) / dot(ab, ab);
    float3 c = a + ab * t;

    float x = length(p - c) - r;
    float y = (abs(t - 0.5) - 0.5) * length(ab);
    float exteriorDistance = length(max(float2(x, y), 0.0));
    float interiorDistance = min(max(x, y), 0.0);

    return exteriorDistance + interiorDistance;
}

// Torus centered at the origin around the Y axis.
// r.x is the major radius and r.y is the tube radius.
float sdTorus(float3 p, float2 r)
{
    float x = length(p.xz) - r.x;
    return length(float2(x, p.y)) - r.y;
}

// Axis-aligned box centered at the origin with half-extents b.
float sdBox(float3 p, float3 b)
{
    float3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

#endif
