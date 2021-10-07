Scriptname SoaS_Seductionmagicfx extends ActiveMagicEffect

import po3_SKSEFunctions

Actor property playerRef auto
Package property FollowPlayer auto
SoaS_SceneStarter property SceneStarter auto

GlobalVariable property SuccubusLevel auto
Perk property AutoSucceedSeduce auto
Faction property PlayerFaction auto

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
            Debug.Notification(target.GetDisplayName() + " resisted your seduction")
            Dispel()
            return
        endif
    endIf
    success = true
    target.AddToFaction(PlayerFaction)
    originalRelationshipRank = target.GetRelationshipRank(playerRef)
    actor[] allies = GetCombatAllies(playerRef)
    int i = 0    
    while(i < allies.length)
        allies[i].SetRelationshipRank(target,3)
        allies[i].StopCombat()
        i += 1
    endWhile
    target.SetRelationshipRank(playerRef, 3)
    ActorUtil.AddPackageOverride(target, FollowPlayer)
    target.EvaluatePackage()
    SceneStarter.StartSceneProximity(target)
endEvent

Event OnEffectFinish(Actor target, Actor Caster)
    if (success == true)
        target.RemoveFromFaction(PlayerFaction)
        target.SetRelationshipRank(playerRef, originalRelationshipRank - 1)
        ActorUtil.RemovePackageOverride(target, FollowPlayer)
        target.EvaluatePackage()

        actor[] allies = GetCombatAllies(playerRef)
        int i = 0    
        while(i < allies.length)
            allies[i].SetRelationshipRank(target,0)
            i += 1
        endWhile
    endif    
endEvent