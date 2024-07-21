Shader "Unlit/HeatDistort"
{
    Properties
    {
    }
    SubShader
    {     
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
            };

            v2f vert (
                float4 vertex : POSITION,
                out float4 pos : SV_POSITION
            )
            {
                v2f o;
                //out pos必须赋值才能返回
                pos = UnityObjectToClipPos(vertex);
                return o;
            }

            fixed4 frag (v2f i, UNITY_VPOS_TYPE screenPos : VPOS) : SV_Target
            {
                fixed2 screenUV = screenPos.xy / _ScreenParams.xy;
                fixed4 color = fixed4(screenUV, 0, 1);
                return color;
            }
            ENDCG
        }
    }
}
