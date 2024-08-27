Shader "Custom/Eye"
{
    Properties
    {
        _MainTex("Albedo", 2D) = "black" {} //fallback

        _Color ("Color", Color) = (1,1,1,1)
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        [HDR] _EmissionColor ("EmissionColor", Color) = (0,0,0)
        _EmissionMap("Emission", 2D) = "white" {} //fallback

        _EyeColor ("Eye Color", Color) = (0, 0, 0)
        _EyeSize ("Eye Size", Float) = 0.0

        _NoiseStrength ("Noise Strength", Float) = 1.0
        _NoiseSteps ("Noise Steps", Float) = 10.0

        _HueAlt ("Hue Alt", Range(0,6.2832)) = 0.0

        _EyeMix ("Eye Mix", Range(0,1)) = 0.0

        _EyeRotation ("Eye Rotation", Vector) = (0,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "VRCFallback"="Standard"}
        LOD 200

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
            float id;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        fixed4 _EmissionColor;
        fixed4 _EyeColor;
        float _EyeSize;
        float _NoiseStrength;
        float _NoiseSteps;

        float _EyeMix;
        float4 _EyeRotation;

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

        float _HueAlt;
        float3 HueShift(float3 col)
        {
            const float3 k = float3(0.57735, 0.57735, 0.57735);
            half cosAngle = cos(_HueAlt);
            return col * cosAngle + cross(k, col) * sin(_HueAlt) + k * dot(k, col) * (1.0 - cosAngle);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float noise = 1.0-(round(IN.id*_NoiseSteps)/_NoiseSteps * _NoiseStrength) + _NoiseStrength/2.0;

            fixed4 c = _Color * noise;

            float eyeH = _EyeRotation.x*_EyeRotation.z;
            float eyeV = _EyeRotation.y*_EyeRotation.w;

            //this should work, not sure why it doesnt - it looks identical in unity but breaks in vrchat
            //float3 direction = normalize(lerp(IN.viewDir, normalize(mul(float3(sin(eyeH),-cos(eyeH),eyeV), unity_WorldToObject)), _EyeMix));
            //float fresnel = dot(IN.worldNormal, direction);

            float3 direction = lerp(normalize(mul(IN.viewDir, unity_ObjectToWorld)), normalize(float3(sin(eyeH),-cos(eyeH),eyeV)), _EyeMix);
            float fresnel = dot(normalize(mul(IN.worldNormal, unity_ObjectToWorld)), normalize(direction));

            fresnel = saturate(_EyeSize-fresnel*_EyeSize);

            c = lerp(_EyeColor, c, fresnel*fresnel*fresnel*fresnel*fresnel);

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
