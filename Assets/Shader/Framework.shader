Shader "ShaderLearn/Framework"
{
    Properties
    {

    }

    SubShader
    {
        pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCg.cginc"

            struct appdata
            {
                float4 vertex : POSITION;  //语义，获得的数据来源，会自动绑定和输入
            };

            struct v2f
            {
                float4 pos : SV_POSITION;    //SV表示systemValue，SV_POSITION用来标识经过顶点着色器变换之后的顶点坐标
            };

            v2f vert(appdata data)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(data.vertex);
                return o;
            }

            fixed4 frag(v2f vert) : SV_TARGET
            {
                return fixed4(1, 1, 1, 1); 
            }

            ENDCG
        }
    }
    Fallback "Diffuse"
}