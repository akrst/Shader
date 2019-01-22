Shader "SS/PolarCoordinates001"{
    Properties{
        _MainTex("MainTex", 2D) = "white"{}    
    }
    
    CGINCLUDE 
    #include "UnityCG.cginc"
    #define PI 3.14159265359
     
    sampler2D _MainTex;   
    float4 frag(v2f_img i) : SV_Target{
        float2 st = 0.5 -i.uv;
        float a = atan2(st.y, st.x);
        // atan2の戻り値は -PI~PIの範囲なので
        // 正規化して色として出力
        return (a + PI) / (PI * 2);
    } 
    ENDCG
    
    SubShader{
        Pass{
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            ENDCG
        }
    }
    FallBack "Diffuse"
}