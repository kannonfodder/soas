Scriptname SoaS_Seductionmagicfx extends ActiveMagicEffect

Actor property playerRef auto
Faction property SeducedFaction auto
Package property FollowPlayer auto
SoaS_SceneStarter property SceneStarter auto

Event OnEffectStart(Actor target, Actor Caster)
    if(target.IsDead())
        return
    endif
    target.AddToFaction(SeducedFaction)
    ActorUtil.AddPackageOverride(target, FollowPlayer)
    target.EvaluatePackage()
    SceneStarter.StartSceneDelay(target)
endEvent

Event OnEffectFinish(Actor target, Actor Caster)

    target.RemoveFromFaction(SeducedFaction)
    ActorUtil.RemovePackageOverride(target, FollowPlayer)
    target.EvaluatePackage()
endEvent