Shader "Custom/BumpShader"
{
     Properties{
//        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
        _MainTex("MainTex", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
        _BumpMap("BumpMap",2D) = "bump" {}
        _BumpScale("BumpScale", Float) = 1.0
    }

    SubShader{
        Pass{
            Tags{"LightMode" = "ForwardBase"}
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
                sampler2D _BumpMap;
                float4 _BumpMap_ST;
                float _BumpScale;



                struct a2f {
                    float4 vertex :POSITION;
                    float3 normal :NORMAL;
                    float4 texcoord : TEXCOORD0;
                    float4 tangent : TANGENT;
                };

                struct v2f {
                    float4 pos : SV_POSITION;
//                    float3 worldNormal : TEXCOORD0;
//                    float3 worldPosition : TEXCOORD1;
                    float4 uv : TEXCOORD0;
                    float3 lightDir : TEXCOORD1;
                    float3 viewDir : TEXCOORD2;
                };

                v2f vert(a2f i){
                    v2f o;
//                    o.pos = UnityObjectToClipPos(i.vertex);
                    o.pos = UnityObjectToClipPos (i.vertex);
                    float3 binormal = cross(normalize(i.normal), normalize(i.tangent.xyz)) * i.tangent.w;
                    float3x3 rotation = float3x3(i.tangent.xyz, binormal, i.normal);
                    o.lightDir =  mul (rotation, ObjSpaceLightDir(i.vertex));
                    o.viewDir = mul (rotation, ObjSpaceViewDir(i.vertex));
//                    o.worldNorm?l = mul(i.normal, (float3x3)unity_WorldToObject);
//                    o.worldPosition = mul(unity_ObjectToWorld, i.vertex).xyz;
                    o.uv.xy = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                    o.uv.zw = i.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                    //TRANSFORM_TEX(i.texcoord, _MainTex)
                    return o;
                }

                fixed4 fragment(v2f i):SV_Target {
                    fixed3 tangentLightDir = normalize(i.lightDir);
                    fixed3 tangentViewDir = normalize(i.viewDir);
                    fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                    fixed3 tangenNormal;
// = UnpackNormal(packedNormal);
                    tangenNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
                   tangenNormal.z = sqrt(1.0 - max(0,dot(tangenNormal.xy, tangenNormal.xy)));
                    fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                    fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangenNormal, tangentLightDir));
                    fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangenNormal, halfDir)), _Gloss);
                    return fixed4(ambient + diffuse + specular,1.0);
//                    fixed3 worldNormal = normalize(i.worldNormal);
//                    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
//                    fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
//                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
//                    fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal,worldLightDir));
//                    fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPosition));
//                    fixed3 halfDir = normalize(worldLightDir + viewDir);
//                    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
//                    return fixed4(ambient + diffuse + specular, 1.0);
                }

            ENDCG
        }
    }
    	FallBack "Specular"

}
