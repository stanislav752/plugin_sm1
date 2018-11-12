#pragma semicolon 1
#pragma deprecated Use SetListenOverride() instead
#define FEATURECAP_PLAYERRUNCMD_11PARAMS	"SDKTools PlayerRunCmd 11Params"


#include <sourcemod>
#include <sdktools>
#include <halflife>
#include <usermessages>
#include <cstrike>
#include <entity_prop_stocks>
#include <sdktools_functions>
#include <sdktools_engine>
#include <sdktools_trace>
#include <sdktools_tempents>
#include <basecomm>
#include <menus>
#include <colors>
#include <sdkhooks>
#include <clientprefs>
#include <sdktools_sound>
#include <cw_stocks>


#define FL_ONGROUND			(1 << 0)
#define FL_DUCKING   (1 << 1)
#define FFADE_IN            0x0001
#define FFADE_OUT            0x0002
#define FFADE_MODULATE    0x0004
#define FFADE_STAYOUT    0x0008
#define FFADE_PURGE        0x0010



public Plugin:myinfo = 
{
	name = "flight",
	author = "Stanislav752",
	description = "flight",
	version = SOURCEMOD_VERSION,
};


new bool:flight[MAXPLAYERS+1];
new allow_flights = 1;



public OnPluginStart()
{
	PrecacheSound("sound/flight.wav"); // flight sound
	
	AddFileToDownloadsTable("sound/flight.wav");
	
	RegisterOffsets();
	
	RegConsoleCmd("sm_f", flight_buy, "flight");
	
	HookEvent("player_spawn", player_spawn);
	HookEvent("player_footstep", player_footstep);
	HookEvent("player_death", player_death, EventHookMode_Pre);
	
	
	
	CreateTimer(0.02, flight_init, _, TIMER_REPEAT);
	CreateTimer(10.0, flight_snd, _, TIMER_REPEAT);
}



public player_spawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	flight[client] = false;
	
	
	
}




public Action:flight_buy(client, args)
{
	/*
	new entity_flight = CreateEntityByName("prop_physics");
	PrecacheModel("models/parachute/parachute_gargoyle.mdl",true);
	SetEntityModel(entity_flight, "models/parachute/parachute_gargoyle.mdl");
	*/
	if(flight[client])
	{
		flight[client] = false;
		FakeClientCommand(client, "stopsound ");
		
		if(GetClientTeam(client) == 2)
		{
			PrecacheModel("models/player/t_arctic.mdl",true);
			SetEntityModel(client, "models/player/t_arctic.mdl");
		}
		else if(GetClientTeam(client) == 3)
		{
			PrecacheModel("models/player/ct_gign.mdl",true);
			SetEntityModel(client, "models/player/ct_gign.mdl");
		}
		SetEntityGravity(client, 1.0);
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
		
		new Float:angs[3];
		GetClientEyeAngles(client, angs);
				
		angs[2] = 0.0;
				
		TeleportEntity(client, NULL_VECTOR, angs, NULL_VECTOR);
	}
	else if(allow_flights == 1)
	{
		flight[client] = true;
		PrecacheModel("models/props/de_dust/wagon.mdl",true);
		SetEntityGravity(client, 3.0);
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.4);
	}
}


public Action:flight_snd(Handle:timer)
{
	for(new i=1; i<=GetMaxClients(); i++)
	{
		if(flight[i] == true)
		{
			ClientCommand(i, "playgamesound flight.wav");
		}
	}
	return Plugin_Continue;
}



public Action:flight_init(Handle:timer)
{
	for(new i=1; i<=GetMaxClients(); i++)
	{
		if(flight[i] == true)
		{
			if(GetClientButtons(i) == 12)
			{
				new Float:alt = GetEntityGravity(i);
				
				if(alt < 6.0) alt += 0.0005;
				
				SetEntityGravity(i, alt);
			}
			else if(GetClientButtons(i) == 8)
			{	
		
				if((GetEntityFlags(i) & FL_ONGROUND) == false)
				{
					if(GetClientButtons(i) == 8)
					{
						new Float:flightspeed = GetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 0);
						
						
						if(flightspeed < 6.0) flightspeed += 0.4;
						SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", flightspeed);
					}
					
					// SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 6.0);
				}
				
			}
			else if((GetClientButtons(i) == 1024) || (GetClientButtons(i) == 1032)) //32
			{	
				new Float:angs[3];
				GetClientEyeAngles(i, angs);
				if(angs[2] > -1.0) angs[2] += 2.0;
				PrintToChat(i, "%f", angs[2]);
				
				TeleportEntity(i, NULL_VECTOR, angs, NULL_VECTOR);
			}
			else if((GetClientButtons(i) == 512) || (GetClientButtons(i) == 520)) //20
			{	
				new Float:angs[3];
				GetClientEyeAngles(i, angs);
				
				if(angs[2] > -49.0) angs[2] -= 2.0;
				
				TeleportEntity(i, NULL_VECTOR, angs, NULL_VECTOR);
			}
			else if(GetClientButtons(i) == 16) //20
			{	
				new Float:flightspeed = GetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 0);
						
						
				if(flightspeed > 1.2) flightspeed -= 0.03;
				SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", flightspeed);
			}
			if(GetEntityFlags(i) & FL_ONGROUND)
			{
				new Float:angs[3];
				GetClientEyeAngles(i, angs);
				
				if(angs[2] > 15 || angs[2] < 0)
				{
					FakeClientCommand(i, "kill");
				}
			}
		}
	}
	return Plugin_Continue;
}

public player_footstep(Handle:event, const String:name[], bool:dontBroadcast)
{
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	
	if(flight[client] == true)
	{
		new Float:flightspeed = GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0);
		if(GetClientButtons(client) == 8)
		{
			if(flightspeed < 5.0) flightspeed += 0.4;
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", flightspeed);
		}
		else if(GetClientButtons(client) == 0)
		{
			if(flightspeed > 0.6)
			{
				flightspeed -= 0.7;
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", flightspeed);
			}
			else
			{
				flightspeed = 0.5;
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
			}
			
		}
		else if(GetClientButtons(client) == 10)
		{
			SetEntityGravity(client, 0.0001);
			
		}
		else if(GetClientButtons(client) == 16)
		{
			
		}
		
		
		
		
		PrintToChat(client, "%d", GetClientButtons(client));
		
	}
	
}



public Action:player_death(Handle:event, const String:name[], bool:silent) 
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	flight[client] = false;
	
}
















