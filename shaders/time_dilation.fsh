//###### Frag Shader
Texture2D gm_BaseTextureObject : register(t0);
SamplerState gm_BaseTexture    : register(s0);

cbuffer gm_PSMaterialConstantBuffer
{
    bool   gm_PS_FogEnabled;
    float4 gm_FogColour;
    bool   gm_AlphaTestEnabled;
    float4 gm_AlphaRefValue;
};

struct Fragment
{
    float4 vPosition : SV_POSITION;
    float4 vColor    : COLOR0;
    float2 vCoord    : TEXCOORD0;
};

uniform float Tranzitioner;
uniform float ShaderStrength;
uniform float OutlineThreshold;
uniform float OutlineSmoothness;
uniform float OutlineStrength;
uniform float3 ShaderAccent;

float3 RGBToGrayscale(float3 color)
{
    return dot(color, float3(0.299f, 0.587f, 0.114f));
}

float plot(float2 st) {
    return smoothstep(Tranzitioner * 2.4, Tranzitioner * 2.4 - 0.5, abs(st.y));
}

float4 main(Fragment INPUT) : SV_Target0 {
    float4 baseColor = gm_BaseTextureObject.Sample(gm_BaseTexture, INPUT.vCoord);
    float3 outlineColor = ShaderAccent;
    
    float2 textureDimensions;
    gm_BaseTextureObject.GetDimensions(textureDimensions.x, textureDimensions.y);
    float2 texelSize = 1.0f / textureDimensions;

    float4 colorL = gm_BaseTextureObject.Sample(gm_BaseTexture, INPUT.vCoord - float2(texelSize.x, 0.0f));
    float4 colorR = gm_BaseTextureObject.Sample(gm_BaseTexture, INPUT.vCoord + float2(texelSize.x, 0.0f));
    float4 colorUp = gm_BaseTextureObject.Sample(gm_BaseTexture, INPUT.vCoord + float2(0.0f, texelSize.y));
    float4 colorDown = gm_BaseTextureObject.Sample(gm_BaseTexture, INPUT.vCoord - float2(0.0f, texelSize.y));

    float lumBase = RGBToGrayscale(baseColor.rgb);
    float lumL = RGBToGrayscale(colorL.rgb);
    float lumR = RGBToGrayscale(colorR.rgb);
    float lumUp = RGBToGrayscale(colorUp.rgb);
    float lumDown = RGBToGrayscale(colorDown.rgb);

    float deltaX = abs(lumR - lumL);
    float deltaY = abs(lumUp - lumDown);

    float edgeStrength = length(float2(deltaX, deltaY)) * ShaderStrength;
    float outlineFactor = smoothstep(OutlineThreshold - OutlineSmoothness, OutlineThreshold + OutlineSmoothness, edgeStrength);
    float3 detectedOutlineColor = lerp(float3(0.0f, 0.0f, 0.0f), outlineColor, outlineFactor * OutlineStrength);
    float3 finalDisplayedColor = baseColor.rgb;
    finalDisplayedColor = lerp(finalDisplayedColor, detectedOutlineColor, outlineFactor * OutlineStrength);

    float pct = plot(INPUT.vCoord.xy);
    finalDisplayedColor = lerp(finalDisplayedColor, detectedOutlineColor, pct);

    return float4(finalDisplayedColor, baseColor.a);
}

