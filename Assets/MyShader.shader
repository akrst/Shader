Shader "Custom/MyShader" {
    // Inspectorに表示するプロパティを宣言
    Properties{
        _Texture("Texture", 2D) = "white"{}
        //アルファチャンネルのビットマップをInspectorビューで指定できるように、追加
        _AlphaMap("AlphaMap", 2D) = "white"{}
    }
    
    SubShader{
        Tags{"Queue" = "Transparent" "RenderType" = "Opaque"}
        // 裏面を描画するために、カリングをオフにする
        Cull off
        CGPROGRAM
        #pragma surface surf Lambert alpha
        struct Input {
            float2 uv_Texture;
            // struct Input{}; の中にアルファチェンネル用のuv座標を入力パラメータとしてsurf関数に渡すため追加
            // 名前は uv_プロパティ変数名となるので、uv_AlphaMapとなる
            float2 uv_AlphaMap;
        };

        sampler2D _Texture;
        // アルファチェンネル用のイメージ情報を受け取るための変数を定義する（propertiesと同名）
        sampler2D _AlphaMap;

        void surf(Input IN, inout SurfaceOutput o){
            // テクスチャマッピングと同様tex2Dを使うが、その出力先をo.Alphaにするだけで
            // イメージの濃淡がアルファチェンネル（透明度）として使用できる
            o.Alpha = tex2D(_AlphaMap, IN.uv_AlphaMap);
            o.Albedo = tex2D(_Texture, IN.uv_Texture).rgb * o.Alpha;
        }
        ENDCG
    }
    FallBack "Diffuse"
}