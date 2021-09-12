Scriptname SoaS_Core extends Quest

Actor Property playerref auto

Faction Property forcelevel0Faction auto
Faction Property forcelevel1Faction auto
Faction Property forcelevel2Faction auto
Faction Property forcelevel3Faction Auto

Faction Property SeducedFaction Auto

Bool Property EnableSOAS auto

float Property DrainedForce auto
float Property PassiveDrainModifier = 0.9 auto
float Property DrainResultModifier = 1.0 auto
float Property ActiveDrainAmount = 30.0 auto
float Property ForceRegenRate = 100.0 auto ; Life force regenerated per day

bool Property EnableUncontrolledDrain = true auto
bool property DisableEssentialFlags = false auto

float Property PlayerLifeForce = 150.0 auto
float PlayerLifeForceLastCheckTime = 0.0
float Property PlayerLifeForceConstantDrain = 100.0 auto


int Property SweetestTasteKeyCode = 39 auto
Spell Property SweetestTasteAbility auto

string property LifeForceName = "soas_life_force" auto
string property LifeForceCheckName = "soas_life_force_check" auto

Spell property PowerOfLilith auto

Spell property DrainSpell auto
Spell property SoulDrainAbility auto
Spell property SeductionSpell auto


Spell property VictimDebuff50 auto
Spell property VictimDebuff25 auto
Spell property VictimDebuff5 auto
	
OsexIntegrationMain ostim 
OSexBar PlayerForceBar
OSexBar Property SecondActorForceBar auto
OSexBar Property ThirdActorForceBar auto

Actor secondActor = none
Actor thirdActor = none

bool property DrainActive = true auto

float secondActorInitialForce
float thirdActorInitialForce

float secondActorPassiveDrain
float thirdActorPassiveDrain

float level1Limit = 100.0
float level2Limit = 400.0
float level3Limit = 490.0

float MaxPlayerLifeForce = 500.0

bool secondActorSeduced = false
bool thirdActorSeduced = false

bool property InSeducedScene = false auto

float property Version auto

;;;;;;;;;;;;;;;;;;;
; TFC Integration ;
;;;;;;;;;;;;;;;;;;;

bool property tfcInstalled = false auto
int property tfcCurseFormId = 1 auto

event OnInit()
	Debug.Notification("Setting up SoaS")
	Maintenance()
endEvent

function Maintenance()
	if(Version < 0.4)
		SetupRefs()
		Version = 0.4
	endif
	if(Version < 1.03)		
		tfcInstalled = game.GetFormFromFile(0x0000801, "TrueFormCurse.esp") != none	
		if(tfcInstalled)
			Debug.Notification("Soas: True form curse installed")
		endif
		Version = 1.03
	endif
	if(EnableSOAS)
		RegisterForModEvents()
	endIf
endFunction

function SetupRefs()
	ostim = game.GetFormFromFile(0x000801, "Ostim.esp") as OsexIntegrationMain	
	PlayerForceBar = (Self as Quest) as OSexBar
	InitPlayerForceBar()
	InitVictimForceBar(SecondActorForceBar, 0)
	InitVictimForceBar(ThirdActorForceBar, 1)
endFunction

function ToggleEnableMod()
	if (EnableSOAS)
		DisableMod()		
	else
		EnableMod()
	endif

endFunction

function EnableMod()
	EnableSOAS = true
	RegisterForModEvents()
	playerref.AddSpell(PowerOfLilith)
	playerref.AddSpell(SeductionSpell)
	RegisterForSingleUpdate(3.0)
endFunction

function RegisterForModEvents()
	RegisterForModEvent("ostim_start", "OstimStartScene")
	RegisterForModEvent("ostim_end", "OStimEndScene")
	RegisterForModEvent("ostim_orgasm", "OstimOrgasm")
endFunction

function UnRegisterForModEvents()
	UnregisterForModEvent("ostim_start")
	UnregisterForModEvent("ostim_end")
	UnregisterForModEvent("ostim_orgasm")	
endFunction

function DisableMod()
	EnableSOAS = false
	UnRegisterForModEvents()	
	playerref.RemoveSpell(PowerOfLilith)
	playerref.RemoveSpell(SeductionSpell)
	playerref.RemoveFromFaction(forcelevel0Faction)
	playerref.RemoveFromFaction(forcelevel1Faction)
	playerref.RemoveFromFaction(forcelevel2Faction)
	playerref.RemoveFromFaction(forcelevel3Faction)
	UnregisterForUpdate()
endFunction

event OnUpdate()
	if(EnableSOAS)
		float currentTime = Utility.GetCurrentGameTime()	
		if(PlayerLifeForceLastCheckTime != 0.0)				
			float drainAmount = PlayerLifeForceConstantDrain * (currentTime - PlayerLifeForceLastCheckTime)
			if drainAmount > PlayerLifeForce
				PlayerLifeForce = 0.0
			else
				PlayerLifeForce -= drainAmount
			endif		
		endif	
		PlayerForceBar.SetPercent(PlayerLifeForce / MaxPlayerLifeForce)
		CalculateLilithChanges()
		PlayerLifeForceLastCheckTime = currentTime
		RegisterForSingleUpdate(3.0)
	endif
endEvent

event OstimStartScene(string eventName, string strArg, float numArg, Form sender)	
	ResetActors()

	Actor[] currentActors = ostim.GetActors()
	bool IsPlayerInvolved = ostim.IsPlayerInvolved()
	if (IsPlayerInvolved)
		if(currentActors.Length == 1)
			return
		endif
		
		if (currentActors[0] == playerref)
			secondActor = currentActors[1]			
			if(currentActors.Length == 3)
				thirdActor = currentActors[2]
			endif
		elseif (currentActors[1] == playerref)
			secondActor = currentActors[0]
			if(currentActors.Length == 3)
				thirdActor = currentActors[2]
			endif
		elseif (currentActors.Length == 3 && currentActors[2] == playerref)
			secondActor = currentActors[0]
			thirdActor = currentActors[1]	
		endif	
		
		if(secondActor.IsInFaction(SeducedFaction))
			secondActorSeduced = true
		endif
		if(thirdActor && thirdActor.IsInFaction(SeducedFaction))
			thirdActorSeduced = true
		endif
		if(!secondActorSeduced && !thirdActorSeduced)
			return
		Else
			InSeducedScene = true
		endif

		PlayerForceBar.ForcePercent(PlayerLifeForce / MaxPlayerLifeForce)
		SetBarVisible(PlayerForceBar, true)
		float currentSecondActorForce = 0.0
		float currentThirdActorForce = 0.0

		if(secondActorSeduced)
			secondActorInitialForce = StartPassiveDrain(secondActor, SecondActorForceBar)
			currentSecondActorForce = secondActorInitialForce
		endif
		if(thirdActor != None && thirdActorSeduced)
			thirdActorInitialForce = StartPassiveDrain(thirdActor, ThirdActorForcebar)
			currentThirdActorForce = thirdActorInitialForce
		endif		
		
		

		While (ostim.animationRunning())
			Utility.Wait(1)
			if (DrainActive)
				if(secondActorSeduced)
					currentSecondActorForce = PassiveDrainActor(secondActor, currentSecondActorForce, SecondActorForceBar)
				endif
				if(thirdActor != None && thirdActorSeduced)
					currentThirdActorForce = PassiveDrainActor(thirdActor, currentThirdActorForce, ThirdActorForceBar)
				endif
			endif
		EndWhile
	endif
		
endEvent



event OStimEndScene(string eventName, string strArg, float numArg, Form sender)
	if(GetLifeForce(secondActor) < 5.0)
		;VictimDebuff5.Cast(secondActor)		
	endif
	SetBarVisible(PlayerForceBar, false)
	InSeducedScene = false
	secondActor.DispelSpell(SeductionSpell)
	if(thirdActor)
		thirdActor.DispelSpell(SeductionSpell)
	endif
	ResetActors()
endEvent

event OstimOrgasm(string eventName, string strArg, float numArg, Form sender)
	Actor orgasmer = ostim.GetMostRecentOrgasmedActor()	
	if(orgasmer == playerref)
		if(EnableUncontrolledDrain)
			if(ostim.ChanceRoll(33))
				Debug.MessageBox("You're losing control!")
				PerformUncontrolledDrain()
			endif
		endif		
	Elseif(orgasmer == secondActor && secondActorSeduced)
		if(Input.IsKeyPressed(SweetestTasteKeyCode))
			MiscUtil.PrintConsole("SoaS: Key Pressed - performing sweetest taste")
			PerformSweetestTaste(secondActor)
		else
			MiscUtil.PrintConsole("SoaS: Key NOT Pressed ")
			
		endif
	ElseIf(orgasmer == thirdActor && thirdActorSeduced)
		if(Input.IsKeyPressed(SweetestTasteKeyCode))
			PerformSweetestTaste(thirdActor)
		endif		
	endif
endEvent

function ResetActors()
	SetBarVisible(SecondActorForceBar, false)
	SetBarVisible(ThirdActorForceBar, false)

	secondActor = None
	secondActorSeduced = false
	thirdActor = None
	thirdActorSeduced = false

	secondActorPassiveDrain = 0.0
	thirdActorPassiveDrain = 0.0
endFunction

float function StartPassiveDrain(Actor act, OSexBar bar)
	MiscUtil.PrintConsole("SoaS: Started drain");
	float initialForce = GetLifeForce(act)
	bar.SetPercent(initialForce / 100)
	SetBarVisible(bar, true)
	return initialForce
endFunction

float function PassiveDrainActor(Actor act, float initialForce, OSexBar actorForceBar)	
	float playerComponent = ostim.GetActorExcitement(playerref) + 1
	if(playerComponent > 100.0)
		playerComponent = 100.0
	endif
	if(playerComponent < 50.0)
		playerComponent = 50.0
	endif
	float victimExcitement = ostim.GetActorExcitement(act)
	if(victimExcitement <= 0.0)
		victimExcitement = 0.1
	endif
	if(victimExcitement > 100.0)
		victimExcitement = 100.0
	endif
	float victimComponent = Math.pow(victimExcitement, 1.5)
	float passiveDrainAmount = (PassiveDrainModifier * (victimComponent) * (playerComponent)) / 10000

	;MiscUtil.PrintConsole("SoaS: Drain Amount: " + passiveDrainAmount)
	if(initialForce >= 1.0)
		float clampedDrainAmount = passiveDrainAmount

		if(passiveDrainAmount > initialForce - 1)
			clampedDrainAmount = initialForce - 1
		endif

		float currentForce = initialForce - clampedDrainAmount
		AbsorbForce(clampedDrainAmount)		
		actorForceBar.SetPercent((currentForce) / 100)
		SetLifeForce(act, currentForce)
		return currentForce
	endif
	return initialForce
endFunction

function PerformUncontrolledDrain() ; Succubus has lost control: Drain 3x active drain amount from the victim
	AttemptDeadlyDrain(secondActor, ActiveDrainAmount * 3.0, false) 
	if (thirdActor != none)
		AttemptDeadlyDrain(thirdActor, ActiveDrainAmount * 3.0, false)
	endif
endFunction

function PerformSweetestTaste(Actor act)
	MiscUtil.PrintConsole("SoaS: performing sweetest taste")
	if(AttemptDeadlyDrain(act, ActiveDrainAmount * 1.5, true)) ; Succubus wants to kill the victim: Drain 1.5x the active drain amount from the victim
		AbsorbForce(25, true) ; free force, should push level 0 -> level 1		
		SweetestTasteAbility.Cast(playerref) ; Only applies buffs if within the corect faction (Spell/ME condition controlled)
	endif
endFunction

bool function AttemptDeadlyDrain(Actor act, float amountToDrain, bool controlled) ; Returns true if the drain killed the victim
	MiscUtil.PrintConsole("SoaS: Draining " + amountToDrain)
	float currentForce = GetLifeForce(act)	
	if (currentForce < amountToDrain)
		AbsorbForce(currentForce)
		MiscUtil.PrintConsole("SoaS: Doing Deadly Drain")
		if(DisableEssentialFlags)
			ActorBase actBase = act.GetActorBase()
			actBase.SetEssential(false)
			actBase.SetProtected(false)
		endif
		;ostim.EndAnimation()
		Utility.Wait(0.5)
		DrainSpell.RemoteCast(playerref, playerref, act)
		return true
	Else
		AbsorbForce(amountToDrain)
		SetLifeForce(act,currentForce - ActiveDrainAmount)
		return false
	endif
	
endFunction

function AbsorbForce(float amount, bool ignoreLevelLimit = false)
	float absorbValue = amount * DrainResultModifier
	DrainedForce += absorbValue
	if(!ignoreLevelLimit && playerRef.IsInFaction(forcelevel0Faction) && PlayerLifeForce + absorbValue > level1Limit)
		PlayerLifeForce = level1Limit
	else
		if(PlayerLifeForce + absorbValue > MaxPlayerLifeForce)
			PlayerLifeForce = MaxPlayerLifeForce
		Else
			PlayerLifeForce += absorbValue
		endif
	endif
	
	PlayerForceBar.SetPercent(PlayerLifeForce / MaxPlayerLifeForce)

	CalculateLilithChanges()
		
	;MiscUtil.PrintConsole("SoaS: Drained " + amount + " * " + drainresultmodifier + " = " + absorbValue);
endFunction

function CalculateLilithChanges(bool silent = false)

	string notificationMessage = ""
	if(PlayerLifeForce <= level1Limit)
		if(!playerref.IsInFaction(forcelevel0Faction))
			
			notificationMessage = "I feel all my strength leaving me, I know I need to kill to regain it"

			playerref.AddToFaction(forcelevel0Faction)
			playerref.RemoveFromFaction(forcelevel1Faction)
			playerref.RemoveFromFaction(forcelevel2Faction)
			playerref.RemoveFromFaction(forcelevel3Faction)
			TurnToCursedForm()
		endif
	elseif(PlayerLifeForce > level1Limit && PlayerLifeForce <= level2Limit)		
		if(!playerref.IsInFaction(forcelevel1Faction))
			if playerref.IsInFaction(forcelevel0Faction)
				notificationMessage = "I'm feeling normal again, I should feed more to gain more power"
			else	
				notificationMessage = "I don't feel Lilith's boon. I must kill more to attain her power"
			endif
			playerref.RemoveFromFaction(forcelevel0Faction)
			playerref.AddToFaction(forcelevel1Faction)
			playerref.RemoveFromFaction(forcelevel2Faction)
			playerref.RemoveFromFaction(forcelevel3Faction)
			TurnToTrueForm()
		endif
	elseif(PlayerLifeForce > level2Limit && PlayerLifeForce <= level3Limit)	
		if(!playerref.IsInFaction(forcelevel2Faction))
			if playerref.IsInFaction(forcelevel0Faction) || playerref.IsInFaction(forcelevel1Faction)
				notificationMessage = "Ultimate power is almost mine, I can taste it!"
			else	
				notificationMessage = "I've lost my ultimate power, but I can get it back"
			endif
			playerref.RemoveFromFaction(forcelevel0Faction)
			playerref.RemoveFromFaction(forcelevel1Faction)
			playerref.AddToFaction(forcelevel2Faction)
			playerref.RemoveFromFaction(forcelevel3Faction)
			TurnToTrueForm()
		endif
	elseif(PlayerLifeForce > level3Limit)		
		if(!playerref.IsInFaction(forcelevel3Faction))
			if playerref.IsInFaction(forcelevel2Faction) || playerref.IsInFaction(forcelevel1Faction) || playerref.IsInFaction(forcelevel2Faction)
				notificationMessage = "This is what true power feels like!"
			endif
			playerref.RemoveFromFaction(forcelevel0Faction)
			playerref.RemoveFromFaction(forcelevel1Faction)
			playerref.RemoveFromFaction(forcelevel2Faction)
			playerref.AddToFaction(forcelevel3Faction)
			TurnToTrueForm()
		endif
	endif
	if(!silent)
		Debug.Notification(notificationMessage)
	endif
endFunction

function InitPlayerForceBar()
	PlayerForceBar.HAnchor = "left"
	PlayerForceBar.VAnchor = "bottom"
	PlayerForceBar.X = 0.0
	PlayerForceBar.Alpha = 0.0
	PlayerForceBar.SetPercent(PlayerLifeForce / MaxPlayerLifeForce)
	PlayerForceBar.FillDirection = "Right"

	
	PlayerForceBar.Y = 180.0
	PlayerForceBar.SetColors(0x660066, 0xCC00CC)

	SetBarVisible(PlayerForceBar, False)
endFunction
	
function InitVictimForceBar(Osexbar bar, int offset)
	bar.HAnchor = "left"
	bar.VAnchor = "bottom"
	bar.X = 980.0
	bar.Alpha = 0.0
	bar.SetPercent(0.0)
	bar.FillDirection = "Left"

	
	bar.Y = 180.0 + (30 * offset)
	bar.SetColors(0xff5533, 0xfff5fd)


	SetBarVisible(bar, False)
endFunction

function SetBarVisible(Osexbar bar, Bool visible)
	If (visible)
		bar.FadeTo(100.0, 1.0)
		bar.FadedOut = False
	Else
		bar.FadeTo(0.0, 1.0)
		bar.FadedOut = True
	EndIf
endFunction

float function GetLifeForce(Actor act)
	
	float lastCheckTime =  StorageUtil.GetFloatValue(act as form, LifeForceCheckName, 0)
	StorageUtil.SetFloatValue(act, LifeForceCheckName, Utility.GetCurrentGameTime())

	float storedAmount = StorageUtil.GetFloatValue(act as form, LifeForceName, 100)
	if(lastcheckTime > 0)		
		float currenttime = Utility.GetCurrentGameTime()
		float timePassed = currenttime - lastCheckTime
		float regenAmount = ForceRegenRate * timePassed
		if(regenAmount > 100.0 - storedAmount)
			storedAmount = 100.0
		else
			storedAmount += regenAmount
		endif
		SetLifeForce(act, storedAmount)
	endif
	return storedAmount
endFunction

function SetLifeForce(Actor act, float amount)
	StorageUtil.SetFloatValue(act as form, LifeForceName, amount)
endFunction


function ShowPlayerForceBar()
	SetBarVisible(PlayerForceBar, true)
	Utility.Wait(5)
	SetBarVisible(PlayerForceBar, false)
endFunction

;;;;;;;;;;;;;;;;;;;
; TFC Integration ;
;;;;;;;;;;;;;;;;;;;

function TurnToCursedForm()
	if(!tfcInstalled)
		return
	endif
	int handle  = ModEvent.Create("TFCForceTurnIntoForm")
	if(handle)
		ModEvent.PushInt(handle, tfcCurseFormId)
		ModEvent.Send(handle)
	endif	
endfunction

function TurnToTrueForm()
	if(!tfcInstalled)
		return
	endif
	SendModEvent("TFCTurnIntoTrueForm")

endFunction
