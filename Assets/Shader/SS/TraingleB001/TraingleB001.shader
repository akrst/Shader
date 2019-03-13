Shader "SS/TriangleB001"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white"{}
    }

    CGINCLUDE
    #include "UnityCG.cginc"
    
    int _UseScreenAspectRatio;


    float2 screen_aspect(float2 uv)
    {
        if (_UseScreenAspectRatio == 0)
            return uv;

        uv.x -= 0.5;
        uv.x *= _ScreenParams.x / _ScreenParams.y;
        uv.x += 0.5;
        return uv;
    }

    float tri(float2 st, float t)
    {
        float tsin = (1 + sin(t * 2) * 0.5) * 1.7;
        float2 fst = frac(st);
        return step(tsin, fst.x + fst.y);
    }

    float4 frag(v2f_img i) : SV_Target
    {
        i.uv = screen_aspect(i.uv);
        
        float2 t = _Time.xy;
        float2 st = i.uv;
        
        float a = tri(frac((st + t.x * 2) * 8), t.y + 0.50) +
                  tri(frac((st + t.x * 4) * 4), t.y + 0.25) +
                  tri(frac((st + t.x * 8) * 2), t.y + 0.00);
        a /= 3;

        return float4(step(0.9, a),
                      step(0.5, a),
                      step(0.1, a), 1);
    }

    ENDCG

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            ENDCG
        }
    }
}