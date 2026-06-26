Shader "Custom/RayMarcher"
{

    // Tutorial: https://www.youtube.com/watch?v=PGtv-dBi2wE
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
            #define SURFACE_DISTANCE 0.01 // Is this the minimum clip plane?

            float GetDistance(fixed3 p)
            {
                fixed4 s = fixed4(0, 1, 6, 1);
                float sphereDistance = length(p - s.xyz) - s.w;
                float planeDistance = p.y;

                float totalDistance = min(sphereDistance, planeDistance);

                return totalDistance;
            }

            float RayMarch(fixed3 rayOrigin, fixed3 rayDirection)
            {
                float distanceOrigin = 0.0;

                for(int i = 0; i < MAX_STEPS; i++)
                {
                    fixed3 p = rayOrigin + rayDirection * distanceOrigin;
                    float distanceScene = GetDistance(p);
                    distanceOrigin += distanceScene;

                    if(distanceOrigin > MAX_DISTANCE || distanceScene < SURFACE_DISTANCE)
                    {
                        break;
                    }
                }


                return distanceOrigin;
            }

            // --- Frag Shader ---
            fixed4 frag(Varyings IN) : SV_Target
            {
                fixed4 color = fixed4(0, 0, 0, 1);

                // Simple Camera Model
                fixed3 rayOrigin = fixed3(0, 1, 0);
                fixed3 rayDirection = normalize(fixed3(IN.uv.x, IN.uv.y, 1));


                // Ray Intersection
                float distance = RayMarch(rayOrigin, rayDirection);
                distance /= 6.0;
                color = fixed4(distance, distance, distance, distance);






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
