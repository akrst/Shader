Shader "ShaderSketches/DistanceField003"{
    Properties{
        _MainTex("MainTex", 2D) = "white"{}    
    }
    
    CGINCLUDE
    #include "UnityCG.cginc" 
    float heart(float2 st){
        // 位置とか形の調整
        st = (st - float2(0.5, 0.38))* float2(2.1, 2.8);
        
        return pow(st.x, 2) + pow(st.y - sqrt(abs(st.x)), 2);
    }
    float4 frag(v2f_img i) : SV_Target{
        float d = heart(i.uv);
        return step(d, abs(sin(d * 8 - _Time.w * 2))) ;
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