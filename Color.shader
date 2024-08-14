Shader "Custom/Color"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)

        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        _HueMain ("Hue Main", Range(0,6.2832)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "VRCFallback"="Standard"}
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldNormal;
            float3 viewDir;
        };

        half _Glossiness;
        half _Metallic;

        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        float _HueMain;
        float3 HueShift(float3 col)
        {
            const float3 k = float3(0.57735, 0.57735, 0.57735);
            half cosAngle = cos(_HueMain);
            return col * cosAngle + cross(k, col) * sin(_HueMain) + k * dot(k, col) * (1.0 - cosAngle);
        }
        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = HueShift(_Color.rgb);

            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = _Color;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
