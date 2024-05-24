Shader "Ciconia Studio/CS_Skin/Builtin/SSS Skin (Specular setup) Opaque"
{
	Properties
	{
		[Space(35)][Header(Main Properties________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________)][Space(15)]_GlobalXYTilingXYZWOffsetXY("Global --> XY(TilingXY) - ZW(OffsetXY)", Vector) = (1,1,0,0)
		[Space(15)]_Color("Color -->BaseColor Intensity(A)", Color) = (1,1,1,1)
		[Toggle]_InvertABaseColor("Invert Alpha", Float) = 0
		_MainTex("Base Color", 2D) = "white" {}
		_Saturation("Saturation", Float) = 0
		_Brightness("Brightness", Range( 1 , 8)) = 1
		[Space(35)]_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpScale("Normal Intensity", Float) = 0.3
		[Space(35)]_SpecularColor("Specular Color -->Desaturate(A)", Color) = (1,1,1,0)
		_SpecGlossMap("Specular Map -->Smoothness(A)", 2D) = "white" {}
		_SpecularIntensity("Specular Intensity", Range( 0 , 2)) = 0.2
		_Glossiness("Smoothness", Range( 0 , 2)) = 0.5
		[Space(10)][KeywordEnum(SpecularAlpha,BaseColorAlpha)] _Source("Source", Float) = 0
		[Header(Fresnel)]_FresnelIntensity("Intensity", Float) = 1
		_FresnelBias("Ambient", Range( 0 , 1)) = 0
		_Fresnelpower("Power", Float) = 3
		[Space(35)]_ParallaxMap("Height Map", 2D) = "white" {}
		_Parallax("Height Scale", Range( -0.1 , 0.1)) = 0
		[Space(35)]_OcclusionMap("Ambient Occlusion Map", 2D) = "white" {}
		_AoIntensity("Ao Intensity", Range( 0 , 2)) = 1
		[HDR][Space(45)]_EmissionColor("Emission Color", Color) = (0,0,0,0)
		_EmissionMap("Emission Map", 2D) = "white" {}
		_EmissionIntensity("Intensity", Range( 0 , 2)) = 1
		[Space(35)][Header(SSS Skin Properties________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________)][Space(15)][Toggle(_VISUALIZETRANSLUCENCY_ON)] _VisualizeTranslucency("Visualize Translucency", Float) = 0
		[Toggle]_LightIntensityToggle("Light Intensity", Float) = 1
		_LightAttenuationTranslucency("Light Attenuation", Range( 0 , 1)) = 1
		[Space(25)]_TranslucencyColor("Translucency Color", Color) = (1,1,1,1)
		_SaturateTraslucency("Saturation", Range( 0 , 2)) = 1
		[Space(25)][Header(Transucency Map)][Space(15)][Toggle]_InvertTranslucencyMap("Invert ", Float) = 0
		_TranslucencyMapRMaskA("Translucency Map (R) -->Mask(A)", 2D) = "black" {}
		_TranslucencyIntensity("Intensity", Range( 0 , 1)) = 1
		[Space(5)]_ContrastTranslucency("Contrast", Float) = 0
		_SpreadTranslucency("Spread", Range( 0 , 1)) = 0.5
		[Space(15)]_Power("Power", Float) = 1
		_NormalTranslucency("Normal Contribution", Float) = 0.5
		[Space(35)][Header(Ambient Translucency)][Space(15)][Toggle]_MaskTranslucency("Exclude - Use Translucency Alpha", Float) = 0
		[Toggle]_InvertTranslucencyAlpha("Invert", Float) = 0
		[Space(10)]_AmbientTranslucency("Ambient Power", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		_ThicknessTranslucency("Thickness", Range( 0 , 1)) = 0
		_DesaturateAmbientTranslucency("Desaturate", Range( 0 , 1)) = 0.5
		[Space(35)][Header(Skin Tone)][Toggle]_EnableSkinTone("Enable", Float) = 0
		_SkinBlend("Skin Blend", Range( 0 , 1)) = 1
		[Space(15)][KeywordEnum(Screen,ColorDodge,SoftLight)] _SkinBlendMode("Blend Mode", Float) = 0
		[Toggle]_ExcludeUseTranslucencyAlpha("Exclude - Use Translucency Alpha", Float) = 0
		[Space(15)]_SkinTone("Color", Color) = (0,0,0,0)
		_ContrastSkin("Skin Contrast", Float) = 1
		_SkinFill("Fill", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
		[Header(Forward Rendering Options)]
		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Reflections", Float) = 1.0
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature _SPECULARHIGHLIGHTS_OFF
		#pragma shader_feature _GLOSSYREFLECTIONS_OFF
		#pragma shader_feature_local _VISUALIZETRANSLUCENCY_ON
		#pragma shader_feature_local _SKINBLENDMODE_SCREEN _SKINBLENDMODE_COLORDODGE _SKINBLENDMODE_SOFTLIGHT
		#pragma shader_feature_local _SOURCE_SPECULARALPHA _SOURCE_BASECOLORALPHA
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
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float3 viewDir;
			half ASEVFace : VFACE;
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _EnableSkinTone;
		uniform float _Brightness;
		uniform float4 _Color;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _GlobalXYTilingXYZWOffsetXY;
		uniform sampler2D _ParallaxMap;
		uniform float4 _ParallaxMap_ST;
		uniform float _Parallax;
		uniform float _Saturation;
		uniform float4 _SkinTone;
		uniform float _ContrastSkin;
		uniform sampler2D _BumpMap;
		uniform float4 _BumpMap_ST;
		uniform float _BumpScale;
		uniform float _SkinFill;
		uniform float _ExcludeUseTranslucencyAlpha;
		uniform sampler2D _TranslucencyMapRMaskA;
		uniform float _SkinBlend;
		uniform float _ContrastTranslucency;
		uniform float _InvertTranslucencyMap;
		uniform float _SpreadTranslucency;
		uniform float _TranslucencyIntensity;
		uniform float _NormalTranslucency;
		uniform float _Power;
		uniform float _SaturateTraslucency;
		uniform float4 _TranslucencyColor;
		uniform float _DesaturateAmbientTranslucency;
		uniform float _ThicknessTranslucency;
		uniform float _AmbientTranslucency;
		uniform float _MaskTranslucency;
		uniform float _InvertTranslucencyAlpha;
		uniform float _LightAttenuationTranslucency;
		uniform float _LightIntensityToggle;
		uniform float4 _EmissionColor;
		uniform sampler2D _EmissionMap;
		uniform float4 _EmissionMap_ST;
		uniform float _EmissionIntensity;
		uniform float4 _SpecularColor;
		uniform sampler2D _SpecGlossMap;
		uniform float4 _SpecGlossMap_ST;
		uniform float _SpecularIntensity;
		uniform float _FresnelBias;
		uniform float _FresnelIntensity;
		uniform float _Fresnelpower;
		uniform float _Glossiness;
		uniform float _InvertABaseColor;
		uniform sampler2D _OcclusionMap;
		uniform float4 _OcclusionMap_ST;
		uniform float _AoIntensity;


		float4 CalculateContrast( float contrastValue, float4 colorTarget )
		{
			float t = 0.5 * ( 1.0 - contrastValue );
			return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			SurfaceOutputStandardSpecular s542 = (SurfaceOutputStandardSpecular ) 0;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 break26_g1075 = float4( uv_MainTex, 0.0 , 0.0 ).xy;
			float GlobalTilingX11 = ( _GlobalXYTilingXYZWOffsetXY.x - 1.0 );
			float GlobalTilingY8 = ( _GlobalXYTilingXYZWOffsetXY.y - 1.0 );
			float2 appendResult14_g1075 = (float2(( break26_g1075.x * GlobalTilingX11 ) , ( break26_g1075.y * GlobalTilingY8 )));
			float GlobalOffsetX10 = _GlobalXYTilingXYZWOffsetXY.z;
			float GlobalOffsetY9 = _GlobalXYTilingXYZWOffsetXY.w;
			float2 appendResult13_g1075 = (float2(( break26_g1075.x + GlobalOffsetX10 ) , ( break26_g1075.y + GlobalOffsetY9 )));
			float2 uv_ParallaxMap = i.uv_texcoord * _ParallaxMap_ST.xy + _ParallaxMap_ST.zw;
			float2 break26_g656 = uv_ParallaxMap;
			float2 appendResult14_g656 = (float2(( break26_g656.x * GlobalTilingX11 ) , ( break26_g656.y * GlobalTilingY8 )));
			float2 appendResult13_g656 = (float2(( break26_g656.x + GlobalOffsetX10 ) , ( break26_g656.y + GlobalOffsetY9 )));
			float4 temp_cast_2 = (tex2D( _ParallaxMap, ( appendResult14_g656 + appendResult13_g656 ) ).g).xxxx;
			float2 paralaxOffset36_g655 = ParallaxOffset( temp_cast_2.x , _Parallax , i.viewDir );
			float2 switchResult47_g655 = (((i.ASEVFace>0)?(paralaxOffset36_g655):(0.0)));
			float2 Parallaxe375 = switchResult47_g655;
			float4 tex2DNode7_g1074 = tex2D( _MainTex, ( ( appendResult14_g1075 + appendResult13_g1075 ) + Parallaxe375 ) );
			float4 lerpResult56_g1074 = lerp( _Color , ( ( _Color * tex2DNode7_g1074 ) * _Color.a ) , _Color.a);
			float clampResult27_g1074 = clamp( _Saturation , -1.0 , 100.0 );
			float3 desaturateInitialColor29_g1074 = lerpResult56_g1074.rgb;
			float desaturateDot29_g1074 = dot( desaturateInitialColor29_g1074, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar29_g1074 = lerp( desaturateInitialColor29_g1074, desaturateDot29_g1074.xxx, -clampResult27_g1074 );
			float clampResult11_g1078 = clamp( _ContrastSkin , 0.0 , 1000.0 );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult4_g1078 = dot( (WorldNormalVector( i , float3(0,0,1) )) , ase_worldlightDir );
			float LightAttenuation661 = ase_lightAtten;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			float2 break26_g697 = uv_BumpMap;
			float2 appendResult14_g697 = (float2(( break26_g697.x * GlobalTilingX11 ) , ( break26_g697.y * GlobalTilingY8 )));
			float2 appendResult13_g697 = (float2(( break26_g697.x + GlobalOffsetX10 ) , ( break26_g697.y + GlobalOffsetY9 )));
			float3 tex2DNode4_g696 = UnpackScaleNormal( tex2D( _BumpMap, ( ( appendResult14_g697 + appendResult13_g697 ) + Parallaxe375 ) ), _BumpScale );
			float3 Normal27 = tex2DNode4_g696;
			UnityGI gi620 = gi;
			float3 diffNorm620 = WorldNormalVector( i , Normal27 );
			gi620 = UnityGI_Base( data, 1, diffNorm620 );
			float3 indirectDiffuse620 = gi620.indirect.diffuse + diffNorm620 * 0.0001;
			float clampResult9_g1078 = clamp( _SkinFill , 0.0 , 1000.0 );
			float4 RGBBaseColor640 = tex2DNode7_g1074;
			float4 temp_cast_9 = (1.0).xxxx;
			float4 tex2DNode106_g1062 = tex2D( _TranslucencyMapRMaskA, i.uv_texcoord );
			float TranslucencyAlpha652 = tex2DNode106_g1062.a;
			float4 temp_cast_10 = (TranslucencyAlpha652).xxxx;
			float4 blendOpSrc637 = ( ( ( _SkinTone * CalculateContrast(clampResult11_g1078,float4( ( ( max( dotResult4_g1078 , 0.0 ) * ( LightAttenuation661 * ase_lightColor.rgb ) ) + indirectDiffuse620 + clampResult9_g1078 ) , 0.0 )) ) * RGBBaseColor640 ) * (( _ExcludeUseTranslucencyAlpha )?( temp_cast_10 ):( temp_cast_9 )) );
			float4 blendOpDest637 = CalculateContrast(_Brightness,float4( desaturateVar29_g1074 , 0.0 ));
			float4 blendOpSrc636 = ( ( ( _SkinTone * CalculateContrast(clampResult11_g1078,float4( ( ( max( dotResult4_g1078 , 0.0 ) * ( LightAttenuation661 * ase_lightColor.rgb ) ) + indirectDiffuse620 + clampResult9_g1078 ) , 0.0 )) ) * RGBBaseColor640 ) * (( _ExcludeUseTranslucencyAlpha )?( temp_cast_10 ):( temp_cast_9 )) );
			float4 blendOpDest636 = CalculateContrast(_Brightness,float4( desaturateVar29_g1074 , 0.0 ));
			float4 blendOpSrc634 = ( ( ( _SkinTone * CalculateContrast(clampResult11_g1078,float4( ( ( max( dotResult4_g1078 , 0.0 ) * ( LightAttenuation661 * ase_lightColor.rgb ) ) + indirectDiffuse620 + clampResult9_g1078 ) , 0.0 )) ) * RGBBaseColor640 ) * (( _ExcludeUseTranslucencyAlpha )?( temp_cast_10 ):( temp_cast_9 )) );
			float4 blendOpDest634 = CalculateContrast(_Brightness,float4( desaturateVar29_g1074 , 0.0 ));
			#if defined(_SKINBLENDMODE_SCREEN)
				float4 staticSwitch635 = ( saturate( ( 1.0 - ( 1.0 - blendOpSrc637 ) * ( 1.0 - blendOpDest637 ) ) ));
			#elif defined(_SKINBLENDMODE_COLORDODGE)
				float4 staticSwitch635 = ( saturate( ( blendOpDest636/ max( 1.0 - blendOpSrc636, 0.00001 ) ) ));
			#elif defined(_SKINBLENDMODE_SOFTLIGHT)
				float4 staticSwitch635 = ( saturate( 2.0f*blendOpDest634*blendOpSrc634 + blendOpDest634*blendOpDest634*(1.0f - 2.0f*blendOpSrc634) ));
			#else
				float4 staticSwitch635 = ( saturate( ( 1.0 - ( 1.0 - blendOpSrc637 ) * ( 1.0 - blendOpDest637 ) ) ));
			#endif
			float4 lerpResult783 = lerp( CalculateContrast(_Brightness,float4( desaturateVar29_g1074 , 0.0 )) , staticSwitch635 , _SkinBlend);
			float4 temp_cast_12 = (( (( _InvertTranslucencyMap )?( ( 1.0 - tex2DNode106_g1062.r ) ):( tex2DNode106_g1062.r )) + (-1.2 + (_SpreadTranslucency - 0.0) * (0.7 - -1.2) / (1.0 - 0.0)) )).xxxx;
			float4 clampResult126_g1062 = clamp( CalculateContrast(_ContrastTranslucency,temp_cast_12) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 newWorldNormal99_g1062 = normalize( (WorldNormalVector( i , float4( Normal27 , 0.0 ).xyz )) );
			float clampResult159_g1062 = clamp( _NormalTranslucency , 0.0 , 1000.0 );
			float dotResult115_g1062 = dot( ase_worldViewDir , -( ( newWorldNormal99_g1062 * clampResult159_g1062 ) + ase_worldlightDir ) );
			float saferPower169_g1062 = abs( dotResult115_g1062 );
			float clampResult160_g1062 = clamp( _Power , 0.0 , 1000.0 );
			float dotResult161_g1062 = dot( pow( saferPower169_g1062 , 0.0 ) , clampResult160_g1062 );
			float4 temp_output_137_0_g1062 = CalculateContrast(_SaturateTraslucency,_TranslucencyColor);
			float3 desaturateInitialColor175_g1062 = temp_output_137_0_g1062.rgb;
			float desaturateDot175_g1062 = dot( desaturateInitialColor175_g1062, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar175_g1062 = lerp( desaturateInitialColor175_g1062, desaturateDot175_g1062.xxx, _DesaturateAmbientTranslucency );
			float dotResult185_g1062 = dot( ase_worldViewDir , -( newWorldNormal99_g1062 + ase_worldlightDir ) );
			float saferPower120_g1062 = abs( dotResult185_g1062 );
			float clampResult122_g1062 = clamp( _AmbientTranslucency , 0.0 , 1000.0 );
			float dotResult124_g1062 = dot( pow( saferPower120_g1062 , (0.0 + (_ThicknessTranslucency - 0.0) * (15.0 - 0.0) / (1.0 - 0.0)) ) , clampResult122_g1062 );
			float TranslucencymapAlpha182_g1062 = tex2DNode106_g1062.a;
			float4 blendOpSrc148_g1062 = ( ( ( clampResult126_g1062 * _TranslucencyIntensity ) * saturate( ( dotResult115_g1062 * dotResult161_g1062 ) ) ) * temp_output_137_0_g1062 );
			float4 blendOpDest148_g1062 = float4( ( desaturateVar175_g1062 * saturate( ( ( dotResult185_g1062 * dotResult124_g1062 ) * (( _MaskTranslucency )?( (( _InvertTranslucencyAlpha )?( ( 1.0 - TranslucencymapAlpha182_g1062 ) ):( TranslucencymapAlpha182_g1062 )) ):( 1.0 )) ) ) ) , 0.0 );
			float lerpResult152_g1062 = lerp( 1.0 , LightAttenuation661 , _LightAttenuationTranslucency);
			float4 temp_output_138_0_g1062 = ( ( saturate( ( blendOpSrc148_g1062 + blendOpDest148_g1062 ) )) * lerpResult152_g1062 * (( _LightIntensityToggle )?( ase_lightColor.a ):( 1.0 )) );
			float4 VisualizeTranslucency400 = temp_output_138_0_g1062;
			#ifdef _VISUALIZETRANSLUCENCY_ON
				float4 staticSwitch468 = VisualizeTranslucency400;
			#else
				float4 staticSwitch468 = (( _EnableSkinTone )?( lerpResult783 ):( CalculateContrast(_Brightness,float4( desaturateVar29_g1074 , 0.0 )) ));
			#endif
			float4 Albedo26 = staticSwitch468;
			s542.Albedo = Albedo26.rgb;
			s542.Normal = WorldNormalVector( i , Normal27 );
			float2 uv_EmissionMap = i.uv_texcoord * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
			float2 break26_g1071 = uv_EmissionMap;
			float2 appendResult14_g1071 = (float2(( break26_g1071.x * GlobalTilingX11 ) , ( break26_g1071.y * GlobalTilingY8 )));
			float2 appendResult13_g1071 = (float2(( break26_g1071.x + GlobalOffsetX10 ) , ( break26_g1071.y + GlobalOffsetY9 )));
			float4 temp_output_5_0_g1070 = ( _EmissionColor * tex2D( _EmissionMap, ( ( appendResult14_g1071 + appendResult13_g1071 ) + Parallaxe375 ) ) );
			float4 Emission110 = ( temp_output_5_0_g1070 * _EmissionIntensity );
			s542.Emission = Emission110.rgb;
			float2 uv_SpecGlossMap = i.uv_texcoord * _SpecGlossMap_ST.xy + _SpecGlossMap_ST.zw;
			float2 break26_g1067 = uv_SpecGlossMap;
			float2 appendResult14_g1067 = (float2(( break26_g1067.x * GlobalTilingX11 ) , ( break26_g1067.y * GlobalTilingY8 )));
			float2 appendResult13_g1067 = (float2(( break26_g1067.x + GlobalOffsetX10 ) , ( break26_g1067.y + GlobalOffsetY9 )));
			float4 tex2DNode3_g1066 = tex2D( _SpecGlossMap, ( ( appendResult14_g1067 + appendResult13_g1067 ) + Parallaxe375 ) );
			float3 desaturateInitialColor508 = ( ( _SpecularColor * tex2DNode3_g1066 ) * _SpecularIntensity ).rgb;
			float desaturateDot508 = dot( desaturateInitialColor508, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar508 = lerp( desaturateInitialColor508, desaturateDot508.xxx, _SpecularColor.a );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
			float fresnelNdotV42_g1066 = dot( mul(ase_tangentToWorldFast,float4( Normal27 , 0.0 ).xyz), ase_worldViewDir );
			float fresnelNode42_g1066 = ( _FresnelBias + ( _SpecularIntensity * _FresnelIntensity ) * pow( 1.0 - fresnelNdotV42_g1066, _Fresnelpower ) );
			float clampResult38_g1066 = clamp( fresnelNode42_g1066 , 0.0 , 1.0 );
			float SpecularFresnel645 = clampResult38_g1066;
			float3 temp_cast_23 = (SpecularFresnel645).xxx;
			float3 blendOpSrc646 = desaturateVar508;
			float3 blendOpDest646 = temp_cast_23;
			float3 temp_cast_24 = (0.0).xxx;
			#ifdef _VISUALIZETRANSLUCENCY_ON
				float3 staticSwitch469 = temp_cast_24;
			#else
				float3 staticSwitch469 = ( saturate( 	max( blendOpSrc646, blendOpDest646 ) ));
			#endif
			float3 Specular41 = staticSwitch469;
			s542.Specular = Specular41;
			float BaseColorAlpha46 = (( _InvertABaseColor )?( ( 1.0 - tex2DNode7_g1074.a ) ):( tex2DNode7_g1074.a ));
			#if defined(_SOURCE_SPECULARALPHA)
				float staticSwitch31_g1066 = ( tex2DNode3_g1066.a * _Glossiness );
			#elif defined(_SOURCE_BASECOLORALPHA)
				float staticSwitch31_g1066 = ( _Glossiness * BaseColorAlpha46 );
			#else
				float staticSwitch31_g1066 = ( tex2DNode3_g1066.a * _Glossiness );
			#endif
			float Smoothness40 = staticSwitch31_g1066;
			s542.Smoothness = Smoothness40;
			float2 uv_OcclusionMap = i.uv_texcoord * _OcclusionMap_ST.xy + _OcclusionMap_ST.zw;
			float2 break26_g1069 = uv_OcclusionMap;
			float2 appendResult14_g1069 = (float2(( break26_g1069.x * GlobalTilingX11 ) , ( break26_g1069.y * GlobalTilingY8 )));
			float2 appendResult13_g1069 = (float2(( break26_g1069.x + GlobalOffsetX10 ) , ( break26_g1069.y + GlobalOffsetY9 )));
			float blendOpSrc2_g1068 = tex2D( _OcclusionMap, ( ( appendResult14_g1069 + appendResult13_g1069 ) + Parallaxe375 ) ).r;
			float blendOpDest2_g1068 = ( 1.0 - _AoIntensity );
			float AmbientOcclusion94 = ( saturate( ( 1.0 - ( 1.0 - blendOpSrc2_g1068 ) * ( 1.0 - blendOpDest2_g1068 ) ) ));
			s542.Occlusion = AmbientOcclusion94;

			data.light = gi.light;

			UnityGI gi542 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g542 = UnityGlossyEnvironmentSetup( s542.Smoothness, data.worldViewDir, s542.Normal, float3(0,0,0));
			gi542 = UnityGlobalIllumination( data, s542.Occlusion, s542.Normal, g542 );
			#endif

			float3 surfResult542 = LightingStandardSpecular ( s542, viewDir, gi542 ).rgb;
			surfResult542 += s542.Emission;

			#ifdef UNITY_PASS_FORWARDADD//542
			surfResult542 -= s542.Emission;
			#endif//542
			float4 Translucency158 = temp_output_138_0_g1062;
			c.rgb = ( float4( surfResult542 , 0.0 ) + Translucency158 ).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows exclude_path:deferred 

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
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
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
}