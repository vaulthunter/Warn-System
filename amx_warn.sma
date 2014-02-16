/*
	CopyRight @ 2014 by LordOfNothing

	This "Warn Plugin" is public
	plugin and is illegal to sell or
	edit it for money or other things
	With this plugin you can warn a player
	like in a comunnity but direct on your
	server !
	

*/

#include <amxmodx>
#include <amxmisc>
#include <nvault>


new const PLUGIN [] = "Warn System";
new const AUTHOR [] = "LordOfNothing";
new const VERSION [] = "1.4";

new g_warns[33];

new g_dede;

new cvars[3];

enum Color
{
	NORMAL = 1, // clients scr_concolor cvar color
	YELLOW = 1, // NORMAL alias
	GREEN, // Green Color
	TEAM_COLOR, // Red, grey, blue
	GREY, // grey
	RED, // Red
	BLUE, // Blue
}
 
new TeamName[][] =
{
	"",
	"TERRORIST",
	"CT",	
	"SPECTATOR"
}


public plugin_init()
{
	register_plugin(PLUGIN,VERSION,AUTHOR);

        g_dede = nvault_open("warn_vaults");

	register_concmd("amx_warn","cmd_warn",ADMIN_KICK,"<NUME>");
	register_concmd("amx_unwarn","cmd_unwarn",ADMIN_KICK,"<NUME>");

	cvars[0] = register_cvar("warn_tag","TAG")
	cvars[1] = register_cvar("warn_max","3")
	cvars[2] = register_cvar("warn_bantime","120")

	register_clcmd("say /warns","ShowWrn")
	register_clcmd("say /warn","ShowWrn")
	register_clcmd("say /warnuri","ShowWrn")
	register_clcmd("say /wrn","ShowWrn")

	register_clcmd("say_team /warns","ShowWrn")
	register_clcmd("say_team /warn","ShowWrn")
	register_clcmd("say_team /warnuri","ShowWrn")
	register_clcmd("say_team /wrn","ShowWrn")
}

public ShowWrn(id)
{
	new szMsg[60]
	get_pcvar_string(cvars[0], szMsg, charsmax(szMsg) - 1)

	ColorChat(id, TEAM_COLOR, "^1[ ^3%s^1 ] Ai ^4%i^1 warn-uri , ai grija la ^4%i^1 vei primi ban pentru ^4%s^1 minute !", szMsg, g_warns[id], get_pcvar_num(cvars[1]), get_pcvar_num(cvars[2]))
	return 1
}

public cmd_warn(id,level,cid)
{
	if(!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED;
	
	new arg[33], amount[33]
	read_argv(1, arg, charsmax(arg) - 1)
	read_argv(2, amount, charsmax(amount) - 1)
	new target = cmd_target(id, arg, 7)
	new admin_name[35], player_name[35];
	get_user_name(target, player_name, charsmax(player_name) - 1);
	get_user_name(id, admin_name, charsmax(admin_name) - 1);

	new szMsg[60]
	get_pcvar_string(cvars[0], szMsg, charsmax(szMsg) - 1)

	new wors = str_to_num(amount)
	
	
	if(!target)
	{
		return 1
	}
	
	if(g_warns[target] < get_pcvar_num(cvars[1]))
	{
		g_warns[target] = g_warns[target] + wors;
		ColorChat(0, TEAM_COLOR, "^1[ ^3%s^1 ] Adminul ^4%s^1 i-a dat ^4%i^1 avertismente lui ^4%s^1 !",szMsg,admin_name,wors,player_name);
		SaveData(target);
		return 0
	}

	else
	{
		server_cmd("amx_ban #%d %i WARN",get_user_userid(target), get_pcvar_num(cvars[2]));
		g_warns[target] = 0;
		return 0
	}

	return 0
}


public cmd_unwarn(id,level,cid)
{
	if(!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED;
	
	new arg[33], amount[33]
	read_argv(1, arg, charsmax(arg) - 1)
	read_argv(2, amount, charsmax(amount) - 1)
	new target = cmd_target(id, arg, 7)
	new admin_name[35], player_name[35];
	get_user_name(target, player_name, charsmax(player_name) - 1);
	get_user_name(id, admin_name, charsmax(admin_name) - 1);

	new szMsg[60]
	get_pcvar_string(cvars[0], szMsg, charsmax(szMsg) - 1)

	new wors = str_to_num(amount)
	
	
	if(!target)
	{
		return 1
	}
	

	g_warns[target] = g_warns[target] - wors;
	ColorChat(0, TEAM_COLOR, "^1[ ^3%s^1 ] Adminul ^4%s^1 i-a scos ^4%i^1 avertismente lui ^4%s^1 !",szMsg,admin_name,wors,player_name);
	SaveData(target);
	return 0
}

public SaveData(id)
{
        new PlayerName[35];
        get_user_authid(id,PlayerName,34);
        
        new vaultkey[64],vaultdata[256];
        format(vaultkey,63,"%s",PlayerName);
        format(vaultdata,255,"%i",g_warns[id]);
        nvault_set(g_dede,vaultkey,vaultdata);
        return PLUGIN_CONTINUE;
}
public LoadData(id)
{
        new PlayerName[35];
        get_user_authid(id,PlayerName,34);
        
        new vaultkey[64],vaultdata[256];
        format(vaultkey,63,"%s",PlayerName);
        format(vaultdata,255,"%i",g_warns[id]);
        nvault_get(g_dede,vaultkey,vaultdata,255);
        
        replace_all(vaultdata, 255, "`", " ");
        
        new playerw[32]
        
        parse(vaultdata, playerw, 31);
        
        g_warns[id] = str_to_num(playerw);
        
        return PLUGIN_CONTINUE;
}

public client_disconnect(id)
{
	SaveData(id)
}

public client_putinserver(id)
{
	LoadData(id)
}


ColorChat(id, Color:type, const msg[], {Float,Sql,Result,_}:...)
{
	new message[256];
 
	switch(type)
	{
		case NORMAL: // clients scr_concolor cvar color
		{
			message[0] = 0x01;
		}
		case GREEN: // Green
		{
			message[0] = 0x04;
		}
		default: // White, Red, Blue
		{
			message[0] = 0x03;
		}
	}
	 
	vformat(message[1], 251, msg, 4);
 
	// Make sure message is not longer than 192 character. Will crash the server.
	message[191] = '^0';
 
	new team, ColorChange, index, MSG_Type;
	if(id)
	{
		MSG_Type = MSG_ONE;
		index = id;
	} else {
		index = FindPlayer();
		MSG_Type = MSG_ALL;
	}

	team = get_user_team(index);
	ColorChange = ColorSelection(index, MSG_Type, type);
 

	ShowColorMessage(index, MSG_Type, message);
	if(ColorChange)
	{
		Team_Info(index, MSG_Type, TeamName[team]);
	}
}
 
ShowColorMessage(id, type, message[])
{
	static get_user_msgid_saytext;
	if(!get_user_msgid_saytext)
	{
		get_user_msgid_saytext = get_user_msgid("SayText");
	}
	message_begin(type, get_user_msgid_saytext, _, id);
	write_byte(id)	
	write_string(message);
	message_end();	
}
 
Team_Info(id, type, team[])
{
	static bool:teaminfo_used;
	static get_user_msgid_teaminfo;
	if(!teaminfo_used)
	{
		get_user_msgid_teaminfo = get_user_msgid("TeamInfo");
		teaminfo_used = true;
	}
	message_begin(type, get_user_msgid_teaminfo, _, id);
	write_byte(id);
	write_string(team);
	message_end();
 
	return 1;
}
 
ColorSelection(index, type, Color:Type)
{
	switch(Type)
	{
		case RED:
		{
			return Team_Info(index, type, TeamName[1]);
		}
		case BLUE:
		{
			return Team_Info(index, type, TeamName[2]);
		}
		case GREY:
		{
			return Team_Info(index, type, TeamName[0]);
		}
	}
 
	return 0;
}
 
FindPlayer()
{
	new i = -1;
	static iMaxPlayers;
	if( !iMaxPlayers )
	{
		iMaxPlayers = get_maxplayers( );
	}
	while(i <= iMaxPlayers)
	{
		if(is_user_connected(++i))
			return i;
	}
 
	return -1;
}
