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



## 自发光材质案例

需求分析：

自发光，不受灯光影响

受击闪白

中毒变绿，火烧变红

死亡溶解消失



### 添加纹理

模型点通过**投影函数**，映射到UV上(0~1)

通过**映射函数**，将UV映射到纹理贴图上获取纹素颜色(根据贴图分辨率，坐标需要取整)

最后将纹素颜色，通过**值变换函数**将颜色映射到模型行

Shader实际能控制的是**映射函数**



