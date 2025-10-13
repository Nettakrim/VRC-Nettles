// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Fur"
{
    Properties
    {
        _MainTex("Albedo", 2D) = "black" {} //fallback
        _Color ("Color", Color) = (1,1,1,1) //fallback

        _Slope ("Slope", Float) = 0.1
        _Offset ("Offset", Float) = 0.1
	}

	SubShader {
		Tags{ "Queue" = "Transparent+10" "RenderType"="Opaque" "VRCFallback"="Standard"}
        Blend DstColor Zero
        Cull Back

        Pass {
            Stencil {
                Ref 10
                ReadMask 10
                Comp Always
                Pass Replace
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"

            float4 vert(appdata_base v) : POSITION {
                return UnityObjectToClipPos (v.vertex);
            }

            fixed4 frag(float4 sp:VPOS) : SV_Target {
                return fixed4(1.0,1.0,1.0,1.0);
            }
            ENDCG
        }

        Pass {
            Stencil {
                Ref 10
                ReadMask 10
                Comp Equal
                Pass Zero
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            float _Slope;
            float _Offset;

            struct Varyings
            {
                float4 pos : SV_POSITION;
                float id : TEXCOORD0;
            };

            struct appdata
            {
                float4 vertex    : POSITION;  
                uint vertexID : SV_VertexID;
            };

            Varyings vert(appdata v) : POSITION {
                Varyings o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.id = frac(sin((float)(v.vertexID)));
                return o;
            }

            fixed4 frag(Varyings v) : SV_Target {
                float x = v.pos.x/_ScreenParams.x;
                float alpha = saturate(min(x-_Offset,1-_Offset-x)/_Slope);
                alpha = alpha*alpha*(3-2*alpha);
                alpha = 1-(alpha*alpha);

                alpha *= (ceil(v.id*2.0) + 254) / 256;

                alpha = 1-alpha;

                return fixed4(alpha,alpha,alpha,1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
