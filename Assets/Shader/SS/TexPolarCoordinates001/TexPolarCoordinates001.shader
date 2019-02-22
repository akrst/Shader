Shader "SS/TexPolarCoordinates001"
{
    Properties{
        _MainTex("MainTex", 2D) = "white"{}    
        _Alpha("Alpha", Range(0, 1)) = 1
    }
    
    CGINCLUDE 
    #include "UnityCG.cginc"
    // #define PI 3.14159265359
     
    sampler2D _MainTex; 
    float _Alpha;  
    float4 frag(v2f_img i) : SV_Target{
        float2 st = 0.5 -i.uv;
        float a = atan2(st.y, st.x);
        float d = min(abs(cos(a * 2.5)) + 0.4, abs(sin(a * 2.5)) + 1.1) * 0.32;
        float r = length(st);
        float4 col = tex2D(_MainTex, d+sin( _Time.y * 2)) * _Alpha;
        return col;
    } 
    ENDCG
    
    SubShader{
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        LOD 100
 
        Blend SrcAlpha OneMinusSrcAlpha 
        Pass{
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            ENDCG
        }
    }
    FallBack "Diffuse"
}