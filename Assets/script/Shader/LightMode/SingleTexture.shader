// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/SingleTexture" {
    Properties{
//        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
        _MainTex("MainTex", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)

    }

    SubShader{
        Pass{
            Tags{"LightMode" = "ForwordBase"}
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment fragment
                #include "Lighting.cginc"

                fixed4 _Diffuse;
                fixed4 _Specular;
                float _Gloss;
                fixed4 _Color;
                sampler2D _MainTex;
                float4 _MainTex_ST;



                struct a2f {
                    float4 vertex :POSITION;
                    float4 normal :NORMAL;
                    float4 texcoord : TEXCOORD0;
                };

                struct v2f {
                    float4 pos : SV_POSITION;
                    float3 worldNormal : TEXCOORD0;
                    float3 worldPosition : TEXCOORD1;
                    float2 uv : TEXCOORD2;
                };

                v2f vert(a2f i){
                    v2f o;
//                    o.pos = UnityObjectToClipPos(i.vertex);
                    o.pos = UnityObjectToClipPos (i.vertex);
                    o.worldNormal = mul(i.normal, (float3x3)unity_WorldToObject);
                    o.worldPosition = mul(unity_ObjectToWorld, i.vertex).xyz;
                    o.uv = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                    //TRANSFORM_TEX(i.texcoord, _MainTex)
                    return o;
                }

                fixed4 fragment(v2f i):SV_Target {
                    fixed3 worldNormal = normalize(i.worldNormal);
                    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                    fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                    fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal,worldLightDir));
                    fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPosition));
                    fixed3 halfDir = normalize(worldLightDir + viewDir);
                    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
                    return fixed4(ambient + diffuse + specular, 1.0);
                }

            ENDCG
        }
    }
    	FallBack "Specular"

}
