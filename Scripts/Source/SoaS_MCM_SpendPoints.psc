Scriptname Soas_MCM_SpendPoints extends nl_mcm_module

GlobalVariable Property SuccubusSavedLevels auto
GlobalVariable Property SuccubusLevel auto
GlobalVariable Property SuccubusLeveledUp auto
GlobalVariable Property SuccubusLevelPerks auto
Actor Property Player auto

event OnInit()
    RegisterModule("Skill Points", 1)
endEvent

event OnPageDraw()
    SetCursorFillMode(TOP_TO_BOTTOM)
    AddHeaderOption("Skill points")
    AddTextOptionST("PointsAvailable", "Points available to spend", SuccubusSavedLevels.GetValueInt())
    
    AddHeaderOption("Combat Skills")
    AddSkillOption("Marksman", "Archery")
    AddSkillOption("Block", "Block")
    AddSkillOption("HeavyArmor", "Heavy Armor")
    AddSkillOption("OneHanded", "One-Handed")
    AddSkillOption("Smithing", "Smithing")
    AddSkillOption("TwoHanded", "Two-Handed")

    AddHeaderOption("Stealth Skills")
    AddSkillOption("Alchemy", "Alchemy")
    AddSkillOption("LightArmor", "LightArmor")
    AddSkillOption("LockPicking", "LockPicking")

    SetCursorPosition(1)
    AddTextOptionST("CloseMenu", "Close Menu", "")
    AddTextOptionST("Succubus", "Succubus", "" +  SuccubusLevel.GetValueInt() + " (1)")

    AddHeaderOption("Magic Skills")
    AddSkillOption("Alteration", "Alteration")
    AddSkillOption("Conjuration", "Conjuration")
    AddSkillOption("Destruction", "Destruction")
    AddSkillOption("Enchanting", "Enchanting")
    AddSkillOption("Illusion", "Illusion")
    AddSkillOption("Restoration", "Restoration")
    AddEmptyOption()
    
    AddSkillOption("PickPocket", "PickPocket")
    AddSkillOption("Sneak", "Sneak")
    AddSkillOption("Speechcraft", "Speech")
    
endEvent


function ToggleMCM()
    int old_hotkey = QuickHotkey
    SetLandingPage("Skill Points")
    QuickHotkey = 83
    Utility.Wait(0.1)
    Input.TapKey(83)
    Utility.Wait(0.5)
    QuickHotkey = old_hotkey
    SetLandingPage("Configuration")
endfunction

function AddSkillOption(string skill, string skillName)
    int currentValue = player.GetActorValue(skill) as int
    if(currentValue == 100)
        AddTextOptionST(skill, skillName, "Max", OPTION_FLAG_DISABLED)
    else
        AddTextOptionST(skill, skillName, "" + currentValue + " (" + CostToIncrease(skill) + ")")
    endif    
endFunction

function SelectSkill(string skill, string skillName)
    int points = CostToIncrease(skill)
    if(points > SuccubusSavedLevels.GetValueInt())
        ShowMessage("Not enough points to level skill", false)
        return
    endif
    if(ShowMessage("Level up " + skillName + " for " + points + " points?", true))
        int newValue = Player.GetActorValue(skill) as int + 1
        Game.IncrementSkill(skill)
        SuccubusSavedLevels.SetValueInt(SuccubusSavedLevels.GetValueInt() - points)
        SetTextOptionValueST("" + newValue + " (" + CostToIncrease(skill) + ")", true)
        SetTextOptionValueST(SuccubusSavedLevels.GetValueInt(), false, "PointsAvailable")
    endif
endFunction

int function CostToIncrease(string skill)
    int currentValue = Player.GetActorValue(skill) as int
    if(currentValue) < 15
        return 1
    elseif(currentValue < 25)
        return 2
    elseif(currentValue < 50)
        return 3
    elseif(currentValue < 75)
        return 4
    Else
        return 5
    endif
endFunction

state CloseMenu
    event OnSelectST(string stateId)
        CloseMCM(true)
    endEvent
endState


;;;;;;;;;;;;;;
;; Succubus ;;
;;;;;;;;;;;;;;

state Succubus
    event OnSelectST(string stateId)
        if(1 > SuccubusSavedLevels.GetValueInt())
            ShowMessage("Not enough points to level skill", false)
            return
        endif
        if(ShowMessage("Level up Succubus skill for 1 point?", true))
            int newSuccubusLevel = SuccubusLevel.GetValueInt() + 1
            SuccubusLevel.SetValue(newSuccubusLevel)
            SuccubusLeveledUp.SetValue(newSuccubusLevel)
            SuccubusSavedLevels.SetValueInt(SuccubusSavedLevels.GetValueInt() - 1)            
			if(!( newSuccubusLevel as float / 5 - Math.Floor(newSuccubusLevel as float / 5) > 0 ) && newSuccubusLevel != 0)
				SuccubusLevelPerks.SetValue(SuccubusLevelPerks.GetValue() + 1)
			endIf
            SetTextOptionValueST("" +  newSuccubusLevel + " (1)")
            SetTextOptionValueST(SuccubusSavedLevels.GetValueInt(), false, "PointsAvailable")
        endif
    endEvent
endState


;;;;;;;;;;;;;
;; Warrior ;;
;;;;;;;;;;;;;

state Marksman
    event OnSelectST(string stateId)        
        SelectSkill("Marksman", "Archery")
    endEvent
endState

state Block
    event OnSelectST(string stateId)        
        SelectSkill("Block", "Block")
    endEvent
endState

state HeavyArmor
    event OnSelectST(string stateId)
        SelectSkill("HeavyArmor", "Heavy Armor")
    endEvent
endState

state OneHanded
    event OnSelectST(string stateId)
        SelectSkill("OneHanded", "One-Handed")
    endEvent
endState

state Smithing
    event OnSelectST(string stateId)        
        SelectSkill("Smithing", "Smithing")
    endEvent
endState

state TwoHanded
    event OnSelectST(string stateId)        
        SelectSkill("TwoHanded", "Two-Handed")
    endEvent
endState
;;;;;;;;;;
;; Mage ;;
;;;;;;;;;;

state Alteration
    event OnSelectST(string stateId)        
        SelectSkill("Alteration", "Alteration")
    endEvent
endState

state Conjuration
    event OnSelectST(string stateId)        
        SelectSkill("Conjuration", "Conjuration")
    endEvent
endState

state Desctruction
    event OnSelectST(string stateId)        
        SelectSkill("Desctruction", "Desctruction")
    endEvent
endState

state Enchanting
    event OnSelectST(string stateId)        
        SelectSkill("Enchanting", "Enchanting")
    endEvent
endState

state Illusion
    event OnSelectST(string stateId)        
        SelectSkill("Illusion", "Illusion")
    endEvent
endState

state Restoration   
     event OnSelectST(string stateId)        
        SelectSkill("Restoration", "Restoration")
    endEvent
endState
;;;;;;;;;;;
;; Thief ;;
;;;;;;;;;;;

state Alchemy
    event OnSelectST(string stateId)        
        SelectSkill("Alchemy", "Alchemy")
    endEvent
endState

state LightArmor
    event OnSelectST(string stateId)        
        SelectSkill("LightArmor", "LightArmor")
    endEvent
endState

state LockPicking
    event OnSelectST(string stateId)        
        SelectSkill("LockPicking", "LockPicking")
    endEvent
endState

state PickPocket
    event OnSelectST(string stateId)        
        SelectSkill("PickPocket", "PickPocket")
    endEvent
endState

state Sneak
    event OnSelectST(string stateId)        
        SelectSkill("Sneak", "Sneak")
    endEvent
endState

state Speechcraft
    event OnSelectST(string stateId)        
        SelectSkill("Speechcraft", "Speech")
    endEvent
endState
