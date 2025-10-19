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

        _Slope ("Slope", Float) = 0.1
        _Offset ("Offset", Float) = 0.1
        _Spooky ("Spooky", Float) = 1
    }
    SubShader
    {
        Tags { "Queue" = "Transparent+11" "RenderType"="Transparent" "VRCFallback"="Standard"}
        Blend OneMinusSrcAlpha SrcAlpha
        LOD 200

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            fixed4 _Color;

            float _NoiseStrengthGlow;
            float _NoiseStepsGlow;

            float _Slope;
            float _Offset;
            float _Spooky;
            float _VRChatCameraMode;

            struct Varyings
            {
                float4 pos : SV_POSITION;
                float id : TEXCOORD0;
            };

            struct appdata
            {
                float4 vertex : POSITION;  
                uint vertexID : SV_VertexID;
            };

            Varyings vert(appdata v) {
                Varyings o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.id = frac(sin((float)(v.vertexID)));
                return o;
            }

            fixed4 frag(Varyings v) : SV_Target
            {
                float noise = 1.0-(round(v.id*_NoiseStepsGlow)/_NoiseStepsGlow * _NoiseStrengthGlow) + _NoiseStrengthGlow/2.0;

                fixed4 c = _Color * noise;

                float x = _VRChatCameraMode > 0 ? 0.5 : frac(v.pos.x/_ScreenParams.x);
                float alpha = saturate(min(x-_Offset,1-_Offset-x)/_Slope * _Spooky);
                c.a = alpha*0.8;

                return c;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
