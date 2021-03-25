#include <sourcemod>
#include <tf2c>

public Plugin:myinfo = 
{
	name = "TF2 All Crit",
	author = "blendmaster345",
	description = "Make every hit a crit",
	version = "1.0",
	url = "http://sourcemod.net/"
};

new Handle:IsAllCritOn;
new bool:g_warmup = false;

public OnPluginStart()
{
	IsAllCritOn = CreateConVar("sm_allcrit_enable","1","Enable/Disable All Crits");
	//HookEvent("player_spawn", OnPlayerSpawn);
}

public TF2_OnWaitingForPlayersStart() {
	g_warmup = true;
}

public TF2_OnWaitingForPlayersEnd() {
	g_warmup = false;
}

public Action:TF2_CalcIsAttackCritical(client, weapon, String:weaponname[], &bool:result)
{
	if (!GetConVarBool(IsAllCritOn) || g_warmup) {
		return Plugin_Continue;
	}
	else {
		result = true; //100% crits
		return Plugin_Handled; //Stop TF2 from doing anything about it
	}
}
/*
public Action:OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast) {
	if (!GetConVarBool(IsAllCritOn) || g_warmup)
		return Plugin_Continue;
	
	new clientId = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (clientId == 0)
		return Plugin_Continue;

	if (IsClientInGame(clientId)) {
		TF2_AddCondition(clientId, TFCond_CritRuneTemp);
	}
	
	return Plugin_Continue;
}
*/