main(); // what is that?
#pragma dynamic 6250 
#pragma warning disable 239
#pragma warning disable 214
#pragma warning disable 202
#pragma warning disable 203
#pragma warning disable 213
#pragma warning disable 217
#pragma warning disable 219
#pragma warning disable 209
#pragma warning disable 234
#pragma warning disable 204

// ............. [ INCLUDES ] .............
#include <a_samp>
#include <KickBanFix>
#include <a_mysql>
#include <Pawn.CMD>
#include <streamer>
#include <sscanf2>
#include <foreach>
#include "../include/Pawn.RakNet.inc"
#include <pawnraknet>
#include "../include/lib/m_dialog.inc"
#include <customhud>
#include <YSI_Coding\y_hooks>
#include <tuning>
// ............. [ MySQL ] .............
// TEST
/*
#define MySQL_Host "host"
#define MySQL_User "user"
#define MySQL_Base "base"
#define MySQL_Pass "password"
*/
// PROD
#define MySQL_Host "host"
#define MySQL_User "user"
#define MySQL_Base "base"
#define MySQL_Pass "password"
// ............. [ COLORS ] .............
#define         color_main              0xbb7dffAA
#define         color_red               0xd54a4aAA
#define         color_blue              0x55adffAA
#define         color_green             0x7aca74AA
#define         color_orange            0xffad55AA
#define         color_yellow            0xf9b961AA
#define         color_purple            0xea8afdAA
#define         color_brown             0x97754fAA
#define         color_black             0x080808AA
#define         color_achat       0x3FD7D0AA
#define         color_lightyellow       0xe1daa3AA

#if !defined color_white
    #define color_white 0xffffffAA
#endif

#if !defined color_gray
    #define color_gray 0x999999AA
#endif

#define SC              "{ffff00}| {ffffff}"
#define USC             "{ff2400}| {ffffff}"

#define         c_main                "{35A8A3}"
#define         c_white               "{ffffff}"
#define         c_red                 "{d54a4a}"
#define         c_blue                "{55adff}"
#define         c_green               "{7aca74}"
#define         c_orange              "{ffad55}"
#define         c_yellow              "{f9b961}"
#define         c_purple              "{ea8afd}"
#define         c_gray                "{999999}"
#define         c_brown               "{97754f}"
#define         c_black               "{080808}"
#define         c_lightyellow           "{e1daa3}"
#define         c_lightred            "{ff6347}"


#define br   "{FF6347}"
#define SERVER_NAME 	"LIT MOBILE"
#define SHORT_NAME "LIT"
#define TELEGRAM "t.me/kuzia15"
// ............. [ DEFINES ] .............
#define SPD ShowPlayerDialog
#define Send SendClientMessage
#define SCMTA SendClientMessageToAll
#define DSL DIALOG_STYLE_LIST
#define DSI DIALOG_STYLE_INPUT
#define DSM DIALOG_STYLE_MSGBOX
#define DSP DIALOG_STYLE_PASSWORD
#define Freeze(%0,%1) TogglePlayerControllable(%0, %1)
#define Pkick(%0) SetTimerEx("TimeKick", 1, false, "i", %0)
#if !defined isnull
#define isnull(%0) ((!(%0[0])) || (((%0[0]) == '\1') && (!(%0[1]))))
#endif
#define         MAX_ADMINS              50
#define CONVERT_TIME_TO_SECONDS 	1
#define CONVERT_TIME_TO_MINUTES 	2
#define CONVERT_TIME_TO_HOURS 		3
#define CONVERT_TIME_TO_DAYS 		4
#define CONVERT_TIME_TO_MONTHS 		5
#define CONVERT_TIME_TO_YEARS 		6
#define MAX_SKINS 10
#define FLOOD_INTERVAL 3000 // 3 �������
#define FLOOD_BLOCK_TIME 5000 // 5 ������
#define MAX_MUTE_DURATION 86400
#define PACKET_CUSTOMRPC 251
#define GetPlayerSpectateData(%0,%1)	g_spectate[%0][%1]
#define SetPlayerSpectateData(%0,%1,%2) g_spectate[%0][%1] = %2
#define	GetPlayerAdminEx(%0) GetPlayerData(%0, pAdmin)
#define GetPlayerData(%0,%1) 	player_info[%0][%1]
#define SetPlayerData(%0,%1,%2)	player_info[%0][%1] = %2
#define AddPlayerData(%0,%1,%2,%3) player_info[%0][%1] %2= %3
// ............. [ FORWARDS ] .............
forward PlayerCheck(playerid);
forward PlayerLogin(playerid);
forward UnmutePlayer(to_player);
forward ClearBanList();
forward UnBanIPs(time);
forward OnSecondTimer();
forward OnMinuteTimer(bool: new_day);
forward OnPlayerTimer(playerid);
forward CheckLogin(playerid);
forward TimeKick(playerid);
forward UpdateTime(playerid);
forward GetID(playerid);
forward FastSpawn(playerid);
forward OnAdminStatsLoad(playerid);
forward TechRestartTimer(playerid);
// ............. [ NEWS ] .............
new dbHandle,
    number_skin[MAX_PLAYERS char],
    number_pass[MAX_PLAYERS char],
    update_timer[MAX_PLAYERS],
    login_timer[MAX_PLAYERS];
    
new bool: login_check[MAX_PLAYERS];
new admin_rang[MAX_PLAYERS][32];
new lastMessageTime[MAX_PLAYERS];
new floodBlockTime[MAX_PLAYERS];
new g_last_m_timer_time;
new g_restart_notified = false;
new bool:isAdminSkin[MAX_PLAYERS];

new Text3D:Veh_3DTEXT[MAX_PLAYERS][MAX_VEHICLES];
new bool:Debug[MAX_PLAYERS];
// ............. [ PLAYER INFO ] .............
enum player
{
    pId,
    pName[MAX_PLAYER_NAME+1],
    pPassword[32+1],
    pEmail[46+1],
    pReferal[MAX_PLAYER_NAME+1],
    pDate_reg[10+1],
    pSkin,
    pMoney,
    pLevel,
    pAdmin,
    pMute,
    pPrefix[32],
    pMuteStartTime,
    pMuteDuration
}
new player_info[MAX_PLAYERS][player];
// ............. [ DIALOG ID ] .............
enum
{
	d_none,
    d_login,
    d_register,
    d_pass_check,
    d_mail,
    d_skin,
	d_skin_set,
    d_ahelp,
    d_tp,
	d_color,
	d_strab
}
// ............. [TP LIST ] .............
enum E_TELEPORT_LIST {
    Float:tpX,
    Float:tpY,
    Float:tpZ,
    tpName[20] // ����� ����� ����������
};

new const TeleportList[][E_TELEPORT_LIST] = {
    // X,           Y,            Z,        ��������
    {570.8985,    845.2556,    -42.0601,   "�����"},
    {25.2571,     2016.1414,   17.6406,    "��������� �����"},
    {1033.8883,   -325.4606,   73.9922,    "�����������"},
    {461.7169,    -1500.8733,  31.0444,    "������� ������"},
    {1956.7321,   -2183.5529,  13.5468,    "���� ������������"},
    {1455.9126,   751.0781,    11.0234,    "����������� �����"},
    {691.5789,    -1275.8549,  13.5607,    "��������� �����"},
    {-2719.3574,  -319.1553,   7.8438,     "������� �����"},
    {-2520.9468,  -624.9526,   132.7846,   "����� ��������"},
    {2259.4182,   -1019.1157,  59.2972,    "�����"},
    {2495.3813,   -1691.1393,  14.7656,    "����"},
    {2148.9360,   -1484.8567,  26.6241,    "������"},
    {1898.9922,   -2037.9436,  13.5469,    "�����"},
    {2736.6499,   -1952.5166,  13.5469,    "����"},
    {1368.9955,   -1279.7224,  13.5469,    "��������� (��)"},
    {-2625.8804,  208.2350,    4.8125,     "��������� (��)"},
    {2159.5447,   943.2023,    10.8203,    "��������� (��)"},
    {1038.8992,   1013.1218,   11.0000,    "���"},
    {155.7305,    1901.9454,   18.6063,    "�������"},
    {206.9499,    1923.3923,   18.6550,    "����� ������"},
    {-2026.5953,  -102.0658,   35.1641,    "���������"},
    {1465.0688,   -1009.9221,  26.8438,    "���� (��)"},
    {1172.0773,   -1323.3893,  15.4031,    "�������� (��)"},
    {1482.6595,   -1772.2944,  18.7958,    "����� (��)"},
    {-2766.5405,  375.6842,    6.3347,     "����� (��)"},
    {2388.9978,   2466.0266,   10.8203,    "����� (��)"}
};
// ............. [ LOGS ] .............
enum
{
	LOG_TYPE_ADMIN_CHAT = 1,
	LOG_TYPE_ADMIN_ANSWER,
	LOG_TYPE_ADMIN_ACTION,
	LOG_TYPE_SET_ADMIN,
	LOG_TYPE_SET_LEADER,
	LOG_TYPE_SMS_CHAT,
	LOG_TYPE_OOC_CHAT,
	LOG_TYPE_REPORT,
	LOG_TYPE_FRACTION,
	LOG_TYPE_SUPERADMIN_ACTION
}
// ............. [ SPEC ] .............
enum E_PLAYER_SPECTATE_STRUCT
{
	Float: S_START_POS_X,
	Float: S_START_POS_Y,
	Float: S_START_POS_Z,
	Float: S_START_ANGLE,
	S_START_INTERIOR,
	S_START_VIRTUAL_WORLD,
	S_PLAYER
};
new g_spectate[MAX_PLAYERS][E_PLAYER_SPECTATE_STRUCT];
// ............. [ ADMIN STATS ] .............
enum eAdminStats {
    mutes,
    bans,
    unbans,
    kicks,
    warns
}
new AdminStats[MAX_PLAYERS][eAdminStats];
new playerCreatedVehicleID[MAX_PLAYERS];
// ............. [ HANDLING ] .............
enum E_HANDLING_PARAMS {
    hpMaxSpeed,        // 0
    hpAcceleration,    // 1
    hpGear,            // 2
    hpEngineInertion,  // 3
    hpMass,            // 4
    hpMassTurn,        // 5
    hpBrakeDeceleration, // 6
    hpTractionMultiplier, // 7
    hpTractionLoss,    // 8
    hpTractionBias,    // 9
    hpSuspensionLowerLimit, // 10
    hpSuspensionBias, // 11
    hpWheelSize,       // 12
    hpMax              // 13
};

new data[] = {
    hpMaxSpeed, 500.0,         // id = 0, fvalue = 1200.0
    hpAcceleration, 50.3,     // id = 1, fvalue = 2998.3
    hpMass, 1700.0,               // id = 4, fvalue = 0.1
    hpMassTurn, 3000.0           // id = 5, fvalue = -0.8
};
// ............. [ PUBLICS ] .............
public OnGameModeInit()
{
	SetGameModeText("MTA");
	ConnectMySQL();
	AddPlayerClass(0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);

	ShowPlayerMarkers(PLAYER_MARKERS_MODE_STREAMED);
	ShowNameTags(true);
	SetNameTagDrawDistance(20.0);
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);

	//new hour;
	//gettime(hour);
	//SetWorldTime(hour); // realtime
	
	SetTimer("ClearBanList", 15_000, false);
	SetTimer("OnSecondTimer", 1000, true);
	SetWeather(3);
	
	g_last_m_timer_time = gettime();
	return true;
}
public OnGameModeExit()
{
	return true;
}
public OnPlayerRequestClass(playerid, classid)
{
	return true;
}
public OnPlayerConnect(playerid)
{
    //SetConnectServer(playerid);
    PlayAudioStreamForPlayer(playerid, "http://cdn.advens.cloud/_/73c8fd99dcf9f83227d7ffc9fbdc506e/game/music/auth.mp3");
	GetPlayerName(playerid, player_info[playerid][pName], MAX_PLAYER_NAME);
 	static fmt_str[] = "SELECT id FROM accounts WHERE name = '%s' LIMIT 1";
	new string[sizeof(fmt_str)+(-2+MAX_PLAYER_NAME)];
	mysql_format(dbHandle, string, sizeof(string), fmt_str, player_info[playerid][pName]);
	mysql_function_query(dbHandle, string, true, "PlayerCheck", "d", playerid);

	Clear(playerid);

	return true;
}
public OnPlayerDisconnect(playerid, reason)
{

    KillTimers(playerid);

	// delete player vehicles
    new createdVehicleID = playerCreatedVehicleID[playerid];
    
    for(new i = 1; i <  GetVehiclePoolSize() + 1; i++)
	{
		DestroyDynamic3DTextLabel(Veh_3DTEXT[playerid][i]);
		Veh_3DTEXT[playerid][i] = Text3D:0;
	}
	Debug[playerid] = false;
	
	if (createdVehicleID != 0 && IsValidVehicle(createdVehicleID))
	{
		DestroyVehicle(createdVehicleID);
		playerCreatedVehicleID[playerid] = 0;
	}

    return true;
}
public OnPlayerSpawn(playerid)
{
    if(login_check[playerid] == true)
	{
		SetPlayerSpawn(playerid);
	}
	else {
		SendClientMessage(playerid, color_white, ""USC"�� �� ��������������!");
	}
	return true;
}
public OnPlayerDeath(playerid, killerid, reason)
{
    new fmt_text[120];
    Debug[playerid] = false;
    
    if(killerid == INVALID_PLAYER_ID || reason >= 47 || !reason)
	{
		format(fmt_text, sizeof fmt_text, "[A] %s[%d] ���� ����", GetPlayerName(playerid), playerid);
		AdmMSG(0x999999FF, fmt_text);
	}
	else
	{
		format(fmt_text, sizeof fmt_text, "[A] %s[%d] ���� %s[%d] (%s)", GetPlayerName(killerid), killerid, GetPlayerName(playerid), playerid, GetWeaponName(reason));
		AdmMSG(0x999999FF, fmt_text);
	}
    
	return true;
}
public OnVehicleSpawn(vehicleid)
{
	return true;
}
public OnVehicleDeath(vehicleid, killerid)
{
	return true;
}
public OnPlayerText(playerid, text[])
{
    if (!login_check[playerid])
    {
        SendClientMessage(playerid, color_gray, "�� �� ������������.");
        return false;
    }


	if(GetPlayerAdminEx(playerid) < 1)
    {
	    if (player_info[playerid][pMute] >= 1)
	    {
	        SendClientMessage(playerid, color_gray, "� ��� �������� ���.");
	        SetPlayerChatBubble(playerid, "<<MUTED>>", color_red, 20.0, 7500);

	        new remaining_time = (player_info[playerid][pMuteStartTime] + player_info[playerid][pMuteDuration]) - gettime();
	        if (remaining_time > 0)
	        {
	            new time_msg[128];
	            format(time_msg, sizeof(time_msg), "�� ����� ����: %d ������", remaining_time);
	            SendClientMessage(playerid, color_red, time_msg);
	        }

	        return false;
	    }
    }

    if (strlen(text) > 144)
    {
        SendClientMessage(playerid, color_red, "������� ������� �����! �� ����� 144 ��������.");
        return false;
    }

    new currentTime = GetTickCount();
    if (currentTime - lastMessageTime[playerid] < FLOOD_INTERVAL)
    {
        if (currentTime < floodBlockTime[playerid])
        {
            SendClientMessage(playerid, color_gray, "�� �������. ��������� ����� ���������.");
            return false;
        }
        floodBlockTime[playerid] = currentTime + FLOOD_BLOCK_TIME; // 5 second mute
    }

    new str[144];
    if(GetPlayerAdminEx(playerid) >= 1)
    {
    	format(str, sizeof(str), ""c_yellow"[�����]"c_white" %s[%i] �������: %s", player_info[playerid][pName], playerid, text);
    }
    else
    {
	    format(str, sizeof(str), "%s[%i] �������: %s", player_info[playerid][pName], playerid, text);
    }
    ProxDetector(20.0, playerid, str, color_white, color_white, color_white, color_white, color_white);
    SetPlayerChatBubble(playerid, text, color_white, 20.0, 7500);

        // ��� / �������
    //new type = (text[0] == '/' && text[1] != '\0') ? 1 : 0;

    //new fmt_log[512];
    //mysql_format(dbHandle, fmt_log, sizeof(fmt_log), "INSERT INTO logchat (acc_id, type, message, timestamp) VALUES (%d, %d, '%s', NOW())", player_info[playerid][pId], type, text);
    //mysql_query(dbHandle, fmt_log, false);

    
    return false;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    //new fmt_log[512];
   // mysql_format(dbHandle, fmt_log, sizeof(fmt_log), "INSERT INTO logchat (acc_id, type, message, timestamp) VALUES (%d, 1, '%s', NOW())", player_info[playerid][pId], cmdtext);
    //mysql_query(dbHandle, fmt_log, false);
    
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return true;
}
public OnPlayerExitVehicle(playerid, vehicleid)
{
	return true;
}
public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return true;
}
public OnPlayerEnterCheckpoint(playerid)
{
	return true;
}
public OnPlayerLeaveCheckpoint(playerid)
{
	return true;
}
public OnPlayerEnterRaceCheckpoint(playerid)
{
	return true;
}
public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return true;
}
public OnRconCommand(cmd[])
{
	return true;
}
public OnPlayerRequestSpawn(playerid)
{
	return true;
}
public OnObjectMoved(objectid)
{
	return true;
}
public OnPlayerObjectMoved(playerid, objectid)
{
	return true;
}
public OnPlayerPickUpPickup(playerid, pickupid)
{
	return true;
}
public OnVehicleMod(playerid, vehicleid, componentid)
{
	return true;
}
public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return true;
}
public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return true;
}
public OnPlayerSelectedMenuRow(playerid, row)
{
	return true;
}
public OnPlayerExitedMenu(playerid)
{
	return true;
}
public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return true;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return true;
}
public OnRconLoginAttempt(ip[], password[], success)
{
	return true;
}
public OnPlayerUpdate(playerid)
{
	return true;
}
public OnPlayerStreamIn(playerid, forplayerid)
{
	return true;
}
public OnPlayerStreamOut(playerid, forplayerid)
{
	return true;
}
public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return true;
}
public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return true;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	new len = strlen(inputtext);
	switch(dialogid)
	{
     case d_register:
	    {
	        if(response)
	        {
	            if(!len)
	            {
	                ShowRegister(playerid);
	                return SendClientMessage(playerid, color_gray, "�� ������ �� �����.");
	            }
	            if(!(6 <= len <= 32))
	            {
	                ShowRegister(playerid);
					return SendClientMessage(playerid, color_gray, !"�������� ����� ������.");
	            }
	            if(CheckRusText(inputtext, len+1))
				{
				    ShowRegister(playerid);
				    return SendClientMessage(playerid, color_gray, !"������� ��������� ����������.");
				}
				strmid(player_info[playerid][pPassword], inputtext, 0, len, 32+1);
				ShowPassCheck(playerid);
	        }
	        else
	        {
	            SendClientMessage(playerid, color_red, !"������� /q[uit]");
	            Pkick(playerid);
	        }
	    }
	    case d_pass_check:
	    {
			if(!strcmp(player_info[playerid][pPassword], inputtext)) ShowEmail(playerid);
			else
			{
			    SendClientMessage(playerid, color_red, !"�������� ������.");
				return Pkick(playerid);
			}
	    }
     case d_mail:
	    {
	        if(response)
	        {
				if(!len)
				{
				    ShowEmail(playerid);
				    return SendClientMessage(playerid, color_gray, !"�� ������ �� �����.");
				}
				if(!(6 <= len <= 46))
				{
				    ShowEmail(playerid);
				    return SendClientMessage(playerid, color_gray, !"�������� ����� ���������� �����.");
				}
				if(strfind(inputtext, "@", false) == -1 || strfind(inputtext, ".", false) == -1)
				{
				    ShowEmail(playerid);
				    return SendClientMessage(playerid, color_gray, !"�������� ������ ����������� �����.");
				}
				if(CheckRusText(inputtext, len+1))
				{
				    ShowEmail(playerid);
				    return SendClientMessage(playerid, color_gray, !"������� ��������� ����������.");
				}
			    strmid(player_info[playerid][pEmail], inputtext, 0, len, 46+1);
			    
			    new year_server,
		        month_server,
		        day_server;
		        
			    SendClientMessage(playerid, color_white, ""SC"�� ������� ������������������");
			    SendClientMessage(playerid, color_white, ""SC"������������� � �������.");
			    login_check[playerid] = true;
			    update_timer[playerid] = SetTimerEx("UpdateTime", 1000, false, "i", playerid);
			    Freeze(playerid, 1);
	
			    player_info[playerid][pLevel] = 1;
			    player_info[playerid][pSkin] = 1 + random(10);
			    SetPlayerSkin(playerid, player_info[playerid][pSkin]);
		        player_info[playerid][pAdmin] = 0;
		        player_info[playerid][pMute] = 0;

			    getdate(year_server, month_server, day_server);
			    format(player_info[playerid][pDate_reg], 10+1, "%02d/%02d/%02d", day_server, month_server, year_server);

			    static fmt_str[] = "INSERT INTO `accounts` (`name`, `password`, `email`, `referal`, `date_reg`, `skin`, `level`, `admin`, `mute`, `prefix`) \
		        VALUES ('%s', '%s', '%s', '%s', '%s', '%d', '%d', '%d', '%d', '%s')";
                new string[sizeof(fmt_str) + MAX_PLAYER_NAME * 2 + 76];
				mysql_format(dbHandle, string, sizeof(string), fmt_str,
				    player_info[playerid][pName],
				    player_info[playerid][pPassword],
				    player_info[playerid][pEmail],
				    player_info[playerid][pReferal],
				    player_info[playerid][pDate_reg],
				    player_info[playerid][pSkin],
				    player_info[playerid][pLevel],
				    player_info[playerid][pAdmin],
				    player_info[playerid][pMute],
                    player_info[playerid][pPrefix]
				);
				ShowLogin(playerid);
				mysql_function_query(dbHandle, string, true, "GetID", "i", playerid);
	        }
	        else ShowPassCheck(playerid);
	    }
	    case d_login:
	    {
	        if(response)
	        {
	        	if(isnull(inputtext))
				{
	                ShowLogin(playerid);
	                return SendClientMessage(playerid, color_gray, "�� ������ �� �����.");
	            }
				static fmt_str[] = "SELECT * FROM `accounts` WHERE `id` = '%d' AND `password` = '%e' LIMIT 1";
				new string[sizeof(fmt_str)+37];
				mysql_format(dbHandle, string, sizeof(string), fmt_str, player_info[playerid][pId], inputtext);
				mysql_function_query(dbHandle, string, true, "PlayerLogin", "d", playerid);
			}
			else
			{
			    SendClientMessage(playerid, color_red, !"������� /q[uit]");
	            Pkick(playerid);
			}
	    }
		case d_skin:
		{
			if(response)
			{
				switch(listitem)
	            {
					case 0: ShowFreeSkin(playerid);
					case 1: ShowPersonSkin(playerid);
				}
			}
		}
	    case d_skin_set:
        {
        	if(response)
	        {
	        	new skinID;
	            switch(listitem)
	            {
	                case 0: skinID = 1; // ea7
	                case 1: skinID = 2; // ������
	                case 2: skinID = 3; // ������
	                case 3: skinID = 4; // ������
	                case 4: skinID = 5; // ����� ����
	                case 5: skinID = 6; // ���� �������
	                case 6: skinID = 7; // ����
	                case 7: skinID = 8; // ������
	                case 8: skinID = 9; // �����
	                case 9: skinID = 10; // ����� ����
                    case 10: skinID = 266; // ���������
                    case 11: skinID = 11; // ������
                    case 12: skinID = 12; // ������
	            }
	            SetSkin(playerid, skinID);
			}
        }
		case d_ahelp:
  		{
		    if(response)
		    {
			    new dialog[512];
		        switch(listitem)
		        {
		            case 0: format(dialog, sizeof(dialog),
					"������� ��� ������ 1 (���������):\n\
					/astats - ����������\n\
					/sp - ������ �� �������\n\
					/spoff - ���� ������\n\
					/slap - ���������� ������\n\
					/kick - ������� ������ � �������\n\
					/unmute - ����� ���������� ���� � ������\n\
					/mute - ������������� ��� ��� ������\n\
					/goto - ����������������� � ������\n\
					/pos - �������� ������� ������\n\
					/a - ��������� ��������� � �����-���\n\
                    /vtp - ����������������� � �/�\n\
                    /flip - ����������� �/�\n\
					/spawn - ��������� ������");
		            case 1: format(dialog, sizeof(dialog),
					"������� ��� ������ 2 (��. �����):\n\
			        /vget - �������� ���������\n\
			        /unban - ����� ��� � ������\n\
			        /ban - �������� ������\n\
                    /banip - �������� ����\n\
                    /getip - �������� ����\n\
			        /gethere - ��������������� ������ � ����");
		            case 2: format(dialog, sizeof(dialog),
			        "������� ��� ������ 3 (�������������):\n\
			        /spermban - �������� ������ ��������\n\
			        /setskin - �������� ���� ������\n\
			        /msg - ��������� ��������� � ��� �� ����� ��������������");
		            case 3: format(dialog, sizeof(dialog),
			        "������� ��� ������ 4 (������� �������������):\n\
			        /cc - �������� ���\n\
			        /givegun - ������ ������ ������");
		            case 4: format(dialog, sizeof(dialog),
				    "������� ��� ������ 5 (������� �������������):\n\
				    /givecash - ������ ������ ������\n\
				    /setadm - �������� ������� ������� ������\n\
				    /settime - ���������� ����� �� �������\n\
			        /setweather - ���������� ������\n\
				    /veh - ������� ������������ ��������\n\
					/delveh - ������� ��� ������������ ��������");
		            case 5: format(dialog, sizeof(dialog), "(��� �������)");
					case 6: format(dialog, sizeof(dialog), "(��� �������)");
		            case 7: format(dialog, sizeof(dialog), "(��� �������)");
		        }
		        ShowPlayerDialog(playerid, d_none, DIALOG_STYLE_MSGBOX, "{3FD7D0}"SHORT_NAME" {FFFFFF}| �������", dialog, "��", "");
		    }
		}
     	case d_tp:
		{
			if(response)
				{
        			new spot_id = listitem;

        			if(spot_id >= 0 && spot_id < sizeof(TeleportList))
        				{
            				SetPlayerPos(
            				playerid,
                			TeleportList[spot_id][tpX],
                			TeleportList[spot_id][tpY],
                			TeleportList[spot_id][tpZ]
       						);

							SendClientMessage(
                			playerid,
                			-1,
                			"�� ��������������� � {3FD7D0}%s", TeleportList[spot_id][tpName]
            				);
        				}
    				}
				}
		}
	return true;
}
public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return true;
}
public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	if(login_check[playerid] == true)
	{
		if(GetPlayerAdminEx(playerid) >= 1)
	    {
			SetPlayerPos(playerid, fX, fY, fZ);
			SetPlayerInterior(playerid, 0);
			SetPlayerVirtualWorld(playerid, 0);
		}
	}
	return 1;
}
public OnPlayerCommandReceived(playerid, cmd[], params[], flags)
{
    if(login_check[playerid] == false)
	{
	    SendClientMessage(playerid, color_gray, !"�� �� ������������.");
	    return false;
	}
	return true;
}
public OnPlayerClickTextDraw(playerid, Text: clickedid)
{
	return 1;
}
// ............. [NEW PUBLICS] .............
public TechRestartTimer(playerid)
{
   RestartServer();
   return 1;
}
public UnmutePlayer(to_player)
{
    if (IsPlayerConnected(to_player))
    {
        UpdatePlayerDatabaseInt(to_player, "Mute", 0);
        player_info[to_player][pMute] = 0;

        SendClientMessage(to_player, color_gray, "������ � ��� ������������.");

        new fmt_msg[80];
        format(fmt_msg, sizeof(fmt_msg), "���� ���������� ���� � %s[acc:%d]", player_info[to_player][pName], player_info[to_player][pId]);
        SendLog(-1, LOG_TYPE_ADMIN_ACTION, fmt_msg);
    }
}
public OnSecondTimer()
{
	new newhour,minute,newsecond;
    gettime(newhour, minute, newsecond);

	new time = gettime();
	if(minute && !newsecond)
	{

			OnMinuteTimer(bool: GetElapsedTime(time, g_last_m_timer_time, CONVERT_TIME_TO_DAYS));
	}

	foreach(new playerid : Player)
	{
		CallLocalFunction("OnPlayerTimer", "i", playerid);
	}
}

public OnMinuteTimer(bool: new_day)
{
	new time;
	new hour, minute, second;

	time = gettime();
	gettime(hour, minute, second);

	if(new_day)
	{
		SetTimer("ClearBanList", 15_000, false);
	}

	if (hour == 5 && minute == 0 && second == 0 && !g_restart_notified)
    {
        SCMTA(color_red, "��������� ������, �������������� ������� ������� �������� ����� 1 ������!");
        g_restart_notified = true; 
    if (hour == 5 && minute == 1 && second == 0 && g_restart_notified)
    {
        RestartServer();
        g_restart_notified = false; 
    }
	
	//SetWorldTime(hour); // realtime
	g_last_m_timer_time = time;
}
}

public OnPlayerTimer(playerid)
{
	if (login_check[playerid] == true)
    {
		if (player_info[playerid][pMute] > 0)
		{
			player_info[playerid][pMute]--;

			UpdatePlayerDatabaseInt(playerid, "Mute", player_info[playerid][pMute]);

			if (player_info[playerid][pMute] <= 0)
			{
				SendClientMessage(playerid, color_gray, "���� �������� ���� ���� ����������");
			}
		}
	}
}
public ClearBanList()
{
    new query[64];
    new time = gettime();

    format(query, sizeof query, "SELECT ip FROM ban_list WHERE ban_time <= %d", time);
    mysql_tquery(dbHandle, query, "UnBanIPs", "i", time);
    return 1;
}
public UnBanIPs(time)
{
    new ip[16];
    new query[64];
    new rows = cache_num_rows();

    if(rows)
    {
        for(new idx = 0; idx < rows; idx++)
        {
            cache_get_row(idx, 0, ip);

            format(query, sizeof query, "unbanip %s", ip);
            SendRconCommand(query);
        }
        SendRconCommand("reloadbans");

        format(query, sizeof query, "DELETE FROM ban_list WHERE ban_time <= %d", time);
        mysql_query(dbHandle, query, false);
    }
    return 1;
}
public PlayerCheck(playerid)
{
	new rows,
		fields;
	cache_get_data(rows, fields);
	if(rows)
	{
	    static fmt_str2[] = "SELECT `description`, `ban_time` FROM `ban_list` WHERE `user_id` = '%d' LIMIT 1";
		new string2[sizeof(fmt_str2)+ MAX_PLAYER_NAME];
		mysql_format(dbHandle, string2, sizeof(string2), fmt_str2, player_info[playerid][pId]);

	    login_timer[playerid] = SetTimerEx("CheckLogin", 1000*60, false, "i", playerid);
	    player_info[playerid][pId] = cache_get_field_content_int(0, "id");
		ShowLogin(playerid);
	}
	else ShowRegister(playerid);
}
public PlayerLogin(playerid)
{
    new rows,
	    fields;
	cache_get_data(rows, fields);
	if(rows)
	{
	    cache_get_field_content(0, "password", player_info[playerid][pPassword], dbHandle, 32+1);
	    cache_get_field_content(0, "email", player_info[playerid][pEmail], dbHandle, 46+1);
	    cache_get_field_content(0, "referal", player_info[playerid][pReferal], dbHandle, MAX_PLAYER_NAME+1);
	    cache_get_field_content(0, "date_reg", player_info[playerid][pDate_reg], dbHandle, 10+1);
	    player_info[playerid][pSkin] = cache_get_field_content_int(0, "skin");
	    player_info[playerid][pMoney] = cache_get_field_content_int(0, "money");
	    player_info[playerid][pLevel] = cache_get_field_content_int(0, "level");
	    player_info[playerid][pAdmin] = cache_get_field_content_int(0, "admin");
	    player_info[playerid][pMute] = cache_get_field_content_int(0, "mute");  
        cache_get_field_content(0, "prefix", player_info[playerid][pPrefix], dbHandle, 15+1);
	    //== == == == == == == == == == == == == == == == == == == == == == ==
	    login_check[playerid] = true;
        	SendClientMessage(playerid, color_gray, "����� ���������� �� ��� ��� ������!");
	SendClientMessage(playerid, color_gray, "���������-����� �������: "c_lightyellow""TELEGRAM"");
	SendClientMessage(playerid, color_gray, "���������� ���: "c_lightyellow"/v");
    SendClientMessage(playerid, -1, ""SC"��� ��������� ������ ������ ����������� {ffff00}/help");

	    SetTimerEx("FastSpawn", 100, false, "i", playerid);
        StopAudioStreamForPlayer(playerid);
	    update_timer[playerid] = SetTimerEx("UpdateTime", 1000, false, "i", playerid);
	    KillTimer(login_timer[playerid]);
    	static fmt_str[] = "SELECT * FROM `accounts` WHERE `name` = '%s' LIMIT 1";
		new string[sizeof(fmt_str) + MAX_PLAYER_NAME - 1];
		mysql_format(dbHandle, string, sizeof(string), fmt_str, player_info[playerid][pName]);
		if(GetPlayerAdminEx(playerid) >= 1)
		{
	    	AdminRangs(playerid);
	    	LoadAdminStats(playerid);
   		}
	}
	else
	{
	    number_pass{playerid} ++;
	    if(number_pass{playerid} == 3)
	    {
	        Pkick(playerid);
	        return SendClientMessage(playerid, color_red, !"������� �� ���� ������ ���������. ������� /q[uit]");
	    }
	    static const fmt_str[] = "�������� ������. �������� �������: %d";
		new string[sizeof(fmt_str)];
		format(string, sizeof(string), fmt_str, 3-number_pass{playerid});
		SendClientMessage(playerid, color_red, string);
	    ShowLogin(playerid);
	}
	return true;
}

public OnAdminStatsLoad(playerid) {
    new rows, fields;
    cache_get_data(rows, fields);

    if (rows) {
        AdminStats[playerid][bans] = cache_get_field_content_int(0, "bans");
        AdminStats[playerid][mutes] = cache_get_field_content_int(0, "mutes");
        AdminStats[playerid][unbans] = cache_get_field_content_int(0, "unbans");
        AdminStats[playerid][kicks] = cache_get_field_content_int(0, "kicks");
        AdminStats[playerid][warns] = cache_get_field_content_int(0, "warns");
    } else {
        new query[128];
        format(query, sizeof(query), "INSERT INTO admin_stats (admin_id) VALUES (%d)", player_info[playerid][pId]);
        mysql_tquery(dbHandle, query);
    }
    return 1;
}
public CheckLogin(playerid)
{
	SendClientMessage(playerid, color_red, !"����� �� ����������� �����. ������� /q[uit]");
	Pkick(playerid);
	return true;
}
public TimeKick(playerid)
{
	Kick(playerid);
	return true;
}
public UpdateTime(playerid)
{
    if(player_info[playerid][pMoney] != GetPlayerMoney(playerid))
	{
	    ResetPlayerMoney(playerid);
	    GivePlayerMoney(playerid, player_info[playerid][pMoney]);
	}
	update_timer[playerid] = SetTimerEx("UpdateTime", 1000, false, "i", playerid);
	return true;
}
public GetID(playerid)
{
	player_info[playerid][pId] = cache_insert_id();
	return true;
}
public FastSpawn(playerid)
{
	SpawnPlayer(playerid);
	return true;
}
// ............. [ STOCKS ] .............
stock ShowLogin(playerid)
{
	new dialog[512];
	format(dialog, sizeof(dialog),
	""c_white"������������ ���, "c_main"%s!"c_white"\n\
	������ ������� "c_green"���������������"c_white" �� ���� �������.\n\n\
	����� ������ ����, ������� ������:"c_gray"\n\
	* � ��� ���� 60 ������ ��� �����������", player_info[playerid][pName]);
	SPD(playerid, d_login, DSP, ""SC"����������� | ������", dialog, "�����", "������");
	return 1;
}
stock ShowRegister(playerid)
{
	new dialog[512];
	format(dialog, sizeof(dialog),
	""c_white"������������ ���, "c_main"%s!"c_white"\n\
	������ ������� "c_red"�� ���������������"c_white" �� ���� �������.\n\n\
	����� ������ ����, ���������� �������� ������:"c_gray"\n\
	* ����������� ����� � ����� ���������� ��������\n\
	* ����� ������ ������ ���� �� 8 �� 20 ��������\n\
	* � ��� ���� 60 ������ ��� �����������", player_info[playerid][pName]);
	SPD(playerid, d_register, DSP, ""SC"����������� | ������", dialog, "�����", "������");
	return 1;
}
stock ShowPassCheck(playerid)
{
	SPD(playerid, d_pass_check, DSP, ""SC"����������� | �������������",
    ""c_white"����������, ����������� ���� "c_main"������"c_white"\n\
    ����� ���������� "c_main"�����������.", "�����", "������");
}
stock ShowEmail(playerid)
{
	SPD(playerid, d_mail, DSI, ""SC"����������� | ����������� �����",
    ""c_white"����������, ������� ����������� ����� "c_main"����������� �����"c_white"\n\
    ���� ��� ������� ����� "c_red"�������"c_white" ��� "c_red"������,\n\
    "c_white"�� �������� �� ���� ������ ��� ��������������.", "�����", "������");
}
stock CheckRusText(string[], size = sizeof(string))
{
    for(new i; i < size; i++)
	switch(string[i])
	{
	    case '�'..'�', '�'..'�', ' ': return true;
	}
	return false;
}
stock Clear(playerid)
{
	number_skin{playerid} = 0;
	number_pass{playerid} = 0;
	login_check[playerid] = false;
}
stock KillTimers(playerid)
{
    KillTimer(update_timer[playerid]);
   	KillTimer(login_timer[playerid]);
}
stock SetPlayerSpawn(playerid)
{
    new Float:spawnCoords[][4] = {
        {-1969.195556, 137.844375, 27.687500, 88.571487}, // spawn sf 1
        {-1974.152099, 143.565399, 27.694049, 179.510604}, // spawn sf 2
        {-1975.025878, 130.372863, 27.694049, 2.190709}, // spawn sf 3
        {1676.714599, 1447.913940, 10.783667, 269.246429}, // spawn ls 1
        {1686.890869, 1437.860351, 10.768882, 300.520965}, // spawn ls 2
        {1687.456909, 1455.129394, 10.768468, 238.038711}, // spawn ls 3
        {1154.199951, -1768.574584, 16.593750, 0.673766}, // spawn los 1
        {1157.242797, -1769.033813, 16.593750, 358.978546}, // spawn los 2
        {1151.125976, -1769.191894, 16.593750, 1.836003} // spawn los 3
    };
    new randomIndex = random(sizeof(spawnCoords));

    SetPlayerPos(playerid, spawnCoords[randomIndex][0], spawnCoords[randomIndex][1], spawnCoords[randomIndex][2]);
    SetPlayerFacingAngle(playerid, spawnCoords[randomIndex][3]);

    SetPlayerScore(playerid, player_info[playerid][pLevel]);
    SetPlayerSkin(playerid, player_info[playerid][pSkin]);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerInterior(playerid, 0);
    SetCameraBehindPlayer(playerid);
    
    // maybe for DM-Zone
    
    SetPlayerSkillLevel(playerid, 0, 999);
	SetPlayerSkillLevel(playerid, 1, 999);
	SetPlayerSkillLevel(playerid, 2, 999);
	SetPlayerSkillLevel(playerid, 3, 999);
	SetPlayerSkillLevel(playerid, 4, 999);
	SetPlayerSkillLevel(playerid, 5, 999);
	SetPlayerSkillLevel(playerid, 6, 999);
	SetPlayerSkillLevel(playerid, 7, 999);
	SetPlayerSkillLevel(playerid, 8, 999);
	SetPlayerSkillLevel(playerid, 9, 999);
	SetPlayerSkillLevel(playerid, 10, 999);

	StopAudioStreamForPlayer(playerid);

	return true;
}
stock SavePlayer(playerid, const field_name[], const set[], const type[])
{
	new string[128+1];
	if(!strcmp(type, "d", true))
	{
	    mysql_format(dbHandle, string, sizeof(string), "UPDATE `accounts` SET `%s` = '%d' WHERE `id` = '%d' LIMIT 1",
		field_name, set, player_info[playerid][pId]);
	}
    else if(!strcmp(type, "s", true))
    {
	    mysql_format(dbHandle, string, sizeof(string), "UPDATE `accounts` SET `%s` = '%s' WHERE `id` = '%d' LIMIT 1",
		field_name, set, player_info[playerid][pId]);
	}
    mysql_function_query(dbHandle, string, false, "", "");
}

stock AdminRangs(playerid)
{
	switch(player_info[playerid][pAdmin])
	{
		case 1: admin_rang[playerid] = "���������";
		case 2: admin_rang[playerid] = "��.�����";
		case 3: admin_rang[playerid] = "�����";
		case 4: admin_rang[playerid] = "��.�����";
		case 5: admin_rang[playerid] = "��";
		case 6: admin_rang[playerid] = "����.�����";
		case 7: admin_rang[playerid] = "�������";
		case 8: admin_rang[playerid] = "����������";
	}
	return 1;
}

stock AdmMSG(color, text[], a_level = 1)
{
	if(a_level < 1)
		a_level = 1;

	new count;
	foreach(new playerid : Player)
	{
		if (GetPlayerAdminEx(playerid) < a_level) continue;

		SendClientMessage(playerid, color, text);
		count ++;
	}
	return count;
}

stock GivePlayerCash(playerid, cash)
{
	player_info[playerid][pMoney] += cash;
	static const fmt_query[] = "UPDATE `accounts` SET `Money` = '%i' WHERE `id` = '%i'";
	new query[sizeof(fmt_query)+(-2+11)+(-2+11)];
	format(query, sizeof(query), fmt_query, player_info[playerid][pMoney], player_info[playerid][pId]);
	mysql_tquery(dbHandle, query);
	return 1;
}

stock GetPlayerIDByName(const player_name[])
{
    for (new playerid = 0; playerid < MAX_PLAYERS; playerid++)
    {
        if (IsPlayerConnected(playerid) && strcmp(player_info[playerid][pName], player_name, true) == 0)
        {
            return playerid;
        }
    }
    return -1;
}

stock AddBan(user_id, time, days, description[], admin_name[])
{
    new query[200];
    new c_time = time - (time % 86400);

    new ban_expiration_time;
    if (days == 0)
    {
        ban_expiration_time = 0; // eternal ban
    }
    else
    {
        ban_expiration_time = c_time + (days * 86400);
    }

    mysql_format(dbHandle, query, sizeof query, "INSERT INTO ban_list (user_id,time,ban_time,description,admin) VALUES (%d,%d,%d,'%e','%e')", user_id, c_time, ban_expiration_time, description, admin_name);
    mysql_query(dbHandle, query, false);

    return !mysql_errno();
}

stock SendLog(playerid = INVALID_PLAYER_ID, type, desc[])
{
	new fmt_log[700];

	mysql_format(dbHandle, fmt_log, sizeof fmt_log, "INSERT INTO action_log (acc_id, type, description, time) VALUES (%d, %d, '%s', %d)",
	player_info[playerid][pId], type, desc, gettime());

	mysql_query(dbHandle, fmt_log, false);

	return 1;
}

stock UpdatePlayerDatabaseInt(playerid, field[], value)
{
	if(!IsPlayerConnected(playerid)) return 1;

	new query[256];

	mysql_format(dbHandle, query, sizeof query, "UPDATE accounts SET `%s`=%d WHERE `id`=%d LIMIT 1", field, value, player_info[playerid][pId]);
	mysql_query(dbHandle, query, false);
	return 1;
}

stock UpdatePlayerDatabaseIntByName(const name[], field[], value)
{
    new query[256];

    mysql_format(dbHandle, query, sizeof query, "UPDATE accounts SET `%s`=%d WHERE `name`='%s' LIMIT 1", field, value, name);

    if (mysql_query(dbHandle, query, false)) {
        return 0;
    }

    return 1;
}

stock UpdatePlayerDatabaseStr(playerid, field[], value[])
{
	if(!IsPlayerConnected(playerid)) return 1;

	new query[256];

	mysql_format(dbHandle, query, sizeof query, "UPDATE accounts SET `%s`=%s WHERE `id`=%d LIMIT 1", field, value, player_info[playerid][pId]);
	mysql_query(dbHandle, query, false);
	return 1;
}

stock UpdatePlayerDatabaseStrByName(const name[], field[], value[])
{
    new query[256];

    mysql_format(dbHandle, query, sizeof query, "UPDATE accounts SET `%s`=%s WHERE `name`='%s' LIMIT 1", field, value, name);

    if (mysql_query(dbHandle, query, false)) {
        return 0;
    }

    return 1;
}

stock GetElapsedTime(time, to_time, type = CONVERT_TIME_TO_HOURS)
{
	new result;

	switch(type)
	{
		case CONVERT_TIME_TO_MINUTES:
		{
			result = ((time - (time % 60)) - (to_time - (to_time % 60))) / 60;
		}
		case CONVERT_TIME_TO_HOURS:
		{
			result = ((time - (time % 3600)) - (to_time - (to_time % 3600))) / 3600;
		}
		case CONVERT_TIME_TO_DAYS:
		{
			result = ((time - (time % 86400)) - (to_time - (to_time % 86400))) / 86400;
		}
		default:
			result = -1;
	}
	return result;
}

stock timestamp_to_date
(
	unix_timestamp = 0,

	& year = 1970,		& month  = 1,		& day    = 1,
	& hour =    0,		& minute = 0,		& second = 0
)
{
	year = unix_timestamp / 31557600;
	unix_timestamp -= year * 31557600;
	year += 1970;

	if ( year % 4 == 0 ) unix_timestamp -= 21600;

	day = unix_timestamp / 86400;

	switch ( day )
	{
		// � second ����� �������� �������� ����� ������
		case    0..30 : { second = day;       month =  1; }
		case   31..58 : { second = day -  31; month =  2; }
		case   59..89 : { second = day -  59; month =  3; }
		case  90..119 : { second = day -  90; month =  4; }
		case 120..150 : { second = day - 120; month =  5; }
		case 151..180 : { second = day - 151; month =  6; }
		case 181..211 : { second = day - 181; month =  7; }
		case 212..242 : { second = day - 212; month =  8; }
		case 243..272 : { second = day - 243; month =  9; }
		case 273..303 : { second = day - 273; month = 10; }
		case 304..333 : { second = day - 304; month = 11; }
		case 334..366 : { second = day - 334; month = 12; }
	}

	unix_timestamp -= day * 86400;
	hour = unix_timestamp / 3600;

	unix_timestamp -= hour * 3600;
	minute = unix_timestamp / 60;

	unix_timestamp -= minute * 60;
	day = second + 1;
	second = unix_timestamp;
}

stock UnbanPlayer(user_id)
{
    new query[256], uip[16];

    format(query, sizeof query, "DELETE FROM ban_list WHERE user_id=%d", user_id);
    mysql_query(dbHandle, query, false);

    format(query, sizeof query, "SELECT ip FROM accounts WHERE id=%d", user_id);
    new Cache: result = mysql_query(dbHandle, query, true);
    cache_get_row(0, 0, uip);
    cache_delete(result);

    format(query, sizeof query, "unbanip %s", uip);
    SendRconCommand(query);

    SendRconCommand("reloadbans");

    new str[128];
    format(str, sizeof(str), "����� � user_id %d ��� ������������� �������������", user_id);
    SendLog(-1, LOG_TYPE_SUPERADMIN_ACTION, str);
}
stock SetSkin(playerid, skinID)
{
    SetPlayerSkin(playerid, skinID);
    player_info[playerid][pSkin] = skinID;
    UpdatePlayerDatabaseInt(playerid, "Skin", skinID);
}
stock IsValidVehicle(vehicleid)
{
    return vehicleid >= 0 && vehicleid < MAX_VEHICLES;
}

stock ShowHelp(playerid)
{
    SPD(playerid, d_none, DSM, !"{3FD7D0}"SHORT_NAME" {FFFFFF}| ������",
    "{FFFFFF}/car - ����� ����������\n\
    {FFFFFF}/skin - ����� �����\n\
    {FFFFFF}/tune - ��������� �������\n\
    {FFFFFF}/v - ������ ���\n\
    {FFFFFF}/tp - ��������-����\n\
    {FFFFFF}/chat - ������ ���\n\
    {FFFFFF}/help - �������� �������\n\
    {FFFFFF}/time - �����\n\
    {FFFFFF}/csettime - ���������� ����� ���\n\
    {FFFFFF}/online - ������ ������ �� �������\n\
    {FFFFFF}/cameditgui - ������ ���������",
    !"OK", !"");
}

stock GetCurrentTime(&year, &month, &day, &hour, &minute, &second)
{
    new currentTime = gettime();

    new timestamp = currentTime + 10800;

    year = timestamp / 31557600 + 1970;
    month = (timestamp / 2629743) % 12 + 1;
    day = (timestamp / 86400) % 30 + 1;
    hour = (timestamp / 3600) % 24; 
    minute = (timestamp / 60) % 60;
    second = timestamp % 60;

    return 1;
}
stock ProxDetector(Float:radi, playerid, string[], col1, col2, col3, col4, col5)
{
	new
		Float: X,
		Float: Y,
		Float: Z,
		Float: X_2,
		Float: Y_2,
		Float: Z_2,
		Float: X_3,
		Float: Y_3,
		Float: Z_3;

	GetPlayerPos(playerid, X_2, Y_2, Z_2);
	foreach(new i : Player)
	{
		if(GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i))
		{
			GetPlayerPos(i, X, Y, Z);
			X_3 = (X_2 - X);
			Y_3 = (Y_2 - Y);
			Z_3 = (Z_2 - Z);
			if(((X_3 < radi/16) && (X_3 > -radi/16)) && ((Y_3 < radi/16) && (Y_3 > -radi/16)) && ((Z_3 < radi/16) && (Z_3 > -radi/16))) SendClientMessage(i, col1, string);
			else if(((X_3 < radi/8) && (X_3 > -radi/8)) && ((Y_3 < radi/8) && (Y_3 > -radi/8)) && ((Z_3 < radi/8) && (Z_3 > -radi/8))) SendClientMessage(i, col2, string);
			else if(((X_3 < radi/4) && (X_3 > -radi/4)) && ((Y_3 < radi/4) && (Y_3 > -radi/4)) && ((Z_3 < radi/4) && (Z_3 > -radi/4))) SendClientMessage(i, col3, string);
			else if(((X_3 < radi/2) && (X_3 > -radi/2)) && ((Y_3 < radi/2) && (Y_3 > -radi/2)) && ((Z_3 < radi/2) && (Z_3 > -radi/2))) SendClientMessage(i, col4, string);
			else if(((X_3 < radi) && (X_3 > -radi)) && ((Y_3 < radi) && (Y_3 > -radi)) && ((Z_3 < radi) && (Z_3 > -radi))) SendClientMessage(i, col5, string);
		}
	}
	return 1;
}
stock ToLowerString(string[]) {
    for (new i = 0; i < strlen(string); i++) {
        if (string[i] >= 'A' && string[i] <= 'Z') {
            string[i] += ('a' - 'A');
        }
    }
    return string;
}
stock StartSpectate(playerid, for_player)
{
    if(GetPlayerAdminEx(playerid) < 1) return 1;

    SetPlayerSpectateData(playerid, S_PLAYER, for_player);

    SetPlayerInterior(playerid, GetPlayerInterior(for_player));
    SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(for_player));

    TogglePlayerSpectating(playerid, true);

    new Float:health;
    GetPlayerHealth(for_player, health);
        
    if (IsPlayerInAnyVehicle(for_player))
    {
        PlayerSpectateVehicle(playerid, GetPlayerVehicleID(for_player));
    }
    else
    {
        PlayerSpectatePlayer(playerid, for_player);
    }

    return 1;
}

stock StopSpectate(playerid)
{
    if(GetPlayerAdminEx(playerid) < 1) return 1;
    if (GetPlayerSpectateData(playerid, S_PLAYER) == -1) return 1;

    TogglePlayerSpectating(playerid, false);

    SetPlayerSpectateData(playerid, S_PLAYER, -1);

    SetPlayerPos
    (
        playerid,
        GetPlayerSpectateData(playerid, S_START_POS_X),
        GetPlayerSpectateData(playerid, S_START_POS_Y),
        GetPlayerSpectateData(playerid, S_START_POS_Z)
    );

    SetPlayerFacingAngle(playerid, GetPlayerSpectateData(playerid, S_START_ANGLE));
    SetPlayerInterior(playerid, GetPlayerSpectateData(playerid, S_START_INTERIOR));
    SetPlayerVirtualWorld(playerid, GetPlayerSpectateData(playerid, S_START_VIRTUAL_WORLD));

    return 1;
}
stock UpdateSpectate(playerid, disconnect)
{
	for(new i; i < MAX_PLAYERS; i ++)
	{
		if(!IsPlayerConnected(i)) continue;
		else if(!IsPlayerLogged(i)) continue;
		else if(GetPlayerAdminEx(i) < 1) continue;
		else if(GetPlayerSpectateData(i, S_PLAYER) != playerid) continue;

		if(disconnect)
		{
			StopSpectate(i);
			GameTextForPlayer(i, "~r~~h~player disconnect", 4000, 4);
		}
		else if(IsPlayerInAnyVehicle(playerid))
		{
			PlayerSpectateVehicle(i, GetPlayerVehicleID(playerid));
		}
		else
		{
			PlayerSpectatePlayer(i, playerid);
		}
	}
	return 1;
}
stock LoadAdminStats(playerid) {
    new query[128];
    format(query, sizeof(query), "SELECT bans, mutes, unbans, kicks, warns FROM admin_stats WHERE admin_id = %d", player_info[playerid][pId]);

    mysql_tquery(dbHandle, query, "OnAdminStatsLoad", "i", playerid);
}
stock UpdateAdminStat(playerid, action[]) {
    if (strcmp(action, "ban", true) == 0) {
        AdminStats[playerid][bans]++;
    } else if (strcmp(action, "mute", true) == 0) {
        AdminStats[playerid][mutes]++;
    } else if (strcmp(action, "unban", true) == 0) {
        AdminStats[playerid][unbans]++;
    } else if (strcmp(action, "kick", true) == 0) {
        AdminStats[playerid][kicks]++;
    } else if (strcmp(action, "warn", true) == 0) {
        AdminStats[playerid][warns]++;
    }

    new query[256];
    format(query, sizeof(query),
        "UPDATE admin_stats SET bans = %d, mutes = %d, unbans = %d, kicks = %d, warns = %d WHERE admin_id = %d",
        AdminStats[playerid][bans],
        AdminStats[playerid][mutes],
        AdminStats[playerid][unbans],
        AdminStats[playerid][kicks],
        AdminStats[playerid][warns],
        player_info[playerid][pId]
    );
    mysql_tquery(dbHandle, query);
}
stock GetPlayerByName(const name[])
{
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (IsPlayerConnected(i) && strcmp(player_info[i][pName], name, true) == 0)
        {
            return i; // ������
        }
    }
    return -1; // ����� �� ������
}
stock SetConnectServer(playerid)
{
	static const fmt_str[] = "SELECT * FROM whitelist WHERE name = '%s'";
	new string[sizeof(fmt_str) + MAX_PLAYER_NAME],d_nick[MAX_PLAYER_NAME];

	GetPlayerName(playerid, d_nick, MAX_PLAYER_NAME);

	mysql_format(dbHandle, string, sizeof(string), "SELECT * FROM whitelist WHERE name = '%e'", d_nick);
	new Cache:result = mysql_query(dbHandle, string);

	if(cache_num_rows())
	{
		//SCM(playerid, color_red, !"Connect");
	}
	else
	{
		SendClientMessage(playerid, color_red, !"������ �������� �� ����������� ������.");
		Pkick(playerid);
	}
	cache_delete(result);
	return 1;
}
stock ShowFreeSkin(playerid)
{
	SPD(playerid, d_skin_set, DSL,
                        !"{3FD7D0}"SHORT_NAME" {FFFFFF}| ����������",
                        !"1. EA7\n\
                        2. ������\n\
                        3. ������\n\
                        4. ������\n\
                        5. �����\n\
                        6. Palm Angeles\n\
                        7. Dior\n\
                        8. ������\n\
                        9. �����\n\
                        10. �����\n\
                        11. ��������� ���\n\
                        12. ������\n\
                        13. ������", 
                        !"�������", !"������");
}
stock ShowPersonSkin(playerid)
{
	SendClientMessage(playerid, color_white, ""USC"� ����������");

	// rqce finish it
	/*if(������ � ����)
	{
		SPD(playerid, d_person_skin, DSL,
							!"{3FD7D0}"SHORT_NAME" {FFFFFF}| �������",
							!"1. ����\n\
							2. ����", 
							!"�������", !"������");
	}*/
}
stock RestartServer()
{
    SendRconCommand("gmx"); // restart
}
stock SendErr(playerid,string[])
{
 	format(String256f,sizeof(String256f),"� {AC0000}[������] "cWH"%s",string);
	SendClientMessage(playerid,0xFFFFFFFF, String256f);
	return 1;
}
stock time_to_words(number)
{
	new 
		hours = 0, mins = 0, secs = 0, string[30];

	hours = floatround(number / 3600);
	mins = floatround((number / 60) - (hours * 60));
	secs = floatround(number - ((hours * 3600) + (mins * 60)));

	if(hours) format(string, 30, "%d � %02d ��� %02d ���", hours, mins, secs);
		else format(string, 30, "%d ��� %02d ���", mins, secs);

	return string;
}
stock GetOnline() // ��� ����� ������� ��������� ���� ��� �������� � ����������
{
    new count=0;
    for(new i=0; i<MAX_PLAYERS; i++)
    {
        if (IsPlayerConnected(i))
        {
            count++;
        }
    }
    return count;
}
// ............. [ OTHER ] .............
stock ConnectMySQL()
{
	dbHandle =mysql_connect(MySQL_Host, MySQL_User, MySQL_Base, MySQL_Pass);
	switch(mysql_errno())
	{
	    case 0: print("MySQL - connected");
	    default: print("MySQL - disconnect");
	}
	mysql_set_charset("cp1251");
}
main() { }
// ............. [ COMMANDS ] .............

stock AdmPreff(level, prefix[], size)
{
    switch (level)
    {
        case 0: format(prefix, size, "[A]");
        case 1: format(prefix, size, "���������");
        case 2: format(prefix, size, "��.�����");
        case 3: format(prefix, size, "�����");
        case 4: format(prefix, size, "��.�����");
        case 5: format(prefix, size, "��");
    }
}

CMD:s(playerid, params[])
{
    new str[128];
	if(sscanf(params, "s[128]", params[0])) return SendClientMessage(playerid, color_white, ""USC"�������: "c_lightyellow"/s [�����]");
	format(str, sizeof (str), ""c_white"%s[%i] ������: %s", player_info[playerid][pName], playerid, params[0]);
	SetPlayerChatBubble(playerid, params[0], color_white, 40.0, 5*1000);
	ProxDetector(40.0, playerid, str, color_white, color_white, color_white, color_gray, color_gray);
	if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) ApplyAnimation(playerid, "ON_LOOKERS", "shout_01",1000.0,0,0,0,0,0,1);
	return 1;
}

CMD:b(playerid, params[])
{
	new str[128];
	if(sscanf(params, "s[128]", params[0])) return SendClientMessage(playerid, color_white, ""USC"�������: "c_lightyellow"/b [�����]");
	format(str, sizeof (str), ""c_white"%s[%i]: (( %s ))", player_info[playerid][pName], playerid, params[0]);
	SetPlayerChatBubble(playerid, params[0], color_gray, 15.0, 5*1000);
	ProxDetector(40.0, playerid, str, color_white, color_white, color_white, color_gray, color_gray);
	return 1;
}

CMD:me(playerid, params[])
{
    new str[128];
	if(sscanf(params, "s[128]", params[0])) return SendClientMessage(playerid, color_white, ""USC"�������: "c_lightyellow"/me [��������]");
	format(str, sizeof (str), "%s %s", player_info[playerid][pName], params[0]);
	SetPlayerChatBubble(playerid, params[0], color_purple, 20.0, 5*1000);
	ProxDetector(40.0, playerid, str, color_white, color_white, color_white, color_gray, color_gray);
	return 1;
}

CMD:do(playerid, params[])
{
    new str[128];
	if(sscanf(params, "s[128]", params[0])) return SendClientMessage(playerid, color_white, ""USC"�������: "c_lightyellow"/do [��������]");
	format(str, sizeof (str), "%s (%s)", params[0], player_info[playerid][pName]);
	SetPlayerChatBubble(playerid, params[0], color_purple, 20.0, 5*1000);
	ProxDetector(40.0, playerid, str, color_white, color_white, color_white, color_gray, color_gray);
	return 1;
}

CMD:try(playerid, params[])
{
    new str[128];
	new rand = random(2);
	if(sscanf(params, "s[128]", params[0])) return SendClientMessage(playerid, color_white, ""USC"�������: "c_lightyellow"/try [��������]");
	if(rand == 1) format(str, sizeof (str), "%s %s {5CDF34} [������]", player_info[playerid][pName], params[0]);
	else format(str, sizeof (str), "%s %s "c_red" [��������]", player_info[playerid][pName], params[0]);
	SetPlayerChatBubble(playerid, params[0], color_purple, 20.0, 5*1000);
	ProxDetector(40.0, playerid, str, color_white, color_white, color_white, color_gray, color_gray);
	return 1;
}

CMD:skin(playerid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
	{
	    SPD(playerid, d_skin, DSL, !"{3FD7D0}"SHORT_NAME" {FFFFFF}| �����",
		!"1. ���������� �����\n\
		2. ������� �����", !"�����", !"������");
	}
	else return SendClientMessage(playerid, color_gray, ""USC"�� ������ ���� �� �����.");
	return 1;
}

CMD:help(playerid)
{
    ShowHelp(playerid);
	return 1;
}       

CMD:time(playerid, params[])
{
    new year, month, day, hour, minute, second;
    GetCurrentTime(year, month, day, hour, minute, second);

    if (hour >= 24)
    {
        hour -= 24;
        day += 1;
    }

    new time_msg[64];
    format(time_msg, sizeof(time_msg), "%02d:%02d:%02d", hour, minute, second);
    GameTextForPlayer(playerid, time_msg, 3000, 1);

    if (player_info[playerid][pMute] >= 1)
    {
        new remaining_time = player_info[playerid][pMute];
        if (remaining_time > 0)
        {
            new remaining_time_msg[64];
            format(remaining_time_msg, sizeof(remaining_time_msg), "�� ����� ����: %d ������", remaining_time);
            SendClientMessage(playerid, color_gray, remaining_time_msg);
        }
        else
        {
            SendClientMessage(playerid, color_gray, "�� ���������.");
        }
    }

    return 1;
}

CMD:v(playerid, params[])
{
	if(player_info[playerid][pMute] >= 1) return SendClientMessage(playerid, color_gray, "� ��� �������� ���.");
	
    new msg[144];
    if (sscanf(params, "s[144]", msg)) return SendClientMessage(playerid, color_white, ""USC"�������: "c_lightyellow"/v [�����]");

    new finalMsg[200];
    if(GetPlayerAdminEx(playerid) >= 1)
    {
    	format(finalMsg, sizeof(finalMsg), "[Community]"c_yellow" [�����]"c_blue" %s[%i]: %s", player_info[playerid][pName], playerid, msg);
    }
    else
    {
    	format(finalMsg, sizeof(finalMsg), "[Community] %s[%i]: %s", player_info[playerid][pName], playerid, msg);
    }

    SendClientMessageToAll(color_blue, finalMsg);

    return 1;
}

CMD:online(playerid, params[])
{
    new onlinep = GetOnline();

    new msg[64];
    format(msg, sizeof(msg), ""SC"������ �� ������� {ffff00}%d �������", onlinep);
    SendClientMessage(playerid, -1, msg); 

    return 1;
}

CMD:mm(playerid)
{
	SendClientMessage(playerid, color_white, "button 1");
}

CMD:tp(playerid)
{
    new dialog[512], string[64];
    strcat(dialog, "�\t�����\n", sizeof(dialog));

    for(new i = 0; i < sizeof(TeleportList); i++)
    {
        format(string, sizeof(string), "%d\t%s\n", i+1, TeleportList[i][tpName]);
        strcat(dialog, string, sizeof(dialog));
    }

    ShowPlayerDialog(
        playerid,
        d_tp,
        DIALOG_STYLE_TABLIST_HEADERS,
        "{3FD7D0}�������� {FFFFFF}| �������� ����",
        dialog,
        "��������",
        "������"
    );
    return 1;
}

CMD:admins(playerid, params[])
{
    new dialog[512], count;
    new string[256];
    format(dialog, sizeof(dialog), "{FFFFFF}ID - ��� - ����\n");
    for (new i; i < MAX_PLAYERS; i++)
    {
        new admin_lvl = player_info[i][pAdmin];

        if (!IsPlayerConnected(i)) continue;
        else if (!(1 <= admin_lvl && admin_lvl <= 8)) continue;
        AdminRangs(i);
        format(string, sizeof(string), "{FFFFFF}%d - %s - %s\n", i, player_info[i][pName], player_info[i][pPrefix]);
        strcat(dialog, string, sizeof(dialog)); 
        count++;
    }
    if (!count) SendClientMessage(playerid, color_gray, "��� ������������� � ����");

    SPD(playerid, d_none, DSL, "{FFFFFF}������ �������������", dialog, "�������", "");
    SendLog(playerid, LOG_TYPE_ADMIN_ACTION, "������� ������ �������������");

    return 1;
}

CMD:csettime(playerid, params[])
{
	
	extract params -> new time; else return SendClientMessage(playerid, 0xCECECEFF, ""USC"�������: "c_lightyellow"/csettime [����� 0-23]");

	if(!(0 <= time <= 23)) return SendClientMessage(playerid, 0x999999FF, ""USC"����� �� 0 �� 23 �����!");

	SetPlayerTime(playerid, time);

	new fmt_text[265];
	
	format(fmt_text, sizeof fmt_text, "�� ���������� ����� %02d:00 � ����", time);
    SendClientMessage(playerid, color_blue, fmt_text);
    
	return 1;
}

stock IsPlayerDriver(playerid)
{
	return (IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER);
}

CMD:eject(playerid, params[])
{
	new vehicleid = GetPlayerVehicleID(playerid);

	if(!vehicleid || !IsPlayerDriver(playerid))
		return SendClientMessage(playerid, 0x999999FF, "�� ������ ������ �� ����� ����������");

	if(!strlen(params))
		return SendClientMessage(playerid, 0x999999FF, "�����������: /eject [id ������]");

	extract params -> new to_player;

	if(vehicleid != GetPlayerVehicleID(to_player) || playerid == to_player)
		return SendClientMessage(playerid, 0x999999FF, "����� ������ ������ � ����� ����������");

	RemovePlayerFromVehicle(to_player);

	new fmt_str[64];
	format(fmt_str, sizeof fmt_str, "%s ������� ��� �� ������ ����������", GetPlayerName(playerid));
	SendClientMessage(to_player, 0x3399FFFF, fmt_str);

	format(fmt_str, sizeof fmt_str, "�� �������� %s �� ������ ����������", GetPlayerName(to_player));
	SendClientMessage(playerid, 0x3399FFFF, fmt_str);

	return 1;
}

#include "API/core.inc"

CMD:dl(playerid)
{
    if(GetPlayerAdminEx(playerid) <= 0) return 0;

	new info[34],
	Float:x,
	Float:y,
	Float:z,
	count = GetVehiclePoolSize() + 1;

	if(!(Debug[playerid]))
	{
		Debug[playerid] = true;

		for(new i = 1; i < count; i++)
		{
			GetVehiclePos(i, x, y, z);
			format(info, sizeof info, "VEH ID:%d \n MODEL ID:%d", i, GetVehicleModel(i));
			Veh_3DTEXT[playerid][i] =  CreateDynamic3DTextLabel(info, 0xFFFFFFFF, x, y, z + 1.0, 20.0, _, i, 0, -1, -1, playerid);
		}
	}
	else
	{
		Debug[playerid] = false;
		for(new i = 1; i < count; i++)
		{
			DestroyDynamic3DTextLabel(Veh_3DTEXT[playerid][i]);
			Veh_3DTEXT[playerid][i] = Text3D:0;
		}

	}
	return 1;
}

CMD:tuning(playerid, params[])
{
    if(!IsPlayerInAnyVehicle(playerid))
        return SendClientMessage(playerid, 0xFF0000AA, "�� ������ ���������� � ������������ ��������!");

    new componentid;
    if(sscanf(params, "i", componentid))
        return SendClientMessage(playerid, 0xFF0000AA, "�������������: /tuning [ID ����������] (�� 1000 �� 1164)");

    new vehicleid = GetPlayerVehicleID(playerid);

    AddVehicleComponent(vehicleid, componentid);

    new message[128];
    format(message, sizeof(message), "�� ���������� ��������� %d �� ��� ����������!", componentid);
    SendClientMessage(playerid, 0x00FF00AA, message);

    return 1;
}

CMD:changecolor(playerid, params[])
{
    if(!IsPlayerInAnyVehicle(playerid))
  return SendClientMessage(playerid, -1, ""USC"�� ������ ���� �� �����!");

  extract params -> new color; else return SendClientMessage(playerid, 0xCECECEFF, "{ffff00}|{ffffff} �����������: /changecolor [id �����]");

    if(!(0 <= color <= 126)) return SendClientMessage(playerid, 0xCECECEFF, "{ffff00}|{ffffff}����������� id ����� �� 0 �� 126");

    new vehicleid = GetPlayerVehicleID(playerid);

    ChangeVehicleColor(vehicleid, color);

   SendClientMessage(playerid, color_white, "���� ������ ���������� ������� �������!");

    return 1;
}
