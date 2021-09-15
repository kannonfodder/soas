Scriptname SoaS_Seductionmagicfx extends ActiveMagicEffect

Actor property playerRef auto
Package property FollowPlayer auto
SoaS_SceneStarter property SceneStarter auto

int originalRelationshipRank = 0

Event OnEffectStart(Actor target, Actor Caster)
    if(target.IsDead())
        Dispel()
        return
    endif
    if(!SceneStarter.CanSeduceMore())
        Dispel()
        return
    endif
    
    originalRelationshipRank = target.GetRelationshipRank(playerRef)
    target.SetRelationshipRank(playerRef, 3)
    ActorUtil.AddPackageOverride(target, FollowPlayer)
    target.EvaluatePackage()
    SceneStarter.StartSceneProximity(target)
endEvent

Event OnEffectFinish(Actor target, Actor Caster)

    target.SetRelationshipRank(playerRef, originalRelationshipRank - 1)
    ActorUtil.RemovePackageOverride(target, FollowPlayer)
    target.EvaluatePackage()
endEvent