Shader "TexDistortionSin001"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        _SinWave("SinWave", Range(0, 1)) = 0.2
        _SinWidth("SinWidth", Range(0, 1)) = 0.5
        _SinSpeed("SinSpeed", Range(0, 1)) = 0.2
        _SinColorDistant("SinColorDistant", Range(0, 1)) = 0.2
	}
	SubShader
	{
		Tags 
        {
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }

		LOD 100
        Cull Off
        Blend One OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
                fixed4 col : COLOR;
				float2 uv : TEXCOORD0;
                float2 texcoord : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
                fixed4 col : COLOR;
                float2 texcoord : TEXCOORD1;
				float4 vertex : SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _SinWave;
			float _SinWidth;
			float _SinSpeed;
			float _SinColorDistant;
            fixed4 _Color;

			float _wave;
			float _speed;
			float _width;
			float _clrDis;
            
            float2 posColor(float2 inUV, float n)
			{
				return inUV + float2(sin(inUV.y *_wave + _speed + _clrDis * n) * _width, 0);
			}
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = v.texcoord;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.col = v.col * _Color;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = fixed4(0, 0, 0, 0);

				float2 inUV = i.texcoord;

				_wave = _SinWave * 100;
				_speed = _Time.y * _SinSpeed * 20.0;
				_width = _SinWidth * 0.2;
				_clrDis = _SinColorDistant * _SinWidth * 5;

				if(_SinColorDistant==0){//カラーチャンネルを分けない

					float mysin = sin(inUV.y *_wave + _speed) * _width;
					col = tex2D(_MainTex, inUV + float2(mysin, 0));

				}else{//カラーチャンネルを個別に設定

					col.r = tex2D(_MainTex, posColor(inUV, 2)).r;
					col.g = tex2D(_MainTex, posColor(inUV, 1)).g;
					col.b = tex2D(_MainTex, posColor(inUV, 0)).b;
					col.a = (
						tex2D(_MainTex, posColor(inUV, 2)).a+
						tex2D(_MainTex, posColor(inUV, 1)).a+
						tex2D(_MainTex, posColor(inUV, 0)).a
					)/3;

				}                
				// sample the texture
				col *= i.col;
				col.rgb *= col.a;

				return col;
			}
			ENDCG
		}
	}
}
