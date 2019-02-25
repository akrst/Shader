// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TexDistanceGradationAlpha"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _Threshold ("Threshold", Range(0., 1.)) = 1

	}
	SubShader
	{
		Tags { "Queue"="Transparent" "RenderType"="Transparent" }
		LOD 100

		Pass
		{
            Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

            float _Threshold;
            sampler2D _MainTex;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;

			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
                float alpha = distance(float2(0.5, 0.5), i.uv) * 1.5;
				float4 col = tex2D(_MainTex, i.uv);
                col.a  = abs(_Threshold - alpha);
				return col;
			}
			ENDCG
		}
	}
}