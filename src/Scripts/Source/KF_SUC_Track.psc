Scriptname KF_SUC_Track extends Quest

Actor Property playerref auto

Bool Property EnableSOAS auto

float Property DrainedForce auto
float Property PassiveDrainAmount = 1.0 auto
float Property ActiveDrainAmount = 25.0 auto

float Property PlayerLifeForce = 50.0 auto

int Property DrainKey = 40 auto

string property LifeForceName = "soas_life_force" auto

Spell property DrainSpell auto
	
OsexIntegrationMain ostim 
OSexBar PlayerForceBar
OSexBar SecondActorForceBar
OSexBar ThirdActorForceBar

Actor secondActor = none
Actor thirdActor = none

float secondActorInitialForce
float thirdActorInitialForce

float secondActorPassiveDrain
float thirdActorPassiveDrain

float MaxPlayerLifeForce = 200.0

Event OnInit()
	Debug.Notification("Setting up SoAS")
	EnableSOAS = true	
	register()	
	ostim = game.GetFormFromFile(0x000801, "Ostim.esp") as OsexIntegrationMain	
	PlayerForceBar = (Self as Quest) as OSexBar
	SecondActorForceBar = (Self as Quest) as OSexBar
	ThirdActorForceBar = (Self as Quest) as OSexBar	
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
	RegisterForKey(DrainKey)
endFunction

function unRegister()
	UnregisterForModEvent("ostim_start")
	UnregisterForModEvent("ostim_end")
	UnRegisterForKey(DrainKey)
endFunction

Event OstimStartScene(string eventName, string strArg, float numArg, Form sender)
		
	Actor[] currentActors = ostim.GetActors()
	bool IsPlayerInvolved = false
	
	if (currentActors[0] == playerref)
		IsPlayerInvolved = true
		secondActor = currentActors[1]
		if(currentActors.Length == 3)
			thirdActor = currentActors[2]
		endif
	elseif (currentActors[1] == playerref)
		IsPlayerInvolved = true
		secondActor = currentActors[0]
		if(currentActors.Length == 3)
			thirdActor = currentActors[2]
		endif
	elseif (currentActors.Length == 3 && currentActors[2] == playerref)
		IsPlayerInvolved = true
		secondActor = currentActors[0]
		thirdActor = currentActors[1]	
	endif
	
	
	if (IsPlayerInvolved)

		PlayerForceBar.ForcePercent(PlayerLifeForce / MaxPlayerLifeForce)
		SetBarVisible(PlayerForceBar, true)

		secondActorInitialForce = StartPassiveDrain(secondActor, SecondActorForceBar)
		float currentSecondActorForce = secondActorInitialForce
		float prevSecondActorExcitment = ostim.GetActorExcitement(secondActor)
		
		float prevThirdActorExcitement = 0.0
		float currentThirdActorForce = 0.0

		if(thirdActor != None)
			thirdActorInitialForce = StartPassiveDrain(thirdActor, ThirdActorForcebar)
			currentThirdActorForce = thirdActorInitialForce
			prevThirdActorExcitement = ostim.GetActorExcitement(thirdActor)
		endif		
		
		

		While (ostim.animationRunning())
			Utility.Wait(1)
			float currentSecondActorExcitement = ostim.GetActorExcitement(secondActor)
			currentSecondActorForce = PassiveDrainActor(secondActor, currentSecondActorForce, SecondActorForceBar, prevSecondActorExcitment, currentSecondActorExcitement)
			prevSecondActorExcitment = currentSecondActorExcitement
			if(thirdActor != None)
				float currentThirdActorExcitement = ostim.GetActorExcitement(secondActor)
				currentThirdActorForce = PassiveDrainActor(thirdActor, currentThirdActorForce, ThirdActorForceBar, prevThirdActorExcitement, currentThirdActorExcitement)
				prevSecondActorExcitment = currentSecondActorExcitement
			endif
		EndWhile

	endif
		
endEvent



Event OStimEndScene(string eventName, string strArg, float numArg, Form sender)
	ResetActors()
	SetBarVisible(PlayerForceBar, false)
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
	MiscUtil.PrintConsole("Started drain");
	float initialForce = StorageUtil.GetFloatValue(act as form, LifeForceName, 100)
	bar.SetPercent(initialForce / 100)
	SetBarVisible(bar, true)
	return initialForce
endFunction

float function PassiveDrainActor(Actor act, float initialForce, OSexBar actorForceBar, float prevActorExcitement, float currentActorExcitement)	
	if(currentActorExcitement > prevActorExcitement && PassiveDrainAmount <= initialForce && initialForce >= 1.0)
		float currentForce = initialForce - PassiveDrainAmount
		AbsorbForce(PassiveDrainAmount)		
		actorForceBar.SetPercent((currentForce) / 100)
		StorageUtil.SetFloatValue(act as form, LifeForceName, currentForce)
		return currentForce
	endif
	return initialForce
endFunction


Event OnKeyDown(int KeyCode)
	If (Utility.IsInMenuMode() || UI.IsMenuOpen("console"))
		Return
	EndIf
	if(KeyCode == DrainKey)
		AttemptActiveDrain()
	endif
endEvent

function AttemptActiveDrain()
	if(ostim.animationRunning() && secondActor != None)
		ostim.EndAnimation()
		Utility.Wait(0.5)
		PerformActiveDrain(secondActor)
		if(thirdActor != None)
			PerformActiveDrain(thirdActor)
		endif
	endif
endFunction

function PerformActiveDrain(Actor act)
	float currentForce = StorageUtil.GetFloatValue(act as form, LifeForceName, 100)
	if (currentForce < ActiveDrainAmount)
		AbsorbForce(currentForce)
		DrainSpell.RemoteCast(playerref, playerref, act)		
	Else
		AbsorbForce(ActiveDrainAmount)
		StorageUtil.SetFloatValue(act as form, LifeForceName, currentForce - ActiveDrainAmount)
	endif
	
endFunction

function AbsorbForce(float amount)
	DrainedForce += amount
	if(PlayerLifeForce + amount < MaxPlayerLifeForce)
		PlayerLifeForce += amount
	Else
		PlayerLifeForce = MaxPlayerLifeForce
	endif
	
	PlayerForceBar.ForcePercent(PlayerLifeForce / MaxPlayerLifeForce)
		
	MiscUtil.PrintConsole("Drained " + amount);
endFunction

function InitPlayerForceBar()
	PlayerForceBar.HAnchor = "left"
	PlayerForceBar.VAnchor = "bottom"
	PlayerForceBar.X = 0.0
	PlayerForceBar.Alpha = 0.0
	PlayerForceBar.SetPercent(0.0)
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

