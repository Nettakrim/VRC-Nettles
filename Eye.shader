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

        _EyeColorA ("Eye Color A", Color) = (0, 0, 0)
        _EyeColorB ("Eye Color B", Color) = (0, 0, 0)
        _EyeSize ("Eye Size", Float) = 0.0

        _NoiseStrength ("Noise Strength", Float) = 1.0
        _NoiseSteps ("Noise Steps", Float) = 10.0

        _EyeMix ("Eye Mix", Range(0,1)) = 0.0

        _EyeRotation ("Eye Rotation", Vector) = (0,0,0,0)

        _Slope ("Slope", Float) = 0.1
        _Offset ("Offset", Float) = 0.1
    }
    SubShader
    {
        Tags { "Queue" = "Transparent+11" "RenderType"="Opaque" "VRCFallback"="Standard"}
        Blend OneMinusSrcAlpha SrcAlpha
        LOD 200

        pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "UnityCG.cginc"

            sampler2D _MainTex;

            struct Varyings
            {
                float4 pos : SV_POSITION;
                float id : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            struct appdata
            {
                float4 vertex : POSITION;  
                uint vertexID : SV_VertexID;
                float3 normal : NORMAL;
            };

            fixed4 _Color;
            fixed4 _EyeColorA;
            fixed4 _EyeColorB;
            float _EyeSize;

            float _NoiseStrength;
            float _NoiseSteps;

            float _EyeMix;
            float4 _EyeRotation;

            float _Slope;
            float _Offset;
            float _VRChatCameraMode;
            float _VRChatMirrorMode;

            Varyings vert(appdata v) {
                Varyings o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.id = frac(sin((float)(v.vertexID)));
                o.worldNormal = normalize(mul(unity_ObjectToWorld, v.normal));
                o.viewDir = normalize(UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, v.vertex)));
                return o;
            }

            fixed4 frag(Varyings v) : SV_Target
            {
                float noise = 1.0-(round(v.id*_NoiseSteps)/_NoiseSteps * _NoiseStrength) + _NoiseStrength/2.0;

                fixed4 c = _Color * noise;

                float x = _VRChatCameraMode > 0 ? 0.5 : frac(v.pos.x/_ScreenParams.x);
                float alpha = saturate(min(x-_Offset,1-_Offset-x)/_Slope);
                c.a = alpha*0.8;

                float eyeH = _EyeRotation.x*_EyeRotation.z;
                float eyeV = _EyeRotation.y*_EyeRotation.w;

                float3 direction = normalize(lerp(v.viewDir, normalize(mul(float3(sin(eyeH),-cos(eyeH),eyeV), unity_WorldToObject)), _EyeMix));
                float fresnel = dot(v.worldNormal, direction);

                fresnel = saturate(_EyeSize-fresnel*_EyeSize);

                float4 eyeColor = lerp(_EyeColorA,_EyeColorB,alpha);
                if (_VRChatCameraMode > 0 || _VRChatMirrorMode > 0) {
                    eyeColor.a = 0;
                }

                c = lerp(eyeColor, c, fresnel*fresnel*fresnel*fresnel*fresnel);

                return c;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
