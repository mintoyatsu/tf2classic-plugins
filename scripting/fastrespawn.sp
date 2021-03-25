#pragma semicolon 1

#include <sourcemod>
#include <tf2c>

#define PLUGIN_VERSION  "1"

new Handle:plugin_enable = INVALID_HANDLE;
//new Handle:plugin_time = INVALID_HANDLE;
new Handle:plugin_time_red = INVALID_HANDLE;
new Handle:plugin_time_blu = INVALID_HANDLE;
new Handle:plugin_time_grn = INVALID_HANDLE;
new Handle:plugin_time_ylw = INVALID_HANDLE;
new bool:sd;

new enablehook = 0;

public Plugin:myinfo = 
{
    name = "Fast Respawn",
    author = "Fire - Dragonshadow",
    description = "Fast Respawn",
    version = PLUGIN_VERSION,
    url = "www.snigsclan.com"
}

public OnPluginStart()
{
    
    CreateConVar("sm_fastrespawn_version", PLUGIN_VERSION, "Fast Respawn Version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
    plugin_enable = CreateConVar("sm_fastrespawn_enable", "1", "Enable/Disable Fast Respawn", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    //plugin_time = CreateConVar("sm_fastrespawn_time", "3.0", "Respawn Time", FCVAR_NOTIFY, true, 0.1, true, 5.0);
    plugin_time_red = CreateConVar("sm_fastrespawn_time_red", "3.0", "Respawn Time", FCVAR_NOTIFY, true, 0.1, true, 5.0);
    plugin_time_blu = CreateConVar("sm_fastrespawn_time_blu", "3.0", "Respawn Time", FCVAR_NOTIFY, true, 0.1, true, 5.0);
    plugin_time_grn = CreateConVar("sm_fastrespawn_time_grn", "3.0", "Respawn Time", FCVAR_NOTIFY, true, 0.1, true, 5.0);
    plugin_time_ylw = CreateConVar("sm_fastrespawn_time_ylw", "3.0", "Respawn Time", FCVAR_NOTIFY, true, 0.1, true, 5.0);

    HookEvent("player_death", death);
    HookEvent("teamplay_round_stalemate", Event_SuddenDeathStart);
    HookEvent("teamplay_round_start", Event_SuddenDeathEnd);
    HookEvent("teamplay_round_win", Event_SuddenDeathStart);
    HookEvent("teamplay_win_panel", Event_SuddenDeathStart);
    
    HookConVarChange(plugin_enable, OnCvarChanged);
}

public OnConfigsExecuted() 
{
    enablehook = GetConVarInt(plugin_enable);
} 

public OnCvarChanged(Handle:convar, const String:oldValue[], const String:newValue[]) 
{
    enablehook = GetConVarInt(plugin_enable);
} 

public Action:respawn(Handle:timer, any:client)
{
    if(enablehook)
    {
        if(!sd)
        {
            if (IsClientConnected(client) && IsClientInGame(client)) 
            {
                new team = GetClientTeam(client);
                if(!IsPlayerAlive(client) && team != 1)
                {
                	TF2_RespawnPlayer(client);
                }
            }
        }
    }
    return Plugin_Continue;
}

public death(Handle:event, const String:name[], bool:dontBroadcast)
{
    if(enablehook)
    {
        if(!sd)
        {
            new deathflags = GetEventInt(event, "death_flags");
            if(!(deathflags & 32))
            {
                new client = GetClientOfUserId(GetEventInt(event,"userid"));
                new TFTeam:team = TF2_GetClientTeam(client);
                new Float:time;
                switch (team) {
                    case TFTeam_Red: {
                        time = GetConVarFloat(plugin_time_red);
                    }
                    case TFTeam_Blue: {
                        time = GetConVarFloat(plugin_time_blu);
                    }
                    case TFTeam_Green: {
                        time = GetConVarFloat(plugin_time_grn);
                    }
                    case TFTeam_Yellow: {
                        time = GetConVarFloat(plugin_time_ylw);
                    }
                    default: {
                        time = GetConVarFloat(plugin_time_red);
                    }
                }
                CreateTimer(time, respawn, client);
            }
        }
    }
}

public Event_SuddenDeathStart(Handle:event, const String:name[], bool:dontBroadcast)
{
    sd = true;
}

public Event_SuddenDeathEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
    sd = false;
}