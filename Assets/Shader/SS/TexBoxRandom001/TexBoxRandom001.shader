Shader "SS/TexBoxRandom001"
{
    Properties{
        _MainTex("MainTex", 2D) = "white"{}
        _Alpha("Alpha", Range(0, 1)) = 1
    }
    
    CGINCLUDE 
    #include "UnityCG.cginc"
    // #define PI 3.14159265359
     float rand(float2 st){
         return frac(sin(dot(st, float2(12.9898, 78.233))) * 43758.5453);
     }

     float box_size(float2 st, float n){
         st = (floor(st * n)+0.5) /n;
         float offs = rand(st) * 5;
         return (1 + sin(_Time.y * 3 + offs)) * 0.5;
     }

    sampler2D _MainTex; 
    float _Alpha;  
    float4 frag(v2f_img i) : SV_Target{
        float n = 5;
        float2 st = frac(i.uv * n);
        float4 col = tex2D(_MainTex, rand(st) * box_size(i.uv, n)) * _Alpha;
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