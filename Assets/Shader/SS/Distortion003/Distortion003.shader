Shader "SS/Distortion003"{
    Properties{
        _MainTex("MainTex", 2D) = "white"{}    
    }


    CGINCLUDE 
    #include "UnityCG.cginc"
    float circle(float2 st)  {
        return step(0.3, distance(0.5, st));
    }

    float4 frag(v2f_img i) : SV_Target{
        float2 st = i.uv;
        float x = 2 * st.y + sin (_Time.y * 3);
        st.x += sin(_Time.y * 10) * 0.5 * sin(5 * x) * (-(x -1)* (x - 1) + 1);
        return float4(circle(i.uv - float2(0, st.x) * 0.1),
                     circle(i.uv + float2(0, st.x) * 0.1),
                     circle(i.uv + float2(st.x, 0) * 0.1), 1);
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