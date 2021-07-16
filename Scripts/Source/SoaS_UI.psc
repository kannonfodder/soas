ScriptName SoaS_UI extends Quest

SoaS_Core property core auto

event OnInit()
    ;RegisterForKey(39)
endEvent

event onKeyDown(int keyCode)    
    if(keyCode == core.SweetestTasteKeyCode)
        if (core.InSeducedScene == false)
            core.ShowPlayerForceBar()
        endif
    endif    
endEvent