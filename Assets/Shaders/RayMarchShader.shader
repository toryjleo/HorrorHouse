Shader "Custom/RayMarchShader"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap("Base Map", 2D) = "white"
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            uniform float4 _CamWorldSpace;
            uniform float4x4 _CamFrustum, _CamToWorld;



            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 ray : TEXCOORD1;
            };



            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                half index = IN.positionOS.z;
                IN.positionOS.z = 0.0;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);


                OUT.ray = _CamFrustum[(int)index].xyz;

                OUT.ray /= abs(OUT.ray.z);

                OUT.ray = mul(_CamWorldSpace, OUT.ray);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 rayDirection = normalize(IN.ray.xyz);
                float3 rayOrigin = _CamWorldSpace;
                return half4(rayDirection, 1.0);
            }
            ENDHLSL
        }
    }
}
