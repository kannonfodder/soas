Scriptname Soas_MCM_SpendPoints extends nl_mcm_module

GlobalVariable Property SuccubusSavedLevels auto
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
    AddEmptyOption()
    AddEmptyOption()

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
        int currentVal = Player.GetActorValue(skill) as int
        Game.IncrementSkill(skill)
        SuccubusSavedLevels.SetValueInt(SuccubusSavedLevels.GetValueInt() - points)
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

;;;;;;;;;;;;;
;; Warrior ;;
;;;;;;;;;;;;;

state Marksman
    event OnSelectST(string stateId)        
        SelectSkill("Marksman", "Archery")
        ForcePageReset()        
    endEvent
endState

state Block
    event OnSelectST(string stateId)        
        SelectSkill("Block", "Block")
        ForcePageReset()        
    endEvent
endState

state HeavyArmor
    event OnSelectST(string stateId)
        SelectSkill("HeavyArmor", "Heavy Armor")
        ForcePageReset()        
    endEvent
endState

state OneHanded
    event OnSelectST(string stateId)
        SelectSkill("OneHanded", "One-Handed")
        ForcePageReset()        
    endEvent
endState

state Smithing
    event OnSelectST(string stateId)        
        SelectSkill("Smithing", "Smithing")
        ForcePageReset()        
    endEvent
endState

state TwoHanded
    event OnSelectST(string stateId)        
        SelectSkill("TwoHanded", "Two-Handed")
        ForcePageReset()        
    endEvent
endState
;;;;;;;;;;
;; Mage ;;
;;;;;;;;;;

state Alteration
    event OnSelectST(string stateId)        
        SelectSkill("Alteration", "Alteration")
        ForcePageReset()        
    endEvent
endState

state Conjuration
    event OnSelectST(string stateId)        
        SelectSkill("Conjuration", "Conjuration")
        ForcePageReset()        
    endEvent
endState

state Desctruction
    event OnSelectST(string stateId)        
        SelectSkill("Desctruction", "Desctruction")
        ForcePageReset()        
    endEvent
endState

state Enchanting
    event OnSelectST(string stateId)        
        SelectSkill("Enchanting", "Enchanting")
        ForcePageReset()        
    endEvent
endState

state Illusion
    event OnSelectST(string stateId)        
        SelectSkill("Illusion", "Illusion")
        ForcePageReset()        
    endEvent
endState

state Restoration   
     event OnSelectST(string stateId)        
        SelectSkill("Restoration", "Restoration")
        ForcePageReset()        
    endEvent
endState
;;;;;;;;;;;
;; Thief ;;
;;;;;;;;;;;

state Alchemy
    event OnSelectST(string stateId)        
        SelectSkill("Alchemy", "Alchemy")
        ForcePageReset()        
    endEvent
endState

state LightArmor
    event OnSelectST(string stateId)        
        SelectSkill("LightArmor", "LightArmor")
        ForcePageReset()        
    endEvent
endState

state LockPicking
    event OnSelectST(string stateId)        
        SelectSkill("LockPicking", "LockPicking")
        ForcePageReset()        
    endEvent
endState

state PickPocket
    event OnSelectST(string stateId)        
        SelectSkill("PickPocket", "PickPocket")
        ForcePageReset()        
    endEvent
endState

state Sneak
    event OnSelectST(string stateId)        
        SelectSkill("Sneak", "Sneak")
        ForcePageReset()        
    endEvent
endState

state Speechcraft
    event OnSelectST(string stateId)        
        SelectSkill("Speechcraft", "Speech")
        ForcePageReset()        
    endEvent
endState

