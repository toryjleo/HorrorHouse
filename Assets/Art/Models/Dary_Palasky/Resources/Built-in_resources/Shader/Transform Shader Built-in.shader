// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Dary_Palasky_Built-in/Transform Shader Built-in"
{
	Properties
	{
		[Header(___SKIN_COLOR___)]_ColorSkin_Human("ColorSkin_Human", Color) = (1,1,1,0)
		_ColorSkin_Veins("ColorSkin_Veins", Color) = (1,1,1,0)
		_ColorSkin_Transform("ColorSkin_Transform", Color) = (1,1,1,0)
		[Header(___TRANSFORM___)]_Transform("Transform", Range( 0 , 2)) = 0
		_Veins("Veins", Range( 0 , 2)) = 0
		_TransformDissolveColor("TransformDissolveColor", Color) = (0.254717,0,0,0)
		_Human_Roughness("Human_Roughness", Range( 0 , 2)) = 1
		_Veins_Roughness("Veins_Roughness", Range( 0 , 1)) = 0.6459731
		_Transform_Roughness("Transform_Roughness", Range( 0 , 2)) = 1
		[Header(___DIRT___)]_DirtColor("DirtColor", Color) = (0.2235294,0.1372549,0.04705883,1)
		_Dirt("Dirt", Range( 0 , 2)) = 0
		_DirtRoughness("Dirt  Roughness", Range( 0 , 0.5)) = 0
		[Header(___BLOOD___)]_BloodColor("Blood Color", Color) = (0.227451,0,0,1)
		_Blood("Blood", Range( 0 , 1)) = 0
		_BloodRoughness("Blood  Roughness", Range( 0 , 1)) = 0
		[Header(___TEXTURES___)][NoScaleOffset]_BaseColor_1("Base Color_1", 2D) = "white" {}
		[NoScaleOffset]_BaseColor_2("Base Color_2", 2D) = "white" {}
		[NoScaleOffset]_BaseColor_3("Base Color_3", 2D) = "white" {}
		[NoScaleOffset]_Normal_1("Normal_1", 2D) = "white" {}
		[NoScaleOffset]_Normal_2("Normal_2", 2D) = "white" {}
		[NoScaleOffset]_Normal_3("Normal_3", 2D) = "white" {}
		[NoScaleOffset]_DistortionTexture("DistortionTexture", 2D) = "white" {}
		[NoScaleOffset]_Transformmask_1("Transform mask_1", 2D) = "white" {}
		[NoScaleOffset]_Transformmask_2("Transform mask_2", 2D) = "white" {}
		[NoScaleOffset]_DirtMask("DirtMask", 2D) = "white" {}
		[NoScaleOffset]_BloodMask("BloodMask", 2D) = "white" {}
		[NoScaleOffset]_Roughness("Roughness", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _Normal_1;
		uniform sampler2D _Normal_2;
		uniform sampler2D _DistortionTexture;
		uniform sampler2D _Transformmask_1;
		uniform float _Veins;
		uniform sampler2D _Normal_3;
		uniform sampler2D _Transformmask_2;
		uniform float _Transform;
		uniform sampler2D _BaseColor_1;
		uniform float4 _ColorSkin_Human;
		uniform sampler2D _BaseColor_2;
		uniform float4 _ColorSkin_Veins;
		uniform float4 _TransformDissolveColor;
		uniform sampler2D _BaseColor_3;
		uniform float4 _ColorSkin_Transform;
		uniform float4 _DirtColor;
		uniform float _Dirt;
		uniform sampler2D _DirtMask;
		uniform float4 _BloodColor;
		uniform float _Blood;
		uniform sampler2D _BloodMask;
		uniform sampler2D _Roughness;
		uniform float _Human_Roughness;
		uniform float _Veins_Roughness;
		uniform float _Transform_Roughness;
		uniform float _DirtRoughness;
		uniform float _BloodRoughness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal_171 = i.uv_texcoord;
			float2 temp_cast_0 = (1.0).xx;
			float2 temp_cast_1 = (1.0).xx;
			float2 uv_TexCoord113 = i.uv_texcoord * temp_cast_0 + temp_cast_1;
			float2 temp_cast_2 = (3.0).xx;
			float mulTime118 = _Time.y * 0.1;
			float4 color107 = IsGammaSpace() ? float4(0,1,0.009106636,0) : float4(0,1,0.000704848,0);
			float2 uv_TexCoord106 = i.uv_texcoord * temp_cast_2 + ( ( 0.25 * mulTime118 ) * color107 ).rg;
			float2 temp_output_112_0 = ( uv_TexCoord113 + ( tex2D( _DistortionTexture, uv_TexCoord106 ).r * 0.01 ) );
			float2 uv_Transformmask_188 = i.uv_texcoord;
			float4 tex2DNode88 = tex2D( _Transformmask_1, uv_Transformmask_188 );
			float lerpResult90 = lerp( -0.5 , ( _Veins + -1.0 ) , 2.0);
			float clampResult97 = clamp( ( ( tex2DNode88.r + tex2DNode88.g ) + lerpResult90 ) , 0.0 , 1.0 );
			float3 lerpResult73 = lerp( UnpackNormal( tex2D( _Normal_1, uv_Normal_171 ) ) , UnpackNormal( tex2D( _Normal_2, temp_output_112_0 ) ) , clampResult97);
			float2 uv_Normal_367 = i.uv_texcoord;
			float2 uv_Transformmask_275 = i.uv_texcoord;
			float4 tex2DNode75 = tex2D( _Transformmask_2, uv_Transformmask_275 );
			float lerpResult80 = lerp( -1.0 , ( _Transform + -1.0 ) , 1.0);
			float clampResult85 = clamp( ( tex2DNode75.b + lerpResult80 ) , 0.0 , 1.0 );
			float3 lerpResult74 = lerp( lerpResult73 , UnpackNormal( tex2D( _Normal_3, uv_Normal_367 ) ) , clampResult85);
			o.Normal = lerpResult74;
			float2 uv_BaseColor_11 = i.uv_texcoord;
			float4 tex2DNode1 = tex2D( _BaseColor_1, uv_BaseColor_11 );
			float4 lerpResult5 = lerp( tex2DNode1 , ( _ColorSkin_Human * tex2DNode1 ) , 1.0);
			float4 tex2DNode7 = tex2D( _BaseColor_2, temp_output_112_0 );
			float4 lerpResult9 = lerp( tex2DNode7 , ( _ColorSkin_Veins * tex2DNode7 ) , 1.0);
			float4 lerpResult25 = lerp( lerpResult5 , lerpResult9 , clampResult97);
			float clampResult86 = clamp( ( lerpResult80 + ( tex2DNode75.b + -0.5 ) ) , 0.0 , 1.0 );
			float4 lerpResult26 = lerp( lerpResult25 , _TransformDissolveColor , ( clampResult86 * 3.0 ));
			float2 uv_BaseColor_319 = i.uv_texcoord;
			float4 tex2DNode19 = tex2D( _BaseColor_3, uv_BaseColor_319 );
			float4 lerpResult21 = lerp( tex2DNode19 , ( _ColorSkin_Transform * tex2DNode19 ) , 1.0);
			float4 lerpResult31 = lerp( lerpResult26 , lerpResult21 , clampResult85);
			float2 uv_DirtMask32 = i.uv_texcoord;
			float lerpResult38 = lerp( 0.0 , _Dirt , tex2D( _DirtMask, uv_DirtMask32 ).r);
			float clampResult40 = clamp( lerpResult38 , 0.0 , 1.0 );
			float4 lerpResult47 = lerp( lerpResult31 , _DirtColor , clampResult40);
			float2 uv_BloodMask41 = i.uv_texcoord;
			float lerpResult43 = lerp( 0.0 , _Blood , tex2D( _BloodMask, uv_BloodMask41 ).r);
			float clampResult46 = clamp( lerpResult43 , 0.0 , 1.0 );
			float4 lerpResult48 = lerp( lerpResult47 , _BloodColor , clampResult46);
			o.Albedo = lerpResult48.rgb;
			float2 uv_Roughness54 = i.uv_texcoord;
			float4 tex2DNode54 = tex2D( _Roughness, uv_Roughness54 );
			float lerpResult57 = lerp( ( tex2DNode54.r * _Human_Roughness ) , _Veins_Roughness , clampResult97);
			float lerpResult60 = lerp( lerpResult57 , ( tex2DNode54.g * _Transform_Roughness ) , clampResult85);
			float lerpResult63 = lerp( lerpResult60 , _DirtRoughness , lerpResult38);
			float lerpResult64 = lerp( lerpResult63 , _BloodRoughness , lerpResult43);
			o.Smoothness = lerpResult64;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.SamplerNode;1;-1248.583,-1230.549;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-667.251,-1094.646;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;5;-438.3088,-1208.25;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;7;-1268.127,-737.6647;Inherit;True;Property;_TextureSample1;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-686.7949,-601.7618;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;9;-457.8529,-715.3658;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;25;-52.54726,-589.066;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-447.9821,-1011.68;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-467.5262,-518.7958;Inherit;False;Constant;_Float1;Float 0;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;26;117.3754,-325.9659;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-428.267,-303.1011;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-576.559,-191.8822;Inherit;False;Constant;_Float2;Float 0;1;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;19;-1246.929,175.8484;Inherit;True;Property;_TextureSample3;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-665.5967,311.7512;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;21;-436.6546,198.1473;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-446.3279,394.7171;Inherit;False;Constant;_Float3;Float 0;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;32;-1283.97,703.5641;Inherit;True;Property;_TextureSample4;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;38;-792.4919,665.7477;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;40;-570.0916,664.1476;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-933.3173,939.8274;Inherit;False;Constant;_Float5;Float 0;1;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;46;-536.8396,1054.342;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;31;251.2771,-68.75757;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;47;377.8499,450.6312;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;48;421.6357,1026.762;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;41;-1250.718,1093.758;Inherit;True;Property;_TextureSample5;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;43;-759.2398,1055.942;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;57;-2583.547,2937.691;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-2625.672,3184.142;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;60;-2384.611,3127.831;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;63;-2030.885,3131.451;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;64;-1703.285,3126.251;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;73;-2625.909,1455.151;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;74;-2493.002,2076.131;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;71;-3222.984,1395.207;Inherit;True;Property;_TextureSample10;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;69;-3178.844,1726.159;Inherit;True;Property;_TextureSample9;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;67;-3205.707,2112.945;Inherit;True;Property;_TextureSample8;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;75;-3373.008,494.6721;Inherit;True;Property;_TextureSample11;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;80;-3041.416,150.9325;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-3527.487,255.9567;Inherit;False;Constant;_Float7;Float 6;24;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;81;-3150.693,64.63654;Inherit;False;Constant;_Float8;Float 6;24;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;-3315.813,159.1491;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;83;-2795.467,194.4925;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-3175.568,260.0804;Inherit;False;Constant;_Float9;Float 6;24;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-3028.59,643.4214;Inherit;False;Constant;_Float10;Float 6;24;0;Create;True;0;0;0;False;0;False;-0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;90;-3011.98,-779.5861;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;92;-3498.052,-674.562;Inherit;False;Constant;_Float11;Float 6;24;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;95;-2766.031,-736.0261;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;97;-2586.95,-733.2463;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;99;-3146.133,-670.4382;Inherit;False;Constant;_Float13;Float 6;24;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;96;-2964.748,-441.3178;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-3341.687,-1293.201;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;107;-3449.952,-1100.48;Inherit;False;Constant;_Color0;Color 0;27;0;Create;True;0;0;0;False;0;False;0,1,0.009106636,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;88;-3343.573,-435.8465;Inherit;True;Property;_TextureSample12;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;108;-2617.584,-1256.334;Inherit;True;Property;_TextureSample13;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-3185.952,-1184.48;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-2219.538,-1178.624;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;94;-3286.377,-771.3695;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;112;-2029.238,-1260.734;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;106;-2953.952,-1197.48;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;113;-2389.694,-1644.526;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;65;-2262.232,3275.114;Inherit;False;Property;_DirtRoughness;Dirt  Roughness;11;0;Create;True;0;0;0;False;0;False;0;0;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-3594.795,-802.9326;Inherit;False;Property;_Veins;Veins;4;0;Create;True;0;0;0;False;0;False;0;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-1896.947,3278.569;Inherit;False;Property;_BloodRoughness;Blood  Roughness;14;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-1049.24,1045.742;Inherit;False;Property;_Blood;Blood;13;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-2703.972,2787.632;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;54;-3272.937,2779.556;Inherit;True;Property;_TextureSample7;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;86;-2599.413,548.8572;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;85;-2616.386,197.2723;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;84;-2891.244,553.3516;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;114;-2746.855,539.8334;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;111;-2332.401,-1063.207;Inherit;False;Constant;_Float14;Float 6;24;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;-2545.448,-1521.806;Inherit;False;Constant;_Float15;Float 6;24;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;116;-2547.448,-1613.806;Inherit;False;Constant;_Float16;Float 6;24;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-3121.258,-865.882;Inherit;False;Constant;_Float12;Float 6;24;0;Create;True;0;0;0;False;0;False;-0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;119;-3107.383,-1286.557;Inherit;False;Constant;_Float18;Float 6;24;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;118;-3526.085,-1242.087;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;117;-3441.085,-1386.087;Inherit;False;Constant;_Float17;Float 6;24;0;Create;True;0;0;0;False;0;False;0.25;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;11;-912.8599,-927.7158;Inherit;False;Property;_ColorSkin_Veins;ColorSkin_Veins;1;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;28;-223.0574,-405.2309;Inherit;False;Property;_TransformDissolveColor;TransformDissolveColor;5;0;Create;True;0;0;0;False;0;False;0.254717,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;23;-889.2633,-14.20277;Inherit;False;Property;_ColorSkin_Transform;ColorSkin_Transform;2;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;35;-1106.569,509.6331;Inherit;False;Constant;_Float4;Float 0;1;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-962.4917,559.5474;Inherit;False;Property;_Dirt;Dirt;10;0;Create;True;0;0;0;False;0;False;0;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;949.2028,757.1902;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Dary_Palasky_Built-in/Transform Shader Built-in;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-2935.276,3255.994;Inherit;False;Property;_Transform_Roughness;Transform_Roughness;8;0;Create;True;0;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-2988.406,2860.891;Inherit;False;Property;_Human_Roughness;Human_Roughness;6;0;Create;True;0;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-2863.893,2966.758;Inherit;False;Property;_Veins_Roughness;Veins_Roughness;7;0;Create;True;0;0;0;False;0;False;0.6459731;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;12;-1501.981,-740.8238;Inherit;True;Property;_BaseColor_2;Base Color_2;16;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;68;-3522.959,2107.701;Inherit;True;Property;_Normal_3;Normal_3;20;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;70;-3508.697,1760;Inherit;True;Property;_Normal_2;Normal_2;19;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.ColorNode;49;85.17549,399.9317;Inherit;False;Property;_DirtColor;DirtColor;9;1;[Header];Create;True;1;___DIRT___;0;0;False;0;False;0.2235294,0.1372549,0.04705883,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;50;163.5293,1029.066;Inherit;False;Property;_BloodColor;Blood Color;12;1;[Header];Create;True;1;___BLOOD___;0;0;False;0;False;0.227451,0,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;78;-3573.337,118.0537;Inherit;False;Property;_Transform;Transform;3;1;[Header];Create;True;1;___TRANSFORM___;0;0;False;0;False;0;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;4;-890.9174,-1420.6;Inherit;False;Property;_ColorSkin_Human;ColorSkin_Human;0;1;[Header];Create;True;1;___SKIN_COLOR___;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;24;-1480.783,172.6893;Inherit;True;Property;_BaseColor_3;Base Color_3;17;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;72;-3511.943,1404.418;Inherit;True;Property;_Normal_1;Normal_1;18;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;55;-3506.79,2775.597;Inherit;True;Property;_Roughness;Roughness;26;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;37;-1517.824,700.405;Inherit;True;Property;_DirtMask;DirtMask;24;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;109;-2878.554,-1445.728;Inherit;True;Property;_DistortionTexture;DistortionTexture;21;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;9659b18079b3cc34187159b658cf85bb;9659b18079b3cc34187159b658cf85bb;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;89;-3632.531,-425.8356;Inherit;True;Property;_Transformmask_1;Transform mask_1;22;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;2;-1482.437,-1232.561;Inherit;True;Property;_BaseColor_1;Base Color_1;15;2;[Header];[NoScaleOffset];Create;True;1;___TEXTURES___;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;42;-1484.572,1091.399;Inherit;True;Property;_BloodMask;BloodMask;25;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;76;-3661.967,504.683;Inherit;True;Property;_Transformmask_2;Transform mask_2;23;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
WireConnection;1;0;2;0
WireConnection;3;0;4;0
WireConnection;3;1;1;0
WireConnection;5;0;1;0
WireConnection;5;1;3;0
WireConnection;5;2;6;0
WireConnection;7;0;12;0
WireConnection;7;1;112;0
WireConnection;8;0;11;0
WireConnection;8;1;7;0
WireConnection;9;0;7;0
WireConnection;9;1;8;0
WireConnection;9;2;10;0
WireConnection;25;0;5;0
WireConnection;25;1;9;0
WireConnection;25;2;97;0
WireConnection;26;0;25;0
WireConnection;26;1;28;0
WireConnection;26;2;29;0
WireConnection;29;0;86;0
WireConnection;29;1;30;0
WireConnection;19;0;24;0
WireConnection;20;0;23;0
WireConnection;20;1;19;0
WireConnection;21;0;19;0
WireConnection;21;1;20;0
WireConnection;21;2;22;0
WireConnection;32;0;37;0
WireConnection;38;0;35;0
WireConnection;38;1;39;0
WireConnection;38;2;32;1
WireConnection;40;0;38;0
WireConnection;46;0;43;0
WireConnection;31;0;26;0
WireConnection;31;1;21;0
WireConnection;31;2;85;0
WireConnection;47;0;31;0
WireConnection;47;1;49;0
WireConnection;47;2;40;0
WireConnection;48;0;47;0
WireConnection;48;1;50;0
WireConnection;48;2;46;0
WireConnection;41;0;42;0
WireConnection;43;0;44;0
WireConnection;43;1;45;0
WireConnection;43;2;41;1
WireConnection;57;0;56;0
WireConnection;57;1;58;0
WireConnection;57;2;97;0
WireConnection;61;0;54;2
WireConnection;61;1;62;0
WireConnection;60;0;57;0
WireConnection;60;1;61;0
WireConnection;60;2;85;0
WireConnection;63;0;60;0
WireConnection;63;1;65;0
WireConnection;63;2;38;0
WireConnection;64;0;63;0
WireConnection;64;1;66;0
WireConnection;64;2;43;0
WireConnection;73;0;71;0
WireConnection;73;1;69;0
WireConnection;73;2;97;0
WireConnection;74;0;73;0
WireConnection;74;1;67;0
WireConnection;74;2;85;0
WireConnection;71;0;72;0
WireConnection;69;0;70;0
WireConnection;69;1;112;0
WireConnection;67;0;68;0
WireConnection;75;0;76;0
WireConnection;80;0;81;0
WireConnection;80;1;77;0
WireConnection;80;2;82;0
WireConnection;77;0;78;0
WireConnection;77;1;79;0
WireConnection;83;0;75;3
WireConnection;83;1;80;0
WireConnection;90;0;93;0
WireConnection;90;1;94;0
WireConnection;90;2;99;0
WireConnection;95;0;96;0
WireConnection;95;1;90;0
WireConnection;97;0;95;0
WireConnection;96;0;88;1
WireConnection;96;1;88;2
WireConnection;104;0;117;0
WireConnection;104;1;118;0
WireConnection;88;0;89;0
WireConnection;108;0;109;0
WireConnection;108;1;106;0
WireConnection;105;0;104;0
WireConnection;105;1;107;0
WireConnection;110;0;108;1
WireConnection;110;1;111;0
WireConnection;94;0;91;0
WireConnection;94;1;92;0
WireConnection;112;0;113;0
WireConnection;112;1;110;0
WireConnection;106;0;119;0
WireConnection;106;1;105;0
WireConnection;113;0;116;0
WireConnection;113;1;115;0
WireConnection;56;0;54;1
WireConnection;56;1;59;0
WireConnection;54;0;55;0
WireConnection;86;0;114;0
WireConnection;85;0;83;0
WireConnection;84;0;75;3
WireConnection;84;1;87;0
WireConnection;114;0;80;0
WireConnection;114;1;84;0
WireConnection;0;0;48;0
WireConnection;0;1;74;0
WireConnection;0;4;64;0
ASEEND*/
//CHKSM=AE1DBD0CE56EDAFC5480B32F107DFB1E2DCE70AF