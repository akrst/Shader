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
        void surf(Input IN, inout SurfaceOutput o){
            o.Albedo = _DiffuseColor * 0.5;
            o.Normal = UnpackNormal(tex2D(_Bump, IN.uv_Bump));
            // texCUBEの第2引数が（WorldReflectionVector(IN, o.Normal)）とすることで
            // 入力されたIN.worldReflに対して、o.Normal（法線マッピング）の処理を追加
            // これで法線マッピング（バンプマッピング）を考慮した鏡面反射が実現できる
            o.Emission = texCUBE(_Cube, WorldReflectionVector(IN, o.Normal)).rgb;
        }   
        ENDCG
    }
    FallBack "Diffuse"
}