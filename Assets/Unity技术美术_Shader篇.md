# Unity技术美术_Shader篇

# 概述

## 渲染流水线概述

应用程序阶段 ——>几何阶段 ——> 光栅化阶段 ——> 帧缓存

几何阶段：

顶点着色(模型变换，视图变换，顶点着色)，曲面细分，裁剪(投影变换，裁剪)，屏幕映射

光栅化阶段：

三角形设置，三角形遍历，片段着色，混合(Alpha测试，模板测试，深度测试，混合)



# Shader基础

## 基本代码结构

```C
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
            //声明顶点和片段着色器
            #pragma vertex vert
            #pragma fragment frag

            float4 vert() : SV_POSITION
            {

            }

            float4 frag() : SV_TARGET
            {
                return 0;
            }

            ENDCG
        }
    }

    SubShader
    {

    }

    CustomEditor ""		//用于自定义Inspector面板，如下拉框、Toggle等

    Fallback "ShaderLearn/Test"
}
```



## 结构和语义

```C
Shader "ShaderLearn/Framework"
{
    ...
    SubShader
    {
        pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;  //语义，获得的数据来源，会自动绑定和输入
            };

            struct v2f
            {
                float4 pos : SV_POSITION;    //SV表示systemValue，SV_POSITION用来标识经过顶点着色器变换之后的顶点坐标
            };

            v2f vert(appdata data) : SV_POSITION    //: SV_POSITION 表示将经过顶点着色器处理的值输出到SV_POSITION，可以省略
            {
                v2f o = (v2f)0;		//初始化返回值
                o.pos = data.vertex;   //返回值中标记了SV_的变量必须进行赋值
                return o;
            }

            fixed4 frag(v2f vert) : SV_TARGET
            {
                return 0;
            }

            ENDCG
        }
    }
    Fallback "Diffuse"
}
```



## CgInclude

常用的cginc

```C
HLSLSupport.cginc;	//编译CGPROGRAM时自动包含该文件，其中声明了许多预处理器宏，帮助多平台开发
UnityShaderVariables;	//编译CGPROGRAM时自动包含该文件，其中声明了许多内置全局变量
UnityCG.cginc;	//需要手动添加，声明了许多内置的函数和结构
```

### 获取途径

#### 从安装目录获取

`F:\Unity\2021.3.9f1\Editor\Data\CGIncludes\xxx.cginc`

#### 从官网下载

官网下载编辑器时选择Built in Shaders



### 使用方法

使用`#include`声明对应文件

```C
#include "UnityCg.cginc"
```



## 空间变换

主要的几个空间变换有：

​	模型变换矩阵    视图变换矩阵    投影变换矩阵

本地空间 ——> 世界空间 ——> 相机空间 ——> 裁剪空间

矩阵变换运算

```C
mul(M, V);	//M为矩阵，V为向量或点
```

例子：物体顶点从模型空间到裁剪空间

```C
o.pos = mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, data.vertex));	//顶点本地空间-世界空间-裁剪空间
o.pos = UnityObjectToClipPos(data.vertex);	//同上
```



## 屏幕映射

屏幕映射为几何阶段的最后一步

将顶点信息和屏幕映射，将顶点的空间位置映射到屏幕的2维位置



## 光栅化

几何阶段完成后，为光栅化阶段

### 三角形设置

根据顶点，每三个顶点组装为一个个三角形



### 三角形遍历

遍历找出所有属于三角形的片段(屏幕像素)



### 插值

根据顶点颜色和深度信息对片段进行插值



## 片段着色器

片段和像素一般为一一对应

但一个像素可能对应多个片段，如开启多重采样后，会将一个像素分割为更多的片段然后插值



## 顶点和片段的区别

每个顶点会执行一次顶点着色，每个片段会执行一次片段着色器

片段比顶点多得多，复杂度更高，能在顶点着色器完成的运算不要在片段着色器完成



## Properties

材质属性

语法格式

```C
[Attribute]_Name ("显示名称", Type) = 默认值
```

Type常用类型：

Color，Int，Float，Vector，2D，3D，Cube



### Color

```C
Properties
{
    [HDR]_Color("Color", Color) = (1, 1, 1, 1)
}
SubShader
{    
    Pass
    {
        CGPROGRAM
        ...
        fixed4 _Color;
        ...
        fixed4 frag (v2f i) : SV_Target
        {
            fixed4 col = _Color;
            return col;
        }
        ENDCG
    }
}
```



### Int & Float

```C
Properties
{
    [HDR]_Color("Color", Color) = (1, 1, 1, 1)
    _Int("Int Value", int) = 0
    _Float("Float Value", float) = 0.5
    _Slider("Slider", Range(0, 1)) = 0.5
    [PowerSlider(2)]_PowerSlider("PowerSlider", Range(0, 10)) = 5	//修改滑杆的映射比例
    [IntRange]_SliderInt("SliderInt", Range(0, 10)) = 5
    [Toggle]_Toggle("Toggle", int) = 0
}
SubShader
{
    Pass
    {
        CGPROGRAM
        ...
        //如果输入小数会向下取整，如果指定为fixed、float，会获取小数
        //具体取值根据下方声明决定，和Properties中声明无关
        int _Int;	
        float _Float;        
        ...
        ENDCG
    }
}
```



### Vector

```C
Properties
{
    ...
    _Vector("Vector", Vector) = (1, 1, 1, 1)
}
```



### 通用特征

```C
Properties
{
    [HideInInspector]
    [Header(Title)]	//不能是中文，不要加双引号
    [Space(10)]
}
```



### 2D纹理

```C
Properties
{
    _2DTex("2DTex", 2D) = "white"{}		//会自带Tilling和Offset
    [NoScaleOffset]_2DTex("2DTex", 2D) = "white"{}		//会隐藏Tilling和Offset
}
```



## 纹理

### 纹理映射

模型点通过**投影函数**，映射到UV上(0~1)

通过**映射函数**，将UV映射到纹理贴图上获取纹素颜色(根据贴图分辨率，坐标需要取整)

最后将纹素颜色，通过**值变换函数**将颜色映射到模型行

Shader实际能控制的是**映射函数**



### 纹理采样

定义属性

在CGPROGRAM中声明变量

在着色器中进行纹理采样

例子：简单采样

```C
Properties 
{
    _MainTex("Main Tex", 2D) = "white"{}
}
SubShader
{
    pass
    {
        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        #include "UnityCG.cginc"

        sampler2D _MainTex;

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

        //每个顶点执行一次
        v2f vert(appdata data)
        {
            v2f o;
            //每个顶点的位置是不同的，映射的uv也是不同的
            o.pos = UnityObjectToClipPos(data.vertex);
            o.uv = data.uv;
            return o;
        }

        //每个片元执行一次
        fixed4 frag(v2f pixel) : SV_TARGET
        {   
            //将贴图和uv进行匹配
            //每个片元所对应的uv坐标是不同的
            fixed4 tex = tex2D(_MainTex, pixel.uv);
            return tex;
        }
        ENDCG
    }
}
```

进行简单采样后，即可显示贴图，但没有匹配Tilling和Offset



### 匹配颜色

```C
Properties 
{
    ...
    _Color("Color", Color) = (1, 1, 1, 1)
}
SubShader
{
    pass
    {
        ...
        fixed4 _Color;
        ...
        fixed4 frag(v2f pixel) : SV_TARGET
        {   
            fixed4 tex = tex2D(_MainTex, pixel.uv);
            //颜色的值设置为0~1的原因是当Color = 1时，这样不会影响贴图原本的颜色，Color=0时全黑
            //方便计算
            fixed4 color = tex * _Color;
            return color;
        }
        ENDCG
    }
}
```



## 其它

Shader的默认值可以在Shader文件上设置，材质reset后采用的是shader的默认值

切换材质时，相同名称的属性值会保留





# 自发光材质案例

需求分析：

自发光，不受灯光影响

受击闪白

中毒变绿，火烧变红

死亡溶解消失



### 溶解效果

用`Clip`来实现溶解的效果

```C
clip(x);	//根据x的值，判断是否舍弃当前片段(像素)，当x<0时，舍弃
```

```C
Properties 
{
    ...
    _DissolveTex("DissolveTex(R)", 2D) = "white"{}     //噪声贴图
    _Clip("Clip", Range(0, 1)) = 0.5	//溶解系数
}
SubShader
{
    pass
    {
        CGPROGRAM
        ...
        sampler2D _DissolveTex;
        float _Clip;
        ...
        fixed4 frag(v2f pixel) : SV_TARGET
        {   
            ...
            //对噪声图进行采样，这样才能确定某个位置的值
            fixed4 dissolveTex = tex2D(_DissolveTex, pixel.uv);
            
            //用噪声图的值-溶解的系数(临界值)，越黑的地方越先溶解，因为减去_Clip先小于0，类似等高线被平面截取
            clip(dissolveTex.r - _Clip);
            
            return color;
        }

        ENDCG
    }
}
```



### 匹配Tilling&Offset

Tilling的x、y表示uv的u、v方向0~1值范围内，贴图的采样次数(缩放系数/重复次数)

如x = 2时，u方向会显示两张贴图，x = 0.5时，只会显示半张贴图，相当于是贴图的平铺次数(系数)

```C
SubShader
{
    pass
    {
        ...
        sampler2D _DissolveTex;
        //声明 float4 贴图名称_ST 会自动关联该贴图的Tilling和Offset属性
        float4 _DissolveTex_ST;     
        ...

        fixed4 frag(v2f pixel) : SV_TARGET
        {   
            ...
            //让uv*_DissolveTex_ST.xy，即让uv乘以Tilling的xy方向的值，
            //如*2，会提前完成贴图的映射(uv*2提前到达1)，这时会进行平铺，重新采样贴图
            //+ _DissolveTex_ST.zw，即+Offset，在uv方向位置上进行偏移
            //注意这里贴图的平铺方式会影响显示效果
            fixed4 dissolveTex = tex2D(_DissolveTex, pixel.uv * _DissolveTex_ST.xy + _DissolveTex_ST.zw);
            ...
        }

        ENDCG
    }
}
```



优化：匹配Tilling和Offset可以在顶点着色器进行

```C
v2f vert(appdata data)
{
    v2f o;
    o.pos = UnityObjectToClipPos(data.vertex);                
    o.uv = data.uv * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
    return o;
}
```



这时Tilling和Offset会同时影响主纹理和噪声贴图

优化：让TillingOffset只影响噪声贴图

```C
struct v2f
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float2 dissolveUV : TEXCOORD1;
};

v2f vert(appdata data)
{
    v2f o;
    o.pos = UnityObjectToClipPos(data.vertex);
    //原始uv不变
    o.uv = data.uv;
    //让Tilling和Offset控制dissolveUV
    o.dissolveUV = data.uv * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
    return o;
}

fixed4 frag(v2f thisPixel) : SV_TARGET
{   
    //主纹理匹配uv
    fixed4 tex = tex2D(_MainTex, thisPixel.uv);
    fixed4 color = tex + _Color;

    //噪声贴图匹配dissolveUV
    fixed4 dissolveTex = tex2D(_DissolveTex, thisPixel.dissolveUV);
    clip(dissolveTex.r - _Clip);
    
    return color;
}
```



优化：用一个float4替换两个float2，节省语义，少用一个TEXCOORD

```C
struct v2f
{
    float4 pos : SV_POSITION;
    float4 uv : TEXCOORD0;
};

v2f vert(appdata data)
{
    ...
    o.uv.xy = data.uv;
    o.uv.zw = data.uv * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
    return o;
}

fixed4 frag(v2f thisPixel) : SV_TARGET
{   
    fixed4 tex = tex2D(_MainTex, thisPixel.uv.xy);
    fixed4 color = tex + _Color;

    fixed4 dissolveTex = tex2D(_DissolveTex, thisPixel.uv.zw);
    clip(dissolveTex.r - _Clip);
    
    return color;
}
```



Unity还提供了内置方法来绑定Tilling和Offset

```C
//o.uv.zw = data.uv * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
o.uv.zw = TRANSFORM_TEX(data.uv, _DissolveTex);		//不必再添加ST，方法中会自动添加以匹配
```



### 溶解光边效果

首先根据噪声贴图来对渐变的颜色贴图进行采样

```C
fixed4 frag(v2f thisPixel) : SV_TARGET
{   
    ...
    //dissolveTex已经进行了采样，已经和uv绑定，每个片元的dissolveTex.r的值是不同的，根据当前片元的dissolveTex.r来计算
    //R越小越接近0的地方(噪声图上越黑的地方)，对应的_RampTex的u值越小，越接近贴图左边的颜色，这里为白黄渐变
    //R越大越接近1的地方(噪声图上越亮的地方)，对应的_RampTex的u值越大，越接近贴图右边的颜色，这里为橙黑渐变
    //加上之前溶解的效果，越黑的地方越先溶解，且这些地方越亮，形成从先溶解到后溶解区域的由亮到黑的颜色渐变
    fixed4 rampTex = tex2D(_RampTex,  dissolveTex.r);
    color += rampTex;
    
    return color;
}
```



这样的颜色虽然存在，但随着溶解，颜色仍然是固定的，我们希望溶解的边缘始终为亮到黑的渐变

这时需要使用smoothStep函数，来钳制开始变换的值，设置开始渐变的值和结束渐变的值

```C
fixed4 frag(v2f thisPixel) : SV_TARGET
{   
    ...
    //fixed4 rampTex = tex2D(_RampTex,  dissolveTex.g);    
        
    //当前片元对应的噪声图的亮度(高度，小于_Clip，返回0，对应_RampTex上最左边的位置，为最亮的位置
    //但是_Clip进行了剔除，所以溶解边缘就是最亮的地方，如果不进行剔除，溶解的内部也是最亮的
    //当前片元对应的噪声图的亮度(高度)，大于_Clip + _RampWidth，对应_RampTex上最右边的位置，为最黑的位置
    //在_Clip + _RampWidth区域外的地方颜色不变
    //当前片元对应的噪声图的亮度在_Clip到_Clip + _RampWidth之间，会进行插值
    //在该区域内会根据对应的_RampTex的u值不同选取不同的颜色形成渐变
    //_Clip为变化的值，且_Clip为截取等高线的平面，是开始溶解的位置
    //_Clip + _RampWidth为指定了一定的宽度，为结束溶解的位置
    //想象有两个平面截取等高线，这两个平面之间的区域会由亮到黑渐变
    fixed4 rampTex = tex2D(_RampTex, smoothstep(_Clip, _Clip + _RampWidth, dissolveTex.r));
    color += rampTex;
    
    return color;
}
```



smoothstep计算量仍然很大，尽量减少使用

看看smoothstep的内部实现：

```C
float smoothstep(min, max, x)
{
    //saturate将值钳制在0~1之间，saturate((x - min) / (max - min))为线性插值
    //t为min到max的线性插值
    float t = saturate((x - min) / (max - min));	
    //让两边实现一定的平滑效果，这里可以不要
    return t * t * (3 - 2 * t);
}
```

优化：

```C
fixed4 frag(v2f thisPixel) : SV_TARGET
{   
    ...
    fixed dissolveValue = saturate((dissolveTex.r - _Clip) / _RampWidth);
    fixed4 rampTex = tex2D(_RampTex, dissolveValue);
    color += rampTex;
    
    return color;
}
```



目前只使用了_RampTex的u方向的值，没有使用v方向的值，可以只采样单个方向

```C
//sampler2D _RampTex;
sampler _RampTex;

fixed4 frag(v2f thisPixel) : SV_TARGET
{   
    ...
    //fixed4 rampTex = tex2D(_RampTex, dissolveValue)
    fixed4 rampTex = tex1D(_RampTex, dissolveValue);
    ...
}
```



# 变体

## 概念

Shader在编译时，会编译为多个shader文件，这些都是原始shader的变体，材质实际引用的是这些编译后的shader

优点：

可以将多个功能和效果集成到一个Shader内，便于使用和管理

缺点：

变体过多会导致加载时间过长和内存占用增加



在shader文件的Compiled code点击展开按钮可以看见变体的数量



## 变体的声明

```C
//变体的名称必须为大写
//可以通过_声明一个默认空的变体，这里声明了_和NAME两个变体
#pragma multi_compile _ NAME
```

## 变体的类型

无论如何都会被编译的变体，Shader内编写的变体，效果稳定不会丢失，可以由程序动态开关

例子：可以将之前的溶解效果编写为变体，到角色死亡时再使用

```C
CGPROGRAM
...
//这里声明了_和DISSOLVE两个变体，默认采用的是_变体
#pragma multi_compile _ DISSOLVE
...
fixed4 frag(v2f thisPixel) : SV_TARGET
{   
    ...
	//因为默认采用了_变体，不是DISSOLVE变体，所以以下代码不会执行
#if DISSOLVE
    fixed4 dissolveTex = tex2D(_DissolveTex, thisPixel.uv.zw);
    clip(dissolveTex.r - _Clip);

    fixed dissolveValue = saturate((dissolveTex.r - _Clip) / _RampWidth);
    fixed4 rampTex = tex1D(_RampTex, dissolveValue) - 0.5;
    color += rampTex;
#endif
    return color;
}
```

可以添加一个开关来绑定变体，实现开关效果 

```C
Properties 
{
    ...
    //添加[Toggle]
    [Toggle]_DissolveEnable("DissolveEnable", int) = 0
    ...
}
SubShader
{
    pass
    {
        ...
        //注意：属性名称需要和变体名称相同然后加_ON，这样就能和开关绑定
        #pragma multi_compile _ _DISSOLVEENABLE_ON
        ...
        fixed4 frag(v2f thisPixel) : SV_TARGET
        {   
            ...
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
```



通过材质使用情况来决定是否编译的变体，不由程序动态改变，由材质的开关属性来控制

例子：

```C

```

# 常用内置函数

## 基本运算符

```C
+ - * /
```



## UV的引入

```C
SubShader
{
    pass
    {
        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        #include "UnityCG.cginc"

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
            return fixed4(thisFrag.uv, 0, 1);
        }

        ENDCG
    }
}
```



## abs

取绝对值

可以做对称效果，二维对称、三维对称

```C
abs(value);
```



## frac

frac为固定周期的线性变换

如frac(x)在0~1时为y=x，在1~2时会变为y=x-1，形成一种锯齿状的图案

会跟随括号中的表达式而变化，如frac(x-0.5)，frac(2*x)

对uv进行u和v方向上的frac，再进行Tilling，就能得到网格

```C
fixed4 frag(v2f thisFrag) : SV_TARGET
{
    fixed4 color = fixed4(frac(thisFrag.uv * _Tilling), 0, 1);
    return color;
}
```



## floor

floor会向下取整，向数轴负方向取整

```C
floor(x)
```

可以处理取值，会丢弃小数

图像会出现颜色突变

函数为楼梯的形状



## ceil

ceil为向上取整，向数轴正方向取整

```C
ceil(x)
```

可以处理取值，会丢弃小数

函数为楼梯的形状



## max

取最大值

```C
max(a, b)
```

如果为两个函数的话，会取交点最上方的线条，包括常数值，为一条水平直线



## min

取最小值

```C
min(a, b)
```

如果为两个函数的话，会取交点最下方的线条



## pow

x的a次方x^a

```
pow(x, a)
```

如：

x^2 = pow(x, 2)

x^3 = pow(x, 3)



## rcp

y = 1/x

```C
rcp(x)或1/x
```

倒数函数



## exp

自然指数，e^x

```C
exp(x)
```



## exp2

2的n次方，2^x

```C
exp2(x)
```



## fmod

取余

```C
fmod(x, a)
x % a
```

x除以a的余数

也可以为`fmod(a, x)`，a除以x的余数

fmod(x, 1)和frac的曲线相同



## saturate

```C
saturate(x)
```

会将值限定在0~1

x < 0，y = 0

0 < x < 1，y=x

x > 1， y =1



## clamp

```C
clamp(x, a, b)
```

会将值限定在a~b

x < a，y = a

a< x < b，y = x

x > b， y = b



## sqrt

求平方根

```C
sqrt(x)
```



## rsqrt

求平方根倒数

```C
rsqrt(x)
pow(x, -0.5)
```

也可写为x^(-1/2)，x的夫二分之一次方



## lerp

线性变换

```C
lerp(a, b, x)
```

函数经过(0, a)和(1, b)两个点

就是函数y = (b - a) * x + a



## sin

```C
sin(x)
```

sin(kx + b) + c



## cos

```C
cos(x)
```

cos(kx + b) + c



## distance

求两个点的距离

```C
float distance(a, b)
{
    float3 v = b - a;
    return sqrt(dot(v, v));
}

distance(x, a)
```

uv方向都取distance，可以得到圆形的渐变

```C
fixed4 color = distance(thisFrag.uv.xy, 0.5);
```

计算的是点(u,v)到某点a的距离，uv上一点离a点越近，distance越小，越黑，uv上一点离点a越远，distance越大，越白



## length

求向量的长度

```C
sqrt(dot(v, v))
```

length可得到圆形渐变

```C
fixed4 color = length(thisFrag.uv.xy - 0.5);
```



## step

阶梯函数

```C
step(a, b)
step(x, a)
step(a, x)
```

a <= b，返回1

a > b，返回0

会在x == a的地方形成阶梯

step加length可以画圆

```C
fixed4 color = step(length(thisFrag.uv.xy - 0.5), _Radius);
```



## smoothstep

会在a,b区间渐变

```C
float smoothstep(a, b, x)
{
    //saturate将值限制在0~1，(x - a) / (b - a)为点(0, a)到点(b, 1)的线性渐变
    float t = saturate((x - a) / (b - a));
    //t * t (3 - (2 * t))为三次函数，通过设置参数和移动让其在点(0, a)到点(b, 1)平滑渐变
    return t * t (3 - (2 * t));
}
```

只需要线性渐变使用：

```
saturate((x - a) / (b - a));
```

saturate将值限制在0~1，(x - a) / (b - a)为点(0, a)到点(b, 1)的线性渐变

使用smoothstep加上之前的length或distance画圆，可以绘制圆形，并控制其开始渐变和结束渐变的半径

```C
fixed4 circle = length(thisFrag.uv.xy - 0.5)
fixed4 color = smoothstep(_OuterRadius, _InnerRadius, circle);	//_OuterRadius, _InnerRadius交换位置可以让黑白色范围交换
```



# 帧缓冲区

帧缓冲区也叫帧缓存，是用于存放一帧中数据信息的容器

片段着色器将颜色写入帧缓存，通过显示控制器显示到屏幕上，为的是图像输出稳定

片段着色器还可以读取帧缓存，进行一些处理，再写入帧缓存



## 片段运算

片段在写入帧缓存前会按顺序进行一系列测试：

Alpha测试 —— 模板测试 —— 深度测试

片段在写入帧缓冲时会进行 混合 操作，如半透明物体



## 显示器扫描方式

随机扫描显示器：已淘汰

光栅扫描显示器

帧缓冲到显示器会从左到右，从上到下更新图像



## 帧缓冲的方式

单缓冲：片段着色器写入前缓冲，前缓冲直接输出到屏幕，效率高，但可能画面撕裂

双缓冲：先写入后缓冲，后缓冲在光栅扫描完毕后(一张图像全部显示完毕)，才复制到前缓冲，前缓冲再显示到显示器，保证图像显示的完整性



## 缓冲区

帧缓冲可以存储多个内容：

颜色缓冲(Color Buffer)

深度缓冲(Depth Buffer)

模板缓冲(Stencil Buffer)

自定义缓冲



### 颜色缓冲

存储每帧颜色的缓冲区

使用16位存储颜色，称为64K色，65536，2Byte

使用24位存储颜色，3通道 * 8bit，称为24位真彩色，占3Byte

1920 x 1080颜色缓冲占用显存计算(采用24位)：

```C
1920 * 1080 * 3Byte / 1024 / 1024 = 5.93MB
```

即一帧需要5.93MB的缓冲

采用双缓冲，就需要

```C
5.93 * 2 = 11.86MB
```



### 清除缓冲区

通过clear方法可以清除缓冲

```C
//在Frame Debugger也可看见该命令
Clear(color + z + stencil)
```

如相机的Clear Flags就是清除缓冲采用的模式

如果不清除缓冲，就会保留上一帧的图像，在此基础上进行叠加



# 通用特效Shader需求分析

根据参考图或需求列表进行分析

特效通用shader功能点：

1、半透明，可以设置不同的混合叠加模式

2、可以单面或双面显示

3、纹理自流动

4、遮罩功能

5、UV扭曲效果

6、溶解效果

# Render Queue 渲染队列

会根据Render Queue的大小，从小到达渲染，Render Queue越小的越先渲染，越大的越后渲染，后渲染的会覆盖先渲染的图像

RenderQueue小于2500的被认为是不透明物体，大于2500被认为是透明物体

常用Render Queue：

1000：Background，背景

2000：Geometry，不透明物体

2450：Alpha Test，透明的地方完全透明，不透明的地方完全不透明，不存在半透明，用于利用贴图实现边缘透明效果，也称为透贴，如树叶和草丛效果

3000：Transparent，透明物体

4000：Overlay，用于叠加效果，最后渲染的东西放在这里，如光晕等



在shader中可以设置渲染队列

```C
SubShader
{
    Tags{"Queue" = "Geometry"}
    ...
}
```



队列可以进行加减

```C
Tags{"Queue" = "Geometry+1" }
```

# ！Blend 混合模式

## 混合概述

为了实现半透明效果，需要将透明遮挡物和被遮挡物体的颜色进行混合

可以调节混合的模式，实现不同的半透明效果



## 混合操作

混合操作在片段着色器写入帧缓冲时进行

对同一片段来说，需要知道片段着色器当前计算出的颜色，称为**源颜色**，和已经写入到帧缓冲区的颜色，称为**目标颜色**，进行混合

已经写入到帧缓冲区的颜色是之前先渲染被遮挡物体的颜色，当前计算出的颜色是半透明遮挡物体的颜色

SrcFactor：源颜色，SourceFactor

DstFactor：目标颜色，DestinationFactor



## ！代码语法

参考：https://docs.unity3d.com/Manual/SL-Blend.html

```C
Blend Off

//配置并启用混合。生成的颜色将乘以 SrcFactor。屏幕上的已有颜色乘以 DstFactor，然后将这两个值相加。默认使用Add操作
//如Blend One One，Blend SrcAlpha OneMinusSrcAlpha
Blend SrcFactor DstFactor

//颜色相加，但使用不同系数来混合 Alpha 通道
//如：Blend SrcColor DstColor, SrcAlpha OneMinusSrcAlpha
Blend SrcFactor DstFactor, SrcFactorA DstFactorA
    
//不将混合颜色相加，而是对它们执行不同的操作。
BlendOp Op
    
//同上，但是对颜色 (RGB) 通道和 Alpha (A) 通道使用不同的混合操作
BlendOp OpColor, OpAlpha
```

```C
//此外，还可以设置上层渲染目标混合模式。当使用多渲染目标 (MRT) 渲染时，上面的常规语法 将为所有渲染目标设置相同的混合模式。以下语法可以为各个渲染目标设置不同的混合模式，其中 N 是渲染目标索引（0 到 7）。此功能适用于大多数现代 API/GPU（DX11/12、GLCore、Metal 和 PS4）：

Blend N SrcFactor DstFactor
Blend N SrcFactor DstFactor, SrcFactorA DstFactorA
BlendOp N Op
BlendOp N OpColor, OpAlpha
```

`AlphaToMask On`：开启 alpha-to-coverage。使用 MSAA 时，alpha-to-coverage 会根据像素着色器结果 Alpha 值按比例修改多重采样覆盖率遮罩。这通常用于比常规 Alpha 测试更少锯齿的轮廓；对植被和其他经过 Alpha 测试的着色器非常有用。



| **Signature**                                                | **Example syntax**           | **Function**                                                 |
| :----------------------------------------------------------- | :--------------------------- | :----------------------------------------------------------- |
| `Blend <state>`                                              | `Blend Off`                  | Disables blending for the default render target. This is the default value. |
| `Blend <render target> <state>`                              | `Blend 1 Off`                | As above, but for a given render target. (1)                 |
| `Blend <source factor> <destination factor>`                 | `Blend One Zero`             | Enables blending for the default render target. Sets blend factors for RGBA values. |
| `Blend <render target> <source factor> <destination factor>` | `Blend 1 One Zero`           | As above, but for a given render target. (1)                 |
| `Blend <source factor RGB> <destination factor RGB>, <source factor alpha> <destination factor alpha>` | `Blend One Zero, Zero One`   | Enables blending the default render target. Sets separate blend factors for RGB and alpha values. (2) |
| `Blend <render target> <source factor RGB> <destination factor RGB>, <source factor alpha> <destination factor alpha>` | `Blend 1 One Zero, Zero One` | As above, but for a given render target. (1) (2)             |



## ！混合系数

参考https://docs.unity3d.com/Manual/SL-Blend.html

以下所有属性对 **Blend** 命令中的 SrcFactor 和 DstFactor 都有效。**源**是指计算所得颜色，**目标**是指屏幕上已有的颜色。如果 **BlendOp** 在使用逻辑运算，则将忽略混合系数。

| 系数             | 解释                                |
| :--------------- | :---------------------------------- |
| One              | 值为 1 - 让源或目标颜色通过。       |
| Zero             | 值为 0 - 删除源或目标值。           |
| SrcColor         | 此阶段的值乘以源颜色值。            |
| SrcAlpha         | 此阶段的值乘以源 Alpha 值。         |
| DstColor         | 此阶段的值乘以帧缓冲区源颜色值。    |
| DstAlpha         | 此阶段的值乘以帧缓冲区源 Alpha 值。 |
| OneMinusSrcColor | 此阶段的值乘以（1 - 源颜色）。      |
| OneMinusSrcAlpha | 此阶段的值乘以（1 - 源 Alpha）。    |
| OneMinusDstColor | 此阶段的值乘以（1 - 目标颜色）。    |
| OneMinusDstAlpha | 此阶段的值乘以（1 - 目标 Alpha）。  |



可以通过属性+枚举在Inspector面板，以下拉框设置混合系数

```C
Properties
{
    [Enum(UnityEngine.Rendering.BlendMode)]_SrcFactor("SrcFactor", int) = 0
    [Enum(UnityEngine.Rendering.BlendMode)]_DstFactor("DstFactor", int) = 0
}

SubShader
{
    Blend [_SrcFactor] [_DstFactor]
}
```



## ！混合运算

参考https://docs.unity3d.com/Manual/SL-BlendOp.html

| 运算                | 概述                                                  |
| :------------------ | :---------------------------------------------------- |
| Add                 | 将源和目标相加。                                      |
| Sub                 | 从源减去目标。                                        |
| RevSub              | 从目标减去源。                                        |
| Min                 | 使用源和目标中的较小者。                              |
| Max                 | 使用源和目标中的较大者。                              |
| LogicalClear        | 逻辑运算：清除 (0) 仅限 DX11.1。                      |
| LogicalSet          | 逻辑运算：设置 (1) 仅限 DX11.1。                      |
| LogicalCopy         | 逻辑运算：复制 (s) 仅限 DX11.1。                      |
| LogicalCopyInverted | 逻辑运算：逆复制 (!s) 仅限 DX11.1。                   |
| LogicalNoop         | 逻辑运算：空操作 (d) 仅限 DX11.1。                    |
| LogicalInvert       | 逻辑运算：逆运算 (!d) 仅限 DX11.1。                   |
| LogicalAnd          | 逻辑运算：与 (s & d) 仅限 DX11.1。                    |
| LogicalNand         | 逻辑运算：与非 !(s & d) 仅限 DX11.1。                 |
| LogicalOr           | Logical operation: Or (s \| d) DX11.1 only.           |
| LogicalNor          | Logical operation: Nor !(s \| d) DX11.1 only.         |
| LogicalXor          | 逻辑运算：异或 (s ^ d) 仅限 DX11.1。                  |
| LogicalEquiv        | 逻辑运算：相等 !(s ^ d) 仅限 DX11.1。                 |
| LogicalAndReverse   | 逻辑运算：反转与 (s & !d) 仅限 DX11.1。               |
| LogicalAndInverted  | 逻辑运算：逆与 (s & d) 仅限 DX11.1。                  |
| LogicalOrReverse    | Logical operation: Reverse Or (s \| !d) DX11.1 only.  |
| LogicalOrInverted   | Logical operation: Inverted Or (!s \| d) DX11.1 only. |

例子：

```C
//表明使用的系数
Blend SrcAlpha One
    
//表面使用的运算
BlendOp RevSub
```



## 常见混合类型

```C
//传统透明度，源颜色透明度 + (1 - 目标颜色透明度)
Blend SrcAlpha OneMinusSrcAlpha 
    
//预乘透明度，源颜色透明度 * 1 + (1 - 目标颜色透明度)
Blend One OneMinusSrcAlpha 

//源颜色x1 + 目标颜色x1，1比1相加，会变得更亮
Blend One One

//软加法，(1 - 源颜色透明度) + 目标颜色透明度 * 1
Blend OneMinusDstColor One
    
//乘法
Blend DstColor Zero

// 2x 乘法
Blend DstColor SrcColor 
```



# Cull 面剔除

```C
Cull Off
Cull Front
Cull Back
```

默认会`Cull Back`

可以通过属性+枚举在Inspector面板，以下拉框设置混Cull模式

```C
Properties
{
    ...
    [Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull", int) = 2
}
SubShader
{
    ...
    Cull [_Cull]
}
```

# Time 时间

```C
//为已经定义的变量
_Time
```

_Time.y：正常时间流速

_Time.x：正常时间的 1 / 20

_Time.z：正常时间的2倍

_Time.w：正常时间的3倍



# UV流动

使用时间，可以实现UV流动和亮度变化

```C
v2f vert(appdata data)
{
    ..
    o.uv = TRANSFORM_TEX(data.uv , _MainTex) + float2(_MainUVSpeedX, _MainUVSpeedY) * _Time.y;
    return o;
}

fixed4 frag(v2f i) : SV_TARGET
{
    ...
    color *= _Color * _Intensity;
    return color;
}
```



# 遮罩实现

使用贴图实现遮罩

为了节省关键词，将uv从float2改为float4

```C
Properties
{
    ...
    _MaskTex("MaskTex", 2D) = "white"{}
}
SubShader
{
    ...
    pass
    {
        CGPROGRAM
        ...
        sampler2D _MaskTex;
        float4 _MaskTex_ST;
        float _MaskUVSpeedX, _MaskUVSpeedY;

        struct appdata
        {
            ...
            //原始顶点uv数据仍然只需要一套即可
            float2 uv : TEXCOORD0;
        };

        struct v2f
        {
            ...
            float4 uv : TEXCOORD0;
        };

        v2f vert(appdata data)
        {
            ...
            o.uv.xy = TRANSFORM_TEX(data.uv, _MainTex) + float2(_MainUVSpeedX, _MainUVSpeedY) * _Time.y;
            //不希望遮罩随着主纹理流动，让遮罩能自行流动，所以需要另一套uv数据，为了节省TEXCOORD，将uv改为float4
            o.uv.zw = TRANSFORM_TEX(data.uv, _MaskTex) + float2(_MaskUVSpeedX, _MaskUVSpeedY) * _Time.y;
            return o;
        }

        fixed4 frag(v2f i) : SV_TARGET
        {
            //改为uv.xy
            fixed4 color = tex2D(_MainTex, i.uv.xy);
            color *= _Color * _Intensity;
            
            //使用uv.zw
            fixed4 maskColor = tex2D(_MaskTex, i.uv.zw);
            color *= maskColor;
            return color;
        }
        ENDCG
    }
}
```

# ！UV 扭曲

让uv的映射根据贴图出现扭曲

类似f(x) = t，t = 2x这种映射关系

```C
Properties
{
    ...
    [Header(Distort)]
    _DistortTex("DistortTex", 2D) = "white"{}
    _DistortIntensity("Distort Intensity", Range(0, 1)) = 0
    _DistortUVSpeedX("MaskUVSpeedX", float) = 0
    _DistortUVSpeedY("MaskUVSpeedY", float) = 0

}
SubShader
{
    ...
    pass
    {
        ...
        sampler2D _DistortTex;
        float4 _DistortTex_ST;
        float _DistortIntensity;
        float _DistortUVSpeedX, _DistortUVSpeedY;

        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };
        
        struct v2f
        {
            float4 pos : SV_POSITION;
            float4 uv : TEXCOORD0;
            float2 uv2 : TEXCOORD1;
        };

        v2f vert(appdata data)
        {
            ...
            o.uv2.xy = TRANSFORM_TEX(data.uv, _DistortTex) + float2(_DistortUVSpeedX, _DistortUVSpeedY) * _Time.y;
            return o;
        }

        fixed4 frag(v2f i) : SV_TARGET
        {
            //将采样的扭曲贴图，作为uv传入Main贴图，相当于是对uv的映射进行处理，类似f(x) = t，t = 2x这样的形式
            fixed4 distortColor = tex2D(_DistortTex, i.uv2.xy);
            
            //根据扭曲值，使用lerp线性插值，逐渐出现扭曲效果
            //_DistortIntensity=0，采用i.uv.xy进行映射，没有扭曲效果，_DistortIntensity=1完全扭曲，采用贴图进行映射
            fixed2 distort = lerp(i.uv.xy, distortColor, _DistortIntensity);
            
            fixed4 color = tex2D(_MainTex, distort);
            color *= _Color * _Intensity;

            fixed4 maskColor = tex2D(_MaskTex, i.uv.zw);
            color *= maskColor;
            return color;
        }
        ENDCG
    }
}
```



# Shader Feature

有的功能并不需要，将这些功能作为可选项

使用`shader_feature`通过材质的使用情况来决定是否编译，用到什么，就编译什么

在Shader代码Compiled Code中，可以选择Skip unused shader_features，这样没有使用的shader_feature就不会被编译，不会生成变体

和multi_compile的区别是：

multi_compile打包后可以用代码在运行时控制功能的开关

shader_feature没有开启的功能就不会打包，打包后无法通过代码在运行时开启

注意：变体数量为 2^n增长，且Unity自身也定义了变体，不要定义过多变体

使用shader_feature，并对代码进行优化

```C
Properties
{
    ...       
    [Toggle]_MaskEnable("MaskEnable", int) = 0
    ...
    //另一种声明方法
    [MaterialToggle(DISTORTENABLE)]_DistortEnable("DistortEnable", int) = 0
    ...
}
SubShader
{
    ...
    pass
    {
        ...
        #pragma shader_feature _MASKENABLE_ON
        //另一种声明方法
        #pragma shader_feature DISTORTENABLE
        ...
        v2f vert(appdata data)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(data.vertex);
            o.uv.xy = TRANSFORM_TEX(data.uv, _MainTex) + float2(_MainUVSpeedX, _MainUVSpeedY) * _Time.y;
#if _MASKENABLE_ON
            o.uv.zw = TRANSFORM_TEX(data.uv, _MaskTex) + float2(_MaskUVSpeedX, _MaskUVSpeedY) * _Time.y;
#endif
            
//另一种声明方法
#if DISTORTENABLE
            o.uv2.xy = TRANSFORM_TEX(data.uv, _DistortTex) + float2(_DistortUVSpeedX, _DistortUVSpeedY) * _Time.y;
#endif            
            return o;
        }
        
        fixed4 frag(v2f i) : SV_TARGET
        {
            fixed4 color; 
            color = _Color * _Intensity;
            float2 uv = i.uv.xy;
//另一种声明方法 
#if DISTORTENABLE             
            fixed4 distortColor = tex2D(_DistortTex, i.uv2.xy);
            uv = lerp(i.uv.xy, distortColor, _DistortIntensity);
#endif                                                
            fixed4 mainColor = tex2D(_MainTex, uv);
            color *= mainColor;

#if _MASKENABLE_ON
            fixed4 maskColor = tex2D(_MaskTex, i.uv.zw);
            color *= maskColor;
#endif                
            return color;
        }
        ENDCG
    }
}
```

# Custom Data

Shader除了用在材质上，还要用在粒子特效上

在Renderer下开启Custom Vertex Streams，这时会显示出一些参数，这些参数可以自定义添加和排序

Shader的appdata结构体需要和这些数据进行匹配，参数后会提示其所使用的数据通道

例如这里添加速度，显示为Speed(TEXCOORD.z)，节省空间和名称，将速度放入的z通道

```C
struct appdata
{
    float4 vertex : POSITION;
    //Speed已经包含在了TEXCOORD0.z中，需要改为float3
    float3 uv : TEXCOORD0;
};

struct v2f
{
    float4 pos : SV_POSITION;
    float4 uv : TEXCOORD0;
    float2 uv2 : TEXCOORD1;
    //声明该对象，用于将速度传入片段着色器，需要占用一个语义，否则无法知道其输出位置
    float speed : TEXCOORD2;
};
v2f vert(appdata data)
{
    ... 
    //获取速度，也可在顶点着色器中直接使用速度
    o.speed = data.uv.z;
    return o;
}
fixed4 frag(v2f i) : SV_TARGET
{
    //获取速度，例如*颜色就能根据速度改变颜色
    float speed = i.speed;
    ...
}
```

Custom Data可以将一些自定义数据传入shader

粒子组件中有Custom Data选项，开启后，可自定义两组数据，颜色或4维向量，进行匹配后，可以这两组数据调整Shader效果

添加之后，可以在Custom Vertex Streams中添加自定义的数据，以传入Shader

添加后需要在appdata中进行匹配

# 案例分析：屏幕扭曲Shader

扭曲的用途：

特效中场景的扭曲效果(热扭曲)

水体表现



## 实现思路

透过面片的地方需要出现扭曲效果

1、将扭曲材质赋予面片

2、抓取当前一帧的图片内容

3、获取屏幕坐标

4、利用屏幕坐标最抓取的图片进行采样

5、用扰动贴图做扭曲

# 屏幕坐标

以屏幕左下角为原点，分x，y轴，长度为屏幕像素
在shader中需要使用的是归一化的坐标，用当前坐标 / 总像素

新建Shader"HeatDistort"

Unity已经提供屏幕相关参数：

```C
_ScreenParams
_ScreenParams.x		//屏幕宽度(像素)
_ScreenParams.y		//屏幕高度
_ScreenParams.z		//1 + 1 / 屏幕宽度
_ScreenParams.w		//1 + 1 / 屏幕高度
```

获取当前片段像素

```C
//UNITY_VPOS_TYPE是为了适配不同平台，有的平台为float2，有的为float4
//screenPos为变量名称，VPOS为语义
fixed4 frag (v2f i, UNITY_VPOS_TYPE screenPos : VPOS) : SV_Target
{
    return 1;
}
```

如果出现VPOS和SV_POSITION重复定义的报错，需要将获取SV_POSITION设置为局部变量

```C
v2f vert (
    float4 vertex : POSITION,
    out float4 pos : SV_POSITION	//从结构体中定义，变为方法中定义，注意该值为返回值，需要out，输入值为POSTION
)
{
    v2f o;
    //out pos必须赋值才能返回
    pos = UnityObjectToClipPos(vertex);
    return o;
}
```

接下来可以计算当前位置 / 屏幕宽度

```C
fixed4 frag (v2f i, UNITY_VPOS_TYPE screenPos : VPOS) : SV_Target
{
    fixed2 screenUV = screenPos.xy / _ScreenParams.xy;
    fixed4 color = fixed4(screenUV, 0, 1);
    return color;
}
```

这时当有该材质的面片在屏幕不同位置时，会呈现不同颜色
充满画面时，可以看到全部颜色

