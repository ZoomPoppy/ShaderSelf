﻿// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/DiffusePixelLevelMat" {
 Properties {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
    }
	SubShader {
	Pass{
				Tags { "LightMode"="ForwardBase" }

	CGPROGRAM
		#pragma vertex vert
		#pragma fragment fragment

		#include "Lighting.cginc"
		#include "UnityCG.cginc"

                fixed4 _Diffuse;

		struct a2f {
		    //定点坐标
            float4 vertex : POSITION;
            //法线信息
            float3 normal : NORMAL;
        };
		struct v2f {
		    float4 pos : SV_POSITION;
		    float3 worldNormal : TEXCOORD0;
		};

		v2f vert(a2f v){
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
            return o;
		}

	    fixed4 fragment(v2f i) : SV_Target {
	        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

	        fixed3 worldNormal = normalize(i.worldNormal);
	        fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
	        fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
	        fixed3 color = ambient + diffuse;
	        return fixed4(color, 1.0);
	    }


		ENDCG
	}
	}

	FallBack "Diffuse"
}
