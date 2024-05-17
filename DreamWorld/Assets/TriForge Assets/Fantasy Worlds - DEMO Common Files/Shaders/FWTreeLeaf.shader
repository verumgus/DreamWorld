// Made with Amplify Shader Editor v1.9.2.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TriForge/Fantasy Worlds/FWTreeLeaf"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_BaseColor("Base Color", 2D) = "white" {}
		_BendingMaskStrength1("Bending Mask Strength", Range( 0.05 , 2)) = 1.236128
		_NormalMap("Normal Map", 2D) = "bump" {}
		_NormalScale("Normal Scale", Float) = 1
		[Toggle(_TFW_FLIPNORMALS)] _FlipBackNormals("Flip Back Normals", Float) = 0
		_LeafFlutterStrength("Leaf Flutter Strength", Range( 0 , 2)) = 0.3
		_WindOverallStrength("Wind Overall Strength", Range( 0 , 1)) = 1
		_ParentWindStrength("Parent Wind Strength", Range( 0 , 2)) = 0.5
		_ParentWindMapScale("Parent Wind Map Scale", Range( 0 , 5)) = 1
		_AOIntensity("AO Intensity", Range( 0 , 1)) = 1
		_MaskClip("Mask Clip", Range( 0 , 1)) = 0.5588235
		[Toggle(_DISTANCEBASEDMASKCLIP_ON)] _DistanceBasedMaskClip("Distance Based Mask Clip", Float) = 1
		_Color("Color", Color) = (1,1,1,0)
		_VertexAOIntensity("Vertex AO Intensity", Range( 0 , 1)) = 1
		_BaseColorSaturation("Base Color Saturation", Range( 0 , 1)) = 1
		_ChildWindStrength("Child Wind Strength", Range( 0 , 2)) = 0.5
		_ChildWindMapScale("Child Wind Map Scale", Range( 0 , 5)) = 0
		_MainWindStrength("Main Wind Strength", Range( 0 , 2)) = 0.5
		_MainWindScale("Main Wind Scale", Range( 0 , 1)) = 1
		_MainBendMaskStrength("Main Bend Mask Strength", Range( 0 , 5)) = 0
		_Undercolor("Undercolor", Color) = (1,1,1,0)
		_UndercolorAmount("Undercolor Amount", Range( 0 , 1)) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}


		//_TransmissionShadow( "Transmission Shadow", Range( 0, 1 ) ) = 0.5
		_TransStrength( "Strength", Range( 0, 50 ) ) = 1
		_TransNormal( "Normal Distortion", Range( 0, 1 ) ) = 0.5
		_TransScattering( "Scattering", Range( 1, 50 ) ) = 2
		_TransDirect( "Direct", Range( 0, 1 ) ) = 0.9
		_TransAmbient( "Ambient", Range( 0, 1 ) ) = 0.1
		_TransShadow( "Shadow", Range( 0, 1 ) ) = 0.5
		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		[HideInInspector][ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[HideInInspector][ToggleOff] _EnvironmentReflections("Environment Reflections", Float) = 1.0
		[HideInInspector][ToggleOff] _ReceiveShadows("Receive Shadows", Float) = 1.0

		[HideInInspector] _QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector] _QueueControl("_QueueControl", Float) = -1

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" "UniversalMaterialType"="Lit" "DisableBatching"="True" }

		Cull Off
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 4.5
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}

		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForwardOnly" "DisableBatching"="True" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#define ASE_TRANSLUCENCY 1
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 140009


			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile_fragment _ _LIGHT_LAYERS
			#pragma multi_compile_fragment _ _LIGHT_COOKIES
			#pragma multi_compile _ _FORWARD_PLUS

			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile_fragment _ DEBUG_DISPLAY
			#pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_FORWARD

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
				#define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature _TFW_FLIPNORMALS
			#pragma shader_feature_local _DISTANCEBASEDMASKCLIP_ON
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				ASE_SV_POSITION_QUALIFIERS float4 clipPos : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float4 lightmapUVOrVertexSH : TEXCOORD1;
				half4 fogFactorAndVertexLight : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					float4 shadowCoord : TEXCOORD6;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					float2 dynamicLightmapUV : TEXCOORD7;
				#endif
				float4 ase_texcoord8 : TEXCOORD8;
				float4 ase_texcoord9 : TEXCOORD9;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Undercolor;
			float4 _NormalMap_ST;
			float4 _Color;
			float4 _BaseColor_ST;
			float _VertexAOIntensity;
			float _Smoothness;
			float _NormalScale;
			float _UndercolorAmount;
			float _BaseColorSaturation;
			float _AOIntensity;
			float _ChildWindMapScale;
			float _WindOverallStrength;
			float _MainWindStrength;
			float _MainWindScale;
			float _MainBendMaskStrength;
			float _ParentWindStrength;
			float _ParentWindMapScale;
			float _BendingMaskStrength1;
			float _ChildWindStrength;
			float _LeafFlutterStrength;
			float _MaskClip;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float3 TF_WIND_DIRECTION;
			float TF_WIND_STRENGTH;
			sampler2D _BaseColor;
			sampler2D _NormalMap;


			real3 ASESafeNormalize(float3 inVec)
			{
				real dp3 = max(FLT_MIN, dot(inVec, inVec));
				return inVec* rsqrt( dp3);
			}
			
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
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 appendResult18_g1 = (float3(( -1.0 * v.texcoord2.y ) , ( -1.0 * v.ase_texcoord3.y ) , v.ase_texcoord3.x));
				float3 temp_output_20_0_g1 = ( 0.001 * appendResult18_g1 );
				float dotResult16_g1 = dot( temp_output_20_0_g1 , temp_output_20_0_g1 );
				float ifLocalVar182_g1 = 0;
				if( dotResult16_g1 > 0.0001 )
				ifLocalVar182_g1 = 1.0;
				else if( dotResult16_g1 < 0.0001 )
				ifLocalVar182_g1 = 0.0;
				float ChildMask26_g1 = saturate( ( ifLocalVar182_g1 * 100.0 ) );
				float SelfBendMask34_g1 = ( 1.0 - v.ase_texcoord4.y );
				float ifLocalVar220 = 0;
				if( TF_WIND_DIRECTION.x == 0.0 )
				ifLocalVar220 = 0.0;
				else
				ifLocalVar220 = 1.0;
				float ifLocalVar221 = 0;
				if( TF_WIND_DIRECTION.z == 0.0 )
				ifLocalVar221 = 0.0;
				else
				ifLocalVar221 = 1.0;
				float3 lerpResult250 = lerp( float3(0,0,1) , TF_WIND_DIRECTION , ( ifLocalVar220 + ifLocalVar221 ));
				float3 worldToObjDir226 = ASESafeNormalize( mul( GetWorldToObjectMatrix(), float4( lerpResult250, 0 ) ).xyz );
				float3 WindDir225 = worldToObjDir226;
				float3 WindVector226_g1 = WindDir225;
				float3 appendResult11_g1 = (float3(( -1.0 * v.texcoord1.x ) , v.texcoord2.x , ( -1.0 * v.texcoord1.y )));
				float3 temp_output_19_0_g1 = ( 0.001 * appendResult11_g1 );
				float3 SelfPivot28_g1 = temp_output_19_0_g1;
				float3 objToWorld54_g1 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float2 temp_cast_0 = ((( ( SelfPivot28_g1 * 1.0 ) + ( objToWorld54_g1 / -2.0 ) )).z).xx;
				float2 panner48_g1 = ( 1.0 * _Time.y * float2( 0,0.85 ) + temp_cast_0);
				float simplePerlin2D53_g1 = snoise( panner48_g1*_ChildWindMapScale );
				simplePerlin2D53_g1 = simplePerlin2D53_g1*0.5 + 0.5;
				float ChildRotation43_g1 = radians( ( simplePerlin2D53_g1 * 12.0 * _ChildWindStrength ) );
				float3 rotatedValue81_g1 = RotateAroundAxis( SelfPivot28_g1, v.vertex.xyz, normalize( WindVector226_g1 ), ChildRotation43_g1 );
				float3 ChildRotationResult119_g1 = ( ( ChildMask26_g1 * SelfBendMask34_g1 ) * ( rotatedValue81_g1 - v.vertex.xyz ) );
				float temp_output_113_0_g1 = saturate( ( 4.0 * pow( SelfBendMask34_g1 , _BendingMaskStrength1 ) ) );
				float dotResult9_g1 = dot( temp_output_19_0_g1 , temp_output_19_0_g1 );
				float ifLocalVar189_g1 = 0;
				if( dotResult9_g1 > 0.0001 )
				ifLocalVar189_g1 = 1.0;
				else if( dotResult9_g1 < 0.0001 )
				ifLocalVar189_g1 = 0.0;
				float TrunkMask29_g1 = saturate( ( ifLocalVar189_g1 * 1000.0 ) );
				float3 ParentPivot27_g1 = temp_output_20_0_g1;
				float3 lerpResult51_g1 = lerp( SelfPivot28_g1 , ParentPivot27_g1 , ChildMask26_g1);
				float2 temp_cast_1 = ((lerpResult51_g1).z).xx;
				float2 panner61_g1 = ( 1.0 * _Time.y * float2( 0,0.45 ) + temp_cast_1);
				float simplePerlin2D60_g1 = snoise( panner61_g1*_ParentWindMapScale );
				simplePerlin2D60_g1 = simplePerlin2D60_g1*0.5 + 0.5;
				float saferPower185_g1 = abs( simplePerlin2D60_g1 );
				float ParentRotation63_g1 = radians( ( pow( saferPower185_g1 , 3.0 ) * 25.0 * _ParentWindStrength ) );
				float3 lerpResult98_g1 = lerp( SelfPivot28_g1 , ParentPivot27_g1 , ChildMask26_g1);
				float3 rotatedValue96_g1 = RotateAroundAxis( lerpResult98_g1, ( ChildRotationResult119_g1 + v.vertex.xyz ), normalize( WindVector226_g1 ), ParentRotation63_g1 );
				float saferPower160_g1 = abs( v.ase_texcoord4.x );
				float MainBendMask35_g1 = saturate( pow( saferPower160_g1 , _MainBendMaskStrength ) );
				float3 ParentRotationResult131_g1 = ( ChildRotationResult119_g1 + ( ( ( ( ( temp_output_113_0_g1 * ( 1.0 - ChildMask26_g1 ) ) + ChildMask26_g1 ) * TrunkMask29_g1 ) * ( rotatedValue96_g1 - v.vertex.xyz ) ) * MainBendMask35_g1 ) );
				float3 objToWorld47_g1 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 saferPower172_g1 = abs( ( objToWorld47_g1 / ( -15.0 * _MainWindScale ) ) );
				float2 panner71_g1 = ( 1.0 * _Time.y * float2( 0,0.07 ) + (pow( saferPower172_g1 , 2.0 )).xz);
				float simplePerlin2D70_g1 = snoise( panner71_g1*2.0 );
				simplePerlin2D70_g1 = simplePerlin2D70_g1*0.5 + 0.5;
				float MainRotation67_g1 = radians( ( simplePerlin2D70_g1 * 25.0 * _MainWindStrength ) );
				float3 temp_output_125_0_g1 = ( ParentRotationResult131_g1 + v.vertex.xyz );
				float3 rotatedValue121_g1 = RotateAroundAxis( float3(0,0,0), temp_output_125_0_g1, normalize( WindVector226_g1 ), MainRotation67_g1 );
				float temp_output_148_0_g1 = pow( MainBendMask35_g1 , 5.0 );
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float2 panner86 = ( 1.0 * _Time.y * float2( -0.2,0.4 ) + (( ase_worldPos / -8.0 )).xz);
				float simplePerlin2D85 = snoise( panner86*10.0 );
				simplePerlin2D85 = simplePerlin2D85*0.5 + 0.5;
				
				float3 vertexToFrag194 = v.ase_normal;
				o.ase_texcoord9.xyz = vertexToFrag194;
				
				o.ase_texcoord8.xy = v.texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord8.zw = 0;
				o.ase_texcoord9.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( ( ( ParentRotationResult131_g1 + ( ( rotatedValue121_g1 - temp_output_125_0_g1 ) * temp_output_148_0_g1 ) ) * _WindOverallStrength * TF_WIND_STRENGTH ) + ( _LeafFlutterStrength * ( v.texcoord.y * simplePerlin2D85 ) * TF_WIND_STRENGTH * 0.6 ) );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				#endif

				#if !defined(LIGHTMAP_ON)
					OUTPUT_SH( normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz );
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					o.dynamicLightmapUV.xy = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					o.lightmapUVOrVertexSH.zw = v.texcoord.xy;
					o.lightmapUVOrVertexSH.xy = v.texcoord.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );

				#ifdef ASE_FOG
					half fogFactor = ComputeFogFactor( positionCS.z );
				#else
					half fogFactor = 0;
				#endif

				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;
				o.clipPosV = positionCS;
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_tangent = v.ase_tangent;
				o.texcoord = v.texcoord;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				o.texcoord = v.texcoord;
				o.ase_texcoord3 = v.ase_texcoord3;
				o.ase_texcoord4 = v.ase_texcoord4;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				o.ase_texcoord3 = patch[0].ase_texcoord3 * bary.x + patch[1].ase_texcoord3 * bary.y + patch[2].ase_texcoord3 * bary.z;
				o.ase_texcoord4 = patch[0].ase_texcoord4 * bary.x + patch[1].ase_texcoord4 * bary.y + patch[2].ase_texcoord4 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						#ifdef _WRITE_RENDERING_LAYERS
						, out float4 outRenderingLayers : SV_Target1
						#endif
						, bool ase_vface : SV_IsFrontFace ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float2 sampleCoords = (IN.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
				#else
					float3 WorldNormal = normalize( IN.tSpace0.xyz );
					float3 WorldTangent = IN.tSpace1.xyz;
					float3 WorldBiTangent = IN.tSpace2.xyz;
				#endif

				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				float2 NormalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.clipPos);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#endif

				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float2 uv_BaseColor = IN.ase_texcoord8.xy * _BaseColor_ST.xy + _BaseColor_ST.zw;
				float4 tex2DNode1 = tex2D( _BaseColor, uv_BaseColor );
				float4 BaseColor33 = tex2DNode1;
				float3 desaturateInitialColor183 = BaseColor33.rgb;
				float desaturateDot183 = dot( desaturateInitialColor183, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar183 = lerp( desaturateInitialColor183, desaturateDot183.xxx, ( 1.0 - _BaseColorSaturation ) );
				float3 vertexToFrag194 = IN.ase_texcoord9.xyz;
				float4 lerpResult186 = lerp( ( _Undercolor * float4( desaturateVar183 , 0.0 ) ) , ( _Color * float4( desaturateVar183 , 0.0 ) ) , saturate( ( vertexToFrag194.y - ( _UndercolorAmount * -2.0 ) ) ));
				float4 FinalColor37 = lerpResult186;
				
				float2 uv_NormalMap = IN.ase_texcoord8.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
				float3 unpack11 = UnpackNormalScale( tex2D( _NormalMap, uv_NormalMap ), _NormalScale );
				unpack11.z = lerp( 1, unpack11.z, saturate(_NormalScale) );
				float3 tex2DNode11 = unpack11;
				float3 break4 = tex2DNode11;
				float switchResult9 = (((ase_vface>0)?(break4.z):(-break4.z)));
				float3 appendResult6 = (float3(break4.x , break4.y , switchResult9));
				#ifdef _TFW_FLIPNORMALS
				float3 staticSwitch7 = appendResult6;
				#else
				float3 staticSwitch7 = tex2DNode11;
				#endif
				float3 FinalNormal8 = staticSwitch7;
				
				float Opacity34 = tex2DNode1.a;
				
				float lerpResult167 = lerp( _MaskClip , ( _MaskClip * 0.4 ) , ( distance( WorldPosition , _WorldSpaceCameraPos ) / 150.0 ));
				#ifdef _DISTANCEBASEDMASKCLIP_ON
				float staticSwitch196 = lerpResult167;
				#else
				float staticSwitch196 = _MaskClip;
				#endif
				float Mask_Clip157 = staticSwitch196;
				

				float3 BaseColor = FinalColor37.rgb;
				float3 Normal = FinalNormal8;
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = 0;
				float Smoothness = _Smoothness;
				float Occlusion = saturate( ( saturate( ( ( 1.0 - _VertexAOIntensity ) + IN.ase_color.r ) ) + ( 1.0 - _AOIntensity ) ) );
				float Alpha = Opacity34;
				float AlphaClipThreshold = Mask_Clip157;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = IN.clipPos.z;
				#endif

				#ifdef _CLEARCOAT
					float CoatMask = 0;
					float CoatSmoothness = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData = (InputData)0;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;

				#ifdef _NORMALMAP
						#if _NORMAL_DROPOFF_TS
							inputData.normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
						#elif _NORMAL_DROPOFF_OS
							inputData.normalWS = TransformObjectToWorldNormal(Normal);
						#elif _NORMAL_DROPOFF_WS
							inputData.normalWS = Normal;
						#endif
					inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				#else
					inputData.normalWS = WorldNormal;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					inputData.shadowCoord = ShadowCoords;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
				#else
					inputData.shadowCoord = float4(0, 0, 0, 0);
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = IN.fogFactorAndVertexLight.x;
				#endif
					inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = IN.lightmapUVOrVertexSH.xyz;
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					inputData.bakedGI = SAMPLE_GI(IN.lightmapUVOrVertexSH.xy, IN.dynamicLightmapUV.xy, SH, inputData.normalWS);
				#else
					inputData.bakedGI = SAMPLE_GI(IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS);
				#endif

				#ifdef ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif

				inputData.normalizedScreenSpaceUV = NormalizedScreenSpaceUV;
				inputData.shadowMask = SAMPLE_SHADOWMASK(IN.lightmapUVOrVertexSH.xy);

				#if defined(DEBUG_DISPLAY)
					#if defined(DYNAMICLIGHTMAP_ON)
						inputData.dynamicLightmapUV = IN.dynamicLightmapUV.xy;
					#endif
					#if defined(LIGHTMAP_ON)
						inputData.staticLightmapUV = IN.lightmapUVOrVertexSH.xy;
					#else
						inputData.vertexSH = SH;
					#endif
				#endif

				SurfaceData surfaceData;
				surfaceData.albedo              = BaseColor;
				surfaceData.metallic            = saturate(Metallic);
				surfaceData.specular            = Specular;
				surfaceData.smoothness          = saturate(Smoothness),
				surfaceData.occlusion           = Occlusion,
				surfaceData.emission            = Emission,
				surfaceData.alpha               = saturate(Alpha);
				surfaceData.normalTS            = Normal;
				surfaceData.clearCoatMask       = 0;
				surfaceData.clearCoatSmoothness = 1;

				#ifdef _CLEARCOAT
					surfaceData.clearCoatMask       = saturate(CoatMask);
					surfaceData.clearCoatSmoothness = saturate(CoatSmoothness);
				#endif

				#ifdef _DBUFFER
					ApplyDecalToSurfaceData(IN.clipPos, surfaceData, inputData);
				#endif

				half4 color = UniversalFragmentPBR( inputData, surfaceData);

				#ifdef ASE_TRANSMISSION
				{
					float shadow = _TransmissionShadow;

					#define SUM_LIGHT_TRANSMISSION(Light)\
						float3 atten = Light.color * Light.distanceAttenuation;\
						atten = lerp( atten, atten * Light.shadowAttenuation, shadow );\
						half3 transmission = max( 0, -dot( inputData.normalWS, Light.direction ) ) * atten * Transmission;\
						color.rgb += BaseColor * transmission;

					SUM_LIGHT_TRANSMISSION( GetMainLight( inputData.shadowCoord ) );

					#if defined(_ADDITIONAL_LIGHTS)
						uint meshRenderingLayers = GetMeshRenderingLayer();
						uint pixelLightCount = GetAdditionalLightsCount();
						#if USE_FORWARD_PLUS
							for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
							{
								FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK

								Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
								#ifdef _LIGHT_LAYERS
								if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
								#endif
								{
									SUM_LIGHT_TRANSMISSION( light );
								}
							}
						#endif
						LIGHT_LOOP_BEGIN( pixelLightCount )
							Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
							#ifdef _LIGHT_LAYERS
							if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
							#endif
							{
								SUM_LIGHT_TRANSMISSION( light );
							}
						LIGHT_LOOP_END
					#endif
				}
				#endif

				#ifdef ASE_TRANSLUCENCY
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _TransStrength;

					#define SUM_LIGHT_TRANSLUCENCY(Light)\
						float3 atten = Light.color * Light.distanceAttenuation;\
						atten = lerp( atten, atten * Light.shadowAttenuation, shadow );\
						half3 lightDir = Light.direction + inputData.normalWS * normal;\
						half VdotL = pow( saturate( dot( inputData.viewDirectionWS, -lightDir ) ), scattering );\
						half3 translucency = atten * ( VdotL * direct + inputData.bakedGI * ambient ) * Translucency;\
						color.rgb += BaseColor * translucency * strength;

					SUM_LIGHT_TRANSLUCENCY( GetMainLight( inputData.shadowCoord ) );

					#if defined(_ADDITIONAL_LIGHTS)
						uint meshRenderingLayers = GetMeshRenderingLayer();
						uint pixelLightCount = GetAdditionalLightsCount();
						#if USE_FORWARD_PLUS
							for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
							{
								FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK

								Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
								#ifdef _LIGHT_LAYERS
								if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
								#endif
								{
									SUM_LIGHT_TRANSLUCENCY( light );
								}
							}
						#endif
						LIGHT_LOOP_BEGIN( pixelLightCount )
							Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
							#ifdef _LIGHT_LAYERS
							if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
							#endif
							{
								SUM_LIGHT_TRANSLUCENCY( light );
							}
						LIGHT_LOOP_END
					#endif
				}
				#endif

				#ifdef ASE_REFRACTION
					float4 projScreenPos = ScreenPos / ScreenPos.w;
					float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, float4( WorldNormal,0 ) ).xyz * ( 1.0 - dot( WorldNormal, WorldViewDirection ) );
					projScreenPos.xy += refractionOffset.xy;
					float3 refraction = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos.xy ) * RefractionColor;
					color.rgb = lerp( refraction, color.rgb, color.a );
					color.a = 1;
				#endif

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
					#else
						color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
					#endif
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
				#endif

				return color;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off
			ColorMask 0

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#define ASE_FOG 1
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#define ASE_TRANSLUCENCY 1
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 140009


			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature_local _DISTANCEBASEDMASKCLIP_ON
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				ASE_SV_POSITION_QUALIFIERS float4 clipPos : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD1;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD2;
				#endif				
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Undercolor;
			float4 _NormalMap_ST;
			float4 _Color;
			float4 _BaseColor_ST;
			float _VertexAOIntensity;
			float _Smoothness;
			float _NormalScale;
			float _UndercolorAmount;
			float _BaseColorSaturation;
			float _AOIntensity;
			float _ChildWindMapScale;
			float _WindOverallStrength;
			float _MainWindStrength;
			float _MainWindScale;
			float _MainBendMaskStrength;
			float _ParentWindStrength;
			float _ParentWindMapScale;
			float _BendingMaskStrength1;
			float _ChildWindStrength;
			float _LeafFlutterStrength;
			float _MaskClip;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float3 TF_WIND_DIRECTION;
			float TF_WIND_STRENGTH;
			sampler2D _BaseColor;


			real3 ASESafeNormalize(float3 inVec)
			{
				real dp3 = max(FLT_MIN, dot(inVec, inVec));
				return inVec* rsqrt( dp3);
			}
			
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
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			float3 _LightDirection;
			float3 _LightPosition;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 appendResult18_g1 = (float3(( -1.0 * v.ase_texcoord2.y ) , ( -1.0 * v.ase_texcoord3.y ) , v.ase_texcoord3.x));
				float3 temp_output_20_0_g1 = ( 0.001 * appendResult18_g1 );
				float dotResult16_g1 = dot( temp_output_20_0_g1 , temp_output_20_0_g1 );
				float ifLocalVar182_g1 = 0;
				if( dotResult16_g1 > 0.0001 )
				ifLocalVar182_g1 = 1.0;
				else if( dotResult16_g1 < 0.0001 )
				ifLocalVar182_g1 = 0.0;
				float ChildMask26_g1 = saturate( ( ifLocalVar182_g1 * 100.0 ) );
				float SelfBendMask34_g1 = ( 1.0 - v.ase_texcoord4.y );
				float ifLocalVar220 = 0;
				if( TF_WIND_DIRECTION.x == 0.0 )
				ifLocalVar220 = 0.0;
				else
				ifLocalVar220 = 1.0;
				float ifLocalVar221 = 0;
				if( TF_WIND_DIRECTION.z == 0.0 )
				ifLocalVar221 = 0.0;
				else
				ifLocalVar221 = 1.0;
				float3 lerpResult250 = lerp( float3(0,0,1) , TF_WIND_DIRECTION , ( ifLocalVar220 + ifLocalVar221 ));
				float3 worldToObjDir226 = ASESafeNormalize( mul( GetWorldToObjectMatrix(), float4( lerpResult250, 0 ) ).xyz );
				float3 WindDir225 = worldToObjDir226;
				float3 WindVector226_g1 = WindDir225;
				float3 appendResult11_g1 = (float3(( -1.0 * v.ase_texcoord1.x ) , v.ase_texcoord2.x , ( -1.0 * v.ase_texcoord1.y )));
				float3 temp_output_19_0_g1 = ( 0.001 * appendResult11_g1 );
				float3 SelfPivot28_g1 = temp_output_19_0_g1;
				float3 objToWorld54_g1 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float2 temp_cast_0 = ((( ( SelfPivot28_g1 * 1.0 ) + ( objToWorld54_g1 / -2.0 ) )).z).xx;
				float2 panner48_g1 = ( 1.0 * _Time.y * float2( 0,0.85 ) + temp_cast_0);
				float simplePerlin2D53_g1 = snoise( panner48_g1*_ChildWindMapScale );
				simplePerlin2D53_g1 = simplePerlin2D53_g1*0.5 + 0.5;
				float ChildRotation43_g1 = radians( ( simplePerlin2D53_g1 * 12.0 * _ChildWindStrength ) );
				float3 rotatedValue81_g1 = RotateAroundAxis( SelfPivot28_g1, v.vertex.xyz, normalize( WindVector226_g1 ), ChildRotation43_g1 );
				float3 ChildRotationResult119_g1 = ( ( ChildMask26_g1 * SelfBendMask34_g1 ) * ( rotatedValue81_g1 - v.vertex.xyz ) );
				float temp_output_113_0_g1 = saturate( ( 4.0 * pow( SelfBendMask34_g1 , _BendingMaskStrength1 ) ) );
				float dotResult9_g1 = dot( temp_output_19_0_g1 , temp_output_19_0_g1 );
				float ifLocalVar189_g1 = 0;
				if( dotResult9_g1 > 0.0001 )
				ifLocalVar189_g1 = 1.0;
				else if( dotResult9_g1 < 0.0001 )
				ifLocalVar189_g1 = 0.0;
				float TrunkMask29_g1 = saturate( ( ifLocalVar189_g1 * 1000.0 ) );
				float3 ParentPivot27_g1 = temp_output_20_0_g1;
				float3 lerpResult51_g1 = lerp( SelfPivot28_g1 , ParentPivot27_g1 , ChildMask26_g1);
				float2 temp_cast_1 = ((lerpResult51_g1).z).xx;
				float2 panner61_g1 = ( 1.0 * _Time.y * float2( 0,0.45 ) + temp_cast_1);
				float simplePerlin2D60_g1 = snoise( panner61_g1*_ParentWindMapScale );
				simplePerlin2D60_g1 = simplePerlin2D60_g1*0.5 + 0.5;
				float saferPower185_g1 = abs( simplePerlin2D60_g1 );
				float ParentRotation63_g1 = radians( ( pow( saferPower185_g1 , 3.0 ) * 25.0 * _ParentWindStrength ) );
				float3 lerpResult98_g1 = lerp( SelfPivot28_g1 , ParentPivot27_g1 , ChildMask26_g1);
				float3 rotatedValue96_g1 = RotateAroundAxis( lerpResult98_g1, ( ChildRotationResult119_g1 + v.vertex.xyz ), normalize( WindVector226_g1 ), ParentRotation63_g1 );
				float saferPower160_g1 = abs( v.ase_texcoord4.x );
				float MainBendMask35_g1 = saturate( pow( saferPower160_g1 , _MainBendMaskStrength ) );
				float3 ParentRotationResult131_g1 = ( ChildRotationResult119_g1 + ( ( ( ( ( temp_output_113_0_g1 * ( 1.0 - ChildMask26_g1 ) ) + ChildMask26_g1 ) * TrunkMask29_g1 ) * ( rotatedValue96_g1 - v.vertex.xyz ) ) * MainBendMask35_g1 ) );
				float3 objToWorld47_g1 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 saferPower172_g1 = abs( ( objToWorld47_g1 / ( -15.0 * _MainWindScale ) ) );
				float2 panner71_g1 = ( 1.0 * _Time.y * float2( 0,0.07 ) + (pow( saferPower172_g1 , 2.0 )).xz);
				float simplePerlin2D70_g1 = snoise( panner71_g1*2.0 );
				simplePerlin2D70_g1 = simplePerlin2D70_g1*0.5 + 0.5;
				float MainRotation67_g1 = radians( ( simplePerlin2D70_g1 * 25.0 * _MainWindStrength ) );
				float3 temp_output_125_0_g1 = ( ParentRotationResult131_g1 + v.vertex.xyz );
				float3 rotatedValue121_g1 = RotateAroundAxis( float3(0,0,0), temp_output_125_0_g1, normalize( WindVector226_g1 ), MainRotation67_g1 );
				float temp_output_148_0_g1 = pow( MainBendMask35_g1 , 5.0 );
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float2 panner86 = ( 1.0 * _Time.y * float2( -0.2,0.4 ) + (( ase_worldPos / -8.0 )).xz);
				float simplePerlin2D85 = snoise( panner86*10.0 );
				simplePerlin2D85 = simplePerlin2D85*0.5 + 0.5;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( ( ( ParentRotationResult131_g1 + ( ( rotatedValue121_g1 - temp_output_125_0_g1 ) * temp_output_148_0_g1 ) ) * _WindOverallStrength * TF_WIND_STRENGTH ) + ( _LeafFlutterStrength * ( v.ase_texcoord.y * simplePerlin2D85 ) * TF_WIND_STRENGTH * 0.6 ) );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				float3 normalWS = TransformObjectToWorldDir(v.ase_normal);

				#if _CASTING_PUNCTUAL_LIGHT_SHADOW
					float3 lightDirectionWS = normalize(_LightPosition - positionWS);
				#else
					float3 lightDirectionWS = _LightDirection;
				#endif

				float4 clipPos = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, UNITY_NEAR_CLIP_VALUE);
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = clipPos;
				o.clipPosV = clipPos;
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord3 = v.ase_texcoord3;
				o.ase_texcoord4 = v.ase_texcoord4;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord3 = patch[0].ase_texcoord3 * bary.x + patch[1].ase_texcoord3 * bary.y + patch[2].ase_texcoord3 * bary.z;
				o.ase_texcoord4 = patch[0].ase_texcoord4 * bary.x + patch[1].ase_texcoord4 * bary.y + patch[2].ase_texcoord4 * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(	VertexOutput IN
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_BaseColor = IN.ase_texcoord3.xy * _BaseColor_ST.xy + _BaseColor_ST.zw;
				float4 tex2DNode1 = tex2D( _BaseColor, uv_BaseColor );
				float Opacity34 = tex2DNode1.a;
				
				float lerpResult167 = lerp( _MaskClip , ( _MaskClip * 0.4 ) , ( distance( WorldPosition , _WorldSpaceCameraPos ) / 150.0 ));
				#ifdef _DISTANCEBASEDMASKCLIP_ON
				float staticSwitch196 = lerpResult167;
				#else
				float staticSwitch196 = _MaskClip;
				#endif
				float Mask_Clip157 = staticSwitch196;
				

				float Alpha = Opacity34;
				float AlphaClipThreshold = Mask_Clip157;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = IN.clipPos.z;
				#endif

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask R
			AlphaToMask Off

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#define ASE_FOG 1
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#define ASE_TRANSLUCENCY 1
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 140009


			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			
			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature_local _DISTANCEBASEDMASKCLIP_ON
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				ASE_SV_POSITION_QUALIFIERS float4 clipPos : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD1;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Undercolor;
			float4 _NormalMap_ST;
			float4 _Color;
			float4 _BaseColor_ST;
			float _VertexAOIntensity;
			float _Smoothness;
			float _NormalScale;
			float _UndercolorAmount;
			float _BaseColorSaturation;
			float _AOIntensity;
			float _ChildWindMapScale;
			float _WindOverallStrength;
			float _MainWindStrength;
			float _MainWindScale;
			float _MainBendMaskStrength;
			float _ParentWindStrength;
			float _ParentWindMapScale;
			float _BendingMaskStrength1;
			float _ChildWindStrength;
			float _LeafFlutterStrength;
			float _MaskClip;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float3 TF_WIND_DIRECTION;
			float TF_WIND_STRENGTH;
			sampler2D _BaseColor;


			real3 ASESafeNormalize(float3 inVec)
			{
				real dp3 = max(FLT_MIN, dot(inVec, inVec));
				return inVec* rsqrt( dp3);
			}
			
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
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 appendResult18_g1 = (float3(( -1.0 * v.ase_texcoord2.y ) , ( -1.0 * v.ase_texcoord3.y ) , v.ase_texcoord3.x));
				float3 temp_output_20_0_g1 = ( 0.001 * appendResult18_g1 );
				float dotResult16_g1 = dot( temp_output_20_0_g1 , temp_output_20_0_g1 );
				float ifLocalVar182_g1 = 0;
				if( dotResult16_g1 > 0.0001 )
				ifLocalVar182_g1 = 1.0;
				else if( dotResult16_g1 < 0.0001 )
				ifLocalVar182_g1 = 0.0;
				float ChildMask26_g1 = saturate( ( ifLocalVar182_g1 * 100.0 ) );
				float SelfBendMask34_g1 = ( 1.0 - v.ase_texcoord4.y );
				float ifLocalVar220 = 0;
				if( TF_WIND_DIRECTION.x == 0.0 )
				ifLocalVar220 = 0.0;
				else
				ifLocalVar220 = 1.0;
				float ifLocalVar221 = 0;
				if( TF_WIND_DIRECTION.z == 0.0 )
				ifLocalVar221 = 0.0;
				else
				ifLocalVar221 = 1.0;
				float3 lerpResult250 = lerp( float3(0,0,1) , TF_WIND_DIRECTION , ( ifLocalVar220 + ifLocalVar221 ));
				float3 worldToObjDir226 = ASESafeNormalize( mul( GetWorldToObjectMatrix(), float4( lerpResult250, 0 ) ).xyz );
				float3 WindDir225 = worldToObjDir226;
				float3 WindVector226_g1 = WindDir225;
				float3 appendResult11_g1 = (float3(( -1.0 * v.ase_texcoord1.x ) , v.ase_texcoord2.x , ( -1.0 * v.ase_texcoord1.y )));
				float3 temp_output_19_0_g1 = ( 0.001 * appendResult11_g1 );
				float3 SelfPivot28_g1 = temp_output_19_0_g1;
				float3 objToWorld54_g1 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float2 temp_cast_0 = ((( ( SelfPivot28_g1 * 1.0 ) + ( objToWorld54_g1 / -2.0 ) )).z).xx;
				float2 panner48_g1 = ( 1.0 * _Time.y * float2( 0,0.85 ) + temp_cast_0);
				float simplePerlin2D53_g1 = snoise( panner48_g1*_ChildWindMapScale );
				simplePerlin2D53_g1 = simplePerlin2D53_g1*0.5 + 0.5;
				float ChildRotation43_g1 = radians( ( simplePerlin2D53_g1 * 12.0 * _ChildWindStrength ) );
				float3 rotatedValue81_g1 = RotateAroundAxis( SelfPivot28_g1, v.vertex.xyz, normalize( WindVector226_g1 ), ChildRotation43_g1 );
				float3 ChildRotationResult119_g1 = ( ( ChildMask26_g1 * SelfBendMask34_g1 ) * ( rotatedValue81_g1 - v.vertex.xyz ) );
				float temp_output_113_0_g1 = saturate( ( 4.0 * pow( SelfBendMask34_g1 , _BendingMaskStrength1 ) ) );
				float dotResult9_g1 = dot( temp_output_19_0_g1 , temp_output_19_0_g1 );
				float ifLocalVar189_g1 = 0;
				if( dotResult9_g1 > 0.0001 )
				ifLocalVar189_g1 = 1.0;
				else if( dotResult9_g1 < 0.0001 )
				ifLocalVar189_g1 = 0.0;
				float TrunkMask29_g1 = saturate( ( ifLocalVar189_g1 * 1000.0 ) );
				float3 ParentPivot27_g1 = temp_output_20_0_g1;
				float3 lerpResult51_g1 = lerp( SelfPivot28_g1 , ParentPivot27_g1 , ChildMask26_g1);
				float2 temp_cast_1 = ((lerpResult51_g1).z).xx;
				float2 panner61_g1 = ( 1.0 * _Time.y * float2( 0,0.45 ) + temp_cast_1);
				float simplePerlin2D60_g1 = snoise( panner61_g1*_ParentWindMapScale );
				simplePerlin2D60_g1 = simplePerlin2D60_g1*0.5 + 0.5;
				float saferPower185_g1 = abs( simplePerlin2D60_g1 );
				float ParentRotation63_g1 = radians( ( pow( saferPower185_g1 , 3.0 ) * 25.0 * _ParentWindStrength ) );
				float3 lerpResult98_g1 = lerp( SelfPivot28_g1 , ParentPivot27_g1 , ChildMask26_g1);
				float3 rotatedValue96_g1 = RotateAroundAxis( lerpResult98_g1, ( ChildRotationResult119_g1 + v.vertex.xyz ), normalize( WindVector226_g1 ), ParentRotation63_g1 );
				float saferPower160_g1 = abs( v.ase_texcoord4.x );
				float MainBendMask35_g1 = saturate( pow( saferPower160_g1 , _MainBendMaskStrength ) );
				float3 ParentRotationResult131_g1 = ( ChildRotationResult119_g1 + ( ( ( ( ( temp_output_113_0_g1 * ( 1.0 - ChildMask26_g1 ) ) + ChildMask26_g1 ) * TrunkMask29_g1 ) * ( rotatedValue96_g1 - v.vertex.xyz ) ) * MainBendMask35_g1 ) );
				float3 objToWorld47_g1 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 saferPower172_g1 = abs( ( objToWorld47_g1 / ( -15.0 * _MainWindScale ) ) );
				float2 panner71_g1 = ( 1.0 * _Time.y * float2( 0,0.07 ) + (pow( saferPower172_g1 , 2.0 )).xz);
				float simplePerlin2D70_g1 = snoise( panner71_g1*2.0 );
				simplePerlin2D70_g1 = simplePerlin2D70_g1*0.5 + 0.5;
				float MainRotation67_g1 = radians( ( simplePerlin2D70_g1 * 25.0 * _MainWindStrength ) );
				float3 temp_output_125_0_g1 = ( ParentRotationResult131_g1 + v.vertex.xyz );
				float3 rotatedValue121_g1 = RotateAroundAxis( float3(0,0,0), temp_output_125_0_g1, normalize( WindVector226_g1 ), MainRotation67_g1 );
				float temp_output_148_0_g1 = pow( MainBendMask35_g1 , 5.0 );
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float2 panner86 = ( 1.0 * _Time.y * float2( -0.2,0.4 ) + (( ase_worldPos / -8.0 )).xz);
				float simplePerlin2D85 = snoise( panner86*10.0 );
				simplePerlin2D85 = simplePerlin2D85*0.5 + 0.5;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( ( ( ParentRotationResult131_g1 + ( ( rotatedValue121_g1 - temp_output_125_0_g1 ) * temp_output_148_0_g1 ) ) * _WindOverallStrength * TF_WIND_STRENGTH ) + ( _LeafFlutterStrength * ( v.ase_texcoord.y * simplePerlin2D85 ) * TF_WIND_STRENGTH * 0.6 ) );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;
				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;
				o.clipPosV = positionCS;
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord3 = v.ase_texcoord3;
				o.ase_texcoord4 = v.ase_texcoord4;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord3 = patch[0].ase_texcoord3 * bary.x + patch[1].ase_texcoord3 * bary.y + patch[2].ase_texcoord3 * bary.z;
				o.ase_texcoord4 = patch[0].ase_texcoord4 * bary.x + patch[1].ase_texcoord4 * bary.y + patch[2].ase_texcoord4 * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(	VertexOutput IN
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_BaseColor = IN.ase_texcoord3.xy * _BaseColor_ST.xy + _BaseColor_ST.zw;
				float4 tex2DNode1 = tex2D( _BaseColor, uv_BaseColor );
				float Opacity34 = tex2DNode1.a;
				
				float lerpResult167 = lerp( _MaskClip , ( _MaskClip * 0.4 ) , ( distance( WorldPosition , _WorldSpaceCameraPos ) / 150.0 ));
				#ifdef _DISTANCEBASEDMASKCLIP_ON
				float staticSwitch196 = lerpResult167;
				#else
				float staticSwitch196 = _MaskClip;
				#endif
				float Mask_Clip157 = staticSwitch196;
				

				float Alpha = Opacity34;
				float AlphaClipThreshold = Mask_Clip157;
				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = IN.clipPos.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Meta"
			Tags { "LightMode"="Meta" }

			Cull Off

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define ASE_TRANSLUCENCY 1
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 140009


			#pragma vertex vert
			#pragma fragment frag

			#pragma shader_feature EDITOR_VISUALIZATION

			#define SHADERPASS SHADERPASS_META

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature_local _DISTANCEBASEDMASKCLIP_ON
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord0 : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef EDITOR_VISUALIZATION
					float4 VizUV : TEXCOORD2;
					float4 LightCoord : TEXCOORD3;
				#endif
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Undercolor;
			float4 _NormalMap_ST;
			float4 _Color;
			float4 _BaseColor_ST;
			float _VertexAOIntensity;
			float _Smoothness;
			float _NormalScale;
			float _UndercolorAmount;
			float _BaseColorSaturation;
			float _AOIntensity;
			float _ChildWindMapScale;
			float _WindOverallStrength;
			float _MainWindStrength;
			float _MainWindScale;
			float _MainBendMaskStrength;
			float _ParentWindStrength;
			float _ParentWindMapScale;
			float _BendingMaskStrength1;
			float _ChildWindStrength;
			float _LeafFlutterStrength;
			float _MaskClip;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float3 TF_WIND_DIRECTION;
			float TF_WIND_STRENGTH;
			sampler2D _BaseColor;


			real3 ASESafeNormalize(float3 inVec)
			{
				real dp3 = max(FLT_MIN, dot(inVec, inVec));
				return inVec* rsqrt( dp3);
			}
			
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
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 appendResult18_g1 = (float3(( -1.0 * v.texcoord2.y ) , ( -1.0 * v.ase_texcoord3.y ) , v.ase_texcoord3.x));
				float3 temp_output_20_0_g1 = ( 0.001 * appendResult18_g1 );
				float dotResult16_g1 = dot( temp_output_20_0_g1 , temp_output_20_0_g1 );
				float ifLocalVar182_g1 = 0;
				if( dotResult16_g1 > 0.0001 )
				ifLocalVar182_g1 = 1.0;
				else if( dotResult16_g1 < 0.0001 )
				ifLocalVar182_g1 = 0.0;
				float ChildMask26_g1 = saturate( ( ifLocalVar182_g1 * 100.0 ) );
				float SelfBendMask34_g1 = ( 1.0 - v.ase_texcoord4.y );
				float ifLocalVar220 = 0;
				if( TF_WIND_DIRECTION.x == 0.0 )
				ifLocalVar220 = 0.0;
				else
				ifLocalVar220 = 1.0;
				float ifLocalVar221 = 0;
				if( TF_WIND_DIRECTION.z == 0.0 )
				ifLocalVar221 = 0.0;
				else
				ifLocalVar221 = 1.0;
				float3 lerpResult250 = lerp( float3(0,0,1) , TF_WIND_DIRECTION , ( ifLocalVar220 + ifLocalVar221 ));
				float3 worldToObjDir226 = ASESafeNormalize( mul( GetWorldToObjectMatrix(), float4( lerpResult250, 0 ) ).xyz );
				float3 WindDir225 = worldToObjDir226;
				float3 WindVector226_g1 = WindDir225;
				float3 appendResult11_g1 = (float3(( -1.0 * v.texcoord1.x ) , v.texcoord2.x , ( -1.0 * v.texcoord1.y )));
				float3 temp_output_19_0_g1 = ( 0.001 * appendResult11_g1 );
				float3 SelfPivot28_g1 = temp_output_19_0_g1;
				float3 objToWorld54_g1 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float2 temp_cast_0 = ((( ( SelfPivot28_g1 * 1.0 ) + ( objToWorld54_g1 / -2.0 ) )).z).xx;
				float2 panner48_g1 = ( 1.0 * _Time.y * float2( 0,0.85 ) + temp_cast_0);
				float simplePerlin2D53_g1 = snoise( panner48_g1*_ChildWindMapScale );
				simplePerlin2D53_g1 = simplePerlin2D53_g1*0.5 + 0.5;
				float ChildRotation43_g1 = radians( ( simplePerlin2D53_g1 * 12.0 * _ChildWindStrength ) );
				float3 rotatedValue81_g1 = RotateAroundAxis( SelfPivot28_g1, v.vertex.xyz, normalize( WindVector226_g1 ), ChildRotation43_g1 );
				float3 ChildRotationResult119_g1 = ( ( ChildMask26_g1 * SelfBendMask34_g1 ) * ( rotatedValue81_g1 - v.vertex.xyz ) );
				float temp_output_113_0_g1 = saturate( ( 4.0 * pow( SelfBendMask34_g1 , _BendingMaskStrength1 ) ) );
				float dotResult9_g1 = dot( temp_output_19_0_g1 , temp_output_19_0_g1 );
				float ifLocalVar189_g1 = 0;
				if( dotResult9_g1 > 0.0001 )
				ifLocalVar189_g1 = 1.0;
				else if( dotResult9_g1 < 0.0001 )
				ifLocalVar189_g1 = 0.0;
				float TrunkMask29_g1 = saturate( ( ifLocalVar189_g1 * 1000.0 ) );
				float3 ParentPivot27_g1 = temp_output_20_0_g1;
				float3 lerpResult51_g1 = lerp( SelfPivot28_g1 , ParentPivot27_g1 , ChildMask26_g1);
				float2 temp_cast_1 = ((lerpResult51_g1).z).xx;
				float2 panner61_g1 = ( 1.0 * _Time.y * float2( 0,0.45 ) + temp_cast_1);
				float simplePerlin2D60_g1 = snoise( panner61_g1*_ParentWindMapScale );
				simplePerlin2D60_g1 = simplePerlin2D60_g1*0.5 + 0.5;
				float saferPower185_g1 = abs( simplePerlin2D60_g1 );
				float ParentRotation63_g1 = radians( ( pow( saferPower185_g1 , 3.0 ) * 25.0 * _ParentWindStrength ) );
				float3 lerpResult98_g1 = lerp( SelfPivot28_g1 , ParentPivot27_g1 , ChildMask26_g1);
				float3 rotatedValue96_g1 = RotateAroundAxis( lerpResult98_g1, ( ChildRotationResult119_g1 + v.vertex.xyz ), normalize( WindVector226_g1 ), ParentRotation63_g1 );
				float saferPower160_g1 = abs( v.ase_texcoord4.x );
				float MainBendMask35_g1 = saturate( pow( saferPower160_g1 , _MainBendMaskStrength ) );
				float3 ParentRotationResult131_g1 = ( ChildRotationResult119_g1 + ( ( ( ( ( temp_output_113_0_g1 * ( 1.0 - ChildMask26_g1 ) ) + ChildMask26_g1 ) * TrunkMask29_g1 ) * ( rotatedValue96_g1 - v.vertex.xyz ) ) * MainBendMask35_g1 ) );
				float3 objToWorld47_g1 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 saferPower172_g1 = abs( ( objToWorld47_g1 / ( -15.0 * _MainWindScale ) ) );
				float2 panner71_g1 = ( 1.0 * _Time.y * float2( 0,0.07 ) + (pow( saferPower172_g1 , 2.0 )).xz);
				float simplePerlin2D70_g1 = snoise( panner71_g1*2.0 );
				simplePerlin2D70_g1 = simplePerlin2D70_g1*0.5 + 0.5;
				float MainRotation67_g1 = radians( ( simplePerlin2D70_g1 * 25.0 * _MainWindStrength ) );
				float3 temp_output_125_0_g1 = ( ParentRotationResult131_g1 + v.vertex.xyz );
				float3 rotatedValue121_g1 = RotateAroundAxis( float3(0,0,0), temp_output_125_0_g1, normalize( WindVector226_g1 ), MainRotation67_g1 );
				float temp_output_148_0_g1 = pow( MainBendMask35_g1 , 5.0 );
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float2 panner86 = ( 1.0 * _Time.y * float2( -0.2,0.4 ) + (( ase_worldPos / -8.0 )).xz);
				float simplePerlin2D85 = snoise( panner86*10.0 );
				simplePerlin2D85 = simplePerlin2D85*0.5 + 0.5;
				
				float3 vertexToFrag194 = v.ase_normal;
				o.ase_texcoord5.xyz = vertexToFrag194;
				
				o.ase_texcoord4.xy = v.texcoord0.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord4.zw = 0;
				o.ase_texcoord5.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( ( ( ParentRotationResult131_g1 + ( ( rotatedValue121_g1 - temp_output_125_0_g1 ) * temp_output_148_0_g1 ) ) * _WindOverallStrength * TF_WIND_STRENGTH ) + ( _LeafFlutterStrength * ( v.texcoord0.y * simplePerlin2D85 ) * TF_WIND_STRENGTH * 0.6 ) );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				o.clipPos = MetaVertexPosition( v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST );

				#ifdef EDITOR_VISUALIZATION
					float2 VizUV = 0;
					float4 LightCoord = 0;
					UnityEditorVizData(v.vertex.xyz, v.texcoord0.xy, v.texcoord1.xy, v.texcoord2.xy, VizUV, LightCoord);
					o.VizUV = float4(VizUV, 0, 0);
					o.LightCoord = LightCoord;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 texcoord0 : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.texcoord0 = v.texcoord0;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				o.ase_texcoord3 = v.ase_texcoord3;
				o.ase_texcoord4 = v.ase_texcoord4;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.texcoord0 = patch[0].texcoord0 * bary.x + patch[1].texcoord0 * bary.y + patch[2].texcoord0 * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				o.ase_texcoord3 = patch[0].ase_texcoord3 * bary.x + patch[1].ase_texcoord3 * bary.y + patch[2].ase_texcoord3 * bary.z;
				o.ase_texcoord4 = patch[0].ase_texcoord4 * bary.x + patch[1].ase_texcoord4 * bary.y + patch[2].ase_texcoord4 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_BaseColor = IN.ase_texcoord4.xy * _BaseColor_ST.xy + _BaseColor_ST.zw;
				float4 tex2DNode1 = tex2D( _BaseColor, uv_BaseColor );
				float4 BaseColor33 = tex2DNode1;
				float3 desaturateInitialColor183 = BaseColor33.rgb;
				float desaturateDot183 = dot( desaturateInitialColor183, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar183 = lerp( desaturateInitialColor183, desaturateDot183.xxx, ( 1.0 - _BaseColorSaturation ) );
				float3 vertexToFrag194 = IN.ase_texcoord5.xyz;
				float4 lerpResult186 = lerp( ( _Undercolor * float4( desaturateVar183 , 0.0 ) ) , ( _Color * float4( desaturateVar183 , 0.0 ) ) , saturate( ( vertexToFrag194.y - ( _UndercolorAmount * -2.0 ) ) ));
				float4 FinalColor37 = lerpResult186;
				
				float Opacity34 = tex2DNode1.a;
				
				float lerpResult167 = lerp( _MaskClip , ( _MaskClip * 0.4 ) , ( distance( WorldPosition , _WorldSpaceCameraPos ) / 150.0 ));
				#ifdef _DISTANCEBASEDMASKCLIP_ON
				float staticSwitch196 = lerpResult167;
				#else
				float staticSwitch196 = _MaskClip;
				#endif
				float Mask_Clip157 = staticSwitch196;
				

				float3 BaseColor = FinalColor37.rgb;
				float3 Emission = 0;
				float Alpha = Opacity34;
				float AlphaClipThreshold = Mask_Clip157;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				MetaInput metaInput = (MetaInput)0;
				metaInput.Albedo = BaseColor;
				metaInput.Emission = Emission;
				#ifdef EDITOR_VISUALIZATION
					metaInput.VizUV = IN.VizUV.xy;
					metaInput.LightCoord = IN.LightCoord;
				#endif

				return UnityMetaFragment(metaInput);
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define ASE_TRANSLUCENCY 1
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 140009


			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_2D

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature_local _DISTANCEBASEDMASKCLIP_ON
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Undercolor;
			float4 _NormalMap_ST;
			float4 _Color;
			float4 _BaseColor_ST;
			float _VertexAOIntensity;
			float _Smoothness;
			float _NormalScale;
			float _UndercolorAmount;
			float _BaseColorSaturation;
			float _AOIntensity;
			float _ChildWindMapScale;
			float _WindOverallStrength;
			float _MainWindStrength;
			float _MainWindScale;
			float _MainBendMaskStrength;
			float _ParentWindStrength;
			float _ParentWindMapScale;
			float _BendingMaskStrength1;
			float _ChildWindStrength;
			float _LeafFlutterStrength;
			float _MaskClip;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float3 TF_WIND_DIRECTION;
			float TF_WIND_STRENGTH;
			sampler2D _BaseColor;


			real3 ASESafeNormalize(float3 inVec)
			{
				real dp3 = max(FLT_MIN, dot(inVec, inVec));
				return inVec* rsqrt( dp3);
			}
			
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
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 appendResult18_g1 = (float3(( -1.0 * v.ase_texcoord2.y ) , ( -1.0 * v.ase_texcoord3.y ) , v.ase_texcoord3.x));
				float3 temp_output_20_0_g1 = ( 0.001 * appendResult18_g1 );
				float dotResult16_g1 = dot( temp_output_20_0_g1 , temp_output_20_0_g1 );
				float ifLocalVar182_g1 = 0;
				if( dotResult16_g1 > 0.0001 )
				ifLocalVar182_g1 = 1.0;
				else if( dotResult16_g1 < 0.0001 )
				ifLocalVar182_g1 = 0.0;
				float ChildMask26_g1 = saturate( ( ifLocalVar182_g1 * 100.0 ) );
				float SelfBendMask34_g1 = ( 1.0 - v.ase_texcoord4.y );
				float ifLocalVar220 = 0;
				if( TF_WIND_DIRECTION.x == 0.0 )
				ifLocalVar220 = 0.0;
				else
				ifLocalVar220 = 1.0;
				float ifLocalVar221 = 0;
				if( TF_WIND_DIRECTION.z == 0.0 )
				ifLocalVar221 = 0.0;
				else
				ifLocalVar221 = 1.0;
				float3 lerpResult250 = lerp( float3(0,0,1) , TF_WIND_DIRECTION , ( ifLocalVar220 + ifLocalVar221 ));
				float3 worldToObjDir226 = ASESafeNormalize( mul( GetWorldToObjectMatrix(), float4( lerpResult250, 0 ) ).xyz );
				float3 WindDir225 = worldToObjDir226;
				float3 WindVector226_g1 = WindDir225;
				float3 appendResult11_g1 = (float3(( -1.0 * v.ase_texcoord1.x ) , v.ase_texcoord2.x , ( -1.0 * v.ase_texcoord1.y )));
				float3 temp_output_19_0_g1 = ( 0.001 * appendResult11_g1 );
				float3 SelfPivot28_g1 = temp_output_19_0_g1;
				float3 objToWorld54_g1 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float2 temp_cast_0 = ((( ( SelfPivot28_g1 * 1.0 ) + ( objToWorld54_g1 / -2.0 ) )).z).xx;
				float2 panner48_g1 = ( 1.0 * _Time.y * float2( 0,0.85 ) + temp_cast_0);
				float simplePerlin2D53_g1 = snoise( panner48_g1*_ChildWindMapScale );
				simplePerlin2D53_g1 = simplePerlin2D53_g1*0.5 + 0.5;
				float ChildRotation43_g1 = radians( ( simplePerlin2D53_g1 * 12.0 * _ChildWindStrength ) );
				float3 rotatedValue81_g1 = RotateAroundAxis( SelfPivot28_g1, v.vertex.xyz, normalize( WindVector226_g1 ), ChildRotation43_g1 );
				float3 ChildRotationResult119_g1 = ( ( ChildMask26_g1 * SelfBendMask34_g1 ) * ( rotatedValue81_g1 - v.vertex.xyz ) );
				float temp_output_113_0_g1 = saturate( ( 4.0 * pow( SelfBendMask34_g1 , _BendingMaskStrength1 ) ) );
				float dotResult9_g1 = dot( temp_output_19_0_g1 , temp_output_19_0_g1 );
				float ifLocalVar189_g1 = 0;
				if( dotResult9_g1 > 0.0001 )
				ifLocalVar189_g1 = 1.0;
				else if( dotResult9_g1 < 0.0001 )
				ifLocalVar189_g1 = 0.0;
				float TrunkMask29_g1 = saturate( ( ifLocalVar189_g1 * 1000.0 ) );
				float3 ParentPivot27_g1 = temp_output_20_0_g1;
				float3 lerpResult51_g1 = lerp( SelfPivot28_g1 , ParentPivot27_g1 , ChildMask26_g1);
				float2 temp_cast_1 = ((lerpResult51_g1).z).xx;
				float2 panner61_g1 = ( 1.0 * _Time.y * float2( 0,0.45 ) + temp_cast_1);
				float simplePerlin2D60_g1 = snoise( panner61_g1*_ParentWindMapScale );
				simplePerlin2D60_g1 = simplePerlin2D60_g1*0.5 + 0.5;
				float saferPower185_g1 = abs( simplePerlin2D60_g1 );
				float ParentRotation63_g1 = radians( ( pow( saferPower185_g1 , 3.0 ) * 25.0 * _ParentWindStrength ) );
				float3 lerpResult98_g1 = lerp( SelfPivot28_g1 , ParentPivot27_g1 , ChildMask26_g1);
				float3 rotatedValue96_g1 = RotateAroundAxis( lerpResult98_g1, ( ChildRotationResult119_g1 + v.vertex.xyz ), normalize( WindVector226_g1 ), ParentRotation63_g1 );
				float saferPower160_g1 = abs( v.ase_texcoord4.x );
				float MainBendMask35_g1 = saturate( pow( saferPower160_g1 , _MainBendMaskStrength ) );
				float3 ParentRotationResult131_g1 = ( ChildRotationResult119_g1 + ( ( ( ( ( temp_output_113_0_g1 * ( 1.0 - ChildMask26_g1 ) ) + ChildMask26_g1 ) * TrunkMask29_g1 ) * ( rotatedValue96_g1 - v.vertex.xyz ) ) * MainBendMask35_g1 ) );
				float3 objToWorld47_g1 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 saferPower172_g1 = abs( ( objToWorld47_g1 / ( -15.0 * _MainWindScale ) ) );
				float2 panner71_g1 = ( 1.0 * _Time.y * float2( 0,0.07 ) + (pow( saferPower172_g1 , 2.0 )).xz);
				float simplePerlin2D70_g1 = snoise( panner71_g1*2.0 );
				simplePerlin2D70_g1 = simplePerlin2D70_g1*0.5 + 0.5;
				float MainRotation67_g1 = radians( ( simplePerlin2D70_g1 * 25.0 * _MainWindStrength ) );
				float3 temp_output_125_0_g1 = ( ParentRotationResult131_g1 + v.vertex.xyz );
				float3 rotatedValue121_g1 = RotateAroundAxis( float3(0,0,0), temp_output_125_0_g1, normalize( WindVector226_g1 ), MainRotation67_g1 );
				float temp_output_148_0_g1 = pow( MainBendMask35_g1 , 5.0 );
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float2 panner86 = ( 1.0 * _Time.y * float2( -0.2,0.4 ) + (( ase_worldPos / -8.0 )).xz);
				float simplePerlin2D85 = snoise( panner86*10.0 );
				simplePerlin2D85 = simplePerlin2D85*0.5 + 0.5;
				
				float3 vertexToFrag194 = v.ase_normal;
				o.ase_texcoord3.xyz = vertexToFrag194;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord3.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( ( ( ParentRotationResult131_g1 + ( ( rotatedValue121_g1 - temp_output_125_0_g1 ) * temp_output_148_0_g1 ) ) * _WindOverallStrength * TF_WIND_STRENGTH ) + ( _LeafFlutterStrength * ( v.ase_texcoord.y * simplePerlin2D85 ) * TF_WIND_STRENGTH * 0.6 ) );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord3 = v.ase_texcoord3;
				o.ase_texcoord4 = v.ase_texcoord4;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord3 = patch[0].ase_texcoord3 * bary.x + patch[1].ase_texcoord3 * bary.y + patch[2].ase_texcoord3 * bary.z;
				o.ase_texcoord4 = patch[0].ase_texcoord4 * bary.x + patch[1].ase_texcoord4 * bary.y + patch[2].ase_texcoord4 * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_BaseColor = IN.ase_texcoord2.xy * _BaseColor_ST.xy + _BaseColor_ST.zw;
				float4 tex2DNode1 = tex2D( _BaseColor, uv_BaseColor );
				float4 BaseColor33 = tex2DNode1;
				float3 desaturateInitialColor183 = BaseColor33.rgb;
				float desaturateDot183 = dot( desaturateInitialColor183, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar183 = lerp( desaturateInitialColor183, desaturateDot183.xxx, ( 1.0 - _BaseColorSaturation ) );
				float3 vertexToFrag194 = IN.ase_texcoord3.xyz;
				float4 lerpResult186 = lerp( ( _Undercolor * float4( desaturateVar183 , 0.0 ) ) , ( _Color * float4( desaturateVar183 , 0.0 ) ) , saturate( ( vertexToFrag194.y - ( _UndercolorAmount * -2.0 ) ) ));
				float4 FinalColor37 = lerpResult186;
				
				float Opacity34 = tex2DNode1.a;
				
				float lerpResult167 = lerp( _MaskClip , ( _MaskClip * 0.4 ) , ( distance( WorldPosition , _WorldSpaceCameraPos ) / 150.0 ));
				#ifdef _DISTANCEBASEDMASKCLIP_ON
				float staticSwitch196 = lerpResult167;
				#else
				float staticSwitch196 = _MaskClip;
				#endif
				float Mask_Clip157 = staticSwitch196;
				

				float3 BaseColor = FinalColor37.rgb;
				float Alpha = Opacity34;
				float AlphaClipThreshold = Mask_Clip157;

				half4 color = half4(BaseColor, Alpha );

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				return color;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthNormals"
			Tags { "LightMode"="DepthNormalsOnly" }

			ZWrite On
			Blend One Zero
			ZTest LEqual
			ZWrite On

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#define ASE_FOG 1
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#define ASE_TRANSLUCENCY 1
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 140009


			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature _TFW_FLIPNORMALS
			#pragma shader_feature_local _DISTANCEBASEDMASKCLIP_ON
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				ASE_SV_POSITION_QUALIFIERS float4 clipPos : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float4 worldTangent : TEXCOORD2;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD3;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD4;
				#endif
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Undercolor;
			float4 _NormalMap_ST;
			float4 _Color;
			float4 _BaseColor_ST;
			float _VertexAOIntensity;
			float _Smoothness;
			float _NormalScale;
			float _UndercolorAmount;
			float _BaseColorSaturation;
			float _AOIntensity;
			float _ChildWindMapScale;
			float _WindOverallStrength;
			float _MainWindStrength;
			float _MainWindScale;
			float _MainBendMaskStrength;
			float _ParentWindStrength;
			float _ParentWindMapScale;
			float _BendingMaskStrength1;
			float _ChildWindStrength;
			float _LeafFlutterStrength;
			float _MaskClip;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float3 TF_WIND_DIRECTION;
			float TF_WIND_STRENGTH;
			sampler2D _NormalMap;
			sampler2D _BaseColor;


			real3 ASESafeNormalize(float3 inVec)
			{
				real dp3 = max(FLT_MIN, dot(inVec, inVec));
				return inVec* rsqrt( dp3);
			}
			
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
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 appendResult18_g1 = (float3(( -1.0 * v.ase_texcoord2.y ) , ( -1.0 * v.ase_texcoord3.y ) , v.ase_texcoord3.x));
				float3 temp_output_20_0_g1 = ( 0.001 * appendResult18_g1 );
				float dotResult16_g1 = dot( temp_output_20_0_g1 , temp_output_20_0_g1 );
				float ifLocalVar182_g1 = 0;
				if( dotResult16_g1 > 0.0001 )
				ifLocalVar182_g1 = 1.0;
				else if( dotResult16_g1 < 0.0001 )
				ifLocalVar182_g1 = 0.0;
				float ChildMask26_g1 = saturate( ( ifLocalVar182_g1 * 100.0 ) );
				float SelfBendMask34_g1 = ( 1.0 - v.ase_texcoord4.y );
				float ifLocalVar220 = 0;
				if( TF_WIND_DIRECTION.x == 0.0 )
				ifLocalVar220 = 0.0;
				else
				ifLocalVar220 = 1.0;
				float ifLocalVar221 = 0;
				if( TF_WIND_DIRECTION.z == 0.0 )
				ifLocalVar221 = 0.0;
				else
				ifLocalVar221 = 1.0;
				float3 lerpResult250 = lerp( float3(0,0,1) , TF_WIND_DIRECTION , ( ifLocalVar220 + ifLocalVar221 ));
				float3 worldToObjDir226 = ASESafeNormalize( mul( GetWorldToObjectMatrix(), float4( lerpResult250, 0 ) ).xyz );
				float3 WindDir225 = worldToObjDir226;
				float3 WindVector226_g1 = WindDir225;
				float3 appendResult11_g1 = (float3(( -1.0 * v.ase_texcoord1.x ) , v.ase_texcoord2.x , ( -1.0 * v.ase_texcoord1.y )));
				float3 temp_output_19_0_g1 = ( 0.001 * appendResult11_g1 );
				float3 SelfPivot28_g1 = temp_output_19_0_g1;
				float3 objToWorld54_g1 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float2 temp_cast_0 = ((( ( SelfPivot28_g1 * 1.0 ) + ( objToWorld54_g1 / -2.0 ) )).z).xx;
				float2 panner48_g1 = ( 1.0 * _Time.y * float2( 0,0.85 ) + temp_cast_0);
				float simplePerlin2D53_g1 = snoise( panner48_g1*_ChildWindMapScale );
				simplePerlin2D53_g1 = simplePerlin2D53_g1*0.5 + 0.5;
				float ChildRotation43_g1 = radians( ( simplePerlin2D53_g1 * 12.0 * _ChildWindStrength ) );
				float3 rotatedValue81_g1 = RotateAroundAxis( SelfPivot28_g1, v.vertex.xyz, normalize( WindVector226_g1 ), ChildRotation43_g1 );
				float3 ChildRotationResult119_g1 = ( ( ChildMask26_g1 * SelfBendMask34_g1 ) * ( rotatedValue81_g1 - v.vertex.xyz ) );
				float temp_output_113_0_g1 = saturate( ( 4.0 * pow( SelfBendMask34_g1 , _BendingMaskStrength1 ) ) );
				float dotResult9_g1 = dot( temp_output_19_0_g1 , temp_output_19_0_g1 );
				float ifLocalVar189_g1 = 0;
				if( dotResult9_g1 > 0.0001 )
				ifLocalVar189_g1 = 1.0;
				else if( dotResult9_g1 < 0.0001 )
				ifLocalVar189_g1 = 0.0;
				float TrunkMask29_g1 = saturate( ( ifLocalVar189_g1 * 1000.0 ) );
				float3 ParentPivot27_g1 = temp_output_20_0_g1;
				float3 lerpResult51_g1 = lerp( SelfPivot28_g1 , ParentPivot27_g1 , ChildMask26_g1);
				float2 temp_cast_1 = ((lerpResult51_g1).z).xx;
				float2 panner61_g1 = ( 1.0 * _Time.y * float2( 0,0.45 ) + temp_cast_1);
				float simplePerlin2D60_g1 = snoise( panner61_g1*_ParentWindMapScale );
				simplePerlin2D60_g1 = simplePerlin2D60_g1*0.5 + 0.5;
				float saferPower185_g1 = abs( simplePerlin2D60_g1 );
				float ParentRotation63_g1 = radians( ( pow( saferPower185_g1 , 3.0 ) * 25.0 * _ParentWindStrength ) );
				float3 lerpResult98_g1 = lerp( SelfPivot28_g1 , ParentPivot27_g1 , ChildMask26_g1);
				float3 rotatedValue96_g1 = RotateAroundAxis( lerpResult98_g1, ( ChildRotationResult119_g1 + v.vertex.xyz ), normalize( WindVector226_g1 ), ParentRotation63_g1 );
				float saferPower160_g1 = abs( v.ase_texcoord4.x );
				float MainBendMask35_g1 = saturate( pow( saferPower160_g1 , _MainBendMaskStrength ) );
				float3 ParentRotationResult131_g1 = ( ChildRotationResult119_g1 + ( ( ( ( ( temp_output_113_0_g1 * ( 1.0 - ChildMask26_g1 ) ) + ChildMask26_g1 ) * TrunkMask29_g1 ) * ( rotatedValue96_g1 - v.vertex.xyz ) ) * MainBendMask35_g1 ) );
				float3 objToWorld47_g1 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 saferPower172_g1 = abs( ( objToWorld47_g1 / ( -15.0 * _MainWindScale ) ) );
				float2 panner71_g1 = ( 1.0 * _Time.y * float2( 0,0.07 ) + (pow( saferPower172_g1 , 2.0 )).xz);
				float simplePerlin2D70_g1 = snoise( panner71_g1*2.0 );
				simplePerlin2D70_g1 = simplePerlin2D70_g1*0.5 + 0.5;
				float MainRotation67_g1 = radians( ( simplePerlin2D70_g1 * 25.0 * _MainWindStrength ) );
				float3 temp_output_125_0_g1 = ( ParentRotationResult131_g1 + v.vertex.xyz );
				float3 rotatedValue121_g1 = RotateAroundAxis( float3(0,0,0), temp_output_125_0_g1, normalize( WindVector226_g1 ), MainRotation67_g1 );
				float temp_output_148_0_g1 = pow( MainBendMask35_g1 , 5.0 );
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float2 panner86 = ( 1.0 * _Time.y * float2( -0.2,0.4 ) + (( ase_worldPos / -8.0 )).xz);
				float simplePerlin2D85 = snoise( panner86*10.0 );
				simplePerlin2D85 = simplePerlin2D85*0.5 + 0.5;
				
				o.ase_texcoord5.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord5.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( ( ( ParentRotationResult131_g1 + ( ( rotatedValue121_g1 - temp_output_125_0_g1 ) * temp_output_148_0_g1 ) ) * _WindOverallStrength * TF_WIND_STRENGTH ) + ( _LeafFlutterStrength * ( v.ase_texcoord.y * simplePerlin2D85 ) * TF_WIND_STRENGTH * 0.6 ) );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;
				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal( v.ase_normal );
				float4 tangentWS = float4(TransformObjectToWorldDir( v.ase_tangent.xyz), v.ase_tangent.w);
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				o.worldNormal = normalWS;
				o.worldTangent = tangentWS;

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;
				o.clipPosV = positionCS;
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_tangent = v.ase_tangent;
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord3 = v.ase_texcoord3;
				o.ase_texcoord4 = v.ase_texcoord4;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord3 = patch[0].ase_texcoord3 * bary.x + patch[1].ase_texcoord3 * bary.y + patch[2].ase_texcoord3 * bary.z;
				o.ase_texcoord4 = patch[0].ase_texcoord4 * bary.x + patch[1].ase_texcoord4 * bary.y + patch[2].ase_texcoord4 * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			void frag(	VertexOutput IN
						, out half4 outNormalWS : SV_Target0
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						#ifdef _WRITE_RENDERING_LAYERS
						, out float4 outRenderingLayers : SV_Target1
						#endif
						, bool ase_vface : SV_IsFrontFace )
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float3 WorldNormal = IN.worldNormal;
				float4 WorldTangent = IN.worldTangent;

				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_NormalMap = IN.ase_texcoord5.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
				float3 unpack11 = UnpackNormalScale( tex2D( _NormalMap, uv_NormalMap ), _NormalScale );
				unpack11.z = lerp( 1, unpack11.z, saturate(_NormalScale) );
				float3 tex2DNode11 = unpack11;
				float3 break4 = tex2DNode11;
				float switchResult9 = (((ase_vface>0)?(break4.z):(-break4.z)));
				float3 appendResult6 = (float3(break4.x , break4.y , switchResult9));
				#ifdef _TFW_FLIPNORMALS
				float3 staticSwitch7 = appendResult6;
				#else
				float3 staticSwitch7 = tex2DNode11;
				#endif
				float3 FinalNormal8 = staticSwitch7;
				
				float2 uv_BaseColor = IN.ase_texcoord5.xy * _BaseColor_ST.xy + _BaseColor_ST.zw;
				float4 tex2DNode1 = tex2D( _BaseColor, uv_BaseColor );
				float Opacity34 = tex2DNode1.a;
				
				float lerpResult167 = lerp( _MaskClip , ( _MaskClip * 0.4 ) , ( distance( WorldPosition , _WorldSpaceCameraPos ) / 150.0 ));
				#ifdef _DISTANCEBASEDMASKCLIP_ON
				float staticSwitch196 = lerpResult167;
				#else
				float staticSwitch196 = _MaskClip;
				#endif
				float Mask_Clip157 = staticSwitch196;
				

				float3 Normal = FinalNormal8;
				float Alpha = Opacity34;
				float AlphaClipThreshold = Mask_Clip157;
				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = IN.clipPos.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				#if defined(_GBUFFER_NORMALS_OCT)
					float2 octNormalWS = PackNormalOctQuadEncode(WorldNormal);
					float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);
					half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);
					outNormalWS = half4(packedNormalWS, 0.0);
				#else
					#if defined(_NORMALMAP)
						#if _NORMAL_DROPOFF_TS
							float crossSign = (WorldTangent.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
							float3 bitangent = crossSign * cross(WorldNormal.xyz, WorldTangent.xyz);
							float3 normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent.xyz, bitangent, WorldNormal.xyz));
						#elif _NORMAL_DROPOFF_OS
							float3 normalWS = TransformObjectToWorldNormal(Normal);
						#elif _NORMAL_DROPOFF_WS
							float3 normalWS = Normal;
						#endif
					#else
						float3 normalWS = WorldNormal;
					#endif
					outNormalWS = half4(NormalizeNormalPerPixel(normalWS), 0.0);
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
				#endif
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "SceneSelectionPass"
			Tags { "LightMode"="SceneSelectionPass" }

			Cull Off
			AlphaToMask Off

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define ASE_TRANSLUCENCY 1
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 140009


			#pragma vertex vert
			#pragma fragment frag

			#define SCENESELECTIONPASS 1

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#pragma shader_feature_local _DISTANCEBASEDMASKCLIP_ON
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Undercolor;
			float4 _NormalMap_ST;
			float4 _Color;
			float4 _BaseColor_ST;
			float _VertexAOIntensity;
			float _Smoothness;
			float _NormalScale;
			float _UndercolorAmount;
			float _BaseColorSaturation;
			float _AOIntensity;
			float _ChildWindMapScale;
			float _WindOverallStrength;
			float _MainWindStrength;
			float _MainWindScale;
			float _MainBendMaskStrength;
			float _ParentWindStrength;
			float _ParentWindMapScale;
			float _BendingMaskStrength1;
			float _ChildWindStrength;
			float _LeafFlutterStrength;
			float _MaskClip;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float3 TF_WIND_DIRECTION;
			float TF_WIND_STRENGTH;
			sampler2D _BaseColor;


			real3 ASESafeNormalize(float3 inVec)
			{
				real dp3 = max(FLT_MIN, dot(inVec, inVec));
				return inVec* rsqrt( dp3);
			}
			
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
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 appendResult18_g1 = (float3(( -1.0 * v.ase_texcoord2.y ) , ( -1.0 * v.ase_texcoord3.y ) , v.ase_texcoord3.x));
				float3 temp_output_20_0_g1 = ( 0.001 * appendResult18_g1 );
				float dotResult16_g1 = dot( temp_output_20_0_g1 , temp_output_20_0_g1 );
				float ifLocalVar182_g1 = 0;
				if( dotResult16_g1 > 0.0001 )
				ifLocalVar182_g1 = 1.0;
				else if( dotResult16_g1 < 0.0001 )
				ifLocalVar182_g1 = 0.0;
				float ChildMask26_g1 = saturate( ( ifLocalVar182_g1 * 100.0 ) );
				float SelfBendMask34_g1 = ( 1.0 - v.ase_texcoord4.y );
				float ifLocalVar220 = 0;
				if( TF_WIND_DIRECTION.x == 0.0 )
				ifLocalVar220 = 0.0;
				else
				ifLocalVar220 = 1.0;
				float ifLocalVar221 = 0;
				if( TF_WIND_DIRECTION.z == 0.0 )
				ifLocalVar221 = 0.0;
				else
				ifLocalVar221 = 1.0;
				float3 lerpResult250 = lerp( float3(0,0,1) , TF_WIND_DIRECTION , ( ifLocalVar220 + ifLocalVar221 ));
				float3 worldToObjDir226 = ASESafeNormalize( mul( GetWorldToObjectMatrix(), float4( lerpResult250, 0 ) ).xyz );
				float3 WindDir225 = worldToObjDir226;
				float3 WindVector226_g1 = WindDir225;
				float3 appendResult11_g1 = (float3(( -1.0 * v.ase_texcoord1.x ) , v.ase_texcoord2.x , ( -1.0 * v.ase_texcoord1.y )));
				float3 temp_output_19_0_g1 = ( 0.001 * appendResult11_g1 );
				float3 SelfPivot28_g1 = temp_output_19_0_g1;
				float3 objToWorld54_g1 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float2 temp_cast_0 = ((( ( SelfPivot28_g1 * 1.0 ) + ( objToWorld54_g1 / -2.0 ) )).z).xx;
				float2 panner48_g1 = ( 1.0 * _Time.y * float2( 0,0.85 ) + temp_cast_0);
				float simplePerlin2D53_g1 = snoise( panner48_g1*_ChildWindMapScale );
				simplePerlin2D53_g1 = simplePerlin2D53_g1*0.5 + 0.5;
				float ChildRotation43_g1 = radians( ( simplePerlin2D53_g1 * 12.0 * _ChildWindStrength ) );
				float3 rotatedValue81_g1 = RotateAroundAxis( SelfPivot28_g1, v.vertex.xyz, normalize( WindVector226_g1 ), ChildRotation43_g1 );
				float3 ChildRotationResult119_g1 = ( ( ChildMask26_g1 * SelfBendMask34_g1 ) * ( rotatedValue81_g1 - v.vertex.xyz ) );
				float temp_output_113_0_g1 = saturate( ( 4.0 * pow( SelfBendMask34_g1 , _BendingMaskStrength1 ) ) );
				float dotResult9_g1 = dot( temp_output_19_0_g1 , temp_output_19_0_g1 );
				float ifLocalVar189_g1 = 0;
				if( dotResult9_g1 > 0.0001 )
				ifLocalVar189_g1 = 1.0;
				else if( dotResult9_g1 < 0.0001 )
				ifLocalVar189_g1 = 0.0;
				float TrunkMask29_g1 = saturate( ( ifLocalVar189_g1 * 1000.0 ) );
				float3 ParentPivot27_g1 = temp_output_20_0_g1;
				float3 lerpResult51_g1 = lerp( SelfPivot28_g1 , ParentPivot27_g1 , ChildMask26_g1);
				float2 temp_cast_1 = ((lerpResult51_g1).z).xx;
				float2 panner61_g1 = ( 1.0 * _Time.y * float2( 0,0.45 ) + temp_cast_1);
				float simplePerlin2D60_g1 = snoise( panner61_g1*_ParentWindMapScale );
				simplePerlin2D60_g1 = simplePerlin2D60_g1*0.5 + 0.5;
				float saferPower185_g1 = abs( simplePerlin2D60_g1 );
				float ParentRotation63_g1 = radians( ( pow( saferPower185_g1 , 3.0 ) * 25.0 * _ParentWindStrength ) );
				float3 lerpResult98_g1 = lerp( SelfPivot28_g1 , ParentPivot27_g1 , ChildMask26_g1);
				float3 rotatedValue96_g1 = RotateAroundAxis( lerpResult98_g1, ( ChildRotationResult119_g1 + v.vertex.xyz ), normalize( WindVector226_g1 ), ParentRotation63_g1 );
				float saferPower160_g1 = abs( v.ase_texcoord4.x );
				float MainBendMask35_g1 = saturate( pow( saferPower160_g1 , _MainBendMaskStrength ) );
				float3 ParentRotationResult131_g1 = ( ChildRotationResult119_g1 + ( ( ( ( ( temp_output_113_0_g1 * ( 1.0 - ChildMask26_g1 ) ) + ChildMask26_g1 ) * TrunkMask29_g1 ) * ( rotatedValue96_g1 - v.vertex.xyz ) ) * MainBendMask35_g1 ) );
				float3 objToWorld47_g1 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 saferPower172_g1 = abs( ( objToWorld47_g1 / ( -15.0 * _MainWindScale ) ) );
				float2 panner71_g1 = ( 1.0 * _Time.y * float2( 0,0.07 ) + (pow( saferPower172_g1 , 2.0 )).xz);
				float simplePerlin2D70_g1 = snoise( panner71_g1*2.0 );
				simplePerlin2D70_g1 = simplePerlin2D70_g1*0.5 + 0.5;
				float MainRotation67_g1 = radians( ( simplePerlin2D70_g1 * 25.0 * _MainWindStrength ) );
				float3 temp_output_125_0_g1 = ( ParentRotationResult131_g1 + v.vertex.xyz );
				float3 rotatedValue121_g1 = RotateAroundAxis( float3(0,0,0), temp_output_125_0_g1, normalize( WindVector226_g1 ), MainRotation67_g1 );
				float temp_output_148_0_g1 = pow( MainBendMask35_g1 , 5.0 );
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float2 panner86 = ( 1.0 * _Time.y * float2( -0.2,0.4 ) + (( ase_worldPos / -8.0 )).xz);
				float simplePerlin2D85 = snoise( panner86*10.0 );
				simplePerlin2D85 = simplePerlin2D85*0.5 + 0.5;
				
				o.ase_texcoord1.xyz = ase_worldPos;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				o.ase_texcoord1.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( ( ( ParentRotationResult131_g1 + ( ( rotatedValue121_g1 - temp_output_125_0_g1 ) * temp_output_148_0_g1 ) ) * _WindOverallStrength * TF_WIND_STRENGTH ) + ( _LeafFlutterStrength * ( v.ase_texcoord.y * simplePerlin2D85 ) * TF_WIND_STRENGTH * 0.6 ) );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				o.clipPos = TransformWorldToHClip(positionWS);

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord3 = v.ase_texcoord3;
				o.ase_texcoord4 = v.ase_texcoord4;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord3 = patch[0].ase_texcoord3 * bary.x + patch[1].ase_texcoord3 * bary.y + patch[2].ase_texcoord3 * bary.z;
				o.ase_texcoord4 = patch[0].ase_texcoord4 * bary.x + patch[1].ase_texcoord4 * bary.y + patch[2].ase_texcoord4 * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float2 uv_BaseColor = IN.ase_texcoord.xy * _BaseColor_ST.xy + _BaseColor_ST.zw;
				float4 tex2DNode1 = tex2D( _BaseColor, uv_BaseColor );
				float Opacity34 = tex2DNode1.a;
				
				float3 ase_worldPos = IN.ase_texcoord1.xyz;
				float lerpResult167 = lerp( _MaskClip , ( _MaskClip * 0.4 ) , ( distance( ase_worldPos , _WorldSpaceCameraPos ) / 150.0 ));
				#ifdef _DISTANCEBASEDMASKCLIP_ON
				float staticSwitch196 = lerpResult167;
				#else
				float staticSwitch196 = _MaskClip;
				#endif
				float Mask_Clip157 = staticSwitch196;
				

				surfaceDescription.Alpha = Opacity34;
				surfaceDescription.AlphaClipThreshold = Mask_Clip157;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;

				#ifdef SCENESELECTIONPASS
					outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				#elif defined(SCENEPICKINGPASS)
					outColor = _SelectionID;
				#endif

				return outColor;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ScenePickingPass"
			Tags { "LightMode"="Picking" }

			AlphaToMask Off

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define ASE_TRANSLUCENCY 1
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 140009


			#pragma vertex vert
			#pragma fragment frag

		    #define SCENEPICKINGPASS 1

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#pragma shader_feature_local _DISTANCEBASEDMASKCLIP_ON
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Undercolor;
			float4 _NormalMap_ST;
			float4 _Color;
			float4 _BaseColor_ST;
			float _VertexAOIntensity;
			float _Smoothness;
			float _NormalScale;
			float _UndercolorAmount;
			float _BaseColorSaturation;
			float _AOIntensity;
			float _ChildWindMapScale;
			float _WindOverallStrength;
			float _MainWindStrength;
			float _MainWindScale;
			float _MainBendMaskStrength;
			float _ParentWindStrength;
			float _ParentWindMapScale;
			float _BendingMaskStrength1;
			float _ChildWindStrength;
			float _LeafFlutterStrength;
			float _MaskClip;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			float3 TF_WIND_DIRECTION;
			float TF_WIND_STRENGTH;
			sampler2D _BaseColor;


			real3 ASESafeNormalize(float3 inVec)
			{
				real dp3 = max(FLT_MIN, dot(inVec, inVec));
				return inVec* rsqrt( dp3);
			}
			
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
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 appendResult18_g1 = (float3(( -1.0 * v.ase_texcoord2.y ) , ( -1.0 * v.ase_texcoord3.y ) , v.ase_texcoord3.x));
				float3 temp_output_20_0_g1 = ( 0.001 * appendResult18_g1 );
				float dotResult16_g1 = dot( temp_output_20_0_g1 , temp_output_20_0_g1 );
				float ifLocalVar182_g1 = 0;
				if( dotResult16_g1 > 0.0001 )
				ifLocalVar182_g1 = 1.0;
				else if( dotResult16_g1 < 0.0001 )
				ifLocalVar182_g1 = 0.0;
				float ChildMask26_g1 = saturate( ( ifLocalVar182_g1 * 100.0 ) );
				float SelfBendMask34_g1 = ( 1.0 - v.ase_texcoord4.y );
				float ifLocalVar220 = 0;
				if( TF_WIND_DIRECTION.x == 0.0 )
				ifLocalVar220 = 0.0;
				else
				ifLocalVar220 = 1.0;
				float ifLocalVar221 = 0;
				if( TF_WIND_DIRECTION.z == 0.0 )
				ifLocalVar221 = 0.0;
				else
				ifLocalVar221 = 1.0;
				float3 lerpResult250 = lerp( float3(0,0,1) , TF_WIND_DIRECTION , ( ifLocalVar220 + ifLocalVar221 ));
				float3 worldToObjDir226 = ASESafeNormalize( mul( GetWorldToObjectMatrix(), float4( lerpResult250, 0 ) ).xyz );
				float3 WindDir225 = worldToObjDir226;
				float3 WindVector226_g1 = WindDir225;
				float3 appendResult11_g1 = (float3(( -1.0 * v.ase_texcoord1.x ) , v.ase_texcoord2.x , ( -1.0 * v.ase_texcoord1.y )));
				float3 temp_output_19_0_g1 = ( 0.001 * appendResult11_g1 );
				float3 SelfPivot28_g1 = temp_output_19_0_g1;
				float3 objToWorld54_g1 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float2 temp_cast_0 = ((( ( SelfPivot28_g1 * 1.0 ) + ( objToWorld54_g1 / -2.0 ) )).z).xx;
				float2 panner48_g1 = ( 1.0 * _Time.y * float2( 0,0.85 ) + temp_cast_0);
				float simplePerlin2D53_g1 = snoise( panner48_g1*_ChildWindMapScale );
				simplePerlin2D53_g1 = simplePerlin2D53_g1*0.5 + 0.5;
				float ChildRotation43_g1 = radians( ( simplePerlin2D53_g1 * 12.0 * _ChildWindStrength ) );
				float3 rotatedValue81_g1 = RotateAroundAxis( SelfPivot28_g1, v.vertex.xyz, normalize( WindVector226_g1 ), ChildRotation43_g1 );
				float3 ChildRotationResult119_g1 = ( ( ChildMask26_g1 * SelfBendMask34_g1 ) * ( rotatedValue81_g1 - v.vertex.xyz ) );
				float temp_output_113_0_g1 = saturate( ( 4.0 * pow( SelfBendMask34_g1 , _BendingMaskStrength1 ) ) );
				float dotResult9_g1 = dot( temp_output_19_0_g1 , temp_output_19_0_g1 );
				float ifLocalVar189_g1 = 0;
				if( dotResult9_g1 > 0.0001 )
				ifLocalVar189_g1 = 1.0;
				else if( dotResult9_g1 < 0.0001 )
				ifLocalVar189_g1 = 0.0;
				float TrunkMask29_g1 = saturate( ( ifLocalVar189_g1 * 1000.0 ) );
				float3 ParentPivot27_g1 = temp_output_20_0_g1;
				float3 lerpResult51_g1 = lerp( SelfPivot28_g1 , ParentPivot27_g1 , ChildMask26_g1);
				float2 temp_cast_1 = ((lerpResult51_g1).z).xx;
				float2 panner61_g1 = ( 1.0 * _Time.y * float2( 0,0.45 ) + temp_cast_1);
				float simplePerlin2D60_g1 = snoise( panner61_g1*_ParentWindMapScale );
				simplePerlin2D60_g1 = simplePerlin2D60_g1*0.5 + 0.5;
				float saferPower185_g1 = abs( simplePerlin2D60_g1 );
				float ParentRotation63_g1 = radians( ( pow( saferPower185_g1 , 3.0 ) * 25.0 * _ParentWindStrength ) );
				float3 lerpResult98_g1 = lerp( SelfPivot28_g1 , ParentPivot27_g1 , ChildMask26_g1);
				float3 rotatedValue96_g1 = RotateAroundAxis( lerpResult98_g1, ( ChildRotationResult119_g1 + v.vertex.xyz ), normalize( WindVector226_g1 ), ParentRotation63_g1 );
				float saferPower160_g1 = abs( v.ase_texcoord4.x );
				float MainBendMask35_g1 = saturate( pow( saferPower160_g1 , _MainBendMaskStrength ) );
				float3 ParentRotationResult131_g1 = ( ChildRotationResult119_g1 + ( ( ( ( ( temp_output_113_0_g1 * ( 1.0 - ChildMask26_g1 ) ) + ChildMask26_g1 ) * TrunkMask29_g1 ) * ( rotatedValue96_g1 - v.vertex.xyz ) ) * MainBendMask35_g1 ) );
				float3 objToWorld47_g1 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 saferPower172_g1 = abs( ( objToWorld47_g1 / ( -15.0 * _MainWindScale ) ) );
				float2 panner71_g1 = ( 1.0 * _Time.y * float2( 0,0.07 ) + (pow( saferPower172_g1 , 2.0 )).xz);
				float simplePerlin2D70_g1 = snoise( panner71_g1*2.0 );
				simplePerlin2D70_g1 = simplePerlin2D70_g1*0.5 + 0.5;
				float MainRotation67_g1 = radians( ( simplePerlin2D70_g1 * 25.0 * _MainWindStrength ) );
				float3 temp_output_125_0_g1 = ( ParentRotationResult131_g1 + v.vertex.xyz );
				float3 rotatedValue121_g1 = RotateAroundAxis( float3(0,0,0), temp_output_125_0_g1, normalize( WindVector226_g1 ), MainRotation67_g1 );
				float temp_output_148_0_g1 = pow( MainBendMask35_g1 , 5.0 );
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float2 panner86 = ( 1.0 * _Time.y * float2( -0.2,0.4 ) + (( ase_worldPos / -8.0 )).xz);
				float simplePerlin2D85 = snoise( panner86*10.0 );
				simplePerlin2D85 = simplePerlin2D85*0.5 + 0.5;
				
				o.ase_texcoord1.xyz = ase_worldPos;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				o.ase_texcoord1.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = ( ( ( ParentRotationResult131_g1 + ( ( rotatedValue121_g1 - temp_output_125_0_g1 ) * temp_output_148_0_g1 ) ) * _WindOverallStrength * TF_WIND_STRENGTH ) + ( _LeafFlutterStrength * ( v.ase_texcoord.y * simplePerlin2D85 ) * TF_WIND_STRENGTH * 0.6 ) );

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord3 = v.ase_texcoord3;
				o.ase_texcoord4 = v.ase_texcoord4;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord3 = patch[0].ase_texcoord3 * bary.x + patch[1].ase_texcoord3 * bary.y + patch[2].ase_texcoord3 * bary.z;
				o.ase_texcoord4 = patch[0].ase_texcoord4 * bary.x + patch[1].ase_texcoord4 * bary.y + patch[2].ase_texcoord4 * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float2 uv_BaseColor = IN.ase_texcoord.xy * _BaseColor_ST.xy + _BaseColor_ST.zw;
				float4 tex2DNode1 = tex2D( _BaseColor, uv_BaseColor );
				float Opacity34 = tex2DNode1.a;
				
				float3 ase_worldPos = IN.ase_texcoord1.xyz;
				float lerpResult167 = lerp( _MaskClip , ( _MaskClip * 0.4 ) , ( distance( ase_worldPos , _WorldSpaceCameraPos ) / 150.0 ));
				#ifdef _DISTANCEBASEDMASKCLIP_ON
				float staticSwitch196 = lerpResult167;
				#else
				float staticSwitch196 = _MaskClip;
				#endif
				float Mask_Clip157 = staticSwitch196;
				

				surfaceDescription.Alpha = Opacity34;
				surfaceDescription.AlphaClipThreshold = Mask_Clip157;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
						clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;

				#ifdef SCENESELECTIONPASS
					outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				#elif defined(SCENEPICKINGPASS)
					outColor = _SelectionID;
				#endif

				return outColor;
			}

			ENDHLSL
		}
		
	}
	
	CustomEditor "UnityEditor.ShaderGraphLitGUI"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
