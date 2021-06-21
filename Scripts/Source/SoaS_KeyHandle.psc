ScriptName SoaS_KeyHandle extends Quest

SoaS_Core property core auto

int property defaultDrainKey = 39 auto

event OnInit()
    RegisterForKey(defaultDrainKey)
endEvent

int _drainActiveToggleKey = 39
int Property AttemptSweetestKissKey 
	int Function Get()
		return _drainActiveToggleKey
	EndFunction
	Function Set(int newValue)		
		UnRegisterForKey(_drainActiveToggleKey)
		core.SweetestTasteKeyCode = newValue
		_drainActiveToggleKey = newValue
		RegisterForKey(_drainActiveToggleKey)
	endFunction
 endProperty


;  Event OnKeyDown(int KeyCode)
; 	If (Utility.IsInMenuMode() || UI.IsMenuOpen("console"))
; 		Return
; 	EndIf
; 	if(KeyCode == DrainActiveToggleKey)
; 		core.drainActive = !core.drainActive
; 		;Show some effect here
; 		if(core.drainActive)
; 			Debug.Notification("Enabled Draining")
; 			MiscUtil.PrintConsole("Enabled Draining")
; 		Else
; 			Debug.Notification("Disabled Draining")
; 			MiscUtil.PrintConsole("Disabled Draining")
; 		endif
; 	endif
; endEvent