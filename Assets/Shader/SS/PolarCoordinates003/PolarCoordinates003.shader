Shader "SS/PolarCoordinates003"
{
    Properties{
        _MainTex("MainTex", 2D) = "white"{}    
    }
    
    CGINCLUDE 
    #include "UnityCG.cginc"
    // #define PI 3.14159265359
     
    sampler2D _MainTex;   
    float4 frag(v2f_img i) : SV_Target{
        float2 st = 0.5 -i.uv;
        float a = atan2(st.y, st.x);
        float d = min(abs(cos(a * 2.5)) + 0.4, abs(sin(a * 2.5)) + 1.1) * 0.32;
        float r = length(st);
        return step(r, d);
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