Scriptname SoaS_MCM extends SKI_ConfigBase

SoaS_Core property core auto

int EnableSoas

Event OnPageInit()
    Debug.Notification("Setting up SoaS Menu")
endEvent

event OnPageReset(string a_page)
        AddToggleOptionST("ModEnabledState", "Register for event", core.EnableSOAS)
endEvent

state ModEnabledState
    event OnDefaultST()
        core.toggleRegister()
        SetToggleOptionValueST(core.EnableSOAS, false, "ModEnabledState")
    endevent

    event OnSelectST()
        core.toggleRegister()
        SetToggleOptionValueST(core.EnableSOAS, false, "ModEnabledState")
    endevent

    event OnHighlightST()
        SetInfoText("Enabled or disables SoaS")
    endevent
endstate
