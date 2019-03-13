Shader "SS/TexLatticeA001"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _Alpha("Alpha", Range(0, 1)) = 1
        _squareSize("SquareSize", Range(0, 50)) = 10
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
            #define PI 3.14159265359

            int _UseScreenAspectRatio;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Alpha;
            float _squareSize;


            float2 screen_aspect(float2 uv)
            {
                if (_UseScreenAspectRatio == 0)
                    return uv;

                uv.x -= 0.5;
                uv.x *= _ScreenParams.x / _ScreenParams.y;
                uv.x += 0.5;
                return uv;
            }

            float2 rotate(float2 st, float angle)
            {
                float2x2 mat = float2x2(cos(angle), -sin(angle),
                                        sin(angle), cos(angle));
                st -= 0.5;
                st = mul(mat, st);
                st += 0.5;
                return st;
            }

            float box(float2 st, float t)
            {
                st = rotate(st, t * 2.05 * PI / 4);
                
                float size = t * 1.42;
                st = step(size, st) * step(size, 1.0 - st);
                return st.x * st.y;
            }
            
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


            float4 frag(v2f i) : SV_Target
            {
                float2 iuvs = screen_aspect(i.uv);
                float2 iuvr = rotate(iuvs, PI / 4);

                float n = _squareSize;
                float freq = 2.5 * length(0.5 - (floor(iuvr * n) + 0.5) / n);
                float t = sin(-_Time.y * 2 + freq) * 0.5;
                float4 col = tex2D(_MainTex, i.uv) * _Alpha;
                col.a = box(frac(iuvr * n), t);
                return col;

            }

             ENDCG
    	}
	}
}
