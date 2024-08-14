Shader "Custom/Glow"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        [HDR] _EmissionColor ("EmissionColor", Color) = (0,0,0)
        _EmissionMap("Emission", 2D) = "white" {} //fallback

        _NoiseStrengthGlow ("Noise Strength", Float) = 1.0
        _NoiseStepsGlow ("Noise Steps", Float) = 10.0

        _HueAlt ("Hue Alt", Range(0,6.2832)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "VRCFallback"="Standard"}
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert

  
        #pragma target 3.5

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
            float id;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        fixed4 _EmissionColor;
        float _NoiseStrengthGlow;
        float _NoiseStepsGlow;

        UNITY_INSTANCING_BUFFER_START(Props)

        UNITY_INSTANCING_BUFFER_END(Props)

        void vert (inout appdata v, out Input o) {
            UNITY_SETUP_INSTANCE_ID(v);
            UNITY_INITIALIZE_OUTPUT(Input,o);

            o.id = frac(sin((float)(v.vertexID)));
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

            fixed4 c = _Color * noise;

            o.Emission = HueShift(c.rgb * c.a * _EmissionColor);

            o.Albedo = HueShift(c.rgb);

            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
