Shader "Unlit/Properties"
{
    Properties
    {
        [Header(Title)]
        [HDR]_Color("Color", Color) = (1, 1, 1, 1)
        _Int("Int Value", int) = 0
        _Float("Float Value", float) = 0.5
        _Slider("Slider", Range(0, 1)) = 0.5
        [PowerSlider(2)]_PowerSlider("PowerSlider", Range(0, 10)) = 5
        [IntRange]_SliderInt("SliderInt", Range(0, 10)) = 5
        [Toggle]_Toggle("Toggle", int) = 0
        _Vector("Vector", Vector) = (1, 1, 1, 1)
        [Space(20)]
        _2DTex("2DTex", 2D) = "white"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"        

            fixed4 _Color;
            int _Int;
            float _Float;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = _Color;
                return col;
            }
            ENDCG
        }
    }
}
