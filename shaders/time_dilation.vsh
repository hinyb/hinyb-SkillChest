//##### Vertex Shader
cbuffer gm_VSTransformBuffer
{
    float4x4 gm_Matrices[MATRICES_MAX];
};

cbuffer gm_VSMaterialConstantBuffer
{
    bool  gm_LightingEnabled;
    bool  gm_VS_FogEnabled;
    float gm_FogStart;
    float gm_RcpFogRange;
};

cbuffer gm_VSLightingConstantBuffer
{
    float4 gm_AmbientColour;                    // rgb=colour, a=1
    float3 gm_Lights_Direction[MAX_VS_LIGHTS];  // normalised direction
    float4 gm_Lights_PosRange [MAX_VS_LIGHTS];  // X,Y,Z position,  W range
    float4 gm_Lights_Colour   [MAX_VS_LIGHTS];  // rgb=colour, a=1
};

struct Attribute
{
    float4 vPosition : POSITION;
    float4 vColor    : COLOR0;
    float2 vTexcoord : TEXCOORD0;
};

struct Fragment
{
    float4 vPosition : SV_POSITION;
    float4 vColor    : COLOR0;
    float2 vCoord    : TEXCOORD0;
};

Fragment main(Attribute INPUT)
{
    Fragment OUTPUT;

    float4 matrixWVP = mul(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], INPUT.vPosition);

    OUTPUT.vPosition = matrixWVP;
    OUTPUT.vColor    = INPUT.vColor;
    OUTPUT.vCoord    = INPUT.vTexcoord; 

    return OUTPUT;
}

