// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'



// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "HOLO/Holo_adv_2"
{
	Properties
	{
		_Diffuse("Diffuse Map", 2D) = "white" {}
		[HDR] _diff_Color ("Diffuse Color Mult", Color) = (1,1,1,1)
		_N_map("Noise", 2D) = "white" {}
		_M_map("Mask", 2D) = "white" {}
		[Toggle] _mask_type("Use Map as Mask", Float) = 1
		_intensity("Intensity", range (0,5.0)) = 0
		_deform("Deformation intensity", float) = 1
		[HDR] _Color ("Outline Color Mult", Color) = (1,1,1,1)
		_Opacity("Opacity", range (0,1)) = 0
		_Bias("Bias", range (0,1)) = 0
		_Scale ("Scale ", range (0,10)) = 0
		_Power("Power", range (0,3)) = 0
		//_Opacity_gl("Glitch Opacity", range (0,1)) = 0
		_Speed("Speed", range (0,1)) = 0
		_t("Extra Option", range (0,1)) = 0
		[Toggle] _X("X Axes", Float) = 1
		[Toggle] _Y("Y Axes", Float) = 1
		[Toggle] _glitchColor("Glitch/Diffuse Color", Float) = 1
		[HDR] _glitchColor_c ("Glitch Color", Color) = (1,1,1,1)
		_noise_details("Noise Details", range (1,16)) = 0
		_cut_level("Cut Level", range (0,1) ) = 0
		_OrigineX("OrigineX", range (0,1)) = 0
		_OrigineY("OrigineY", range (0,1)) = 0
		_Circle_wave("Circle_wave", range (0,100)) = 5
		_Speed_wave("Speed_wave", float) = 0
		_Zoom("Zoom", Range(0.5, 200)) = 1
    	_Speed_face ("_Speed_face", Range(0.01, 10)) = 1
    	_Rotation("Rotation", Range(0, 1)) = 0
		//[Toggle] _grey("GREY", Float) = 1
		_Distance("Distance", float) = 0
		_Amplitude("Amplitude", float) = 0
		_Speed_Up("_Speed_Up", float) = 0
		_Amount("Amount", Range(0, 1)) = 0



	}

	Subshader
	{
		//http://docs.unity3d.com/462/Documentation/Manual/SL-SubshaderTags.html
	    // Background : 1000     -        0 - 1499 = Background
        // Geometry   : 2000     -     1500 - 2399 = Geometry
        // AlphaTest  : 2450     -     2400 - 2699 = AlphaTest
        // Transparent: 3000     -     2700 - 3599 = Transparent
        // Overlay    : 4000     -     3600 - 5000 = Overlay
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			Zwrite on
			ZTest on
			//cull off
			CGPROGRAM
			//http://docs.unity3d.com/Manual/SL-ShaderPrograms.html
			#pragma vertex vert
			#pragma fragment frag


			#include "UnityCG.cginc"

			//http://docs.unity3d.com/ru/current/Manual/SL-ShaderPerformance.html
			//http://docs.unity3d.com/Manual/SL-ShaderPerformance.html

			// VARIABLES ///////////////////////////////////////////////////////////////////////////////////////////
			uniform half4 _Color;
			uniform half4 _diff_Color ;
			uniform sampler2D _Diffuse;
			uniform sampler2D _N_map;
			uniform sampler2D _M_map;

			uniform float4 _Diffuse_ST;
			uniform float4 _N_map_ST;
			uniform float4 _M_map_ST;
			uniform float _intensity;
			uniform float _deform ;
			uniform float _Bias ;
			uniform float _Scale ;
			uniform float _Power ;
			uniform float _Speed ;
			uniform float _t ;
			uniform float _noise_details ;
			uniform float _cut_level ;
			uniform float _X ;
			uniform float _Y ;
			uniform float _mask_type ;
			//uniform float _grey ;
			uniform float _glitchColor ;
			uniform half4 _glitchColor_c ;
			uniform float _Opacity ;
			uniform float _OrigineX ;
			uniform float _OrigineY ;
			uniform float _Speed_wave ;
			uniform float _Circle_wave ;
			half _Zoom;
      		half _Speed_face;
      		uniform float _Rotation ;
			//uniform float _Opacity_gl ;

			uniform float _Distance ;
			uniform float _Amplitude ;
			uniform float _Speed_Up ;
			uniform float _Amount ;



			////////////////////////////////////////////////////////////////////////////////////////////////////////


			//https://msdn.microsoft.com/en-us/library/windows/desktop/bb509647%28v=vs.85%29.aspx#VS

			// STRUCTURS  //////////////////////////////////////////////////////////////////////////////////////////
			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 normal : NORMAL;

			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 pos_w : TEXCOORD5;
				float4 uv : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float3 uv_matcap : TEXCOORD2;
				float3 normalDir : TEXCOORD3;
				float4 R : TEXCOORD4;
				float4 normal : NORMAL;
				float4 mpos : TEXCOORD6;

			};
			////////////////////////////////////////////////////////////////////////////////////////////////////////


			// FUNCTIONS /////////////////////////////////////////////////////////////////////////////////////////////

			float4 glitch(float2 coord)
			{
				float4 c = float4(coord,0,1);
			    float4 d;
			    float4 e;
			    for (int j=_noise_details;j>0;j--) {
			        e=floor(c);
			        d+=(sin(e*e.yxyx+e*(_Time/10)));
			       	c*=2.5;
			    }
				float4 glitch_res = d;
				return glitch_res;
			}
			//////////////////////////////////////////////////////////////////////////////////////////////////////////


			// VERTEX OPERATIONS ////////////////////////////////////////////////////////////////////////////////////
			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				UNITY_INITIALIZE_OUTPUT(vertexOutput, o);

				fixed T = 1;//(_Time * _Speed*30);
				fixed offset_sin = sin(T*2);
				fixed offset_cos = cos(T*2);
				/////// Procedural Mask wave
				fixed4 colors;
        		float distanceToCenter;
        		float time = _Time.x * _Speed_wave;

        		float xdist = _OrigineX - v.texcoord.x;
        		float ydist = _OrigineY - v.texcoord.y;

       			distanceToCenter = (xdist * xdist + ydist * ydist) * _Circle_wave;

       			colors = (sin(distanceToCenter + time)+1)/2;
				colors.a = 1;
        ////////////////
				float4 mask_map = colors ; //tex2Dlod(_M_map, float4((v.texcoord.xy * ((((_M_map_ST.y),(_M_map_ST.y * offset_cos)))  ) + (((_M_map_ST.z ),(_M_map_ST.w * offset_sin)))),0,0));
				float4 glitch_ver = glitch(v.texcoord.xy)*(0.001 *  _deform)* mask_map.x * (0.1*_intensity) ;
				float3 axe = float3(_X,_Y,1);
				float Animation_Sinus = sin(_Time.y * _Speed_Up + (v.vertex.y*axe.y) +(v.vertex.x*axe.x)* _Amplitude)  *_Distance * _Amount * _cut_level;
				//v.vertex.xyz += (glitch_ver.xyz * axe * v.normal.xyz) ;//v.normal.xyz
				v.vertex.x += Animation_Sinus *axe.x *glitch_ver.x;
				v.vertex.y += Animation_Sinus *axe.y *glitch_ver.y;
				//v.vertex.x += (glitch_ver.x * axe.x * v.normal.x ) ;//v.normal.xyz
				//v.vertex.y += (glitch_ver.x * axe.y * v.normal.y ) ;//v.normal.xyz


				// PROJECTIONS
				o.mpos = v.vertex;
				o.pos = UnityObjectToClipPos( v.vertex);
				float3 posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;

				o.uv = v.texcoord;

				o.pos_w.xyz = posWorld;

				//float3 normWorld = normalize(mul(float3x3(unity_ObjectToWorld), v.normal));


				float3 normalVS = mul(UNITY_MATRIX_MV,v.normal);
				normalVS = normalize(normalVS);

				o.normalDir = UnityObjectToWorldNormal(v.normal);
				o.uv_matcap.xy = normalVS.xy * 0.5 + float2(0.5,0.5);

				float3 I = normalize(posWorld - _WorldSpaceCameraPos.xyz);
				fixed temp1 =  dot(I, o.normalDir) + _t;
				o.R.x = _Bias * _Scale * pow(temp1, _Power);

				// Pivot
		        //float2 pivot = float2(0, 0);
		        // Rotation Matrix
		        //float cosAngle = cos(_a);
		        //float sinAngle = sin(_a);
		        //float2x2 rot = float2x2(cosAngle, -sinAngle, sinAngle, cosAngle);

		        // Rotation consedering pivot
		        //float2 uv = o.uv.xy - pivot;
		        //o.uv.xy = mul(rot,uv);
		        //o.uv.xy += pivot;

				return o;
			}
			////////////////////////////////////////////////////////////////////////////////////////////////////////


			// FRAGMENTS OPERATIONS ///////////////////////////////////////////////////////////////////////////////
			half4 frag(vertexOutput i , float facing : VFACE) : COLOR
			{

				fixed T = 1;//_Time * _Speed*30	 ;
				fixed offset_sin =  (sin(T*2)+1);
				fixed offset_cos = (cos(T*2)+1);

				/////// Procedural Mask wave
				fixed4 colors;
		        float distanceToCenter;
		        float time = _Time.x * _Speed_wave;

		        float xdist = _OrigineX - i.uv.x;
		        float ydist = _OrigineY - i.uv.y;

		        distanceToCenter = (xdist * xdist + ydist * ydist) * _Circle_wave;

		        colors = (sin(distanceToCenter + time)+1)/2;
		        colors.a = 1;
				//clip (frac((i.pos_w.y + i.pos_w.x*0.01)*0.2)-_a);

				// Pivot
				_Rotation *= 1.57;
		        float2 pivot = float2(0, 0);
		        // Rotation Matrix
		        float cosAngle = cos(_Rotation);
		        float sinAngle = sin(_Rotation);
		        float2x2 rot = float2x2(cosAngle, -sinAngle, sinAngle, cosAngle);

		        // Rotation consedering pivot
		        float2 uv = i.uv.xy - pivot;
		        i.uv.yz = mul(rot,uv);
		        i.uv.yz += pivot;


				//////////////////////////////////
				float4 temp_noise = tex2D(_N_map, float2((i.pos.xy/ _ScreenParams.xy) + float2(_CosTime.x * 100*_Speed_face, _SinTime.x *100* _Speed_face) / _Zoom)); //tex2D(_N_map, float4((i.uv.xy * (_N_map_ST.xy  ) + (_N_map_ST.zw  * T)),0,0));
				float4 mask = colors;// tex2D(_M_map, float4((i.uv.xy * ((((_M_map_ST.y),(_M_map_ST.y * offset_cos)))  ) + (((_M_map_ST.z ),(_M_map_ST.w * offset_sin)))),0,0));
				float4 mask_map = tex2D(_M_map, float4((i.uv.xy * ((((_M_map_ST.y),(_M_map_ST.y * offset_cos)))  ) + (((_M_map_ST.z ),(_M_map_ST.w * offset_sin)))),0,0));
				fixed temp = temp_noise.x * mask.x   ;

				float4 diff = tex2D(_Diffuse, i.uv);
				i.uv.xy += (temp * sin(1)* i.uv.x)*(_intensity) ;

				float4 col = tex2D(_Diffuse ,float4((i.uv_matcap.xy * ((_Diffuse_ST.x), _Diffuse_ST.y  ) + ((_Diffuse_ST.z ),_Diffuse_ST.w )), 0,0)) ;
				float Animation_Sinus_frag = sin(_Time.y * _Speed_Up + (i.uv.y) * _Amplitude)  *_Distance * _Amount;
				//////////// Procedural noise glitch

				float4 glitch_res = glitch(i.uv.xy) * _glitchColor ;
				//////////////////////////////////////
				float4 col2 = _Color;



				float variant = temp * sin(1) ;
				col2.r += (variant * glitch_res.x * (_intensity)*0.25)  ;
				col2.g +=(variant * glitch_res.y* (_intensity)*0.5)  ;
				col2.b += (variant  * glitch_res.x * (_intensity)) ;



				col.a *= _Opacity;
				col *= _diff_Color ;

				fixed col2_to_grey = (col2.r +col2.g + col2.b) /3;
				fixed col_to_grey = (col.r +col.g + col.b) /3;
				col2.rgb = float3(col2_to_grey,col2_to_grey,col2_to_grey);
				col.rgb = float3(col_to_grey,col_to_grey,col_to_grey);
				col2.rgb *= _glitchColor_c;
				//col.rgb *= _glitchColor_c + 0.3;
				_cut_level *= col2_to_grey.x *10  ;
				//_cut_level *= sin(_Time *20);


				//Transition
				float trans_coord = i.uv.z;
				float transition = lerp(1, 0, _cut_level*trans_coord);

				if ((i.mpos.y) < (transition))
				{
				discard ;
				}


				/////// Erosion value
				float ero_value = step(_cut_level/50, mask.r);


			return lerp(col,col2,i.R.x);;
			}
			///////////////////////////////////////////////////////////////////////////////////////////////////////

			ENDCG
		}
	}

}
