﻿Shader "SS/TexDistanceCircle003"{
    Properties{
        _MainTex("MainTex", 2D) = "white"{}    
        _Alpha("Alpha", Range(0, 1)) = 1
    }
    
    CGINCLUDE 
    #include "UnityCG.cginc"
     
    sampler2D _MainTex;
    float _Alpha;
    float4 frag(v2f_img i) : SV_Target{
        float d = distance(float2(0.5, 0.5), i.uv);
        d = sin(d * 10 - _CosTime * 100) ;
        d = sqrt(100-d*d);
        float4 col = tex2D(_MainTex, d) * _Alpha;
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