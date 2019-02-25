Shader "TexUnlitNormalExtrusion"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _ExtrusionAmount("Extrusion Amount", Range( -1 , 20)) = 0.5
		[HideInInspector] __dirty( "", Int ) = 1
		_ExtrusionPoint("ExtrusionPoint", Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

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
		    float _ExtrusionAmount;            
            float _ExtrusionPoint;
			
			v2f vert (appdata v)
			{
				v2f o;
                v.vertex.xyz += ( v.normal * max( ( sin( ( ( v.vertex.y + _Time.x ) / _ExtrusionPoint ) ) / _ExtrusionAmount ) , 0.0 ) );
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}