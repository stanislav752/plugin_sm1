#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdktools_engine>
#include <sdkhooks>
#include <cstrike>

public Plugin:myinfo = 
{
	name = "bomba",
	author = "Stanislav752",
	description = "bomb defuse and kill all",
	version = SOURCEMOD_VERSION,
};

new t_died;
new ct_died;

public OnPluginStart()
{
	HookEvent("bomb_defused", bomb_defused, EventHookMode_Pre);	
	HookEvent("player_spawn", player_spawn);
	HookEvent("player_death", player_death);
}

public player_spawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	t_died = 0;
	ct_died = 0;
}


public Action:bomb_defused(Handle:event, const String:name[], bool:dontBroadcast) 
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	GivePlayerItem(client, "weapon_c4", 0);
	
	SetConVarInt(FindConVar("sv_cheats"), 1, false, false);
	FakeClientCommand(client, "ent_fire planted_c4 kill");
	SetConVarInt(FindConVar("sv_cheats"), 0, false, false);
	
	PrintToChatAll("%d", t_died);
	PrintToChatAll("%d", GetTeamClientCount(2));
	
	if(GetTeamClientCount(2) == t_died)
	{
		PrintToChatAll("%d", t_died);
		return Plugin_Continue;
	}
	else
	{
		CS_TerminateRound(3.0, CSRoundEnd_BombDefused, false);
		return Plugin_Changed;
	}
}

public Action:player_death(Handle:event, const String:name[], bool:dontBroadcast) 
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(GetClientTeam(client) == 2)
	{
		t_died++;
	}
	
	if(GetClientTeam(client) == 3)
	{
		ct_died++;
		if(GetTeamClientCount(3) == ct_died)
		{
			CS_TerminateRound(3.0, CSRoundEnd_CTWin, false);
		}
	}
}


public Action:CS_OnTerminateRound(&Float:delay, &CSRoundEndReason:reason)
{
	if(reason == CSRoundEnd_BombDefused)
	{
		if(GetTeamClientCount(2) != t_died)
		{
			PrintToChatAll("Handled");
			return Plugin_Handled;
		}
		else
		{
			return Plugin_Continue;
		}
	}
	else
	{
		return Plugin_Continue;
	}
}






