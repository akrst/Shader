Shader "Custom/MyShader" {
    // Inspectorに表示するプロパティを宣言
    Properties{
        _Bump("Bump", 2D)="white"{} 
    }
    
    SubShader{
        Tags{"RenderType" = "Opaque"}

        CGPROGRAM
        #pragma surface surf Lambert
    
        struct Input {
            float2 uv_Bump;
        };
        
        sampler2D _Bump;
        void surf(Input IN, inout SurfaceOutput o){
            o.Albedo = half3(1.0, 0.6, 0.4);
            // tex2D関数の出力をo.Nomalに代入するだけでは、表示がおかしくなる
            // UnpackNormal関数を使って変換したものをo.Normalに代入することで、正常に表示されるようになる
            o.Normal = UnpackNormal(tex2D(_Bump, IN.uv_Bump));
        }
        ENDCG
    }
    FallBack "Diffuse"
}