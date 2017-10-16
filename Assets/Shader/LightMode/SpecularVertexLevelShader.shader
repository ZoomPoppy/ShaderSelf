﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/SpecularVertexLevelShader" {
	Properties {
	    _Diffuse ("Diffuse", Color) = (1, 1, 1 , 1)
	    _Specular ("Specular", Color) = (1, 1, 1, 1)
	    _Gloss ("Gloss" , Range(8.0, 256)) = 20
	}
	SubShader {
	    Pass{
	        Tags { "LightMode" = "ForwardBase" }
	        CGPROGRAM

	        #pragma vertex vert
	        #pragma fragment frag

	        #include "Lighting.cginc"

	        fixed4 _Diffuse;
	        fixed4 _Specular;
	        float _Gloss;

	        struct a2v {
	            float4 vertex : POSITION;
	            float3 normal : NORMAL;
	        };

	        struct v2f {
	            float4 pos : SV_POSITION;
	            float3 color : COLOR;
	        };

	        v2f vert(a2v v){
	            v2f o;
	            o.pos = UnityObjectToClipPos(v.vertex);
	            fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
	            fixed3 worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
	            fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
	            fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));
	            fixed3 refectDir = normalize(reflect(-worldLightDir,worldNormal));

	            fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
	            fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(refectDir, viewDir)), _Gloss);

	            o.color = ambient + diffuse + specular;

	            return o;
	        }

	        fixed4 frag(v2f i) : SV_Target {
	            return fixed4(i.color, 1.0);
	        }

		    ENDCG

	    }

	}
	FallBack "Specular"
}