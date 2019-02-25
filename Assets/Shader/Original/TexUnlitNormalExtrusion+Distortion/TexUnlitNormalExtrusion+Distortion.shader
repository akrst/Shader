Shader "TexUnlitNormalExtrusion+Distortion"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _Alpha("Alpha", Range(0, 1)) = 1
        _Speed("Speed", Range(1, 100)) = 1
		[HideInInspector] __dirty( "", Int ) = 1
        _ExtrusionAmount("Extrusion Amount", Range( -1 , 20)) = 0.5
		_ExtrusionPoint("ExtrusionPoint", Float) = 0
	}
	SubShader
	{
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        LOD 100
 
        Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

            float circle(float2 st)  {
                return step(0.3, distance(0.5, st));
            }

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
                float3 normal :NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
            float _Alpha;
            float _Speed;
		    float _ExtrusionAmount;
            float _ExtrusionPoint;

			v2f vert (appdata v)
			{
				v2f o;
                v.vertex.xyz += ( v.normal * max( ( sin( ( ( v.vertex.y + _Time.x * _Speed ) / _ExtrusionPoint ) ) / _ExtrusionAmount ) , 0.0 ) );
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
                //歪みの計算
                float x = 2 * i.uv.y + sin (_Time.y *5);
                float distort = sin(_Time.y * 10) * 0.1 * sin(5 * x) * (-(x -1)* (x - 1) + 1);
                //座標を歪ませる
                i.uv.x += distort;
                //RGBごとに少しずつ座標をずらす
                float4 d = (circle(i.uv - float2(0, distort) * 0.3),
                            circle(i.uv + float2(0, distort) * 0.3),
                            circle(i.uv + float2(distort, 0) * 0.3), 1);
                float4 col = tex2D(_MainTex, i.uv.x += distort) * _Alpha;
                col %= d * sin(2 * x);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}