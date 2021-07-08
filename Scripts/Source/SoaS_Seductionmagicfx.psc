Scriptname SoaS_Seductionmagicfx extends ActiveMagicEffect

Actor property playerRef auto
Faction property SeducedFaction auto
Package property FollowPlayer auto

Event OnEffectStart(Actor target, Actor Caster)
    target.AddToFaction(SeducedFaction)
    ActorUtil.AddPackageOverride(target, FollowPlayer)
    target.EvaluatePackage()
	RegisterForSingleUpdate(3.0)
endEvent

event onUpdate() 
    Actor target = GetTargetActor()   
    if(target.GetDistance(playerRef) < 256)
        OsexIntegrationMain ostim = game.GetFormFromFile(0x000801, "Ostim.esp") as OsexIntegrationMain	
        ostim.StartScene(playerRef, target)
    endif
endevent

Event OnEffectFinish(Actor target, Actor Caster)

    target.RemoveFromFaction(SeducedFaction)
    ActorUtil.RemovePackageOverride(target, FollowPlayer)
    target.EvaluatePackage()
endEvent