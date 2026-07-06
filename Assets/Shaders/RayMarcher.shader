Shader "Custom/RayMarcher"
{

    // DONE: https://www.youtube.com/watch?v=PGtv-dBi2wE
    // NEXT: https://www.youtube.com/watch?v=Ff0jJyyiVyw
    Properties
    {
        [PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
        _Color("Tint", Color) = (1, 1, 1, 1)

        [HideInInspector] _StencilComp("Stencil Comparison", Float) = 8
        [HideInInspector] _Stencil("Stencil ID", Float) = 0
        [HideInInspector] _StencilOp("Stencil Operation", Float) = 0
        [HideInInspector] _StencilWriteMask("Stencil Write Mask", Float) = 255
        [HideInInspector] _StencilReadMask("Stencil Read Mask", Float) = 255
        [HideInInspector] _ColorMask("Color Mask", Float) = 15
        [HideInInspector] [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("Use Alpha Clip", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "PreviewType" = "Plane"
            "CanUseSpriteAtlas" = "True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            struct Attributes
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                float2 uv : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            fixed4 _Color;
            float4 _ClipRect;

            // --- Vertex Shader ---
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.worldPosition = IN.vertex;
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                //OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex); // Apply image texture offset and tiling to uvs (useless)
                OUT.uv = IN.uv * 2.0 - 1.0; // Transform uvs from [0, 1] to [-1, 1]
                OUT.color = IN.color * _Color;
                return OUT;
            }

            // TODO: Move section to a separate file:
            // --- Ray Marching Functions --- 
            #define MAX_STEPS 100
            #define MAX_DISTANCE 100.0
            #define SURFACE_DISTANCE 0.001
            #define NORMAL_EPSILON 0.001
            #define SHADOW_BIAS 0.02
            #define SHADOW_BRIGHTNESS 0.1

            float sdCapsule(float3 p, float3 a, float3 b, float r)
            {
                float3 ab = b - a;
                float3 ap = p - a;

                float t = clamp(dot(ap, ab) / dot(ab, ab), 0.0, 1.0);
                float3 c = a + ab * t;
                return length(p - c) - r;
            }

            float sdTorus(float3 p, float2 r)
            {
                float x = length(p.xz) - r.x;
                return length(float2(x, p.y)) - r.y;
            }

            float GetDistance(float3 p)
            {
                float4 s = float4(0, 1, 6, 1);
                float sphereDistance = length(p - s.xyz) - s.w;
                float planeDistance = p.y;

                float capsuleDistance = sdCapsule(p, float3(0, 1, 6), float3(1, 2, 6), 0.2);
                float torusDistance = sdTorus(p - float3(0,.5,6), float2(1.5, 0.3));
                float totalDistance = min(capsuleDistance, planeDistance);
                totalDistance = min(totalDistance, torusDistance);

                return totalDistance;
            }


            float RayMarch(float3 rayOrigin, float3 rayDirection)
            {
                float distanceOrigin = 0.0;

                for(int i = 0; i < MAX_STEPS; i++)
                {
                    float3 p = rayOrigin + rayDirection * distanceOrigin;
                    float distanceScene = GetDistance(p);
                    distanceOrigin += distanceScene;

                    if(distanceOrigin > MAX_DISTANCE || distanceScene < SURFACE_DISTANCE)
                    {
                        break;
                    }
                }


                return distanceOrigin;
            }

            float3 GetNormal(float3 p)
            {
                float2 e = float2(NORMAL_EPSILON, 0);

                float3 normal = float3(
                    GetDistance(p + e.xyy) - GetDistance(p - e.xyy),
                    GetDistance(p + e.yxy) - GetDistance(p - e.yxy),
                    GetDistance(p + e.yyx) - GetDistance(p - e.yyx)
                );

                return normalize(normal);
            }

            float GetLight(float3 p)
            {
                float3 lightPosition = float3(0, 5, 6);

                lightPosition.xz += float2(sin(_Time.y), cos(_Time.y));

                float3 lightDirection = normalize(lightPosition - p);
                float3 surfaceNormal = GetNormal(p);


                float dif = clamp(dot(lightDirection, surfaceNormal), 0.0, 1.0);
                
                float d = RayMarch(p + surfaceNormal * SHADOW_BIAS, lightDirection);
                if (d < length(lightPosition - p))
                {
                    dif *= SHADOW_BRIGHTNESS;
                }

                return dif;
            }

            // --- Frag Shader ---
            fixed4 frag(Varyings IN) : SV_Target
            {
                fixed4 color = fixed4(0, 0, 0, 1);

                // Simple Camera Model
                float3 rayOrigin = float3(0, 2, 0);
                float3 rayDirection = normalize(float3(IN.uv.x, IN.uv.y - .2, 1));


                // Ray Intersection
                float distance = RayMarch(rayOrigin, rayDirection);

                // Lighting
                float3 p = rayOrigin + rayDirection * distance;

                float diffuse = GetLight(p);


                color = fixed4(diffuse, diffuse, diffuse, 1);

                // EXTRA
                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip(color.a - 0.001);
                #endif

                return color;
            }
            ENDCG
        }
    }
}
