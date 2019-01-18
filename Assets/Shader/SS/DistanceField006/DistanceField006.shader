Shader "SS/DistanceField006"{
    Properties{
        _MainTex("MainTex", 2D) = "white"{}    
    }
    
    CGINCLUDE
    #include "UnityCG.cginc"
    float4 frag(v2f_img i) : SV_Target
    {
        float d = distance(float2(0.5, 0.5), i.uv);
        d = abs(cos(d * (_Time.y))) * 40; 
        d = sqrt(100-d*d);
        return d;
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