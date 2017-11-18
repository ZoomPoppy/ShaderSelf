// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//逐定点光照的漫反射模型
Shader "Unity Shaers Book/Chapter 6/Diffuse Vertex-Level"{
    Properties {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
    }

    SubShader {
        Pass {
        //指定光照模式，定义正确的光照模式，才能得到内置的光照变量
            Tags {"LightMode" = "ForwardBase"}

                CGPROGRAM

                #pragma vertex vertex
                #pragma fragment fragment

                #include "Lighting.cginc"
                #include "UnityCG.cginc"
                //为使用properties 中定义的属性，需要定义一个与该属性类型相匹配的变量
                fixed4 _Diffuse;

                struct a2v {
                    //定点坐标
                    float4 vertex : POSITION;
                    //发现信息
                    float3 normal : NORMAL;
                };

                struct v2f {
                    //
                    float4 pos : SV_POSITION;
                    //
                    fixed3 color : COLOR;
                };


                v2f vertex (a2v v) {
                    v2f o;
                    //从物体空间转换到 投影 空间
                    o.pos = UnityObjectToClipPos(v.vertex);
                    //环境光
                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                    fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                    fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                    //saturate是将参数截取到（0，1）之间
                    fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
                    o.color = ambient + diffuse;
                    return o;
                }

                fixed4 fragment (v2f i) : SV_Target {
                    return fixed4(i.color, 1.0);
                }
                ENDCG
        }


    }
      Fallback "Diffuse"
}