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
        [HDR] _OutlineEmission ("Outline emission", Color) = (0,0,0,1)
		_OutlineWidth ("Outline width", Range (0.0, 1.0)) = 0.5

        _NoiseStrengthGlow ("Noise Strength", Float) = 1.0
        _NoiseStepsGlow ("Noise Steps", Float) = 10.0

        _GlossinessGlow ("Smoothness Glow", Range(0,1)) = 0.5
        _MetallicGlow ("Metallic Glow", Range(0,1)) = 0.0

        _VertexRounding ("Vertex Rounding", Float) = 0.0
	}

	SubShader {
		Tags{ "Queue" = "Geometry+10" "RenderType"="Opaque" "VRCFallback"="Standard"}

        ZWrite Off
        Cull Back

		CGPROGRAM //Outline from https://github.com/Shrimpey/Outlined-Diffuse-Shader-Fixed/blob/master/UniformOutline.shader
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

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

        half _GlossinessGlow;
        half _MetallicGlow;

        uniform float _OutlineWidth;
        uniform fixed4 _OutlineColor;
        uniform fixed4 _OutlineEmission;

        float _NoiseStrengthGlow;
        float _NoiseStepsGlow;

        float _VertexRounding;


        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void vert (inout appdata v, out Input o) {
            UNITY_SETUP_INSTANCE_ID(v);
            UNITY_INITIALIZE_OUTPUT(Input,o);

            if (_VertexRounding > 0) {
                float rounding = 2 << ((int)max(10-_VertexRounding,5));
                v.vertex = round(v.vertex*rounding)/rounding;
            }

            o.id = frac(sin((float)(v.vertexID)));
            v.vertex.xyz += _OutlineWidth * normalize(v.vertex.xyz);
        }

        float _HueAlt;
        float3 HueShift(float3 col)
        {
            const float3 k = float3(0.57735, 0.57735, 0.57735);
            half cosAngle = cos(_HueAlt);
            return col * cosAngle + cross(k, col) * sin(_HueAlt) + k * dot(k, col) * (1.0 - cosAngle);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float noise = 1.0-(round(IN.id*_NoiseStepsGlow)/_NoiseStepsGlow * _NoiseStrengthGlow) + _NoiseStrengthGlow/2.0;

            fixed4 c = _OutlineColor * noise;

            o.Emission = HueShift(c.rgb * c.a * _OutlineEmission);

            o.Albedo = HueShift(c.rgb);

            o.Metallic = _MetallicGlow;
            o.Smoothness = _GlossinessGlow;
            o.Alpha = c.a;
        }
		ENDCG

        ZWrite On

        CGPROGRAM // normal fur shader
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

        float _VertexRounding;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void vert (inout appdata v, out Input o) {
            UNITY_SETUP_INSTANCE_ID(v);
            UNITY_INITIALIZE_OUTPUT(Input,o);

            if (_VertexRounding > 0) {
                float rounding = 2 << ((int)max(10-_VertexRounding,5));
                v.vertex = round(v.vertex*rounding)/rounding;
            }
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
