#include <sourcemod>
#include <sdktools>
#include <tf2c>

#include <misc-sm>
//#tryinclude <tf2antiafk>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.0.0"

#define DEBUG 0

ConVar gcv_bEnable;
ConVar gcv_iSize;
ConVar gcv_bRandom;
ConVar gcv_bGravity;
ConVar gcv_flTimeout;
ConVar gcv_bSandvich;
ConVar gcv_bBirthday;
ConVar gcv_bHalloween;

public Plugin myinfo =
{
	name = "[TF2] Medkit Drop",
	author = "mintoyatsu",
	description = "Players drop medkits when they are killed.",
	version = PLUGIN_VERSION,
	url = "mintosoft.net"
};

public void OnPluginStart() {
	gcv_bEnable = CreateConVar("sm_medkitdrop_enabled", "1", "<0/1> Enable Plugin");
	gcv_iSize = CreateConVar("sm_medkitdrop_size", "2", "<1 to 3> Dropped medkit size", _, true, 1.0, true, 3.0);
	gcv_bRandom = CreateConVar("sm_medkitdrop_random", "0", "<0/1> Randomize dropped medkit size");
	gcv_bGravity = CreateConVar("sm_medkitdrop_physics", "1", "<0/1> Medkits affected by gravity");
	gcv_flTimeout = CreateConVar("sm_medkitdrop_time", "15.0", "Time before medkit is removed (seconds)", 0, true, 0.0, true, 60.0);
	gcv_bSandvich = CreateConVar("sm_medkitdrop_sandvich", "0", "<0/1> Sandvich model");
	gcv_bBirthday = CreateConVar("sm_medkitdrop_birthday", "0", "<0/1> Cake model");
	gcv_bHalloween = CreateConVar("sm_medkitdrop_halloween", "0", "<0/1> Candy model");

	HookConVarChange(gcv_bEnable, OnConVarChange);

	HookEvent("player_death", Event_PlayerDeath);
}

public void OnConVarChange(Handle hCvar, char[] oldValue, char[] newValue) {
	if(hCvar == gcv_bEnable) {
		if(GetConVarInt(gcv_bEnable) <= 0) {
			UnhookEvent("player_death", Event_PlayerDeath);
		}
		else {
			HookEvent("player_death", Event_PlayerDeath);
		}
	}
}

public void OnMapStart() {
	PrecacheModel("models/items/medkit_large.mdl", true);
	PrecacheModel("models/items/medkit_medium.mdl", true);
	PrecacheModel("models/items/medkit_small.mdl", true);
	PrecacheModel("models/items/plate.mdl", true);
	PrecacheModel("models/items/medkit_small_bday.mdl", true);
	PrecacheModel("models/items/medkit_medium_bday.mdl", true);
	PrecacheModel("models/items/medkit_large_bday.mdl", true);
	PrecacheModel("models/props_halloween/halloween_medkit_small.mdl", true);
	PrecacheModel("models/props_halloween/halloween_medkit_medium.mdl", true);
	PrecacheModel("models/props_halloween/halloween_medkit_large.mdl", true);
}

public Action Event_PlayerDeath(Handle hEvent, char[] sName, bool dontBroadcast) {
	// Don't create a medkit for Dead Ringer Spies
	//int iFlags = GetEventInt(hEvent, "death_flags");
	//if (iFlags & TF_DEATHFLAG_DEADRINGER)
	//	return;

	// Don't create a medkit for suicides
	int iUserIdVictim = GetEventInt(hEvent, "userid");
	int iUserIdAttacker = GetEventInt(hEvent, "attacker");
	if (!iUserIdAttacker || (iUserIdVictim == iUserIdAttacker))
		return;

	int iClientVictim = GetClientOfUserId(iUserIdVictim);
	int iClientAttacker = GetClientOfUserId(iUserIdAttacker);
	if (!IsValidClient(iClientVictim) || !IsValidClient(iClientAttacker))
		return;

	//if (TF2AntiAFK_IsFrozen(iClientVictim))
	//	return;

	float flPos[3];
	GetClientAbsOrigin(iClientVictim, flPos);
	flPos[2] += 10.0;

	float a_flVelocity[3];
	a_flVelocity[0] = float(GetRandomInt(0, 100)), a_flVelocity[1] = float(GetRandomInt(0, 100)), a_flVelocity[2] = 300.0;

	int iEntityMedkit;
	int iSize;

	if(GetConVarInt(gcv_bRandom) >= 1) {
		iSize = GetRandomInt(1, 3);
	}
	else {
		iSize = GetConVarInt(gcv_iSize);
	}

	switch (iSize) {
		case 1:
		{
			iEntityMedkit = CreateEntityByName("item_healthkit_small");
		}
		case 2:
		{
			iEntityMedkit = CreateEntityByName("item_healthkit_medium");
		}
		case 3:
		{
			iEntityMedkit = CreateEntityByName("item_healthkit_full");
		}
		default:
		{
			iEntityMedkit = CreateEntityByName("item_healthkit_full");
		}
	}

	if (IsValidEntity(iEntityMedkit)) {
		if(GetConVarInt(gcv_bSandvich) >= 1) {
			DispatchKeyValue(iEntityMedkit, "powerup_model", "models/items/plate.mdl");	// Set the correct model
		}
		if(GetConVarInt(gcv_bBirthday) >= 1) {
			switch (iSize)
			{
				case 1:
				{
					DispatchKeyValue(iEntityMedkit, "powerup_model", "models/items/medkit_small_bday.mdl");	// Set the correct model
				}
				case 2:
				{
					DispatchKeyValue(iEntityMedkit, "powerup_model", "models/items/medkit_medium_bday.mdl");	// Set the correct model
				}
				case 3:
				{
					DispatchKeyValue(iEntityMedkit, "powerup_model", "models/items/medkit_large_bday.mdl");	// Set the correct model
				}
				default:
				{
					DispatchKeyValue(iEntityMedkit, "powerup_model", "models/items/medkit_large_bday.mdl");	// Set the correct model
				}
			}
		}
		if(GetConVarInt(gcv_bHalloween) >= 1) {
			switch (iSize)
			{
				case 1:
				{
					DispatchKeyValue(iEntityMedkit, "powerup_model", "models/props_halloween/halloween_medkit_small.mdl");	// Set the correct model
				}
				case 2:
				{
					DispatchKeyValue(iEntityMedkit, "powerup_model", "models/props_halloween/halloween_medkit_medium.mdl");	// Set the correct model
				}
				case 3:
				{
					DispatchKeyValue(iEntityMedkit, "powerup_model", "models/props_halloween/halloween_medkit_large.mdl");	// Set the correct model
				}
				default:
				{
					DispatchKeyValue(iEntityMedkit, "powerup_model", "models/props_halloween/halloween_medkit_large.mdl");	// Set the correct model
				}
			}
		}
		
		DispatchKeyValue(iEntityMedkit, "AutoMaterialize", "0");
		DispatchKeyValue(iEntityMedkit, "velocity", "0.0 0.0 1.0");
		DispatchKeyValue(iEntityMedkit, "basevelocity", "0.0 0.0 1.0");
		TeleportEntity(iEntityMedkit, flPos, NULL_VECTOR, a_flVelocity);
		SetEntProp(iEntityMedkit, Prop_Data, "m_bActivateWhenAtRest", 1);
		SetEntProp(iEntityMedkit, Prop_Send, "m_ubInterpolationFrame", 0);
		//SetEntPropEnt(iEntityMedkit, Prop_Send, "m_hOwnerEntity", iClientAttacker);
		
		DispatchSpawn(iEntityMedkit);
		ActivateEntity(iEntityMedkit);
		
		DispatchKeyValue(iEntityMedkit, "nextthink", "0.1"); // The fix to the laggy physics. This is what you're looking for on the forum.
		
		SetVariantString("OnPlayerTouch !self:Kill::0:-1");
		AcceptEntityInput(iEntityMedkit, "AddOutput");
		
		float flTimeout = GetConVarFloat(gcv_flTimeout);
		CreateTimer(flTimeout, Timer_RemoveDroppedMedkit, iEntityMedkit, TIMER_FLAG_NO_MAPCHANGE);
		
		if(GetConVarBool(gcv_bGravity))
			RequestFrame(SpawnPack_FrameCallback, iEntityMedkit); // Have to change movetype in a frame callback
	}
}

public Action Timer_RemoveDroppedMedkit(Handle hTimer, int iEntity) {
	if(IsValidEntity(iEntity)) {
		char sClassname[35];
		GetEdictClassname(iEntity, sClassname, sizeof(sClassname));
#if DEBUG
		LogMessage("Found edict classname: %s Entity: %d", sClassname, iEntity);
#endif
		if (!strncmp(sClassname, "item_healt", 10, false)) {
#if DEBUG
			LogMessage("Removing edict classname: %s Entity: %d", sClassname, iEntity);
#endif
			RemoveEdict(iEntity);
		}
	}
}

void SpawnPack_FrameCallback(int pack)
{
	if (!IsValidEntity(pack) || pack < 1) return;
	
	SetEntityMoveType(pack, MOVETYPE_FLYGRAVITY);
	SetEntProp(pack, Prop_Send, "movecollide", 1); // These two...
	SetEntProp(pack, Prop_Data, "m_MoveCollide", 1); // ...allow the pack to bounce.
}
