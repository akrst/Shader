Shader "SS/TexDistanceCircle003"{
    Properties{
        _MainTex("MainTex", 2D) = "white"{}    
    }
    
    CGINCLUDE 
    #include "UnityCG.cginc"
     
    sampler2D _MainTex;   
    float4 frag(v2f_img i) : SV_Target{
        float d = distance(float2(0.5, 0.5), i.uv);
        d = sin(d * 10 - _CosTime * 100) ;
        d = sqrt(100-d*d);
        float4 col = tex2D(_MainTex, d);
        return col;
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