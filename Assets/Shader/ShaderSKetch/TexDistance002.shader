﻿Shader "SS/TexDistance002"{
    Properties{
        _MainTex("MainTex", 2D) = "white"{}    
    }
    
    CGINCLUDE
    #include "UnityCG.cginc"      

    sampler2D _MainTex;   
    float4 frag(v2f_img i) : SV_Target{
        float d = abs(atan(i.uv));
        d = abs(cos(d * 8 - _Time.w * 1));
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