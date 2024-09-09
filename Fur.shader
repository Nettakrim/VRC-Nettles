Shader "Custom/Fur"
{
    Properties
    {
        _MainTex("Albedo", 2D) = "black" {} //fallback
        _Color ("Color", Color) = (1,1,1,1) //fallback

        _ColorMain ("Color Main", Color) = (1,1,1,1)
        _ColorHigh ("Color High", Color) = (1,1,1,1)
        _ColorLow ("Color Low", Color) = (1,1,1,1)
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        _NoiseStrength ("Noise Strength", Float) = 1.0
        _NoiseSteps ("Noise Steps", Float) = 10.0

        _HueMain ("Hue Main", Range(0,6.2832)) = 0.0
        _HueAlt ("Hue Alt", Range(0,6.2832)) = 0.0

        _OutlineColor ("Outline color", Color) = (0,0,0,1)
		_OutlineWidth ("Outline width", Range (0.0, 1.0)) = 0.5
    }
    SubShader
    {
		Tags{ "Queue" = "Geometry-1" "RenderType"="Opaque" "VRCFallback"="Standard"}
        LOD 200

		Pass //Outline from https://github.com/Shrimpey/Outlined-Diffuse-Shader-Fixed/blob/master/UniformOutline.shader
		{
			ZWrite Off
			Cull Back
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

            uniform float _OutlineWidth;
            uniform float3 _OutlineColor;

            struct appdata
            {
                float4 vertex : POSITION;
            };
        
            struct v2f
            {
                float4 pos : POSITION;
            };
        

			v2f vert(appdata v)
			{
				appdata original = v;
				v.vertex.xyz += _OutlineWidth * normalize(v.vertex.xyz);

				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;

			}

            float _HueAlt;
            float3 HueShift(float3 col)
            {
                const float3 k = float3(0.57735, 0.57735, 0.57735);
                half cosAngle = cos(_HueAlt);
                return col * cosAngle + cross(k, col) * sin(_HueAlt) + k * dot(k, col) * (1.0 - cosAngle);
            }

			half4 frag(v2f i) : COLOR
			{
                float3 col = HueShift(_OutlineColor);
				return half4(col.r, col.g, col.b, 1.0);
			}

			ENDCG
		}

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct appdata
        {
            float4 vertex    : POSITION;  
            float3 normal    : NORMAL;    
            float4 texcoord  : TEXCOORD0; 
            float4 texcoord1 : TEXCOORD1; 
            float4 texcoord2 : TEXCOORD2; 
            float4 tangent   : TANGENT;  
            float4 color     : COLOR;

            uint vertexID : SV_VertexID;
            uint instanceID : SV_InstanceID;

        };

        struct Input
        {
            float2 uv_MainTex;
            float3 worldNormal;
            float3 viewDir;
            float4 vertexCol : COLOR;
            float id;
        };

        half _Glossiness;
        half _Metallic;

        fixed4 _ColorMain;
        fixed4 _ColorHigh;
        fixed4 _ColorLow;

        float _NoiseStrength;
        float _NoiseSteps;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void vert (inout appdata v, out Input o) {
            UNITY_SETUP_INSTANCE_ID(v);
            UNITY_INITIALIZE_OUTPUT(Input,o);

            o.id = frac(sin((float)(v.vertexID)));
        }

        float _HueMain;
        float3 HueShift(float3 col)
        {
            const float3 k = float3(0.57735, 0.57735, 0.57735);
            half cosAngle = cos(_HueMain);
            return col * cosAngle + cross(k, col) * sin(_HueMain) + k * dot(k, col) * (1.0 - cosAngle);
        }
        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float c = GammaToLinearSpace(IN.vertexCol.r);
            c = ((round(c*3.999)/3.999)*2.0)-1.0;

            c += (round(IN.id*_NoiseSteps)/_NoiseSteps * _NoiseStrength) - _NoiseStrength/2.0;

            fixed4 col = _ColorHigh*saturate(c) + _ColorMain*saturate(1-abs(c)) + _ColorLow*saturate(-c);

            o.Albedo = HueShift(col.rgb);

            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = col.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
