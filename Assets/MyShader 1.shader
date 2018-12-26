Shader "Custom/MyShader" {
    Properties{
        _DiffuseColor("Diffuse Color", Color)=(1.0, 1.0, 1.0)
        // 第2引数にCUBEを指定すると、キューブマップとして認識される
        _Cube("Cubemap", CUBE)= ""{} 
        _Bump("Bump", 2D)= "white"{}
    }
    
    SubShader{
        Tags{"RenderType" = "Opaque"}
        Cull Off
        CGPROGRAM
        #pragma surface surf Lambert
    
        struct Input {
            float2 uv_Bump;
            // サーフェスシェーダーにオブジェクトの反射ベクトルを入力できる
            float3 worldRefl;
            // INTERNAL_DATAを追加しなければ、エラーになる
            INTERNAL_DATA
        };
        float3 _DiffuseColor;
        // キューブマップテクスチャを受けとるための変数を定義
        // キューブマップは｢samplerCUBE｣という型で定義する
        samplerCUBE _Cube;
        sampler2D _Bump;
        void Surf (Input IN, inout SurfaceOutputStandard o){
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}