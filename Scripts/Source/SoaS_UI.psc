Scriptname SoaS_UI extends Quest

float Property Version auto
int Property UI_Modifier = 56 auto 
SoaS_Core core

Event OnInit()
    Maintenance()
endEvent


function Maintenance()
    if(Version < 0.4)
        SetupRefs()
        Version = 0.4
    endIf
    RegisterForKey(UI_Modifier) ; alt
    RegisterForKey(core.SweetestTasteKeyCode)
endFunction

function SetupRefs()
    core = game.GetFormFromFile(0x000806,"SoaS.esp") as SoaS_Core
endFunction

event OnKeyDown(int keycode)
    if (Utility.IsInMenuMode() || UI.IsMenuOpen("console"))
        return
    endIf
    if(Input.IsKeyPressed(UI_Modifier))
        if(keycode == core.SweetestTasteKeyCode)
            core.ShowPlayerForceBar()            
            MiscUtil.PrintConsole("SoaS: PlayerForce: " + core.PlayerLifeForce)
        endIf
    endIf
endEvent