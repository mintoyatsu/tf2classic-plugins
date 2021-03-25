#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <tf2c>
#include <sdktools>
//#undef REQUIRE_PLUGIN
//#tryinclude <tf2pyroairjump>
//#define REQUIRE_PLUGIN

#define PLUGIN_VERSION "1.2.2"

new Handle:sm_needlejump_version = INVALID_HANDLE;
new Handle:sm_needlejump_enabled = INVALID_HANDLE;
new Handle:sm_needlejump_prethink = INVALID_HANDLE;
//new Handle:tf_flamethrower_burst_zvelocity = INVALID_HANDLE;

new bool:bPluginEnabled = true;
new bool:bOnPreThink = false;
//new Float:flZVelocity = 0.0;

new Float:flNextPrimaryAttack[MAXPLAYERS+1];

//new Handle:fwOnPyroAirBlast = INVALID_HANDLE;

public Plugin:myinfo = {
	name = "[TF2] Medic Needle Jump",
	author = "mintoyatsu",
	description = "Jump with needle gun",
	version = PLUGIN_VERSION,
	url = "mintosoft.net"
}

//public APLRes:AskPluginLoad2(Handle:hMySelf, bool:bLate, String:strError[], iMaxErrors)
//{
//    RegPluginLibrary( "tf2pyroairjump" );
//    return APLRes_Success;
//}

public OnPluginStart()
{
	sm_needlejump_version = CreateConVar("sm_needlejump_version", PLUGIN_VERSION, "TF2 Medic Needle Jump plugin version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_REPLICATED);
	SetConVarString(sm_needlejump_version, PLUGIN_VERSION, true, true);
	HookConVarChange(sm_needlejump_version, OnConVarChanged_PluginVersion);
	
	sm_needlejump_enabled = CreateConVar("sm_needlejump_enabled", "1", "", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(sm_needlejump_enabled, OnConVarChanged);
	
	sm_needlejump_prethink = CreateConVar("sm_needlejump_prethink", "0", "Use OnPreThink instead of OnGameFrame?", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(sm_needlejump_prethink, OnConVarChanged);
	
	//tf_flamethrower_burst_zvelocity = FindConVar( "tf_flamethrower_burst_zvelocity" );
	
	//fwOnPyroAirBlast = CreateGlobalForward( "TF2_OnPyroAirBlast", ET_Event, Param_Cell );
	
	for( new i = 0; i <= MAXPLAYERS; i++ )
	{
		flNextPrimaryAttack[i] = GetGameTime();
		if( IsValidClient(i) )
		{
			if( bOnPreThink )
				SDKHook( i, SDKHook_PreThink, OnPreThink );
			SDKHook( i, SDKHook_WeaponSwitchPost, OnWeaponSwitchPost );
		}
	}
}

public OnConVarChanged_PluginVersion( Handle:hConVar, const String:strOldValue[], const String:strNewValue[] )
	if( strcmp( strNewValue, PLUGIN_VERSION, false ) != 0 )
		SetConVarString( hConVar, PLUGIN_VERSION, true, true );
public OnConVarChanged( Handle:hConVar, const String:strOldValue[], const String:strNewValue[] )
	OnConfigsExecuted();

public OnConfigsExecuted()
{
	bPluginEnabled = GetConVarBool( sm_needlejump_enabled );
	bOnPreThink = GetConVarBool( sm_needlejump_prethink );
	for( new i = 1; i <= MaxClients; i++ )
		if( IsValidClient( i ) )
		{
			if( bOnPreThink )
				SDKHook( i, SDKHook_PreThink, OnPreThink );
			else
				SDKUnhook( i, SDKHook_PreThink, OnPreThink );
		}
	//flZVelocity = GetConVarFloat( tf_flamethrower_burst_zvelocity );
}

public OnClientPutInServer( iClient )
{
	flNextPrimaryAttack[iClient] = GetGameTime();
	if( bOnPreThink )
		SDKHook( iClient, SDKHook_PreThink, OnPreThink );
	SDKHook( iClient, SDKHook_WeaponSwitchPost, OnWeaponSwitchPost );
}

public OnGameFrame()
{
	for( new i = 1; i <= MaxClients; i++ )
		if( IsValidClient( i ) )
			OnPreThink( i );
}

public OnPreThink( iClient )
{
	if( !IsPlayerAlive(iClient) )
		return;
	
	if( TF2_GetPlayerClass(iClient) != TFClass_Medic )
		return;

	new iNextTickTime = RoundToNearest( FloatDiv( GetGameTime() , GetTickInterval() ) ) + 5;
	SetEntProp( iClient, Prop_Data, "m_nNextThinkTick", iNextTickTime );
	
	//new Float:flSpeed = GetEntPropFloat( iClient, Prop_Send, "m_flMaxspeed" );
	//if( flSpeed > 0.0 && flSpeed < 5.0 )
	//	return;
	
	if( GetEntProp( iClient, Prop_Data, "m_nWaterLevel" ) > 1 )
		return;
	
	if( (GetClientButtons(iClient) & IN_ATTACK) != IN_ATTACK )
		return;

	new iWeapon = GetEntPropEnt( iClient, Prop_Send, "m_hActiveWeapon" );
	if( !IsValidEntity(iWeapon) )
		return;
	
	decl String:strClassname[32];
	GetEntityClassname( iWeapon, strClassname, sizeof(strClassname) );
	if( !StrEqual( strClassname, "tf_weapon_syringegun_medic", false ) )
		return;
	
	if( ( GetEntPropFloat( iWeapon, Prop_Send, "m_flNextPrimaryAttack" ) - flNextPrimaryAttack[iClient] ) <= 0.0 )
		return;
	flNextPrimaryAttack[iClient] = GetEntPropFloat( iWeapon, Prop_Send, "m_flNextPrimaryAttack" );
	
	//PrintToChat( iClient, "%0.1f", GetEntPropFloat( iWeapon, Prop_Send, "m_flNextPrimaryAttack" ) - flNextPrimaryAttack[iClient] );
	//PrintToChat( iClient, "%0.1f %0.1f %0.1f", GetEntPropFloat( iWeapon, Prop_Send, "m_flNextPrimaryAttack" ), flNextPrimaryAttack[iClient], GetGameTime() );
	
	//decl Action:result;
	//Call_StartForward( fwOnPyroAirBlast );
	//Call_PushCell( iClient );
	//Call_Finish( result );
	//if( result == Plugin_Handled || result == Plugin_Stop )
	//	return;
	
	if( (GetEntityFlags(iClient) & FL_ONGROUND) == FL_ONGROUND )
		return;
	
	if( !bPluginEnabled )
		return;
	
	decl Float:vecAngles[3], Float:vecVelocity[3];
	GetClientEyeAngles( iClient, vecAngles );
	GetEntPropVector( iClient, Prop_Data, "m_vecVelocity", vecVelocity );
	
	vecVelocity[0] += (10.0 * Cosine(DegToRad(vecAngles[1])) * -1.0);
	vecVelocity[1] += (10.0 * Sine(DegToRad(vecAngles[1])) * -1.0);
	vecVelocity[2] -= (100.0 * Sine(DegToRad(vecAngles[0])) * -1.0);
	
	if (FloatAbs(vecVelocity[0]) > 400.0)
	{
		vecVelocity[0] = vecVelocity[0] > 0.0
			? 400.0
			: -400.0;
	}

	if (FloatAbs(vecVelocity[1]) > 400.0)
	{
		vecVelocity[1] = vecVelocity[1] > 0.0
			? 400.0
			: -400.0;
	}

	if (vecVelocity[2] > 400.0)
	{
		vecVelocity[2] = 400.0;
	}
	
	TeleportEntity( iClient, NULL_VECTOR, NULL_VECTOR, vecVelocity );
}

public OnWeaponSwitchPost( iClient, iWeapon )
{
	if( !IsValidClient(iClient) || !IsPlayerAlive(iClient) || !IsValidEntity(iWeapon) )
		return;
	
	decl String:strClassname[32];
	GetEntityClassname( iWeapon, strClassname, sizeof(strClassname) );
	if( !StrEqual( strClassname, "tf_weapon_syringegun_medic", false ) )
		return;
	
	flNextPrimaryAttack[iClient] = GetEntPropFloat( iWeapon, Prop_Send, "m_flNextPrimaryAttack" );
}

stock bool:IsValidClient( iClient )
{
	if( iClient <= 0 ) return false;
	if( iClient > MaxClients ) return false;
	if( !IsClientConnected(iClient) ) return false;
	return IsClientInGame(iClient);
}