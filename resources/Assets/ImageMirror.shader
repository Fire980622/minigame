// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Xcqy/ImageMirror"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Offset ("Offset", float) = 0.0//表示顶点的偏移量
		_AlphaFadeIn ("AlphaFadeIn", Range(0,1)) = 0.0//淡入位置
		_AlphaFadeOut ("AlphaFadeOut", Range(0,1)) = 1.0//淡出位置
        _Alpha ("Alpha", Range(0,1)) = 1 //透明度
		_Color ("Tint", Color) = (1,1,1,1)

		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15
	}

	CGINCLUDE
	//定义顶点的输入结构
		struct appdata_ui
		{
			float4 vertex   : POSITION;
			float4 color    : COLOR;
			float2 texcoord : TEXCOORD0;
		};

		//定义顶点到片段的结构
		struct v2f_ui
		{
			float4 pos   : SV_POSITION;
			fixed4 color    : COLOR;
			half2 uv  : TEXCOORD0;
			float4 worldPosition : TEXCOORD1;
		};

		fixed4 _Color;

		//两个Pass通用的顶点函数
		void vert_ui(inout appdata_ui Input, out v2f_ui Output){

            Output.worldPosition = Input.vertex;
			Output.pos = UnityObjectToClipPos(Input.vertex);
				Output.uv = Input.texcoord;
			#ifdef UNITY_HALF_TEXEL_OFFSET
				Output.uv.xy += (_ScreenParams.zw-1.0)*float2(-1,1);
			#endif
				Output.color = Input.color * _Color;
		}
	ENDCG

	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
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
		Fog { Mode Off }
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		Pass
		{
			//第一个Pass，正常渲染
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
            #include "UnityUI.cginc"

			v2f_ui vert(appdata_ui v)
			{
				v2f_ui o;
				vert_ui(v, o);
				return o;
			}

			sampler2D _MainTex;
            float4 _ClipRect;

			fixed4 frag(v2f_ui i) : SV_Target
			{
				half4 color = tex2D(_MainTex, i.uv) * i.color;
                color.a *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
				clip (color.a - 0.01);
				return color;
			}
		ENDCG
		}

		Pass
		{
			//第二个Pass，渲染倒影
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
            #include "UnityUI.cginc"

			sampler2D _NoiseTex;

            float4 _ClipRect;
			float _Offset;
			float _AlphaFadeIn;
			float _AlphaFadeOut;
            float _Alpha;

			v2f_ui vert(appdata_ui v)
			{
				v2f_ui o;
				//v.vertex.y = v.vertex.y - _Offset;//偏移顶点坐标
				//vert_ui(v, o);

				            o.worldPosition = v.vertex;
							float4 cs= v.vertex;
							 cs.y = v.vertex.y - _Offset;//偏移顶点坐标
			o.pos = UnityObjectToClipPos( cs);
				o.uv = v.texcoord;
			#ifdef UNITY_HALF_TEXEL_OFFSET
				o.uv.xy += (_ScreenParams.zw-1.0)*float2(-1,1);
			#endif
				o.color = v.color * _Color;

				return o;
			}

			sampler2D _MainTex;

			fixed4 frag(v2f_ui i) : SV_Target
			{

                //把UV上下翻转
				float2 ruv = float2(i.uv.x, 1 - i.uv.y);
				//使用扭曲UV对纹理采样
				float4 c = tex2D (_MainTex, ruv);
				//对淡入Alpha和淡出Alpha的插值
				fixed fadeA = saturate((_AlphaFadeOut - ruv.y) / (_AlphaFadeOut - _AlphaFadeIn));
                i.color.a = i.color.a * fadeA * _Alpha;
                i.color.a *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
				c = c * _Color * i.color;
				clip (c.a - 0.01);
				return c;
			}
		ENDCG
		}
	}
}