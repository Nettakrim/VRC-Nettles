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

            ColorMask 0
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
                float4 vertex : POSITION;  
                uint vertexID : SV_VertexID;
            };

            Varyings vert(appdata v) {
                Varyings o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.id = frac(sin((float)(v.vertexID)));
                return o;
            }

            fixed4 frag(Varyings v) : SV_Target {
                float x = frac(v.pos.x/_ScreenParams.x);

                float r = ceil(v.id*2.0)/2.0;
                if (x > 0.5) {
                    x += (r - 0.5)/100;
                } else {
                    x -= (r - 0.5)/100;
                }
                x += (r - 0.5)/100.0 * sign(x-0.5);

                float alpha = saturate(min(x-_Offset,1-_Offset-x)/_Slope);
                alpha = alpha*alpha*(3-2*alpha);
                alpha = 1-(alpha*alpha);

                alpha *= (r + 80) / 81;

                alpha = 1-alpha;

                return fixed4(alpha,alpha,alpha,1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
