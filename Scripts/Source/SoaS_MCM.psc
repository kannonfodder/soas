Scriptname SoaS_MCM extends nl_mcm_module

SoaS_Core property core auto
SoaS_UI property soasui auto

int _soas_enabled_flag
int _tfc_installed_flag

string[] tfcMenuEntries

event OnInit()
    RegisterModule("Configuration")
endEvent

Event OnPageInit()
    SetModName("Soul of a Succubus")
    SetLandingPage("Configuration")
endEvent

event OnPageDraw()
    SetupTFCMenu()
    if(core.EnableSOAS)
        _soas_enabled_flag = OPTION_FLAG_NONE
    Else
        _soas_enabled_flag = OPTION_FLAG_DISABLED
    endif
    if(core.tfcInstalled)
        _tfc_installed_flag = OPTION_FLAG_NONE
    else
        _tfc_installed_flag = OPTION_FLAG_DISABLED
    endif
    SetCursorFillMode(TOP_TO_BOTTOM)
    AddHeaderOption("Core Features")
    AddToggleOptionST("ModEnabledState", "Enable SoaS", core.EnableSOAS)
    AddToggleOptionST("EnableUncontrolledDrain", "Enable Uncontrolled Drains", core.EnableUncontrolledDrain, _soas_enabled_flag) 
    AddToggleOptionST("DisableEssentialFlagsToggle", "Disable Essential Flags", core.DisableEssentialFlags, _soas_enabled_flag)
    AddHeaderOption("Influenced NPCs")
    GetInfluencedNPCs()
    AddHeaderOption("TFC Integration")
    AddToggleOptionST("TFCDetected","TFC Detected", core.tfcInstalled, OPTION_FLAG_DISABLED)
    AddMenuOptionST("TFCFormSelect", "TFC Cursed Form", tfcMenuEntries[0], _tfc_installed_flag)
    
    SetCursorPosition(1)
    AddHeaderOption("Sweetest Taste")
    AddKeyMapOptionST("AttemptSweetestKissMap","Activate Sweetest Taste key", core.SweetestTasteKeyCode, _soas_enabled_flag)
    AddParagraph("The sweetest taste a succubus can experience is to kill their victim at the peak of an orgasm. Activating sweetest taste at the point of orgasm will force you to try and draw a large sum of force from the victim when they orgasm. If their life force is fully drained they will die.")
    AddKeyMapOptionST("UIModifierKeyMap", "Ui key", soasui.UI_Modifier, _soas_enabled_flag)
endEvent

function SetupTFCMenu()
    int i = 0
    tfcMenuEntries = new String[16]
    while (i < 16)
        tfcMenuEntries[i] = "Curse Form " + (i + 1)
        i += 1

    endWhile    
endFunction

function GetInfluencedNPCs()
    int i = 0
    while(i < core.maxInfluencedActors)
        if(i < core.InfluencedActors.Length)
            AddParagraph(core.InfluencedActors[i].GetDisplayName())
        else
            AddParagraph("Empty")
        endif
        i = i + 1
    endWhile
endFunction

state ModEnabledState
    event OnDefaultST(string state_id)
        core.DisableMod()
        SetToggleOptionValueST(core.EnableSOAS)
    endevent

    event OnSelectST(string state_id)
        core.ToggleEnableMod()
        ForcePageReset()
    endevent

    event OnHighlightST(string state_id)
        SetInfoText("Enabled or disables SoaS")
    endevent
endstate

state AttemptSweetestKissMap
    event OnDefaultST(string state_id)    
        core.UnregisterForKey(core.SweetestTasteKeyCode)
        soasui.UnregisterForKey(core.SweetestTasteKeyCode)
        core.SweetestTasteKeyCode = 39 ;
        soasui.RegisterForKey(39)
        SetKeyMapOptionValueST(39)
    endEvent

    event OnHighLightST(string state_id)
        SetInfoText("If held during a victim orgasm, perform the Sweetest Taste. Potentially fatal.")
    endevent

    event OnKeyMapChangeST(string state_id, int keycode)
        core.UnregisterForKey(core.SweetestTasteKeyCode)
        soasui.UnregisterForKey(core.SweetestTasteKeyCode)
        core.SweetestTasteKeyCode = keycode
        core.RegisterForKey(keycode)
        soasui.RegisterForKey(keycode)
        SetKeyMapOptionValueST(keycode)
    endevent
endState

state UIModifierKeyMap
    event OnDefaultST(string state_id)
        soasui.UnregisterForKey(soasui.UI_Modifier)
        soasui.UI_Modifier = 56 ;alt
        soasui.RegisterForKey(soasui.UI_Modifier)
        SetKeyMapOptionValueST(soasui.UI_Modifier)
    endEvent

    event OnHighLightST(string state_id)
        SetInfoText("If held with the sweetest taste key will show the player's life force bar")
    endEvent

    event OnKeyMapChangeST(string state_id, int keycode)
        soasui.UnregisterForKey(soasui.UI_Modifier)
        soasui.UI_Modifier = keycode
        soasui.RegisterForKey(soasui.UI_Modifier)
        SetKeyMapOptionValueST(keycode)
    endEvent
endState

state EnableUncontrolledDrain
    event OnDefaultST(string state_id)
        core.EnableUncontrolledDrain = true
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

state DisableEssentialFlagsToggle
    event OnDefaultST(string state_id)
        core.DisableEssentialFlags = false
        SetToggleOptionValueST(core.DisableEssentialFlags)
    endEvent

    event OnSelectST(string state_id)
        core.DisableEssentialFlags = !core.DisableEssentialFlags
        SetToggleOptionValueST(core.DisableEssentialFlags)
    endEvent

    event OnHighlightST(string state_id)
        SetInfoText("Disable any essential flags on vicitms and allow their death. Warning! This will break quests. Use at your own risk.")
    endEvent
endState

;;;;;;;;;;;;;;;;;;;
; TFC Integration ;
;;;;;;;;;;;;;;;;;;;

state TFCDetected
    event OnDefaultST(string state_id)
    endEvent

    event OnSelectST(string state_id)
    endEvent

    event OnHighLightST(string state_id)
        SetInfoText("Detects if True Form Curse is installed. If so you will transform into the Cursed Form Set below when your life force gets too low")
    endEvent
endState

;;Core.TFCCurseFormId is from 1-16 to match the value that tfc expects
; The 
state TFCFormSelect
    event OnMenuOpenST(string state_id)
		SetMenuDialogStartIndex(core.tfcCurseFormId - 1)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(tfcMenuEntries)
	endEvent

	event OnMenuAcceptST(string state_id, int index)
		core.tfcCurseFormId = index + 1
		SetMenuOptionValueST(tfcMenuEntries[index])
	endEvent

	event OnDefaultST(string state_id)
		core.tfcCurseFormId = 1
		SetMenuOptionValueST(tfcMenuEntries[0])
	endEvent

	event OnHighlightST(string state_id)
		SetInfoText("Which cursed form to use if tfc is enabled")
	endEvent
endState