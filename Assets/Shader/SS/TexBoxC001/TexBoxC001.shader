﻿Shader "SS/TexBoxC001"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _Alpha("Alpha", Range(0, 1)) = 1
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

            float3 hue_to_rgb(float h)
            {
                h = frac(h) * 6 - 2;
                return saturate(float3(abs(h - 1) - 1, 2 - abs(h),
                                2 - abs(h - 2)));
            }

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

            float tri(float2 st, float size)
            {
                float2 fst = frac(st);
                return step(size * 0.1, fst.x + fst.y);
            }

            float box(float2 st, float t)
            {
                st = rotate(st, t * 2.05 * PI / 4);
                
                float size = t * 1.42;
                st = step(size, st) * step(size, 1.0 - st);
                return st.x * st.y;
            }

            float swirl(float2 st)
            {
                float phi = atan2(st.y, st.x);
                return tan(length(st) * -4 + phi - _Time.y * -2) * 0.5 + 0.5;
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
                //i.uv = screen_aspect(i.uv);
                
                float2 st = i.uv + float2(i.uv.y * 0.5 - 0.25, 0);
                float sw = swirl(floor((st) * 13) / 13 - 0.5);
                sw = lerp(float4(hue_to_rgb(sw * 0.4 + 0.8), 1),
                            float4(0, 0, 0, 1),
                    box(frac(st * 13), sw));
                float4 col = tex2D(_MainTex, sw) * _Alpha;
                col.a = sw;
                return col;
            }
            ENDCG
    	}
	}
}