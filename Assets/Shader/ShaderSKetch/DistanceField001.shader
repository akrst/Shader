Shader "SS/DistanceField001"{
    Properties{
        _MainTex("MainTex", 2D) = "white"{}    
    }
    
    CGINCLUDE
    #include "UnityCG.cginc" 
    // 自身の座標から中心の座標までのディスタンスフィールドを作る
    float4 frag(v2f_img i) : SV_Target{
        // distance(a, b) aとbの距離を返す 
        float d = distance(float2(0.5, 0.5), i.uv);
        float a = abs(sin(_Time.y)) * 0.4; // 閾値
        // xがa以上なら1 aより小さければ0
        return step(a, d);
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