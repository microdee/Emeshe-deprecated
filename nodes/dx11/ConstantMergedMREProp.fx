//@author: microdee
#include "../../../mp.fxh/MREForward.fxh"
#include "../../../mp.fxh/GetMergedID.fxh"

StructuredBuffer<InstanceParams> InstancedParams;
#if !defined(HAS_SUBSETID)
	StructuredBuffer<uint> SubsetVertexCount : FR_SUBSETVCOUNT;
#endif

cbuffer cbPerDraw : register( b0 )
{
	float4x4 tV : VIEW;
	float4x4 tP : PROJECTION;
	float4x4 tVP : VIEWPROJECTION;
};

cbuffer cbPerObjectGeom : register( b1 )
{
	float4x4 tW : WORLD;
	float SubsetCount = 1;
};

#include "../../../mp.fxh/MREForwardMergedPSProp.fxh"

PSinProp VS(VSin In)
{
    // inititalize
    PSinProp Out = (PSinProp)0;
	// get Instance ID from GeomFX
	float ii = 0;
	#if defined(HAS_SUBSETID)
		ii = In.SubsetID;
	#else
		ii = GetMergedGeomID(SubsetVertexCount, In.vid, SubsetCount);
	#endif
	Out.ii = ii;
	
	// TexCoords
	float4x4 tT = InstancedParams[ii].tTex;
	float4x4 w = mul(InstancedParams[ii].tW,tW);
	
    Out.PosW = mul(In.PosO, w);
	Out.NormW = mul(float4(In.NormO, 0), w).xyz;
	
	#if defined(HAS_TEXCOORD)
		Out.TexCd = mul(float4(In.TexCd.xy,0,1), tT);
	#else
		Out.TexCd = 0;
	#endif
	
    Out.PosWVP = mul(Out.PosW, tVP);
	
    return Out;
}

technique10 DeferredProp
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}
