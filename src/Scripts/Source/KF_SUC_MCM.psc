Scriptname KF_SUC_MCM extends SKI_ConfigBase

KF_SUC_Track Property core Auto

int EnableSoas

event OnPageReset(string a_page)
		EnableSoas = AddToggleOption("Register for event", core.EnableSOAS)
endEvent

event OnOptionSelect(int option)
	if(option == EnableSoas)		
		core.toggleRegister()
		SetToggleOptionValue(option, core.EnableSOAS)
	endIf
endEvent