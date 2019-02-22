Shader "TexVertexWave+BoxRandom001x"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white"{}
        _Alpha("Alpha", Range(0, 1)) = 1
        _Boxsize("BoxSize", Range(0, 10)) = 5
        _Speed("Speed ",Range(0, 100)) = 1
        _Frequency("Frequency ", Range(0, 3)) = 1
        _Amplitude("Amplitude", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        LOD 100
 
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha 

        Pass
        {
            CGPROGRAM
           #pragma vertex vert
           #pragma fragment frag
            
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
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv     : TEXCOORD0;

            };
            
            sampler2D _MainTex;
            float _Alpha;
            float _Boxsize;
            float _Speed;
            float _Frequency;
            float _Amplitude;

            v2f vert (appdata v)
            {
                v2f o;
                
                // 時間によって波が移動するように
                float time     = _Time * _Speed;
                float offsetX  = sin(time + v.vertex.y * _Frequency) + sin(time + v.vertex.z * _Frequency);
                offsetX         *= _Amplitude;
                v.vertex.x      += offsetX;
                o.vertex        = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            float4 frag (v2f i) : SV_Target
            {
                float n = _Boxsize;
                float2 st = frac(i.uv * n);
                float4 col = tex2D(_MainTex, box_size(i.uv, n)) * _Alpha;
                return col;
            }
            ENDCG
        }
    }
}