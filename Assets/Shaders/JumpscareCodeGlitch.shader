Shader "HorrorHouse/Jumpscare Code Glitch"
{
    Properties
    {
        /*
        <summary>
        - `_GlitchStrength`: bigger horizontal tearing.
        - `_NoiseScale`: more or fewer glitch bands.
        - `_ScanlineStrength`: darker scanlines.
        - `_RedBlueSplit`: stronger red/blue channel split.
        - `_FlashColor` and `_FlashIntensity`: color and strength of the random flashes.
        */


        [PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
        _Color("Tint", Color) = (1, 1, 1, 1)

        _ScareProgress("Scare Progress", Range(0, 1)) = 0
        _GlitchStrength("Glitch Strength", Range(0, 0.25)) = 0.055
        _NoiseScale("Noise Scale", Range(1, 120)) = 42
        _ScanlineStrength("Scanline Strength", Range(0, 1)) = 0.35
        _RedBlueSplit("Red Blue Split", Range(0, 0.08)) = 0.018
        _FlashColor("Flash Color", Color) = (1, 0.03, 0.02, 1)
        _FlashIntensity("Flash Intensity", Range(0, 3)) = 1.4

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

        /*
        TODO: Comment these in
        - `hash12`: makes repeatable fake noise from a `float2`.
        - `band`: splits the screen into horizontal rows.
        - `offset`: moves selected bands left or right.
        - `red` and `blue`: sample color channels from different positions.
        - `scanline`: dims every other thin row.
        - `flash`: randomly blends toward `_FlashColor`.
        
        
        */

        Pass
        {
            Name "JumpscareGlitch"

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

            float _ScareProgress;
            float _GlitchStrength;
            float _NoiseScale;
            float _ScanlineStrength;
            float _RedBlueSplit;
            fixed4 _FlashColor;
            float _FlashIntensity;

            float hash12(float2 value)
            {
                float3 p = frac(float3(value.xyx) * 0.1031);
                p += dot(p, p.yzx + 33.33);
                return frac((p.x + p.y) * p.z);
            }

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
                float progress = saturate(_ScareProgress);
                float time = _Time.y;

                float band = floor(input.uv.y * _NoiseScale + time * 18.0);
                float bandNoise = hash12(float2(band, floor(time * 20.0)));
                float bandMask = step(0.58, bandNoise);

                float spike = pow(saturate(sin(progress * 31.4)), 4.0);
                float offset = (bandNoise - 0.5) * _GlitchStrength * bandMask * (0.2 + progress + spike);

                float split = _RedBlueSplit * (0.25 + progress) * bandMask;
                fixed4 baseSample = tex2D(_MainTex, input.uv + float2(offset, 0));
                fixed red = tex2D(_MainTex, input.uv + float2(offset + split, 0)).r;
                fixed blue = tex2D(_MainTex, input.uv + float2(offset - split, 0)).b;

                fixed4 color = baseSample;
                color.r = red;
                color.b = blue;

                float scanline = frac(input.uv.y * 320.0 + time * 45.0);
                color.rgb *= 1.0 - step(0.5, scanline) * _ScanlineStrength * (0.35 + progress);

                float flash = step(0.74, hash12(float2(band + 17.0, floor(time * 34.0))));
                color.rgb = lerp(color.rgb, _FlashColor.rgb, flash * _FlashIntensity * progress * 0.35);

                color *= input.color;

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
