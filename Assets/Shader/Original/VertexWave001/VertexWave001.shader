Shader "TexVertexWave001"
{
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

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };
            
            v2f vert (appdata v)
            {
                v2f o;

                // x座標とz座標に応じて-1～1の連続した値を計算する
                float offsetY  = sin(v.vertex.x) + sin(v.vertex.z);
                // その値をy座標に足す
                v.vertex.y      += offsetY;
                o.vertex        = UnityObjectToClipPos(v.vertex);

                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = 1;
                return col;
            }
            ENDCG
        }
    }
}