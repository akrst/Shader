Shader "SS/TransformGrid002"
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

    float2 transform_uv(float2 uv, float2 radius)
    {
        float distance = length(0.5 - uv);
        float distortion = 1 - smoothstep(radius * 90, radius, distance);
        return uv + (0.5 - uv) * distortion;
    }
    
    float4 frag(v2f_img i) : SV_Target
    {
        i.uv = screen_aspect(i.uv);
        
        float radius = (1 + sin(_Time.y)) * 0.05 + 0.05;
        float2 uv = transform_uv(i.uv, radius);

        float2 fst = frac(uv * 7);
        float4 grid = lerp(float4(0, 0, 0, 1),
                           float4(1, 1, 1, 1),
                           step(0.95, fst.x) + step(0.95, fst.y));
        return grid;
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