Shader "Unlit/length"
{
     Properties
    {
        _Tilling("Tilling", vector) = (1, 1, 1, 1)
        _InnerRadius("InnerRadius", float) = 0.3
        _OuterRadius("OuterRadius", float) = 0.4
    }
    SubShader
    {
        pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float2 _Tilling;
            float _InnerRadius;
            float _OuterRadius;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata data)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(data.vertex);
                o.uv = data.uv;
                return o;
            }

            fixed4 frag(v2f thisFrag) : SV_TARGET
            {
                //fixed4 color = distance(thisFrag.uv.xy, 0.5);
                //fixed4 color = length(thisFrag.uv.xy - 0.5);
                //fixed4 color = step(length(thisFrag.uv.xy - 0.5), _InnerRadius);
                fixed4 color = smoothstep(_OuterRadius, _InnerRadius, length(thisFrag.uv.xy - 0.5));
                return color;
            }

            ENDCG
        }
    }
}
