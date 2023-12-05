#include <sourcemod>
#include <cstrike>
//#include <vip_core>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "0.1"


#define CT 3
#define TT 2
#define SPEC 1

static char CTDefault[][] = {
    "models/player/ct_gign.mdl", 
    "models/player/ct_gsg9.mdl", 
    "models/player/ct_sas.mdl", 
    "models/player/ct_urban.mdl", 
};

static char TDefault[][] = {
    "models/player/t_arctic.mdl", 
    "models/player/t_guerilla.mdl", 
    "models/player/t_leet.mdl", 
    "models/player/t_phoenix.mdl", 
};

public Plugin myinfo = 
{
    name = "[VX] Chrismas Default Model", 
    author = "SoupSpy!", 
    description = "NO ANY MODEL COULD BE USED! Changes player's skin on spawn to santa", 
    version = PLUGIN_VERSION, 
    url = "http://vortex.oyunboss.net/"
};

ConVar g_cvPluginEnabled;


public void OnPluginStart()
{
    g_cvPluginEnabled = CreateConVar("sm_vxchristmas_skins_enabled", "1", "", _, true, 0.0, true, 1.0);
    HookEvent("player_spawn", VX_PlayerSpawn);
}

public Action VX_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_cvPluginEnabled.BoolValue)
        return Plugin_Continue;
    
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    
    if (IsClientValid(client))
        RequestFrame(VX_ChangeSkinOnSpawn, client);
    
    return Plugin_Continue;
}

public void VX_ChangeSkinOnSpawn(any client)
{
    char m_ModelName[PLATFORM_MAX_PATH];
    GetEntPropString(client, Prop_Data, "m_ModelName", m_ModelName, sizeof(m_ModelName));
    
    int iTeam = GetClientTeam(client);
    if (iTeam == CT)
    {
        for (int i = 0; i < sizeof(CTDefault); i++)
        {
            if (strcmp(m_ModelName, CTDefault[i][0], false) == 0)
                break;
            if (i == sizeof(CTDefault)-1)
                return;
        }
        SetEntityModel(client, "models/player/vad36militiasanta/santa_ct.mdl");
    }
    else if (iTeam == TT)
    {
        for ( int i = 0; i <sizeof(TDefault); i++ )
        {
            if ( strcmp(m_ModelName, TDefault[i][0], false) == 0 )
                break;
            if ( i == sizeof(CTDefault)-1 )
                return;
        }
        SetEntityModel(client, "models/player/vad36militiasanta/santa.mdl");
    }
    
}

public void OnConfigsExecuted()
{
    char szMainPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, szMainPath, sizeof(szMainPath), "configs");
    
    char szPath[PLATFORM_MAX_PATH];
    Format(szPath, sizeof(szPath), "%s\\vx_christmas_downloadlist.txt", szMainPath);
    
    Handle hFile = INVALID_HANDLE;
    hFile = OpenFile(szPath, "r");
    if (hFile != INVALID_HANDLE)
        VX_PreCachenDownload(hFile);
}

void VX_PreCachenDownload(Handle hFile)
{
    while (!IsEndOfFile(hFile))
    {
        char buffer[255];
        ReadFileLine(hFile, buffer, 255);
        
        TrimString(buffer);
        
        if (buffer[0] != '/')
        {
            if (FileExists(buffer))
            {
                AddFileToDownloadsTable(buffer);
                
                if (StrEqual(buffer[strlen(buffer) - 4], ".mdl", false))
                {
                    PrecacheModel(buffer, true);
                }
            }
        }
    }
}

stock bool IsClientValid(int client)
{
    if (IsClientConnected(client) && IsClientInGame(client) && 0 < client <= MaxClients)
        return true;
    return false;
} 