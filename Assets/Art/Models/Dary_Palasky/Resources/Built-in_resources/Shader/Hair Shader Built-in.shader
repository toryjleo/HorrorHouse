// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Dary_Palasky_Built-in/Hair built-in"
{
	Properties
	{
		[SingleLineTexture]_ColorTexture("ColorTexture", 2D) = "white" {}
		_AlphaClip("Alpha Clip", Range( 0 , 1)) = 0.5
		[SingleLineTexture]_RootTexture("RootTexture", 2D) = "white" {}
		_TipColor("TipColor", Color) = (1,1,1,0)
		_RootColor("RootColor", Color) = (1,1,1,0)
		_RootPower("RootPower", Range( -5 , 1)) = 0.5
		_TipPower("TipPower", Range( -5 , 1)) = 0.5
		_Disappearing_Hair_A("Disappearing_Hair_A", Range( 0 , 2)) = 0
		_Disappearing_Hair_B("Disappearing_Hair_B", Range( 0 , 2)) = 0
		[SingleLineTexture]_OpacityTexture("OpacityTexture", 2D) = "white" {}
		_Roughness("Roughness", Range( 0 , 1)) = 0
		_WindPosition_1("WindPosition_1", Color) = (0,0.2196079,0,1)
		_NormalPower("Normal Power", Range( 0 , 1)) = 0
		_WindPosition_2("WindPosition_2", Color) = (0,0,0.1921569,1)
		_WindEffect("WindEffect", Range( 0 , 25)) = 0
		[Normal][SingleLineTexture]_Normal("Normal", 2D) = "white" {}
		[NoScaleOffset][SingleLineTexture]_FurMap2("AO", 2D) = "white" {}
		_WindMask("WindMask", 2D) = "black" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" }
		Cull Off
		AlphaToMask On
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#define ASE_USING_SAMPLING_MACROS 1
		#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))//ASE Sampler Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
		#define SAMPLE_TEXTURE2D_LOD(tex,samplerTex,coord,lod) tex.SampleLevel(samplerTex,coord, lod)
		#else//ASE Sampling Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex2D(tex,coord)
		#define SAMPLE_TEXTURE2D_LOD(tex,samplerTex,coord,lod) tex2Dlod(tex,float4(coord,0,lod))
		#endif//ASE Sampling Macros

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
			float3 worldPos;
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform float4 _WindPosition_1;
		uniform float4 _WindPosition_2;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_WindMask);
		uniform float4 _WindMask_ST;
		SamplerState sampler_WindMask;
		uniform float _WindEffect;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Normal);
		uniform float4 _Normal_ST;
		SamplerState sampler_Normal;
		uniform float _NormalPower;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_ColorTexture);
		uniform float4 _ColorTexture_ST;
		SamplerState sampler_ColorTexture;
		uniform float4 _TipColor;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_RootTexture);
		uniform float4 _RootTexture_ST;
		SamplerState sampler_RootTexture;
		uniform float _TipPower;
		uniform float4 _RootColor;
		uniform float _RootPower;
		uniform float _Roughness;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_FurMap2);
		SamplerState sampler_FurMap2;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_OpacityTexture);
		uniform float4 _OpacityTexture_ST;
		SamplerState sampler_OpacityTexture;
		uniform float _Disappearing_Hair_A;
		uniform float _Disappearing_Hair_B;
		uniform float _AlphaClip;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float simplePerlin2D94 = snoise( ( ase_worldPos + ( _Time.y * 0.2 ) ).xy*2.0 );
			simplePerlin2D94 = simplePerlin2D94*0.5 + 0.5;
			float simplePerlin2D93 = snoise( ( ase_worldPos + ( ( 1.0 - _Time.y ) * 0.1 ) ).xy*3.0 );
			simplePerlin2D93 = simplePerlin2D93*0.5 + 0.5;
			float lerpResult97 = lerp( simplePerlin2D94 , simplePerlin2D93 , 0.5);
			float4 lerpResult99 = lerp( _WindPosition_1 , _WindPosition_2 , lerpResult97);
			float2 uv_WindMask = v.texcoord * _WindMask_ST.xy + _WindMask_ST.zw;
			v.vertex.xyz = ( float4( ase_vertex3Pos , 0.0 ) + ( ( lerpResult99 * SAMPLE_TEXTURE2D_LOD( _WindMask, sampler_WindMask, uv_WindMask, 0.0 ) ) * _WindEffect ) ).rgb;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float3 NormalMap223 = UnpackScaleNormal( SAMPLE_TEXTURE2D( _Normal, sampler_Normal, uv_Normal ), _NormalPower );
			o.Normal = NormalMap223;
			float2 uv_ColorTexture = i.uv_texcoord * _ColorTexture_ST.xy + _ColorTexture_ST.zw;
			float4 tex2DNode2 = SAMPLE_TEXTURE2D( _ColorTexture, sampler_ColorTexture, uv_ColorTexture );
			float2 uv_RootTexture = i.uv_texcoord * _RootTexture_ST.xy + _RootTexture_ST.zw;
			float4 tex2DNode143 = SAMPLE_TEXTURE2D( _RootTexture, sampler_RootTexture, uv_RootTexture );
			float lerpResult162 = lerp( 0.0 , 1.0 , pow( tex2DNode143.r , ( 1.0 - _TipPower ) ));
			float clampResult165 = clamp( lerpResult162 , 0.0 , 1.0 );
			float4 lerpResult166 = lerp( tex2DNode2 , ( tex2DNode2 * _TipColor ) , clampResult165);
			float lerpResult171 = lerp( 0.0 , 1.0 , pow( ( 1.0 - tex2DNode143.r ) , ( 1.0 - _RootPower ) ));
			float clampResult170 = clamp( lerpResult171 , 0.0 , 1.0 );
			float4 lerpResult174 = lerp( lerpResult166 , ( tex2DNode2 * _RootColor ) , clampResult170);
			o.Albedo = lerpResult174.rgb;
			float3 PixelNormalWorld195 = (WorldNormalVector( i , NormalMap223 ));
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 LightDirection189 = ase_worldlightDir;
			float3 normalizeResult188 = normalize( ( _WorldSpaceCameraPos - ase_worldPos ) );
			float3 ViewDirection190 = normalizeResult188;
			float3 normalizeResult194 = normalize( ( LightDirection189 + ViewDirection190 ) );
			float3 HalfVector196 = normalizeResult194;
			float dotResult197 = dot( PixelNormalWorld195 , HalfVector196 );
			float nDotH198 = dotResult197;
			float2 uv_FurMap2216 = i.uv_texcoord;
			float4 tex2DNode216 = SAMPLE_TEXTURE2D( _FurMap2, sampler_FurMap2, uv_FurMap2216 );
			float dotResult199 = dot( PixelNormalWorld195 , LightDirection189 );
			float nDotL200 = dotResult199;
			o.Smoothness = ( _Roughness + ( ( pow( max( sin( radians( ( ( -1.0 + nDotH198 ) * 180.0 ) ) ) , tex2DNode216.r ) , 64.0 ) * 0.0 ) * nDotL200 ) );
			o.Occlusion = tex2DNode216.g;
			o.Alpha = 1;
			float2 uv_OpacityTexture = i.uv_texcoord * _OpacityTexture_ST.xy + _OpacityTexture_ST.zw;
			float smoothstepResult45 = smoothstep( 0.0 , _Disappearing_Hair_A , ( 1.0 - i.uv_texcoord.y ));
			float smoothstepResult251 = smoothstep( 0.0 , _Disappearing_Hair_B , ( 1.0 - i.uv_texcoord.y ));
			float smoothstepResult258 = smoothstep( 1.0 , 1.0 , i.uv_texcoord.x);
			float lerpResult263 = lerp( ( ( SAMPLE_TEXTURE2D( _OpacityTexture, sampler_OpacityTexture, uv_OpacityTexture ).r * 1.5 ) * pow( smoothstepResult45 , 5.0 ) ) , ( ( SAMPLE_TEXTURE2D( _OpacityTexture, sampler_OpacityTexture, uv_OpacityTexture ).r * 1.5 ) * pow( smoothstepResult251 , 5.0 ) ) , smoothstepResult258);
			clip( lerpResult263 - _AlphaClip );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows dithercrossfade vertex:vertexDataFunc 

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
				vertexDataFunc( v, customInputData );
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
Node;AmplifyShaderEditor.CommentaryNode;226;-3472.735,2341.728;Inherit;False;5002.463;2167.9;Smoothness;23;214;202;211;210;209;205;207;201;206;216;215;213;212;80;198;197;200;199;192;182;181;180;179;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;179;-3123.503,3832.953;Inherit;False;911.5641;491.3683;View Direction Vector;5;190;188;186;184;185;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;180;-2937.734,3455.641;Inherit;False;533.0206;260.4803;Light Direction Vector;2;189;187;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;181;-2235.88,3443.736;Inherit;False;661.2201;238.5203;Halfway Vector;3;196;194;191;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;182;-2947.101,3021.152;Inherit;False;537.9105;289.5802;Pixel Normal Vector;2;220;195;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;187;-2921.734,3487.641;Inherit;True;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;189;-2649.734,3487.641;Float;True;LightDirection;3;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;191;-2187.88,3507.736;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;194;-2059.881,3475.736;Inherit;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;196;-1819.88,3491.736;Float;False;HalfVector;6;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1368.42,-26.48331;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Dary_Palasky_Built-in/Hair built-in;False;False;False;False;False;False;False;False;False;False;False;False;True;False;True;False;False;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Masked;0.5;True;True;0;False;TransparentCutout;;AlphaTest;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Absolute;0;;-1;-1;-1;-1;0;True;0;0;False;;-1;0;True;_AlphaClip;0;0;0;False;0.1;False;;0;False;;True;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;185;-3107.503,3880.953;Inherit;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;184;-3107.503,4056.95;Float;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;186;-2856.329,3940.062;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;188;-2642.048,3938.864;Inherit;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;190;-2400.924,3929.002;Float;True;ViewDirection;4;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;195;-2675.101,3085.152;Float;True;PixelNormalWorld;2;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;220;-2918.131,3079.935;Inherit;True;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;192;-3140.956,3088.639;Inherit;False;223;NormalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;199;-2332.956,3200.686;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;-2086.263,3202.383;Float;False;nDotL;5;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;197;-1486.904,3090.637;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;198;-1232.817,3080.128;Float;False;nDotH;7;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;957.9553,2742.468;Inherit;False;Property;_Roughness;Roughness;11;0;Create;True;0;0;0;False;0;False;0;0.365;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;212;162.6606,3076.365;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;213;420.472,2944.709;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;215;91.10023,2961.898;Float;False;Constant;_AnisotropyFalloff;Anisotropy Falloff;17;0;Create;True;0;0;0;False;1;Header(Anisotropy);False;64;66;1;256;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;216;-334.1787,2755.354;Inherit;True;Property;_FurMap2;AO;17;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;206;723.0926,2939.054;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;201;755.4835,3222.313;Inherit;False;200;nDotL;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;207;1001.092,2921.054;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;205;1266.227,2747.019;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;209;-432.6805,3067.006;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;180;False;1;FLOAT;0
Node;AmplifyShaderEditor.RadiansOpNode;210;-214.4059,3067.006;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;211;-38.40582,3067.006;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;202;-657.2292,3060.839;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;214;-960.5911,3000.68;Float;False;Constant;_AnisotropyOffset;Anisotropy Offset;18;0;Create;True;0;0;0;False;0;False;-1;-0.3;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;225;-3424.864,709.2145;Inherit;False;3672.496;1408.17;Wind effect;31;121;105;109;110;108;104;102;107;106;103;101;100;98;99;97;96;95;94;93;89;92;91;90;88;87;86;85;84;83;82;243;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;82;-2393.066,1119.188;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-2613.888,1149.986;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;84;-2884.809,1144.829;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-2767.809,1270.829;Inherit;False;Constant;_Float8;Float 8;11;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;86;-2743.809,920.8291;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;87;-2418.199,1614.885;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-2639.021,1645.682;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;90;-2792.942,1766.525;Inherit;False;Constant;_Float12;Float 8;11;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;91;-2768.942,1416.525;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;92;-2961.313,1666.629;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;89;-3191.942,1635.525;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;93;-2163.354,1590.626;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;94;-2137.583,1138.231;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-2332.583,1287.231;Inherit;False;Constant;_Float13;Float 13;11;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-2355.583,1502.231;Inherit;False;Constant;_Float14;Float 13;11;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;97;-1705.246,1478.58;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;99;-1244.766,1366.787;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;98;-1906.89,1498.946;Inherit;False;Constant;_Float15;Float 13;11;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;100;-1632.818,1042.144;Inherit;False;Property;_WindPosition_1;WindPosition_1;12;0;Create;True;0;0;0;False;0;False;0,0.2196079,0,1;0,0.2196078,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;101;-1641.59,1220.01;Inherit;False;Property;_WindPosition_2;WindPosition_2;14;0;Create;True;0;0;0;False;0;False;0,0,0.1921569,1;0,0,0.05660379,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-888.8403,1392.558;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;-628.6752,1386.481;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;110;-351.8431,1206.061;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;178;996.3421,77.77844;Inherit;False;Property;_AlphaClip;Alpha Clip;1;0;Create;True;0;0;0;False;0;False;0.5;0.141;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;227;-3453.132,-1761.251;Inherit;False;2182.296;1334.92;Color;25;1;142;177;176;5;166;149;172;175;167;2;12;173;169;168;171;170;174;151;150;164;163;165;162;143;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;228;-5574.549,-807.3833;Inherit;False;2031.678;918.1493;Opacity;13;47;140;55;139;54;66;45;44;141;133;53;43;42;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;229;-3360.825,-2752.173;Inherit;False;1111.434;727.3622;Normal;4;224;123;122;223;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;143;-3116.093,-984.7125;Inherit;True;Property;_TextureSample1;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;162;-2343.722,-1231.593;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;165;-2155.421,-1238.858;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;163;-2527.492,-1320.04;Inherit;False;Constant;_Float4;Float 4;14;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;164;-2530.735,-1245.488;Inherit;False;Constant;_Float5;Float 4;14;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;150;-2519.457,-1117.853;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;151;-3090.159,-1183.755;Inherit;False;Property;_TipPower;TipPower;6;0;Create;True;0;0;0;False;0;False;0.5;-1.73;-5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;174;-1505.422,-1013.421;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;170;-2154.729,-802.6364;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;171;-2324.548,-797.6219;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;168;-2514.837,-863.3441;Inherit;False;Constant;_Float6;Float 4;14;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;169;-2508.864,-784.241;Inherit;False;Constant;_Float7;Float 4;14;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;173;-2507.904,-665.9888;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;12;-2350.748,-1008.005;Inherit;False;Property;_RootColor;RootColor;4;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.4150943,0.2679641,0.06489345,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-2883.323,-1628.663;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;167;-2768.387,-1180.64;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;175;-2721.294,-712.3947;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;172;-2721.851,-612.0861;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;149;-2882.144,-616.5724;Inherit;False;Property;_RootPower;RootPower;5;0;Create;True;0;0;0;False;0;False;0.5;-2.74;-5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;166;-1822.339,-1330.713;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;5;-2412.212,-1432.994;Inherit;False;Property;_TipColor;TipColor;3;0;Create;True;0;0;0;True;0;False;1,1,1,0;1,0.7281962,0.19407,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;176;-2155.665,-1411.533;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;177;-2041.031,-949.1138;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;142;-3380.23,-987.0197;Inherit;True;Property;_RootTexture;RootTexture;2;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;1;-3135.671,-1627.281;Inherit;True;Property;_ColorTexture;ColorTexture;0;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;223;-2542.643,-2472.375;Inherit;True;NormalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;122;-2909.211,-2462.318;Inherit;True;Property;_TextureSample2;Texture Sample 2;15;0;Create;True;0;0;0;False;0;False;123;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;123;-3293.057,-2639.369;Inherit;True;Property;_Normal;Normal;16;2;[Normal];[SingleLineTexture];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;224;-3228.631,-2388.298;Float;False;Property;_NormalPower;Normal Power;13;0;Create;True;0;0;0;False;0;False;0;0.75;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;121;-641.3875,1159.547;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;103;-1009.081,1696.725;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;106;-1314.474,1781.731;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TextureCoordinatesNode;107;-1623.843,1855.019;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;104;-1176.474,1756.731;Inherit;False;Constant;_Float16;Float 16;13;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-1182.474,1848.731;Inherit;False;Constant;_Float17;Float 16;13;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;243;-1164.265,1030.487;Inherit;True;Property;_WindMask;WindMask;18;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;109;-899.7038,1544.765;Inherit;False;Property;_WindEffect;WindEffect;15;0;Create;True;0;0;0;False;0;False;0;0;0;25;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;42;-5248.373,-277.7936;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TextureCoordinatesNode;43;-5520.372,-309.7936;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-3792.371,-405.7938;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;133;-4112.371,-261.7935;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;141;-4208.37,-133.7934;Inherit;False;Constant;_Float0;Float 0;13;0;Create;True;0;0;0;False;0;False;5;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;44;-5024.371,-389.7938;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;45;-4768.369,-357.7937;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-5056.371,-101.7932;Inherit;False;Constant;_Float10;Float 7;5;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;54;-4176.052,-718.679;Inherit;True;Property;_TextureSample3;Texture Sample 2;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-3776.052,-622.6789;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;55;-4480.05,-734.679;Inherit;True;Property;_OpacityTexture;OpacityTexture;10;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;140;-4041.255,-438.9265;Inherit;False;Constant;_Float11;Float 11;14;0;Create;True;0;0;0;False;0;False;1.5;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-5126.672,-23.9529;Inherit;False;Property;_Disappearing_Hair_A;Disappearing_Hair_A;7;0;Create;True;0;0;0;False;0;False;0;1.5;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;244;-5615.219,161.0699;Inherit;False;2031.678;918.1493;Opacity;13;257;256;255;254;253;252;251;250;249;248;247;246;245;;1,1,1,1;0;0
Node;AmplifyShaderEditor.BreakToComponentsNode;245;-5289.043,690.6589;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TextureCoordinatesNode;246;-5561.042,658.6589;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;247;-3833.042,562.6586;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;248;-4153.042,706.659;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;249;-4249.041,834.6591;Inherit;False;Constant;_Float1;Float 0;13;0;Create;True;0;0;0;False;0;False;5;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;250;-5065.042,578.6586;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;251;-4809.04,610.6588;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;252;-5097.042,866.6592;Inherit;False;Constant;_Float18;Float 7;5;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;253;-4216.722,249.7743;Inherit;True;Property;_TextureSample4;Texture Sample 2;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;254;-3816.723,345.7744;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;255;-4520.72,233.7743;Inherit;True;Property;_OpacityTexture1;OpacityTexture;9;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;256;-4081.925,529.5259;Inherit;False;Constant;_Float19;Float 11;14;0;Create;True;0;0;0;False;0;False;1.5;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;257;-5167.342,944.5001;Inherit;False;Property;_Disappearing_Hair_B;Disappearing_Hair_B;8;0;Create;True;0;0;0;False;0;False;0;1.5;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;258;-2956.638,82.22432;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;261;-3068.198,215.9723;Inherit;False;Constant;_Float2;Float 2;19;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;259;-3365.718,121.5816;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;260;-3134.496,97.00076;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.LerpOp;263;-2590.219,15.08233;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
WireConnection;189;0;187;0
WireConnection;191;0;189;0
WireConnection;191;1;190;0
WireConnection;194;0;191;0
WireConnection;196;0;194;0
WireConnection;0;0;174;0
WireConnection;0;1;223;0
WireConnection;0;4;205;0
WireConnection;0;5;216;2
WireConnection;0;10;263;0
WireConnection;0;11;110;0
WireConnection;186;0;185;0
WireConnection;186;1;184;0
WireConnection;188;0;186;0
WireConnection;190;0;188;0
WireConnection;195;0;220;0
WireConnection;220;0;192;0
WireConnection;199;0;195;0
WireConnection;199;1;189;0
WireConnection;200;0;199;0
WireConnection;197;0;195;0
WireConnection;197;1;196;0
WireConnection;198;0;197;0
WireConnection;212;0;211;0
WireConnection;212;1;216;1
WireConnection;213;0;212;0
WireConnection;213;1;215;0
WireConnection;206;0;213;0
WireConnection;207;0;206;0
WireConnection;207;1;201;0
WireConnection;205;0;80;0
WireConnection;205;1;207;0
WireConnection;209;0;202;0
WireConnection;210;0;209;0
WireConnection;211;0;210;0
WireConnection;202;0;214;0
WireConnection;202;1;198;0
WireConnection;82;0;86;0
WireConnection;82;1;83;0
WireConnection;83;0;84;0
WireConnection;83;1;85;0
WireConnection;87;0;91;0
WireConnection;87;1;88;0
WireConnection;88;0;92;0
WireConnection;88;1;90;0
WireConnection;92;0;89;0
WireConnection;93;0;87;0
WireConnection;93;1;96;0
WireConnection;94;0;82;0
WireConnection;94;1;95;0
WireConnection;97;0;94;0
WireConnection;97;1;93;0
WireConnection;97;2;98;0
WireConnection;99;0;100;0
WireConnection;99;1;101;0
WireConnection;99;2;97;0
WireConnection;102;0;99;0
WireConnection;102;1;243;0
WireConnection;108;0;102;0
WireConnection;108;1;109;0
WireConnection;110;0;121;0
WireConnection;110;1;108;0
WireConnection;143;0;142;0
WireConnection;162;0;163;0
WireConnection;162;1;164;0
WireConnection;162;2;150;0
WireConnection;165;0;162;0
WireConnection;150;0;143;1
WireConnection;150;1;167;0
WireConnection;174;0;166;0
WireConnection;174;1;177;0
WireConnection;174;2;170;0
WireConnection;170;0;171;0
WireConnection;171;0;168;0
WireConnection;171;1;169;0
WireConnection;171;2;173;0
WireConnection;173;0;175;0
WireConnection;173;1;172;0
WireConnection;2;0;1;0
WireConnection;167;0;151;0
WireConnection;175;0;143;1
WireConnection;172;0;149;0
WireConnection;166;0;2;0
WireConnection;166;1;176;0
WireConnection;166;2;165;0
WireConnection;176;0;2;0
WireConnection;176;1;5;0
WireConnection;177;0;2;0
WireConnection;177;1;12;0
WireConnection;223;0;122;0
WireConnection;122;0;123;0
WireConnection;122;5;224;0
WireConnection;103;0;106;1
WireConnection;103;1;104;0
WireConnection;103;2;105;0
WireConnection;106;0;107;0
WireConnection;42;0;43;0
WireConnection;53;0;139;0
WireConnection;53;1;133;0
WireConnection;133;0;45;0
WireConnection;133;1;141;0
WireConnection;44;0;42;1
WireConnection;45;0;44;0
WireConnection;45;1;66;0
WireConnection;45;2;47;0
WireConnection;54;0;55;0
WireConnection;139;0;54;1
WireConnection;139;1;140;0
WireConnection;245;0;246;0
WireConnection;247;0;254;0
WireConnection;247;1;248;0
WireConnection;248;0;251;0
WireConnection;248;1;249;0
WireConnection;250;0;245;1
WireConnection;251;0;250;0
WireConnection;251;1;252;0
WireConnection;251;2;257;0
WireConnection;253;0;55;0
WireConnection;254;0;253;1
WireConnection;254;1;256;0
WireConnection;258;0;260;0
WireConnection;258;1;261;0
WireConnection;258;2;261;0
WireConnection;260;0;259;0
WireConnection;263;0;53;0
WireConnection;263;1;247;0
WireConnection;263;2;258;0
ASEEND*/
//CHKSM=F9768DAABC86DEC39B3A251C11544F24E6048CAF