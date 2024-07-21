Shader "Unlit/CharacterUnlit"
{
    Properties 
    {
        [NoScaleOffset]_MainTex("Main Tex", 2D) = "white"{}
        _Color("Color", Color) = (0, 0, 0, 1)

        [Space(10)]
        [Header(DissolveEffect)]
        [Space(10)]
        [Toggle]_DissolveEnable("DissolveEnable", int) = 0
        _DissolveTex("DissolveTex(R)", 2D) = "white"{}     //噪声贴图
        _Clip("Clip", Range(0, 1)) = 0.5
        [NoScaleOffset]_RampTex("RampTex(RGB)", 2D) = "white"{}     //溶解边缘贴图
        _RampWidth("RampWidth", float) = 0.1    //溶解边缘的宽度
    }
    SubShader
    {
        Tags{"Queue" = "Geometry"}

        pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            #pragma multi_compile _ _DISSOLVEENABLE_ON

            sampler2D _MainTex;
            fixed4 _Color;
            sampler2D _DissolveTex;
            float4 _DissolveTex_ST;     //声明 float4 贴图名称_ST 会自动关联该贴图的Tilling和Offset属性
            float _Clip;
            sampler _RampTex;
            float _RampWidth;

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            v2f vert(appdata data)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(data.vertex);
                o.uv.xy = data.uv;
                //o.uv.zw = data.uv * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
                o.uv.zw = TRANSFORM_TEX(data.uv, _DissolveTex);
                return o;
            }

            fixed4 frag(v2f thisPixel) : SV_TARGET
            {   
                fixed4 tex = tex2D(_MainTex, thisPixel.uv.xy);
                fixed4 color = tex + _Color;

#if _DISSOLVEENABLE_ON
                fixed4 dissolveTex = tex2D(_DissolveTex, thisPixel.uv.zw);
                clip(dissolveTex.r - _Clip);

                fixed dissolveValue = saturate((dissolveTex.r - _Clip) / _RampWidth);
                fixed4 rampTex = tex1D(_RampTex, dissolveValue) - 0.5;
                color += rampTex;
#endif
                return color;
            }

            ENDCG
        }
    }
}
