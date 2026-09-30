// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Dary_Palasky_Built-in/Eyes Shader Built-in"
{
	Properties
	{
		[Header(___BASE___)]_ColorHumanEyes("ColorHumanEyes", Color) = (1,1,1,0)
		_ColorTransformEyes("ColorTransformEyes", Color) = (1,1,1,0)
		[HDR]_EmissionColor("EmissionColor", Color) = (1,0,0,0)
		_ColorEffect("Color Effect", Color) = (1,0,0,0)
		_EmissionIntensity("EmissionIntensity", Range( 0 , 100)) = 0
		_brightnessHuman("brightnessHuman", Range( 0 , 5)) = 1.5
		_brightnessTransform("brightnessTransform", Range( 0 , 5)) = 0
		_Roughness("Roughness", Range( 0 , 1)) = 0.89
		_TransformEyes("TransformEyes", Range( 0 , 1)) = 0
		[Header(___TEXTURES___)][NoScaleOffset]_MainColor("MainColor", 2D) = "white" {}
		[NoScaleOffset]_Transform_Mask("Transform_Mask", 2D) = "white" {}
		[NoScaleOffset]_IrisMask("IrisMask", 2D) = "white" {}
		[NoScaleOffset]_ColorTransform("ColorTransform", 2D) = "white" {}
		[NoScaleOffset]_EmissiveMask("EmissiveMask", 2D) = "white" {}
		[NoScaleOffset]_Noise("Noise", 2D) = "white" {}
		[Toggle]_EmissiveMaskSwitch("EmissiveMask Switch", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
		};

		uniform sampler2D _MainColor;
		uniform float _brightnessHuman;
		uniform float4 _ColorHumanEyes;
		uniform sampler2D _IrisMask;
		uniform sampler2D _ColorTransform;
		uniform sampler2D _Noise;
		uniform float4 _ColorTransformEyes;
		uniform float _brightnessTransform;
		uniform float4 _ColorEffect;
		uniform sampler2D _Transform_Mask;
		uniform float _TransformEyes;
		uniform float _EmissiveMaskSwitch;
		uniform float4 _EmissionColor;
		uniform float _EmissionIntensity;
		uniform sampler2D _EmissiveMask;
		uniform float _Roughness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_MainColor1 = i.uv_texcoord;
			float4 temp_output_3_0 = ( tex2D( _MainColor, uv_MainColor1 ) * _brightnessHuman );
			float2 uv_IrisMask9 = i.uv_texcoord;
			float4 lerpResult8 = lerp( temp_output_3_0 , ( temp_output_3_0 * _ColorHumanEyes ) , tex2D( _IrisMask, uv_IrisMask9 ).r);
			float2 temp_cast_0 = (1.0).xx;
			float2 temp_cast_1 = (1.0).xx;
			float2 uv_TexCoord25 = i.uv_texcoord * temp_cast_0 + temp_cast_1;
			float2 temp_cast_2 = (0.5).xx;
			float2 center45_g1 = temp_cast_2;
			float2 delta6_g1 = ( i.uv_texcoord - center45_g1 );
			float angle10_g1 = ( length( delta6_g1 ) * 7.0 );
			float x23_g1 = ( ( cos( angle10_g1 ) * delta6_g1.x ) - ( sin( angle10_g1 ) * delta6_g1.y ) );
			float2 break40_g1 = center45_g1;
			float4 color38 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);
			float2 break41_g1 = ( ( 0.05 * _Time.y ) * color38 ).rg;
			float y35_g1 = ( ( sin( angle10_g1 ) * delta6_g1.x ) + ( cos( angle10_g1 ) * delta6_g1.y ) );
			float2 appendResult44_g1 = (float2(( x23_g1 + break40_g1.x + break41_g1.x ) , ( break40_g1.y + break41_g1.y + y35_g1 )));
			float4 tex2DNode22 = tex2D( _ColorTransform, ( uv_TexCoord25 + ( tex2D( _Noise, appendResult44_g1 ).r * 0.22 ) ) );
			float4 lerpResult60 = lerp( tex2DNode22 , ( tex2DNode22 * _ColorTransformEyes ) , float4( 1,1,1,0 ));
			float4 temp_output_15_0 = ( lerpResult60 * _brightnessTransform );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV17 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode17 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV17, 1.0 ) );
			float4 lerpResult14 = lerp( temp_output_15_0 , ( _ColorEffect * fresnelNode17 ) , 0.8);
			float4 lerpResult12 = lerp( temp_output_15_0 , lerpResult14 , fresnelNode17);
			float2 uv_Transform_Mask50 = i.uv_texcoord;
			float lerpResult41 = lerp( -1.0 , ( ( _TransformEyes * 2.0 ) + -1.0 ) , 1.0);
			float clampResult43 = clamp( ( tex2D( _Transform_Mask, uv_Transform_Mask50 ).b + lerpResult41 ) , 0.0 , 1.0 );
			float4 lerpResult11 = lerp( lerpResult8 , ( lerpResult12 * lerpResult14 ) , clampResult43);
			o.Albedo = lerpResult11.rgb;
			float fresnelNdotV56 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode56 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV56, -1.0 ) );
			float4 temp_output_55_0 = ( ( _EmissionColor * ( _EmissionIntensity * 100000.0 ) ) * fresnelNode56 );
			float2 uv_EmissiveMask65 = i.uv_texcoord;
			o.Emission = (( _EmissiveMaskSwitch )?( ( temp_output_55_0 * tex2D( _EmissiveMask, uv_EmissiveMask65 ).r ) ):( temp_output_55_0 )).rgb;
			o.Smoothness = _Roughness;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.SamplerNode;1;-916.4069,-594.527;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;11;365.4917,331.1066;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-432.1606,-516.9748;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;12;-307.952,280.8801;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-484.2958,664.1053;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;0;False;0;False;0.8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;17;-695.2114,999.7971;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-833.1073,1110.568;Inherit;False;Constant;_Float1;Float 1;4;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-624.3347,412.4709;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-460.8325,844.9418;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;9;-642.079,31.4303;Inherit;True;Property;_TextureSample1;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;25;-1823.396,505.7268;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;26;-1980.396,566.7268;Inherit;False;Constant;_Float2;Float 2;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1912.385,905.689;Inherit;False;Constant;_Float3;Float 2;7;0;Create;True;0;0;0;False;0;False;0.22;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;30;-2494.023,649.0447;Inherit;False;Twirl;-1;;1;90936742ac32db8449cd21ab6dd337c8;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;4;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-2663.379,668.4983;Inherit;False;Constant;_Float4;Float 4;8;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-1780.385,805.689;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-2606.638,951.4253;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-2749.51,907.2031;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;36;-2972.097,917.7432;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-2672.379,758.4983;Inherit;False;Constant;_Float5;Float 4;8;0;Create;True;0;0;0;False;0;False;7;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-2897.097,809.7432;Inherit;False;Constant;_Float6;Float 4;8;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;38;-2828.097,1087.743;Inherit;False;Constant;_Color1;Color 1;8;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-76.33545,333.6245;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-2373.11,1841.798;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;24;-1606.077,662.409;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;14;-303.3655,627.1584;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;41;-1789.862,1873.398;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;-2070.058,1857.078;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-1537.384,1890.146;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;43;-1301.539,1918.907;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-1942.483,1765.051;Inherit;False;Constant;_Float8;Float 7;8;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-2003.483,1979.051;Inherit;False;Constant;_Float9;Float 7;8;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-2249.483,1970.051;Inherit;False;Constant;_Float7;Float 7;8;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-2581.059,1958.471;Inherit;False;Constant;_Float11;Float 7;8;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;211.2722,2419.942;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;56;-68.59472,2437.767;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-636.8623,-392.3857;Inherit;False;Property;_brightnessHuman;brightnessHuman;5;0;Create;True;0;0;0;False;0;False;1.5;1.34;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-240.2301,2547.428;Inherit;False;Constant;_Float13;Float 10;11;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;21.82898,2259.49;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;230.8807,2271.987;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-270.0853,2243.802;Inherit;False;Property;_EmissionIntensity;EmissionIntensity;4;0;Create;True;0;0;0;False;0;False;0;100;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-158.5799,2341.925;Inherit;False;Constant;_Float12;Float 10;11;0;Create;True;0;0;0;False;0;False;100000;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;58;33.67715,2068.04;Inherit;False;Property;_EmissionColor;EmissionColor;2;1;[HDR];Create;True;0;0;0;False;0;False;1,0,0,0;1.267651E+30,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;940.2587,224.339;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Dary_Palasky_Built-in/Eyes Shader Built-in;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-837.0416,521.8221;Inherit;False;Property;_brightnessTransform;brightnessTransform;6;0;Create;True;0;0;0;False;0;False;0;3.43;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-2693.686,1768.521;Inherit;False;Property;_TransformEyes;TransformEyes;8;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;8;-147.132,-384.474;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-428.8022,-267.2054;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-1200.443,310.7444;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;60;-1011.021,205.5461;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;22;-1386.101,14.94813;Inherit;True;Property;_TextureSample2;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;78bf728953ae5c140b4a58f8b36fc12d;78bf728953ae5c140b4a58f8b36fc12d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;65;316.1465,2669.717;Inherit;True;Property;_TextureSample5;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;78bf728953ae5c140b4a58f8b36fc12d;78bf728953ae5c140b4a58f8b36fc12d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;640.6275,2580.547;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ToggleSwitchNode;77;791.2312,2149.465;Inherit;False;Property;_EmissiveMaskSwitch;EmissiveMask Switch;15;0;Create;True;0;0;0;False;0;False;0;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;51;607.8605,464.9123;Inherit;False;Property;_Roughness;Roughness;7;0;Create;True;0;0;0;False;0;False;0.89;0.918;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;23;-1730.913,12.13432;Inherit;True;Property;_ColorTransform;ColorTransform;12;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;78bf728953ae5c140b4a58f8b36fc12d;78bf728953ae5c140b4a58f8b36fc12d;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.ColorNode;20;-732.1873,754.5396;Inherit;False;Property;_ColorEffect;Color Effect;3;0;Create;True;0;0;0;False;0;False;1,0,0,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;64;-28.66546,2666.903;Inherit;True;Property;_EmissiveMask;EmissiveMask;13;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;78bf728953ae5c140b4a58f8b36fc12d;78bf728953ae5c140b4a58f8b36fc12d;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;10;-902.9911,24.11505;Inherit;True;Property;_IrisMask;IrisMask;11;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;50;-1984.039,2190.435;Inherit;True;Property;_Transform_Mask;Transform_Mask;10;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;7;-663.2292,-198.0771;Inherit;False;Property;_ColorHumanEyes;ColorHumanEyes;0;1;[Header];Create;True;1;___BASE___;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;61;-1434.87,379.0727;Inherit;False;Property;_ColorTransformEyes;ColorTransformEyes;1;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.8113207,0.8113207,0.8113207,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;29;-2228.38,764.8052;Inherit;True;Property;_Noise;Noise;14;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;9659b18079b3cc34187159b658cf85bb;9659b18079b3cc34187159b658cf85bb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;2;-1177.319,-601.8422;Inherit;True;Property;_MainColor;MainColor;9;2;[Header];[NoScaleOffset];Create;True;1;___TEXTURES___;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
WireConnection;1;0;2;0
WireConnection;11;0;8;0
WireConnection;11;1;13;0
WireConnection;11;2;43;0
WireConnection;3;0;1;0
WireConnection;3;1;4;0
WireConnection;12;0;15;0
WireConnection;12;1;14;0
WireConnection;12;2;17;0
WireConnection;17;3;18;0
WireConnection;15;0;60;0
WireConnection;15;1;21;0
WireConnection;19;0;20;0
WireConnection;19;1;17;0
WireConnection;9;0;10;0
WireConnection;25;0;26;0
WireConnection;25;1;26;0
WireConnection;30;2;32;0
WireConnection;30;3;33;0
WireConnection;30;4;34;0
WireConnection;27;0;29;1
WireConnection;27;1;28;0
WireConnection;34;0;35;0
WireConnection;34;1;38;0
WireConnection;35;0;37;0
WireConnection;35;1;36;0
WireConnection;13;0;12;0
WireConnection;13;1;14;0
WireConnection;39;0;47;0
WireConnection;39;1;48;0
WireConnection;24;0;25;0
WireConnection;24;1;27;0
WireConnection;14;0;15;0
WireConnection;14;1;19;0
WireConnection;14;2;16;0
WireConnection;41;0;45;0
WireConnection;41;1;40;0
WireConnection;41;2;46;0
WireConnection;40;0;39;0
WireConnection;40;1;44;0
WireConnection;42;0;50;3
WireConnection;42;1;41;0
WireConnection;43;0;42;0
WireConnection;55;0;54;0
WireConnection;55;1;56;0
WireConnection;56;3;59;0
WireConnection;53;0;52;0
WireConnection;53;1;57;0
WireConnection;54;0;58;0
WireConnection;54;1;53;0
WireConnection;0;0;11;0
WireConnection;0;2;77;0
WireConnection;0;4;51;0
WireConnection;8;0;3;0
WireConnection;8;1;5;0
WireConnection;8;2;9;1
WireConnection;5;0;3;0
WireConnection;5;1;7;0
WireConnection;62;0;22;0
WireConnection;62;1;61;0
WireConnection;60;0;22;0
WireConnection;60;1;62;0
WireConnection;22;0;23;0
WireConnection;22;1;24;0
WireConnection;65;0;64;0
WireConnection;63;0;55;0
WireConnection;63;1;65;1
WireConnection;77;0;55;0
WireConnection;77;1;63;0
WireConnection;29;1;30;0
ASEEND*/
//CHKSM=FC6DBD931B4E8618B6538CA9BC2EB8A5B2205C2A