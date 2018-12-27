Shader "SS/DistanceField004"{
    Properties{
        _MainTex("MainTex", 2D) = "white"{}    
    }
    
    CGINCLUDE
    #include "UnityCG.cginc"         
    float4 frag(v2f_img i) : SV_Target{
        float d = abs(tan(i.uv *3.0));
        return step(d, abs(tan(d * 8 - _Time.w * 1))) ;
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