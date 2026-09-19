// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Dary_Palasky_Built-in/Fabric built-in"
{
	Properties
	{
		[Header(___BASE___)]_ColorCloth("ColorCloth", Color) = (1,1,1,0)
		_Transform("Transform", Range( 0 , 1)) = 0
		_Veins("Veins", Range( 0 , 1)) = 0
		_Cloth_Roughness("Cloth_Roughness", Range( 0 , 1)) = 0
		_Opacity_1_intensity("Opacity_1_intensity", Range( 0 , 1)) = 1
		_Opacity_2_intensity("Opacity_2_intensity", Range( 0 , 1)) = 1
		[Header(___TEXTURES___)][NoScaleOffset]_BaseColor_1("Base Color_1", 2D) = "white" {}
		[NoScaleOffset]_BaseColor_2("Base Color_2", 2D) = "white" {}
		[NoScaleOffset]_BaseColor_3("Base Color_3", 2D) = "white" {}
		[NoScaleOffset]_Metallic("Metallic", 2D) = "black" {}
		[NoScaleOffset]_Opacity_1("Opacity_1", 2D) = "white" {}
		[NoScaleOffset]_Opacity_2("Opacity_2", 2D) = "white" {}
		[NoScaleOffset]_TransformMask_1("TransformMask_1", 2D) = "white" {}
		[NoScaleOffset]_Normal_2("Normal_2", 2D) = "white" {}
		[NoScaleOffset]_Normal("Normal", 2D) = "white" {}
		[NoScaleOffset]_Roughness_1("Roughness_1", 2D) = "white" {}
		[NoScaleOffset]_Roughness_2("Roughness_2", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" }
		Cull Off
		AlphaToMask On
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			half3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _Normal;
		uniform sampler2D _Normal_2;
		uniform sampler2D _TransformMask_1;
		uniform half _Transform;
		uniform sampler2D _BaseColor_1;
		uniform sampler2D _BaseColor_2;
		uniform half _Veins;
		uniform sampler2D _BaseColor_3;
		uniform half4 _ColorCloth;
		uniform sampler2D _Metallic;
		uniform sampler2D _Roughness_1;
		uniform sampler2D _Roughness_2;
		uniform half _Cloth_Roughness;
		uniform sampler2D _Opacity_1;
		uniform half _Opacity_1_intensity;
		uniform sampler2D _Opacity_2;
		uniform half _Opacity_2_intensity;


		float4 CalculateContrast( float contrastValue, float4 colorTarget )
		{
			float t = 0.5 * ( 1.0 - contrastValue );
			return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal48 = i.uv_texcoord;
			float2 uv_Normal_261 = i.uv_texcoord;
			float2 uv_TransformMask_141 = i.uv_texcoord;
			half4 tex2DNode41 = tex2D( _TransformMask_1, uv_TransformMask_141 );
			half lerpResult38 = lerp( -1.0 , 1.0 , _Transform);
			half clampResult39 = clamp( ( ( tex2DNode41.g + tex2DNode41.b ) + lerpResult38 ) , 0.0 , 1.0 );
			half3 lerpResult50 = lerp( UnpackNormal( tex2D( _Normal, uv_Normal48 ) ) , UnpackNormal( tex2D( _Normal_2, uv_Normal_261 ) ) , clampResult39);
			o.Normal = lerpResult50;
			float2 uv_BaseColor_11 = i.uv_texcoord;
			float2 uv_BaseColor_23 = i.uv_texcoord;
			half lerpResult35 = lerp( -1.0 , 1.0 , _Veins);
			half clampResult37 = clamp( ( tex2DNode41.r + lerpResult35 ) , 0.0 , 1.0 );
			half4 lerpResult5 = lerp( tex2D( _BaseColor_1, uv_BaseColor_11 ) , tex2D( _BaseColor_2, uv_BaseColor_23 ) , clampResult37);
			float2 uv_BaseColor_37 = i.uv_texcoord;
			half4 lerpResult6 = lerp( lerpResult5 , tex2D( _BaseColor_3, uv_BaseColor_37 ) , clampResult39);
			half4 lerpResult9 = lerp( lerpResult6 , ( lerpResult6 * _ColorCloth ) , 1.0);
			half4 temp_output_16_0 = ( ( lerpResult9 * 1.5 ) * 0.5 );
			float3 ase_worldPos = i.worldPos;
			half3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			half3 ase_worldNormal = WorldNormalVector( i, half3( 0, 0, 1 ) );
			half fresnelNdotV19 = dot( ase_worldNormal, ase_worldViewDir );
			half fresnelNode19 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV19, 4.0 ) );
			half4 lerpResult18 = lerp( temp_output_16_0 , ( temp_output_16_0 * 4.0 ) , fresnelNode19);
			o.Albedo = lerpResult18.rgb;
			float2 uv_Metallic59 = i.uv_texcoord;
			o.Metallic = tex2D( _Metallic, uv_Metallic59 ).r;
			float2 uv_Roughness_151 = i.uv_texcoord;
			float2 uv_Roughness_253 = i.uv_texcoord;
			half4 lerpResult55 = lerp( tex2D( _Roughness_1, uv_Roughness_151 ) , tex2D( _Roughness_2, uv_Roughness_253 ) , clampResult39);
			o.Smoothness = ( ( 1.0 - lerpResult55 ) * _Cloth_Roughness ).r;
			float2 uv_Opacity_125 = i.uv_texcoord;
			half lerpResult58 = lerp( 1.0 , tex2D( _Opacity_1, uv_Opacity_125 ).r , _Opacity_1_intensity);
			float2 uv_Opacity_284 = i.uv_texcoord;
			half lerpResult87 = lerp( 1.0 , tex2D( _Opacity_2, uv_Opacity_284 ).r , _Opacity_2_intensity);
			half4 temp_cast_3 = (clampResult39).xxxx;
			half lerpResult90 = lerp( lerpResult58 , lerpResult87 , CalculateContrast(1.0,temp_cast_3).r);
			o.Alpha = lerpResult90;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			AlphaToMask Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
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
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
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
Node;AmplifyShaderEditor.LerpOp;5;-462.5404,-683.1219;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;3;-976.4325,-704.7189;Inherit;True;Property;_TextureSample1;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;6;-274.6712,-366.9798;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;72.5544,-235.3737;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;15;450.0406,-187.4582;Inherit;False;Constant;_Float1;Float 0;3;0;Create;True;0;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;670.9097,-272.0099;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-247.0928,476.2742;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;9;309.6175,-370.9323;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;18;197.0925,372.3159;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;19;-126.1476,646.3813;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;203.927,-146.8256;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-778.4747,472.8777;Inherit;False;Constant;_Float2;Float 2;4;0;Create;True;0;0;0;False;0;False;0.5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;-964.7977,-168.8874;Inherit;True;Property;_TextureSample2;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;21;-415.8707,632.9838;Inherit;False;Constant;_Float3;Float 3;3;0;Create;True;0;0;0;False;0;False;4;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-651.4357,374.0702;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;35;-2975.879,-448.1774;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;37;-2381.047,-427.7665;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-2627.813,-425.785;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;38;-2979.818,-190.6745;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;39;-2384.986,-170.2636;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;-2631.752,-168.2821;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-966.4811,-994.7652;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;43;-2816.195,178.194;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-3304.649,-233.3446;Inherit;False;Constant;_Float7;Float 6;9;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-3303.904,-312.5034;Inherit;False;Constant;_Float6;Float 6;9;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;41;-3181.113,128.0787;Inherit;True;Property;_TextureSample6;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;51;-3310.229,1104.826;Inherit;True;Property;_TextureSample8;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;46;-3561.968,-444.0071;Inherit;False;Property;_Veins;Veins;2;0;Create;True;0;0;0;False;0;False;0;-1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-292.6978,760.8506;Inherit;False;Constant;_FresnelPower;FresnelPower;6;0;Create;True;0;0;0;False;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;50;-2811.24,379.6438;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;61;-3198.569,585.9907;Inherit;True;Property;_TextureSample11;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;48;-3198.198,368.3163;Inherit;True;Property;_TextureSample7;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;55;-2833.397,1312.826;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;53;-3301.716,1577.311;Inherit;True;Property;_TextureSample9;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;912.0825,805.9631;Half;False;True;-1;6;ASEMaterialInspector;0;0;Standard;Dary_Palasky_Built-in/Fabric built-in;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;ForwardOnly;12;all;True;True;True;True;0;False;;False;193;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;1;False;;1;False;;0;1;False;;1;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;6;-1;-1;-1;0;True;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-2302.589,1323.197;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;79;-2629.44,1251.882;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-3566.21,-107.5127;Inherit;False;Property;_Transform;Transform;1;0;Create;True;0;0;0;False;0;False;0;-1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-2498.651,1491.18;Inherit;False;Property;_Cloth_Roughness;Cloth_Roughness;3;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;54;-3564.719,1496.392;Inherit;True;Property;_Roughness_2;Roughness_2;17;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;52;-3566.326,1092.333;Inherit;True;Property;_Roughness_1;Roughness_1;16;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;63;-3456.861,600.8357;Inherit;True;Property;_Normal_2;Normal_2;14;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;49;-3454.237,378.5227;Inherit;True;Property;_Normal;Normal;15;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;42;-3437.21,115.5859;Inherit;True;Property;_TransformMask_1;TransformMask_1;13;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;4;-1232.53,-717.2117;Inherit;True;Property;_BaseColor_2;Base Color_2;8;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;8;-1220.895,-181.3802;Inherit;True;Property;_BaseColor_3;Base Color_3;9;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;2;-1222.579,-1007.258;Inherit;True;Property;_BaseColor_1;Base Color_1;7;2;[Header];[NoScaleOffset];Create;True;1;___TEXTURES___;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.ColorNode;13;-164.3528,-131.8736;Inherit;False;Property;_ColorCloth;ColorCloth;0;1;[Header];Create;True;1;___BASE___;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;25;-298.2646,1139.785;Inherit;True;Property;_TextureSample4;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;59;596.7428,1625.394;Inherit;True;Property;_TextureSample10;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;26;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;60;360.388,1638.02;Inherit;True;Property;_Metallic;Metallic;10;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;None;None;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;34;-180.1432,1348.74;Inherit;False;Property;_Opacity_1_intensity;Opacity_1_intensity;4;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;58;94.61411,1188.508;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-16.86493,1126.22;Inherit;False;Constant;_Float4;Float 4;18;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;84;-351.8206,1693.443;Inherit;True;Property;_TextureSample5;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;82;-343.3037,1905.534;Inherit;False;Property;_Opacity_2_intensity;Opacity_2_intensity;5;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;88;23.98662,1729.764;Inherit;False;Constant;_Float5;Float 4;18;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;87;152.6587,1737.348;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleContrastOpNode;83;-889.4852,1427.685;Inherit;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;90;451.9651,1282.192;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-1106.984,1506.891;Inherit;False;Constant;_Float8;Float 8;18;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;26;-603.0718,1136.192;Inherit;True;Property;_Opacity_1;Opacity_1;11;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;85;-624.8698,1698.764;Inherit;True;Property;_Opacity_2;Opacity_2;12;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
WireConnection;5;0;1;0
WireConnection;5;1;3;0
WireConnection;5;2;37;0
WireConnection;3;0;4;0
WireConnection;6;0;5;0
WireConnection;6;1;7;0
WireConnection;6;2;39;0
WireConnection;11;0;6;0
WireConnection;11;1;13;0
WireConnection;14;0;9;0
WireConnection;14;1;15;0
WireConnection;17;0;16;0
WireConnection;17;1;21;0
WireConnection;9;0;6;0
WireConnection;9;1;11;0
WireConnection;9;2;10;0
WireConnection;18;0;16;0
WireConnection;18;1;17;0
WireConnection;18;2;19;0
WireConnection;19;3;20;0
WireConnection;7;0;8;0
WireConnection;16;0;14;0
WireConnection;16;1;22;0
WireConnection;35;0;44;0
WireConnection;35;1;45;0
WireConnection;35;2;46;0
WireConnection;37;0;36;0
WireConnection;36;0;41;1
WireConnection;36;1;35;0
WireConnection;38;0;44;0
WireConnection;38;1;45;0
WireConnection;38;2;47;0
WireConnection;39;0;40;0
WireConnection;40;0;43;0
WireConnection;40;1;38;0
WireConnection;1;0;2;0
WireConnection;43;0;41;2
WireConnection;43;1;41;3
WireConnection;41;0;42;0
WireConnection;51;0;52;0
WireConnection;50;0;48;0
WireConnection;50;1;61;0
WireConnection;50;2;39;0
WireConnection;61;0;63;0
WireConnection;48;0;49;0
WireConnection;55;0;51;0
WireConnection;55;1;53;0
WireConnection;55;2;39;0
WireConnection;53;0;54;0
WireConnection;0;0;18;0
WireConnection;0;1;50;0
WireConnection;0;3;59;0
WireConnection;0;4;56;0
WireConnection;0;9;90;0
WireConnection;56;0;79;0
WireConnection;56;1;57;0
WireConnection;79;0;55;0
WireConnection;25;0;26;0
WireConnection;59;0;60;0
WireConnection;58;0;86;0
WireConnection;58;1;25;1
WireConnection;58;2;34;0
WireConnection;84;0;85;0
WireConnection;87;0;88;0
WireConnection;87;1;84;1
WireConnection;87;2;82;0
WireConnection;83;1;39;0
WireConnection;83;0;91;0
WireConnection;90;0;58;0
WireConnection;90;1;87;0
WireConnection;90;2;83;0
ASEEND*/
//CHKSM=B12D0969A67D2D56CD54A64E8FCF3551999EA2A8