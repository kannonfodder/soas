Scriptname SoaS_MCM extends nl_mcm_module

SoaS_Core property core auto

int _soas_enabled_flag

event OnInit()
    RegisterModule("Configuration")
endEvent

Event OnPageInit()
    SetModName("Soul of a Succubus")
    SetLandingPage("Configuration")
endEvent

event OnPageDraw()
    if(core.EnableSOAS)
        _soas_enabled_flag = OPTION_FLAG_NONE
    Else
        _soas_enabled_flag = OPTION_FLAG_DISABLED
    endif
    SetCursorFillMode(TOP_TO_BOTTOM)
    AddToggleOptionST("ModEnabledState", "Enable SoaS", core.EnableSOAS)
    AddToggleOptionST("EnableUncontrolledDrain", "Enable Uncontrolled Drains", core.EnableUncontrolledDrain, _soas_enabled_flag) 
    SetCursorPosition(1)   
    AddHeaderOption("Sweetest Taste")
    AddKeyMapOptionST("AttemptSweetestKissMap","Toggle Draining Key", 39, _soas_enabled_flag)
    AddParagraph("The sweetest taste a succubus can experience is to kill their victim at the peak of an orgasm. Activating sweetest taste will force you to try and draw a large sum of force from the victim when they orgasm. If their life force is fully drained they will die.")
endEvent


state ModEnabledState
    event OnDefaultST(string state_id)
        core.toggleRegister()
        SetToggleOptionValueST(core.EnableSOAS)
    endevent

    event OnSelectST(string state_id)
        core.toggleRegister()
        ForcePageReset()
    endevent

    event OnHighlightST(string state_id)
        SetInfoText("Enabled or disables SoaS")
    endevent
endstate

state AttemptSweetestKissMap
    event OnDefaultST(string state_id)    
        SetKeyMapOptionValueST(core.SweetestTasteKeyCode)
        RegisterForKey(core.SweetestTasteKeyCode)
    endEvent

    event OnHighLightST(string state_id)
        SetInfoText("If held during a victim orgasm, perform the sweetest taste. Potentially fatal.")
    endevent

    event OnKeyMapChangeST(string state_id, int keycode)
        UnregisterForKey(core.SweetestTasteKeyCode)
        core.SweetestTasteKeyCode
        RegisterforKey(core.SweetestTasteKeyCode)
        SetKeyMapOptionValueST(keycode)
    endevent
endState

state EnableUncontrolledDrain
    event OnDefaultST(string state_id)
        SetToggleOptionValueST(core.EnableUncontrolledDrain)
    endevent

    event OnSelectST(string state_id)
        core.EnableUncontrolledDrain = !core.EnableUncontrolledDrain
        SetToggleOptionValueST(core.EnableUncontrolledDrain)
    endevent

    event OnHighlightST(string state_id)
        SetInfoText("Enable uncontrolled drain chance on player orgasm. Warning this may be fatal to victim")
    endevent
endstate