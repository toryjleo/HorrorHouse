Shader "HorrorHouse/Image Stretch Inset"
{
    Properties
    {
        [PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
        _Color("Tint", Color) = (1, 1, 1, 1)

        _InsetScale("Inset Scale", Range(0.01, 1)) = 0.2
        _Padding("Padding", Range(0, 0.5)) = 0.04
        _StretchStrength("Stretch Strength", Range(0, 1)) = 1
        _StretchTint("Stretch Tint", Color) = (1, 1, 1, 1)
        _StretchAlpha("Stretch Alpha", Range(0, 1)) = 1

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
            Name "ImageStretchInset"

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                float2 uv : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float4 _ClipRect;

            float _InsetScale;
            float _Padding;
            float _StretchStrength;
            fixed4 _StretchTint;
            float _StretchAlpha;

            v2f vert(appdata input)
            {
                v2f output;
                output.worldPosition = input.vertex;
                output.vertex = UnityObjectToClipPos(input.vertex);
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                output.color = input.color * _Color;
                return output;
            }

            fixed4 frag(v2f input) : SV_Target
            {
                float2 uv = input.uv;
                float insetScale = saturate(_InsetScale);
                float padding = saturate(_Padding);
                float2 insetSize = float2(insetScale, insetScale);
                float2 insetMax = 1.0 - padding;
                float2 insetMin = insetMax - insetSize;

                float2 clampedInsetUv = clamp(uv, insetMin, insetMax);
                float2 sourceUv = saturate((clampedInsetUv - insetMin) / max(insetSize, 0.0001));

                fixed4 insetColor = tex2D(_MainTex, sourceUv) * input.color;
                fixed4 originalColor = tex2D(_MainTex, uv) * input.color;

                float2 insideMin = step(insetMin, uv);
                float2 insideMax = step(uv, insetMax);
                float insideInset = insideMin.x * insideMin.y * insideMax.x * insideMax.y;

                fixed4 stretchedColor = insetColor * _StretchTint;
                stretchedColor.a *= _StretchAlpha;
                fixed4 color = lerp(originalColor, stretchedColor, _StretchStrength);
                color = lerp(color, insetColor, insideInset);

                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(input.worldPosition.xy, _ClipRect);
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
