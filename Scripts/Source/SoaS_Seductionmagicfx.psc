Scriptname SoaS_Seductionmagicfx extends ActiveMagicEffect

Actor property playerRef auto
Package property FollowPlayer auto
SoaS_SceneStarter property SceneStarter auto

GlobalVariable property SuccubusLevel auto
Perk property AutoSucceedSeduce auto

int originalRelationshipRank = 0
bool success = false

Event OnEffectStart(Actor target, Actor Caster)
    if(target.IsDead())
        Dispel()
        return
    endif
    if(!SceneStarter.CanSeduceMore())
        Dispel()
        return
    endif

    
    if(!playerRef.HasPerk(AutoSucceedSeduce))
        if((playerRef.GetLevel() / target.GetLevel()) + (SuccubusLevel.GetValueInt() / 20) + Utility.RandomFloat(-2, 2) < 0)
            Debug.Notification(target.GetDisplayName() + "resisted your seduction")
            Dispel()
            return
        endif
    endIf
    success = true
    originalRelationshipRank = target.GetRelationshipRank(playerRef)
    target.SetRelationshipRank(playerRef, 3)
    ActorUtil.AddPackageOverride(target, FollowPlayer)
    target.EvaluatePackage()
    SceneStarter.StartSceneProximity(target)
endEvent

Event OnEffectFinish(Actor target, Actor Caster)
    if (success == false)
        target.SetRelationshipRank(playerRef, originalRelationshipRank - 1)
    endif    
    ActorUtil.RemovePackageOverride(target, FollowPlayer)
    target.EvaluatePackage()
endEvent