Shader "SS/Distrotion001"{
    Properties{
        _MainTex("MainTex", 2D) = "white"{}    
    }
    
    CGINCLUDE 
    #include "UnityCG.cginc"

    float circle(float2 st)  {
        return step(0.3, distance(0.5, st));
    }

    float4 frag(v2f_img i) : SV_Target{
        i.uv.x += sin(i.uv.y * 20) * 0.05;
        return circle(i.uv);
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