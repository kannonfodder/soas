Scriptname SoaS_MCM extends nl_mcm_module

SoaS_Core property core auto


event OnInit()
    RegisterModule("Core")
endEvent

Event OnPageInit()
    SetModName("Soul of a Succubus")
    SetLandingPage("Core")
    Debug.Notification("Setting up SoaS Menu")
endEvent

event OnPageDraw()
    SetCursorFillMode(TOP_TO_BOTTOM)
    AddToggleOptionST("ModEnabledState", "Register for event", core.EnableSOAS)
    AddKeyMapOptionST("ActiveDrainKeyMap","Active Drain", core.DrainKey)
endEvent


state ModEnabledState
    event OnDefaultST(string state_id)
        core.toggleRegister()
        SetToggleOptionValueST(core.EnableSOAS, false, "ModEnabledState")
    endevent

    event OnSelectST(string state_id)
        core.toggleRegister()
        SetToggleOptionValueST(core.EnableSOAS, false, "ModEnabledState")
    endevent

    event OnHighlightST(string state_id)
        SetInfoText("Enabled or disables SoaS")
    endevent
endstate

state ActiveDrainKeyMap
    event OnDefaultSt(string state_id)
        core.DrainKey = 40
        SetKeyMapOptionValueST(core.DrainKey)
    endEvent

    event OnHighLightST(string state_id)
        SetInfoText("Key to use to active drain. Warning may kill partner")
    endevent

    event OnKeyMapChangeST(string state_id, int keycode)
        core.DrainKey = keycode
        SetKeyMapOptionValueST(keycode)
    endevent
endState