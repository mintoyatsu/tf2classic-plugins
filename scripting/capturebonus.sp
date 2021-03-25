#pragma semicolon 1

#include <sourcemod>
#include <tf2c>

#define PLUGIN_VERSION "1.0"

new Handle:g_hCVEnable;
new Handle:g_hCVBonusMode;
new Handle:g_hCVBonusTime;

public Plugin:myinfo =
{
	name = "[TF2] Capturebonus",
	author = "fluxX",
	description = "Gives players a bonus when they capturing a point.",
	version = PLUGIN_VERSION,
	url = "http://wcfan.de"
};

public OnPluginStart()
{
	new Handle:hVersion = CreateConVar("sm_capturebonus_version", PLUGIN_VERSION, "CaptureBonus", FCVAR_NOTIFY|FCVAR_REPLICATED|FCVAR_DONTRECORD);
	if(hVersion != INVALID_HANDLE)
	{
		SetConVarString(hVersion, PLUGIN_VERSION);
		HookConVarChange(hVersion, OnConVarVersionChange);
	}
	
	g_hCVEnable = CreateConVar("sm_capturebonus_enabled", "1", "Plugin CaptureBonus (0 = Disabled, 1 = Enabled).", FCVAR_NONE);
	g_hCVBonusMode = CreateConVar("sm_capturebonus_mod", "1", "Bonus mode (1 = crits,  2 = mini-crits, 3 = ubercharge).", FCVAR_NONE, true, 1.0,true, 3.0);
	g_hCVBonusTime = CreateConVar("sm_capturebonus_time", "10", "How long should the bonus hold on?", FCVAR_NONE);
	
	HookConVarChange(g_hCVEnable, OnConVarChange);
	HookConVarChange(g_hCVBonusMode, OnConVarChange);
	HookConVarChange(g_hCVBonusTime, OnConVarChange);
	
	if(!HookEvent("teamplay_point_captured", Event_TeamplayPointCaptured))
	{
		SetFailState("Could not hook the teampoint_point_captured event! - Wrong mod?");
	}

	AutoExecConfig(true, "capturebonus");
}

public OnConVarVersionChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	SetConVarString(convar, PLUGIN_VERSION);
}

public OnConVarChange(Handle:hCvar, const String:oldValue[], const String:newValue[])
{
	if(hCvar == g_hCVEnable)
		SetConVarString(g_hCVEnable, newValue);
	if(hCvar == g_hCVBonusMode)
		SetConVarString(g_hCVBonusMode, newValue);
	if(hCvar == g_hCVBonusTime)
		SetConVarString(g_hCVBonusTime, newValue);
}

public Action:Event_TeamplayPointCaptured(Handle:hEvent, const String:name[], bool:dontBroadcast)
{
	new String:sCappers[MAXPLAYERS+1], iClient;
	GetEventString(hEvent, "cappers", sCappers, MAXPLAYERS);
	for(new i=0; i<=MAXPLAYERS; i++)
	{
		iClient = sCappers[i]; // for some reason it's very important
		if(iClient>0 && iClient<=MaxClients && IsClientInGame(iClient))
		{
			GiveCaptureBonus(iClient);
		}
	}
}

public GiveCaptureBonus(client)
{
	new Float:fBonusTime = GetConVarFloat(g_hCVBonusTime);
	new iBonusMode = GetConVarInt(g_hCVBonusMode);
	
	if(!GetConVarBool(g_hCVEnable) || fBonusTime <= 0.0)
		return;
	
	if(!IsClientInGame(client) || !IsPlayerAlive(client))
		return;
	
	switch(iBonusMode)
	{
		case 1:		
			TF2_AddCondition(client, TFCond_CritRuneTemp, fBonusTime);
		case 2:
			TF2_AddCondition(client, TFCond_Buffed, fBonusTime);
		case 3:
			TF2_AddCondition(client, TFCond_UberchargedCanteen, fBonusTime);
		default:
			SetFailState("g_hCVBonusMode has a wrong value!");
	}
}