/*
 * 
 * Instant Knife Kills
 * 
 * All knife stabs are instant kill (facestabs)
 * 
 */


#include <sourcemod>
#include <sdkhooks>
#include <tf2c>

#define PLUGIN_NAME "Facestabs"
#define PLUGIN_VERSION "0.0.1"
#define PLUGIN_DESC "All knife stabs are facestabs"
#define PLUGIN_URL "http://www.team-vipers.com"
#define PLUGIN_AUTHOR "InsaneMosquito"

public Plugin:myinfo = 
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESC,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

new Handle:gcv_bEnable = INVALID_HANDLE;

public OnPluginStart()
{
	gcv_bEnable = CreateConVar("sm_facestab_enabled", "1", "<0/1> Enable Plugin");
	
	HookConVarChange(gcv_bEnable, OnConVarChange);
}

public OnConfigsExecuted()
{
	if (GetConVarInt(gcv_bEnable))
	{
		for (new i = 1; i < MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				PlayerDamage_Hook(i);
			}
		}
	}
}

public OnConVarChange(Handle:convar, const String:oldValue[], const String:newValue[]) {
	if(convar == gcv_bEnable) {
		for (new i = 1; i < MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				if(GetConVarInt(gcv_bEnable) <= 0) {
					PlayerDamage_UnHook(i);
				}
				else {
					PlayerDamage_Hook(i);
				}
			}
		}
	}
}

public OnClientPutInServer(client)
{
    PlayerDamage_Hook(client);
}

PlayerDamage_Hook(client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage_Hook);
}

PlayerDamage_UnHook(client)
{
    SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage_Hook);
}

public Action:OnTakeDamage_Hook(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3])
{
	if (!GetConVarInt(gcv_bEnable))
		return Plugin_Continue;
	
	if( attacker <= 0 ) return Plugin_Continue;
	if( attacker > MaxClients ) return Plugin_Continue;

	new iWeapon = GetEntPropEnt( attacker, Prop_Send, "m_hActiveWeapon" );
	if( !IsValidEntity(iWeapon) )
		return Plugin_Continue;
	
	decl String:strClassname[32];
	GetEntityClassname( iWeapon, strClassname, sizeof(strClassname) );
	if( !StrEqual( strClassname, "tf_weapon_knife", false ) )
		return Plugin_Continue;

	damage = 10000.0;
	damagetype = DMG_SLASH;
	return Plugin_Changed;
}
