Shader "TexUnlitNormalExtrusion+BoxRandom"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _Alpha("Alpha", Range(0, 1)) = 1
        _Boxsize("BoxSize", Range(0, 10)) = 5
        _ExtrusionAmount("Extrusion Amount", Range( -1 , 20)) = 0.5
        _Speed("Speed", Range(1, 100)) = 1
		[HideInInspector] __dirty( "", Int ) = 1
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

            float rand(float2 st){
                return frac(sin(dot(st, float2(12.9898, 78.233))) * 43758.5453);
            }

            float box_size(float2 st, float n){
                st = (floor(st * n)+0.5) /n;
                float offs = rand(st) * 5;
                return (1 + sin(_Time.y * 3 + offs)) * 0.5;
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
            float _Boxsize;
            float _Speed;
            float _ExtrusionPoint;
		    float _ExtrusionAmount;

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
                float n = _Boxsize;
                float2 st = frac(i.uv * n);
                float4 col = tex2D(_MainTex, box_size(i.uv, n)) * _Alpha;
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
