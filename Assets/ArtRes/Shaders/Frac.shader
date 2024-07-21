Shader "Unlit/Frac"
{
    Properties
    {
        _Tilling("Tilling", vector) = (1, 1, 1, 1)
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
                fixed4 color = fixed4(frac(thisFrag.uv * _Tilling), 0, 1);
                return color;
            }

            ENDCG
        }
    }
}
