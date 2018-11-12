#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <cstrike>

public Plugin:myinfo = 
{
	name = "respa",
	author = "Stanislav752",
	description = "respa",
	version = SOURCEMOD_VERSION,
};


public OnPluginStart()
{
	RegAdminCmd("sm_spawn", Respawn, ADMFLAG_BAN, "respa");
}

public Action:Respawn(client, args)
{
	new args_num = GetCmdArgs();
 
	if(args_num == 1)
	{
	new String:arg1[16];
	GetCmdArg(1, arg1, sizeof(arg1));
	new respa = StringToInt(arg1);
	if(respa > 0)
	{
		CS_RespawnPlayer(respa);
	}
	else
	{
		PrintToChat(client, "Usage: sm_spawn [int:client]");
	}
	else if(args_num < 1)
	{
		CS_RespawnPlayer(client);
	}
	else
	{
		PrintToChat(client, "Usage: sm_spawn [int:client]");
	}
}