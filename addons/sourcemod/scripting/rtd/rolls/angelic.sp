#pragma semicolon 1

#include <sourcemod>
#include <tf2_stocks>
#include <sdkhooks>
#include <tf2>
#include <rtd_rollinfo>

public Action:Spawn_AngelicDispenser(client, health, maxHealth)
{	
	new Float:pos[3];
	new Float: playerAngle[3];
	
	GetClientEyePosition(client, pos);
	GetClientAbsAngles(client, playerAngle);
	playerAngle[1] += 90.0;
	
	new Float:Direction[3];
	Direction[0] = pos[0];
	Direction[1] = pos[1];
	Direction[2] = pos[2]-1024;
	
	new Float:floorPos[3];
	
	new Handle:Trace = TR_TraceRayFilterEx(pos, Direction, MASK_SOLID, RayType_EndPoint, TraceFilterAll, client);
	TR_GetEndPosition(floorPos, Trace);
	CloseHandle(Trace);
	
	floorPos[2] += 50.0;
	
	new angelic = CreateEntityByName("prop_dynamic_override");
	
	SetEntityModel(angelic,MODEL_ANGELIC);
	SetEntProp(angelic, Prop_Data, "m_takedamage", 2);  //default = 2
	
	DispatchSpawn(angelic);
	
	new iTeam = GetClientTeam(client);
	SetVariantInt(iTeam);
	AcceptEntityInput(angelic, "TeamNum", -1, -1, 0);
	
	SetVariantInt(iTeam);
	AcceptEntityInput(angelic, "SetTeam", -1, -1, 0); 
	
	SetEntProp(angelic, Prop_Data, "m_takedamage", 2);  //default = 2
	
	SetEntPropEnt(angelic, Prop_Data, "m_hLastAttacker", client);
	
	SetEntProp( angelic, Prop_Data, "m_nSolidType", 6 );
	SetEntProp( angelic, Prop_Send, "m_nSolidType", 6 );
	
	SetEntProp(angelic, Prop_Data, "m_CollisionGroup", 3);
	SetEntProp(angelic, Prop_Send, "m_CollisionGroup", 3);
	
	//Set the entity's health
	SetEntProp(angelic, Prop_Data, "m_iMaxHealth", maxHealth);
	SetEntProp(angelic, Prop_Data, "m_iHealth", health);
	
	decl String:entityName[32];
	Format(entityName, 32, "angelic_%i", angelic);
	DispatchKeyValue(angelic, "targetname", entityName);
	
	AcceptEntityInput( angelic, "DisableCollision" );
	AcceptEntityInput( angelic, "EnableCollision" );
	
	if(GetClientTeam(client) == RED_TEAM)
	{
		SetVariantString(bluDamageFilter);
		DispatchKeyValue(angelic, "skin","0"); 
	}else{
		SetVariantString(redDamageFilter);
		DispatchKeyValue(angelic, "skin","3"); 
	}
	
	AcceptEntityInput(angelic, "SetDamageFilter", -1, -1, 0); 
	
	TeleportEntity(angelic,floorPos, playerAngle, NULL_VECTOR);
	
	HookSingleEntityOutput(angelic, "OnBreak", AngelicBreak, false);
	
	EmitSoundToAll(SND_DROP, client);
	
	SetVariantString("idle");
	AcceptEntityInput(angelic, "SetAnimation", -1, -1, 0); 
	
	
	/////////////////////////////////////////////
	//Initiate the timer.                      //
	//Important variables to keep track of     //
	/////////////////////////////////////////////
	new Handle:dataPack;
	CreateDataTimer(0.5,Angelic_Timer,dataPack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE|TIMER_DATA_HNDL_CLOSE);
	WritePackCell(dataPack, EntIndexToEntRef(angelic));
	WritePackCell(dataPack, GetTime());//PackPosition(8) 
	WritePackCell(dataPack, 720); //PackPosition(16) amount of time it will live
	WritePackCell(dataPack, GetTime()); //PackPosition(24) time it can teleport to a player
	WritePackCell(dataPack, 0); //PackPosition(32) used to re-emit it's sound
	WritePackCell(dataPack, GetClientUserId(client)); //40
	WritePackString(dataPack, entityName); //PackPosition(48)
	
	//"Angelic Dispenser heals +150 HP (def: +100 HP)"
	if(RTD_PerksLevel[client][55] == 1)
	{
		WritePackCell(dataPack, 150);
	}else{
		WritePackCell(dataPack, 100);
	}
	
	//"Angelic Dispenser cooldown period: 5s (def: 8s)"
	if(RTD_PerksLevel[client][56] == 1)
	{
		WritePackCell(dataPack, 5);
	}else{
		WritePackCell(dataPack, 8);
	}
	
	////////////////////////////////
	//Setup the pretty stuff      //
	////////////////////////////////
	AttachRTDParticle(angelic, "ghost_appearation", true, false, 10.0);
	
	AttachFastParticle2(angelic, "halopoint", 20.0, "hat");
	
	SDKHook(angelic,	SDKHook_OnTakeDamage, 	AngelicHook);
	
	return Plugin_Continue;
}

//particles to use
//god_rays
//halopoint
//target_break_child_puff - use for teleporting in and out
//AttachTempParticle(crap, "superrare_flies", 14.0, true, crapName, 30.0, false);

public Action:AngelicHook(angelic, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(GetEntProp(angelic, Prop_Data, "m_iTeamNum") == GetEntProp(attacker, Prop_Data, "m_iTeamNum"))
	{
		damage = 0.0;
		return Plugin_Changed;
	}
	
	if(GetEntProp(angelic, Prop_Data, "m_PerformanceMode") < GetTime())
	{
		AttachTempParticle(angelic,"tpdamage_1", 1.0, false,"", 0.0, false);
		SetEntProp(angelic, Prop_Data, "m_PerformanceMode", GetTime() + 1);
		
		if(GetEntProp(angelic, Prop_Data, "m_iTeamNum") == RED_TEAM)
		{
			DispatchKeyValue(angelic, "skin","2"); 
		}else{
			DispatchKeyValue(angelic, "skin","5"); 
		}
	}
	
	if(attacker > 0 && attacker < MaxClients)
	{
		//homewrecker does double damage
		if(isActiveWeapon(attacker, 153))
		{
			damage *= 2.0;
			return Plugin_Changed;
		}
	}
	
	
	return Plugin_Continue;
}

public Action:Angelic_Timer(Handle:timer, Handle:dataPackHandle)
{
	////////////////////////////////
	//Should we stop this timer?  //
	////////////////////////////////
	if(stopAngelicTimer(dataPackHandle))
		return Plugin_Stop;
	
	decl String:entityName[32];
	
	//////////////////////////////////////////
	//Retrieve the values from the dataPack //
	// Set to the beginning and unpack it   //
	//////////////////////////////////////////
	ResetPack(dataPackHandle);
	new angelic = EntRefToEntIndex(ReadPackCell(dataPackHandle));
	SetPackPosition(dataPackHandle, 24);
	new nextTeleportationTime = ReadPackCell(dataPackHandle);
	new lastSoundTime = ReadPackCell(dataPackHandle);
	new ownerID = GetClientOfUserId(ReadPackCell(dataPackHandle));
	ReadPackString(dataPackHandle, entityName, 32);
	new healRate = ReadPackCell(dataPackHandle);
	new coolDownTime = ReadPackCell(dataPackHandle);
	
	/////////////////////////////////////////////
	//Reemit sounds every 30s even though this //
	//sound is already "loopable" this is done //
	//to make sure everyone hears it...        //
	/////////////////////////////////////////////
	if(lastSoundTime < GetTime())
	{
		SetPackPosition(dataPackHandle, 32);
		
		StopSound(angelic, SNDCHAN_AUTO, SOUND_FLAP);
		WritePackCell(dataPackHandle, GetTime() + 30);
		EmitSoundToAll(SOUND_FLAP, angelic);
	}
	
	/////////////////
	//update eyes  //
	/////////////////
	new iTeam = GetEntProp(angelic, Prop_Data, "m_iTeamNum");
	
	if(GetEntProp(angelic, Prop_Data, "m_PerformanceMode") < GetTime())
	{
		if(iTeam == RED_TEAM)
		{
			if(GetEntProp(angelic, Prop_Data, "m_nSkin") != 0)
				DispatchKeyValue(angelic, "skin","0"); 
		}else{
			if(GetEntProp(angelic, Prop_Data, "m_nSkin") != 3)
				DispatchKeyValue(angelic, "skin","3"); 
		}
	}
	
	////////////////
	//heal self   //
	////////////////
	SetVariantInt(1);
	AcceptEntityInput(angelic, "AddHealth");
	
	if(GetEntProp(angelic, Prop_Data, "m_iHealth") > GetEntProp(angelic, Prop_Data, "m_iMaxHealth"))
		SetEntProp(angelic, Prop_Data, "m_iHealth", GetEntProp(angelic, Prop_Data, "m_iMaxHealth"));
	
	//////////////////////////////////////////////
	// Determine if it can teleport to a player //
	//////////////////////////////////////////////
	if(GetTime() < nextTeleportationTime)
		return Plugin_Continue;
	
	/////////////////////////////////////////////
	//Find allies with health lass than 30%    //
	/////////////////////////////////////////////
	new Float:playerPos[3];
	new Float: clientHealth;
	new Float: triggerHealth;
	new Float: distance;
	new Float:nearbyClientPos[3];
	new Float: playerAngle[3];
	new bool:bypassToOwner = false;
	
	//prioritize owner
	if(ownerID > 0)
	{
		if(IsClientInGame(ownerID) && IsPlayerAlive(ownerID))
		{
			if(GetClientTeam(ownerID) == iTeam)
			{
				if(client_rolls[ownerID][AWARD_G_ANGELIC][4] < GetTime())
				{
					clientHealth = float(GetClientHealth(ownerID));
					triggerHealth = float(finalHealthAdjustments(ownerID)) * 0.35;
					
					if (clientHealth <= triggerHealth)
					{
						//PrintToChatAll("debug: bypassing to owner!");
						bypassToOwner = true;
					}
				}
			}
		}
	}
	
	for (new i = 1; i <= MaxClients ; i++)
	{
		if(bypassToOwner)
			i = ownerID;
		
		if(!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;
		
		if(GetClientTeam(i) != iTeam)
			continue;
		
		//cooloff period before player can be saved again
		if(client_rolls[i][AWARD_G_ANGELIC][4] > GetTime())
			continue;
		
		clientHealth = float(GetClientHealth(i));
		triggerHealth = float(finalHealthAdjustments(i)) * 0.35;
		
		//client doesn't need to be saved
		if (clientHealth > triggerHealth)
			continue;
		
		//teleport to the player
		//AttachTempParticle(entity, String:particleType[], Float:lifetime, bool:parent, String:parentName[], Float:zOffset, bool:randOffset)
		AttachTempParticle(angelic, "target_break_child_puff", 4.0, false, "", 31.0, false);
		
		GetClientAbsOrigin(i, playerPos);
		playerPos[2] += 50.0;
		
		GetClientAbsAngles(i, playerAngle);
		playerAngle[1] += 90.0;
		
		//telepor Angelic a bit above the player
		//this is to prevent clipping issues
		//prorably needs a check so it doesnt teleport up into a wall?
		playerPos[2] += 30.0;
		
		TeleportEntity(angelic, playerPos, playerAngle, NULL_VECTOR);
		
		AttachTempParticle(angelic, "god_rays", 5.0, false, "", 31.0, false);
		
		for (new nearbyClient = 1; nearbyClient <= MaxClients ; nearbyClient++)
		{
			if(!IsClientInGame(nearbyClient) || !IsPlayerAlive(nearbyClient))
				continue;
			
			if(GetClientTeam(i) != GetClientTeam(nearbyClient))
				continue;
			
			GetClientAbsOrigin(nearbyClient, nearbyClientPos);
			
			distance = GetVectorDistance( nearbyClientPos, playerPos);
			
			if( distance < 100.0)
			{
				PrintCenterText(nearbyClient, "Angelic Dispenser came to the rescue!");
				addHealth(nearbyClient, healRate, false);
				TF2_AddCondition(nearbyClient, TFCond_InHealRadius, 4.0);
				
				Shake2(nearbyClient, 1.0, 65.0);
			}
		}
		
		//adjust next time it can teleport
		SetPackPosition(dataPackHandle, 24);
		
		WritePackCell(dataPackHandle, GetTime() + coolDownTime); //PackPosition(24) time it can teleport to a player
		
		//mark the player as unable to be saved for the next 60s
		client_rolls[i][AWARD_G_ANGELIC][4] = GetTime() + 30;
		
		break;
	}
	
	return Plugin_Continue;
}

public stopAngelicTimer(Handle:dataPackHandle)
{	
	ResetPack(dataPackHandle);
	new angelic = EntRefToEntIndex(ReadPackCell(dataPackHandle));
	
	if(!IsValidEntity(angelic))
	{	
		return true;
	}
	
	//caled when entity handler is unloading this object
	if(GetEntProp(angelic, Prop_Data, "m_PerformanceMode") == 66)
		return true;
	
	return false;
}

public AngelicBreak (const String:output[], caller, activator, Float:delay)
{
	if(IsValidEntity(caller))
	{
		// play sound 
		EmitSoundToAll(SOUND_SENTRY_EXPLODE, caller);
		StopSound(caller, SNDCHAN_AUTO, SOUND_FLAP);
		
		TF_SpawnMedipack(caller, "item_healthkit_medium", true);
		
		UnhookSingleEntityOutput(caller,"OnBreak", AmplifierBreak);
	}
}