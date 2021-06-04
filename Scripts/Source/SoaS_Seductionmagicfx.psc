Scriptname SoaS_Seductionmagicfx extends ActiveMagicEffect

Actor property playerRef auto
Faction property SeducedFaction auto
Package property FollowPlayer auto
SoaS_SceneStarter property SceneStarter auto

int originalRelationshipRank = 0

Event OnEffectStart(Actor target, Actor Caster)
    if(target.IsDead())
        return
    endif
    originalRelationshipRank = target.GetRelationshipRank(playerRef)
    target.SetRelationshipRank(playerRef, 3)
    target.AddToFaction(SeducedFaction)
    ActorUtil.AddPackageOverride(target, FollowPlayer)
    target.EvaluatePackage()
    SceneStarter.StartSceneProximity(target)
endEvent

Event OnEffectFinish(Actor target, Actor Caster)

    target.RemoveFromFaction(SeducedFaction)
    target.SetRelationshipRank(playerRef,originalRelationshipRank)
    ActorUtil.RemovePackageOverride(target, FollowPlayer)
    target.EvaluatePackage()
endEvent