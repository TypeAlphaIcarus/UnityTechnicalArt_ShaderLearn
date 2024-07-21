Shader "Unlit/UniversalEffect"
{
    Properties
    {
        [Header(RenderMode)]
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcFactor("SrcFactor", int) = 0
        [Enum(UnityEngine.Rendering.BlendMode)]_DstFactor("DstFactor", int) = 0
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull", int) = 2

        [Header(MainTex)]
        _MainTex("MainTex", 2D) = "white"{}
        _Color("Color", Color) = (1, 1, 1, 1)
        _Intensity("Intensity", Range(-5, 5)) = 1
        _MainUVSpeedX("MainUVSpeedX", float) = 0
        _MainUVSpeedY("MainUVSpeedY", float) = 0
        
        [Header(Mask)]
        [Toggle]_MaskEnable("MaskEnable", int) = 0
        _MaskTex("MaskTex", 2D) = "white"{}
        _MaskUVSpeedX("MaskUVSpeedX", float) = 0
        _MMaskUVSpeedY("MaskUVSpeedY", float) = 0
        
        [Header(Distort)]
        [MaterialToggle(DISTORTENABLE)]_DistortEnable("DistortEnable", int) = 0
        _DistortTex("DistortTex", 2D) = "white"{}
        _DistortIntensity("Distort Intensity", Range(0, 1)) = 0
        _DistortUVSpeedX("MaskUVSpeedX", float) = 0
        _DistortUVSpeedY("MaskUVSpeedY", float) = 0

    }
    SubShader
    {
        Tags{"Queue" = "Transparent"}
        Blend [_SrcFactor] [_DstFactor]
        Cull [_Cull]

        pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            #pragma shader_feature _MASKENABLE_ON
            #pragma shader_feature DISTORTENABLE

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            half _Intensity;
            float _MainUVSpeedX, _MainUVSpeedY;
            
            sampler2D _MaskTex;
            float4 _MaskTex_ST;
            float _MaskUVSpeedX, _MaskUVSpeedY;

            sampler2D _DistortTex;
            float4 _DistortTex_ST;
            float _DistortIntensity;
            float _DistortUVSpeedX, _DistortUVSpeedY;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
            };
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float speed : TEXCOORD2;
            };

            v2f vert(appdata data)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(data.vertex);
                o.uv.xy = TRANSFORM_TEX(data.uv, _MainTex) + float2(_MainUVSpeedX, _MainUVSpeedY) * _Time.y;
#if _MASKENABLE_ON
                o.uv.zw = TRANSFORM_TEX(data.uv, _MaskTex) + float2(_MaskUVSpeedX, _MaskUVSpeedY) * _Time.y;
#endif
#if DISTORTENABLE
                o.uv2.xy = TRANSFORM_TEX(data.uv, _DistortTex) + float2(_DistortUVSpeedX, _DistortUVSpeedY) * _Time.y;
#endif                
                o.speed = data.uv.z;
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed4 color; 
                color = _Color * _Intensity;
                float2 uv = i.uv.xy;
                float speed = i.speed;

#if DISTORTENABLE                
                //将采样的扭曲贴图，作为uv传入Main贴图，相当于是对uv的映射进行处理，类似f(x) = t，t = 2x这样的形式
                fixed4 distortColor = tex2D(_DistortTex, i.uv2.xy);
                //根据扭曲值，使用lerp线性插值，逐渐出现扭曲效果，_DistortIntensity=0没有扭曲效果，_DistortIntensity=1完全扭曲
                uv = lerp(i.uv.xy, distortColor, _DistortIntensity);
#endif                                                
                fixed4 mainColor = tex2D(_MainTex, uv);
                color *= mainColor;

#if _MASKENABLE_ON
                fixed4 maskColor = tex2D(_MaskTex, i.uv.zw);
                color *= maskColor;
#endif                

                return color * speed;
            }

            ENDCG
        }
    }
}
