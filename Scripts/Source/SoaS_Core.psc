Scriptname SoaS_Core extends Quest

Actor Property playerref auto

Faction Property forcelevel0Faction auto
Faction Property forcelevel05Faction auto
Faction Property forcelevel1Faction auto
Faction Property forcelevel2Faction auto
Faction Property forcelevel3Faction Auto

Bool Property EnableSOAS = true auto

float Property DrainedForce auto
float _baseDrainResult = 1.0
float Property PassiveDrainModifier
	function set(float newVal)
		_baseDrainResult = newVal
	endFunction
	float function get()
		if (playerRef.HasPerk(DrainRate00))
			return _baseDrainResult * 2
		elseIf (playerRef.HasPerk(DrainRate80))
			return _baseDrainResult * 1.8
		elseIf (playerRef.HasPerk(DrainRate60))
			return _baseDrainResult * 1.6
		elseIf (playerRef.HasPerk(DrainRate40))				
			return _baseDrainResult * 1.4
		elseIf (playerRef.HasPerk(DrainRate20))
			return _baseDrainResult * 1.2
		else
			return _baseDrainResult
		endif			
	endFunction
endProperty
float Property ActiveDrainAmount = 30.0 auto
float Property ForceRegenRate = 100.0 auto ; Life force regenerated per day

bool Property EnableUncontrolledDrain = true auto
bool Property DisableEssentialFlags = false auto

float Property PlayerLifeForce = 200.0 auto
float PlayerLifeForceLastCheckTime = 0.0
float Property PlayerLifeForceConstantDrain = 100.0 auto


int Property SweetestTasteKeyCode = 39 auto
Spell Property SweetestTasteAbility auto

string Property LifeForceName = "soas_life_force" auto
string Property LifeForceCheckName = "soas_life_force_check" auto

Spell Property PowerOfLilith auto

Spell Property DrainSpell auto
Spell Property SoulDrainAbility auto
Spell Property SeductionSpell auto
Spell Property InfluenceSpell auto


Spell Property VictimDebuff50 auto
Spell Property VictimDebuff25 auto
Spell Property VictimDebuff5 auto
	
OsexIntegrationMain ostim 
OSexBar PlayerForceBar
OSexBar Property SecondActorForceBar auto
OSexBar Property ThirdActorForceBar auto

Actor secondActor = none
Actor thirdActor = none

bool Property DrainActive = true auto

float secondActorInitialForce
float thirdActorInitialForce

float secondActorPassiveDrain
float thirdActorPassiveDrain

float level1Limit = 75.0
float level15Limit = 150.0
float level2Limit = 400.0
float level3Limit = 490.0

float MaxPlayerLifeForce = 500.0

float Property Version auto

int Property maxInfluencedActors = 2 auto
Actor[] Property InfluencedActors auto

;;;;;;;;;;;;;;;;;;;
; TFC Integration ;
;;;;;;;;;;;;;;;;;;;

bool Property tfcInstalled = false auto
bool Property tfcIntegrated = false auto
int Property tfcCurseFormId = 1 auto ; value in tfc, ranges from 1 - 16

;;;;;;;;;;;;;;;;;
;; Progression ;;
;;;;;;;;;;;;;;;;;

float Property CurrentExp = 0.0 auto
float killExpValue = 100.0
float overdrainExpValue = 0.2
float Property nextRequiredExp = 0.0 auto
GlobalVariable Property SuccubusLevel auto 
GlobalVariable Property SuccubusLevelUpRatio auto ; level up % for bar
GlobalVariable Property SuccubusSavedLevels auto 
Message Property SaveOrSpendMessage auto

Perk Property DrainRate20 auto
Perk Property DrainRate40 auto
Perk Property DrainRate60 auto
Perk Property DrainRate80 auto
Perk Property DrainRate00 auto

SoaS_MCM_SpendPoints Property SpendPointsMCM auto

;;;;;;;;;;;;;;;;;;;;;;
;; Message Queueing ;;
;;;;;;;;;;;;;;;;;;;;;;

string[] messageQueue


event OnInit()
	Debug.Notification("Setting up SoaS")
	Maintenance()
endEvent

function Maintenance() ; Called by the player ref script attached to player alias
	if(SuccubusLevel.GetValueInt() == 0)
		SuccubusLevel.SetValue(1)
	endIf
	if(Version == 0 && EnableSOAS)			
		playerref.AddSpell(PowerOfLilith)
		playerref.AddSpell(SeductionSpell)		
	endIf
	if(Version < 0.4)
		SetupRefs()
		Version = 0.4
	endif
	
	if(Version < 1.1)
		tfcInstalled = game.GetFormFromFile(0x0000801, "TrueFormCurse.esp") != none
		tfcIntegrated = tfcInstalled
		if(EnableSOAS)		
			playerref.AddSpell(InfluenceSpell)			
		endif
		InfluencedActors = PapyrusUtil.ActorArray(0)
		CalculateNextRequiredExp()
		messageQueue = PapyrusUtil.StringArray(10)
		if( nl_mcm_globalinfo.CurrentVersion() < 105 )
			Debug.MessageBox(" Soul of a Succubus requires the latest version of nl_mcm (at least 1.0.5) to work properly. Go get it")
		endif
	endif
	
	Version = 1.1	
	
	if(EnableSOAS)
		RegisterForModEvents()
	endIf
	RegisterForSingleUpdate(3.0)
endFunction

function SetupRefs()
	ostim = game.GetFormFromFile(0x000801, "Ostim.esp") as OsexIntegrationMain	
	PlayerForceBar = (Self as Quest) as OSexBar
	InitPlayerForceBar()
	InitVictimForceBar(SecondActorForceBar, 0)
	InitVictimForceBar(ThirdActorForceBar, 1)
	RegisterForKey(80) ; DEBUG
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
	playerref.AddSpell(InfluenceSpell)
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
	playerref.RemoveFromFaction(forcelevel05Faction)
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
	if(ostim.HasSceneMetadata("Ostim_Manual_Start"))
		return 
	endif
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
		float currentSecondActorForce = 0.0
		float currentThirdActorForce = 0.0

		secondActorInitialForce = StartPassiveDrain(secondActor, SecondActorForceBar)
		currentSecondActorForce = secondActorInitialForce

		if(thirdActor != None)
			thirdActorInitialForce = StartPassiveDrain(thirdActor, ThirdActorForcebar)
			currentThirdActorForce = thirdActorInitialForce
		endif		
		
		
		float cachedDrainModifier = PassiveDrainModifier
		While (ostim.animationRunning())
			Utility.Wait(1)
			if (DrainActive)
				currentSecondActorForce = PassiveDrainActor(secondActor, currentSecondActorForce, SecondActorForceBar, cachedDrainModifier)

				if(thirdActor != None)
					currentThirdActorForce = PassiveDrainActor(thirdActor, currentThirdActorForce, ThirdActorForceBar, cachedDrainModifier)
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
	secondActor.DispelSpell(SeductionSpell)
	if(thirdActor)
		thirdActor.DispelSpell(SeductionSpell)
	endif
	ResetActors()
	Utility.Wait(1)
	CalculateExpChanges()
	SendQueuedMessages()
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
	float initialForce = GetLifeForce(act)
	bar.SetPercent(initialForce / 100)
	SetBarVisible(bar, true)
	return initialForce
endFunction

float function PassiveDrainActor(Actor act, float initialForce, OSexBar actorForceBar, float cachedDrainModifier)	
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
	float passiveDrainAmount = (cachedDrainModifier * (victimComponent) * (playerComponent)) / 10000 

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
		AddExp(killExpValue) ; Only reward exp if within sweetest taste
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
		DrainSpell.Cast(playerref, act)
		;DrainSpell.RemoteCast(playerref, playerref, act)
		while(!act.IsDead())
			Utility.Wait(0.3)
		endWhile
		ostim.EndAnimation()
		return true
	Else
		AbsorbForce(amountToDrain)
		SetLifeForce(act,currentForce - ActiveDrainAmount)
		return false
	endif
	
endFunction

function AbsorbForce(float amount, bool ignoreLevelLimit = false)
	float absorbValue = amount
	DrainedForce += absorbValue
	if(!ignoreLevelLimit && playerRef.IsInFaction(forcelevel0Faction) && PlayerLifeForce + absorbValue > level1Limit)
		PlayerLifeForce = level1Limit
	else
		if(PlayerLifeForce + absorbValue > MaxPlayerLifeForce)
			float overDrain = MaxPlayerLifeForce - (PlayerLifeForce + absorbValue)
			AddExp(overdrainExpValue * overDrain)
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

			playerref.RemoveFromFaction(forcelevel05Faction)
			playerref.RemoveFromFaction(forcelevel1Faction)
			playerref.RemoveFromFaction(forcelevel2Faction)
			playerref.RemoveFromFaction(forcelevel3Faction)

			
			playerref.AddToFaction(forcelevel0Faction)
			TurnToCursedForm()
		endif
	elseif(PlayerLifeForce > level1Limit && PlayerLifeForce <= level15Limit)
		if(!playerref.IsInFaction(forcelevel05Faction))
			if playerRef.IsInFaction(forcelevel0Faction)
				notificationMessage = "I feel stronger, but still not my usual self"
			else
				notificationMessage = "I feel my strength fading, I must feed more"
			endif

			playerref.RemoveFromFaction(forcelevel0Faction)
			playerref.RemoveFromFaction(forcelevel1Faction)
			playerref.RemoveFromFaction(forcelevel2Faction)
			playerref.RemoveFromFaction(forcelevel3Faction)
			
			playerref.AddToFaction(forcelevel05Faction)
			TurnToTrueForm()
		endif
	elseif(PlayerLifeForce > level1Limit && PlayerLifeForce <= level2Limit)		
		if(!playerref.IsInFaction(forcelevel1Faction))
			if playerref.IsInFaction(forcelevel0Faction)
				notificationMessage = "I'm feeling normal again, I should feed more to gain more power"
			else	
				notificationMessage = "I don't feel Lilith's boon. I must kill more to attain her power"
			endif
			playerref.RemoveFromFaction(forcelevel0Faction)
			playerref.RemoveFromFaction(forcelevel05Faction)
			playerref.RemoveFromFaction(forcelevel2Faction)
			playerref.RemoveFromFaction(forcelevel3Faction)
			
			playerref.AddToFaction(forcelevel1Faction)
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
			playerref.RemoveFromFaction(forcelevel05Faction)
			playerref.RemoveFromFaction(forcelevel1Faction)
			playerref.RemoveFromFaction(forcelevel3Faction)
			
			playerref.AddToFaction(forcelevel2Faction)
			TurnToTrueForm()
		endif
	elseif(PlayerLifeForce > level3Limit)		
		if(!playerref.IsInFaction(forcelevel3Faction))
			if playerref.IsInFaction(forcelevel2Faction) || playerref.IsInFaction(forcelevel1Faction) || playerref.IsInFaction(forcelevel2Faction)
				notificationMessage = "This is what true power feels like!"
			endif
			playerref.RemoveFromFaction(forcelevel0Faction)
			playerref.RemoveFromFaction(forcelevel05Faction)
			playerref.RemoveFromFaction(forcelevel1Faction)
			playerref.RemoveFromFaction(forcelevel2Faction)
			
			playerref.AddToFaction(forcelevel3Faction)
			TurnToTrueForm()
		endif
	endif
	if(!silent)
		QueueNotification(notificationMessage)
	endif
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


function InfluenceActor(Actor act)
	if(InfluencedActors.Length == maxInfluencedActors)
		InfluencedActors[0].DispelSpell(InfluenceSpell)
		InfluencedActors = PapyrusUtil.RemoveActor(InfluencedActors, InfluencedActors[0])
	endif
	InfluencedActors = PapyrusUtil.PushActor(InfluencedActors, act)
endFunction

function UnInfluenceActor(Actor act)	
	InfluencedActors = PapyrusUtil.RemoveActor(InfluencedActors, act)
endFunction

;;;;;;;;;;
;;; UI ;;;
;;;;;;;;;;


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

function ShowPlayerForceBar()
	SetBarVisible(PlayerForceBar, true)
	Utility.Wait(5)
	SetBarVisible(PlayerForceBar, false)
endFunction

;;;;;;;;;;;;;;;;;;;
; TFC Integration ;
;;;;;;;;;;;;;;;;;;;

function TurnToCursedForm()
	if(!tfcIntegrated)
		return
	endif
	int handle  = ModEvent.Create("TFCForceTurnIntoForm")
	if(handle)
		ModEvent.PushInt(handle, tfcCurseFormId)
		ModEvent.Send(handle)
	endif	
endfunction

function TurnToTrueForm()
	if(!tfcIntegrated)
		return
	endif
	int handle  = ModEvent.Create("TFCTurnIntoTrueForm")
	if(handle)
		ModEvent.Send(handle)
	endif	
endFunction


;;;;;;;;;;;;;;;;;
;; Progression ;;
;;;;;;;;;;;;;;;;;

function AddExp(float exp)
	CurrentExp = CurrentExp + exp
endFunction

function AddExpAndCalculateChanges(float exp)
	CurrentExp = CurrentExp + exp
	CalculateExpChanges()
endFunction

function CalculateNextRequiredExp()	
	nextRequiredExp = nextRequiredExp + ( 45 * Math.Log(Math.Pow(SuccubusLevel.GetValue(), 2) + Math.Pow(playerref.GetLevel() * 5, 2)) )
endfunction

function CalculateExpChanges()
	
	while(CurrentExp > nextRequiredExp) ; Level Up	
		SuccubusLevelUpRatio.SetValue(1.0)			
		CalculateNextRequiredExp()
		SuccubusSavedLevels.SetValue(SuccubusSavedLevels.GetValue() + 1)
		UpdateCurrentInstanceGlobal(SuccubusSavedLevels)
		
		int selection = SaveOrSpendMessage.Show()
		if(selection == 0)
		else
			Utility.Wait(0.1)
			
			SpendPointsMCM.OpenMCM("Skill Points")
		endif		
		Utility.Wait(0.75)
	endWhile
	SuccubusLevelUpRatio.SetValue(CurrentExp / nextRequiredExp)
endFunction


;;;;;;;;;;;
;; Debug ;;
;;;;;;;;;;;

event OnKeyDown(int keycode)
	; if(ostim.AnimationRunning() || Utility.IsInMenuMode())
	; 	return
	; endif
	; if(keycode == 80)
	; 	AddExpAndCalculateChanges(100)
	; endif
endevent


;;;;;;;;;;;;;;;;;;;;;;
;; Message Queueing ;;
;;;;;;;;;;;;;;;;;;;;;;


function QueueNotification(string notification)
	if(ostim.AnimationRunning())
		messageQueue = PapyrusUtil.PushString(messageQueue, notification)
	else
		Debug.Notification(notification)
	endif
endFunction

function SendQueuedMessages()
	int i = 0
	while (i < messageQueue.Length)
		string val = messageQueue[i]
		if(val != "")
			Debug.Notification(val)
			Utility.Wait(0.5)
		endIf
		i = i + 1
	endWhile
	messageQueue = PapyrusUtil.StringArray(10)
endFunction
