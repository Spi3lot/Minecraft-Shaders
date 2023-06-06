#define MAT_ID_OPAQUE 1
#define MAT_ID_GRASS 2
#define MAT_ID_LEAVES 3
#define MAT_ID_HAND 4
#define MAT_ID_ENTITY_PLAYER 5
#define MAT_ID_WATER 6
#define MAT_ID_STAINED_GLASS 7
#define MAT_ID_ICE 8
#define MAT_ID_TORCH 30
#define MAT_ID_LAVA 31
#define MAT_ID_GLOWSTONE 32
#define MAT_ID_FIRE 33
#define MAT_ID_LIT_FURNACE 34



struct MaterialMask
{
	float sky;
	float opaque;
	float grass;
	float leaves;
	float hand;
	float entityPlayer;
	float water;
	float stainedGlass;
	float ice;
	float torch;
	float lava;
	float glowstone;
	float fire;
	float litFurnace;
};


float GetMaterialMask(const in int ID, in float matID) 
{
	//Catch last part of sky
	if (matID > 254.0f) 
	{
		matID = 0.0f;
	}

	if (matID == ID) 
	{
		return 1.0f;
	} 
	else 
	{
		return 0.0f;
	}
}

MaterialMask CalculateMasks(float materialID)
{
	MaterialMask zmecwWmFca;

	materialID *= 255.0;

	// if (isEyeInWater > 0)
	// {
	// 	// zmecwWmFca.sky = 0.0f;
	// }
	// else
	{
		zmecwWmFca.sky = 0.0;
		if (texture2D(depthtex1, texcoord.st).x > 0.999999)
		{
			zmecwWmFca.sky = 1.0;
		}
	}
		//zmecwWmFca.sky = GetMaterialMask(0, materialID);
		//zmecwWmFca.sky = texture2D(depthtex1, texcoord).x > 0.999999 ? 1.0 : 0.0;



	zmecwWmFca.opaque 		= GetMaterialMask(MAT_ID_OPAQUE, materialID);
	zmecwWmFca.grass 			= GetMaterialMask(MAT_ID_GRASS, materialID);
	zmecwWmFca.leaves 		= GetMaterialMask(MAT_ID_LEAVES, materialID);
	zmecwWmFca.hand 			= GetMaterialMask(MAT_ID_HAND, materialID);
	zmecwWmFca.entityPlayer 	= GetMaterialMask(MAT_ID_ENTITY_PLAYER, materialID);
	zmecwWmFca.water 			= GetMaterialMask(MAT_ID_WATER, materialID);
	zmecwWmFca.stainedGlass	= GetMaterialMask(MAT_ID_STAINED_GLASS, materialID);
	zmecwWmFca.ice 			= GetMaterialMask(MAT_ID_ICE, materialID);
	zmecwWmFca.torch 			= GetMaterialMask(MAT_ID_TORCH, materialID);
	zmecwWmFca.lava 			= GetMaterialMask(MAT_ID_LAVA, materialID);
	zmecwWmFca.glowstone 		= GetMaterialMask(MAT_ID_GLOWSTONE, materialID);
	zmecwWmFca.fire 			= GetMaterialMask(MAT_ID_FIRE, materialID);
	zmecwWmFca.litFurnace 	= GetMaterialMask(MAT_ID_LIT_FURNACE, materialID);

	return zmecwWmFca;
}
