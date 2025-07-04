#include <YSI_Coding\y_hooks>

// ............. [ DEFINES ] .............
#define SPD ShowPlayerDialog
#define SCM SendClientMessage
#define DSL DIALOG_STYLE_LIST
#define SC "{ffff00}| {ffffff}"
#define USC "{ff2400}| {ffffff}"
// ............. [ COLORS ] .............
#define color_white 0xFFFFFF
#define         color_gray              0x999999
// ............. [ NEWS ] .............
// ............. [ DIALOGS ] .............
DIALOG_TUNE(playerid)
{
    Dialog_Open
    (
        playerid, Dialog:TUNE, DSL, 
        "{3FD7D0}LIT MOBILE {FFFFFF}| ������",
        "{FFFFFF}| ������� ����\n\
		����������",
        "�����", "������"
    );
    return 1;
}

DIALOG_COLOR(playerid)
{
    Dialog_Open
    (
        playerid, Dialog:COLOR, DSL, 
        "LIT MOBILE | �������� ����", 
        "�����\n\
        ������\n\
        �������\n\
        ������\n\
        �����",
        "�������", "�������"
    );
    return 1;
}

DIALOG_COMP(playerid)
{
    Dialog_Open
    (
        playerid, Dialog:COMP, DSL, 
        "LIT MOBILE | �������� ���������",
        "����������\n\
        �����",
        "�������", "�������"
    );
    return 1;
}
// ............. [ COMMANDS ] .............
CMD:tune(playerid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
	    DIALOG_TUNE(playerid);
	}
	else return SCM(playerid, color_gray, ""USC"�� ������ ���� �� �����.");
	return 1;
}

// ............. [ RESPONSES ] .............
Dialog_Response:TUNE(playerid, response, listitem)
{
    if (!response) {
        return 1;
    }

    switch (listitem) {
        case 0: DIALOG_COLOR(playerid);
        case 1: DIALOG_COMP(playerid);
    }
    return 1;
}

Dialog_Response:COLOR(playerid, response, listitem)
{
    if (!response) {
        return 1;
    }

    new vehicleid = GetPlayerVehicleID(playerid);
    switch (listitem) {
        case 0: ChangeVehicleColor(vehicleid, 1, 0); // �����
        case 1: ChangeVehicleColor(vehicleid, 0, 0); // ������
        case 2: ChangeVehicleColor(vehicleid, 3, 0); // �������
        case 3: ChangeVehicleColor(vehicleid, 6, 0); // ������
        case 4: ChangeVehicleColor(vehicleid, 2, 0); // �����
    }
    return 1;
}

Dialog_Response:COMP(playerid, response, listitem)
{
    if (!response) {
        return 1;
    }

    new vehicleid = GetPlayerVehicleID(playerid);
    switch (listitem) {
        case 0: AddVehicleComponent(vehicleid, 1087); // ����������
        case 1: AddVehicleComponent(vehicleid, 1010); // �����
    }
    return 1;
}

// ............. [ STOCKS ] .............
// ............. [ HOOKS ] .............