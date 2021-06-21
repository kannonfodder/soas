Scriptname SoaS_Core extends Quest

Actor Property playerref auto

Bool Property EnableSOAS auto

float Property DrainedForce auto
float Property PassiveDrainModifier = 1.0 auto
float Property DrainResultModifier = 5.0 auto
float Property ActiveDrainAmount = 30.0 auto

bool Property EnableUncontrolledDrain = true auto

float Property PlayerLifeForce = 50.0 auto


int Property SweetestTasteKeyCode = 39 auto

string property LifeForceName = "soas_life_force" auto

Spell property PowerOfLilith auto

Spell property DrainSpell auto
	
OsexIntegrationMain ostim 
OSexBar PlayerForceBar
OSexBar Property SecondActorForceBar auto
OSexBar Property ThirdActorForceBar auto

Actor secondActor = none
Actor thirdActor = none

bool property drainActive = true auto

float secondActorInitialForce
float thirdActorInitialForce

float secondActorPassiveDrain
float thirdActorPassiveDrain

float MaxPlayerLifeForce = 500.0

Event OnInit()
	Debug.Notification("Setting up SoAS")
	EnableSOAS = true	
	register()
	ostim = game.GetFormFromFile(0x000801, "Ostim.esp") as OsexIntegrationMain	
	PlayerForceBar = (Self as Quest) as OSexBar
	InitPlayerForceBar()
	InitVictimForceBar(SecondActorForceBar, 0)
	InitVictimForceBar(ThirdActorForceBar, 1)
endEvent

function toggleRegister()
	EnableSOAS = !EnableSOAS
	if (EnableSOAS)
		register()
	else
		unRegister()
	endif

endFunction

function register()
	RegisterForModEvent("ostim_start","OstimStartScene")
	RegisterForModEvent("ostim_end","OStimEndScene")
	RegisterForModEvent("ostim_orgasm", "OstimOrgasm")	
endFunction

function unRegister()
	UnregisterForModEvent("ostim_start")
	UnregisterForModEvent("ostim_end")
	UnregisterForModEvent("ostim_orgasm")
endFunction

Event OstimStartScene(string eventName, string strArg, float numArg, Form sender)
		
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
	

		PlayerForceBar.ForcePercent(PlayerLifeForce / MaxPlayerLifeForce)
		SetBarVisible(PlayerForceBar, true)

		secondActorInitialForce = StartPassiveDrain(secondActor, SecondActorForceBar)
		float currentSecondActorForce = secondActorInitialForce
		
		float currentThirdActorForce = 0.0

		if(thirdActor != None)
			thirdActorInitialForce = StartPassiveDrain(thirdActor, ThirdActorForcebar)
			currentThirdActorForce = thirdActorInitialForce
		endif		
		
		

		While (ostim.animationRunning())
			Utility.Wait(1)
			if (drainActive)
				currentSecondActorForce = PassiveDrainActor(secondActor, currentSecondActorForce, SecondActorForceBar)
				if(thirdActor != None)
					currentThirdActorForce = PassiveDrainActor(thirdActor, currentThirdActorForce, ThirdActorForceBar)
				endif
			endif
		EndWhile

	endif
		
endEvent



Event OStimEndScene(string eventName, string strArg, float numArg, Form sender)
	ResetActors()
	SetBarVisible(PlayerForceBar, false)
endEvent

event OstimOrgasm(string eventName, string strArg, float numArg, Form sender)
	Actor orgasmer = ostim.GetMostRecentOrgasmedActor()	
	if(orgasmer == playerref)
		if(EnableUncontrolledDrain)
			PerformUncontrolledDrain()
		endif		
	Elseif(orgasmer == secondActor)
		if(Input.IsKeyPressed(SweetestTasteKeyCode))
			MiscUtil.PrintConsole("SoaS: Key Pressed - performing sweetest taste")
			PerformSweetestTaste(secondActor)
		else
			MiscUtil.PrintConsole("SoaS: Key NOT Pressed ")
		endif
	ElseIf(orgasmer == thirdActor)
		if(Input.IsKeyPressed(SweetestTasteKeyCode))
			PerformSweetestTaste(thirdActor)
		endif		
	endif
endEvent

function ResetActors()
	SetBarVisible(SecondActorForceBar, false)
	SetBarVisible(ThirdActorForceBar, false)

	secondActor = None
	thirdActor = None

	secondActorPassiveDrain = 0.0
	thirdActorPassiveDrain = 0.0
endFunction

float function StartPassiveDrain(Actor act, OSexBar bar)
	MiscUtil.PrintConsole("SoaS: Started drain");
	float initialForce = StorageUtil.GetFloatValue(act as form, LifeForceName, 100)
	bar.SetPercent(initialForce / 100)
	SetBarVisible(bar, true)
	return initialForce
endFunction

float function PassiveDrainActor(Actor act, float initialForce, OSexBar actorForceBar)	
	float playerComponent = ostim.GetActorExcitement(playerref) + 1
	if(playerComponent < 50.0)
		playerComponent = 50.0
	endif
	float victimComponent = Math.pow(ostim.GetActorExcitement(act) + 1, 1.5)
	if(victimComponent < 0)
		victimComponent = 0
	endif	
	float passiveDrainAmount = (PassiveDrainModifier * (victimComponent) * (playerComponent)) / 10000

	MiscUtil.PrintConsole("SoaS: Drain Amount: " + passiveDrainAmount)
	if(initialForce >= 1.0)
		float clampedDrainAmount = passiveDrainAmount

		if(passiveDrainAmount > initialForce - 1)
			clampedDrainAmount = initialForce - 1
		endif

		float currentForce = initialForce - clampedDrainAmount
		AbsorbForce(clampedDrainAmount)		
		actorForceBar.SetPercent((currentForce) / 100)
		StorageUtil.SetFloatValue(act as form, LifeForceName, currentForce)
		return currentForce
	endif
	return initialForce
endFunction




function PerformUncontrolledDrain() ; Succubus has lost control: Drain 3x active drain amount from the victim
	AttemptDeadlyDrain(secondActor, 3) 
	if (thirdActor != none)
		AttemptDeadlyDrain(thirdActor, 3)
	endif
endFunction

function PerformSweetestTaste(Actor act)
	if(AttemptDeadlyDrain(act, ActiveDrainAmount * 1.5)) ; Succubus wants to kill the victim: Drain 1.5x the active drain amount from the victim
		AbsorbForce(50) ; reward for killing the victim
	endif
endFunction

bool function AttemptDeadlyDrain(Actor act, float amountToDrain) ; Returns true if the drain killed the victim
	float currentForce = StorageUtil.GetFloatValue(act as form, LifeForceName, 100)	
	if (currentForce < amountToDrain)
		AbsorbForce(currentForce)
		DrainSpell.RemoteCast(playerref, playerref, act)
		return true
	Else
		AbsorbForce(amountToDrain)
		StorageUtil.SetFloatValue(act as form, LifeForceName, currentForce - ActiveDrainAmount)
		return false
	endif
	
endFunction

function AbsorbForce(float amount)
	float absorbValue = amount * DrainResultModifier
	DrainedForce += absorbValue
	if(PlayerLifeForce + absorbValue < MaxPlayerLifeForce)
		PlayerLifeForce += absorbValue
	Else
		PlayerLifeForce = MaxPlayerLifeForce
	endif
	
	PlayerForceBar.SetPercent(PlayerLifeForce / MaxPlayerLifeForce)

	if(PlayerLifeForce > 100)
		PowerOfLilith.Cast(playerref, playerref)
	endif
		
	MiscUtil.PrintConsole("SoaS: Drained " + amount + " * " + drainresultmodifier + " = " + absorbValue);
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

