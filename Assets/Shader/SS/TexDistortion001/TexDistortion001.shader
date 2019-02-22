Shader "SS/TexDistortion001"{
    Properties{
        _MainTex("MainTex", 2D) = "white"{}    
        _Alpha("Alpha", Range(0, 1)) = 1
    }
    
    CGINCLUDE 
    #include "UnityCG.cginc"
    
    float circle(float2 st)  {
        return step(0.3, distance(0.5, st));
    }
    sampler2D _MainTex;
    float _Alpha;

    float4 frag(v2f_img i) : SV_Target{
        //歪みの計算
        float x = 2 * i.uv.y + sin (_Time.y *5);
        float distort = sin(_Time.y * 10) * 0.1 * sin(5 * x) * (-(x -1)* (x - 1) + 1);
        //座標を歪ませる
        i.uv.x += distort;
        //RGBごとに少しずつ座標をずらす
        float4 d = (circle(i.uv - float2(0, distort) * 0.3),
                     circle(i.uv + float2(0, distort) * 0.3),
                     circle(i.uv + float2(distort, 0) * 0.3), 1);
        float4 col = tex2D(_MainTex, i.uv.x += distort) * _Alpha;
        col %= d * sin(2 * x);
        return col;
    } 
    ENDCG
    
    SubShader{
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        LOD 100
 
        ZWrite Off
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