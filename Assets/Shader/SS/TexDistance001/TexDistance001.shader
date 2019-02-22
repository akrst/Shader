 Shader "SS/TexDistance001"{
    Properties{
        _MainTex("MainTex", 2D) = "white"{}
        _Alpha("Alpha", Range(0, 1)) = 1
    }
    
    CGINCLUDE
    #include "UnityCG.cginc"      

    sampler2D _MainTex;   
    float _Alpha;
    fixed4 _Color;
    float4 frag(v2f_img i) : SV_Target{
        float d = abs(atan(i.uv));
        d = ddx(tan(d * 8 - _Time.y * 1));
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