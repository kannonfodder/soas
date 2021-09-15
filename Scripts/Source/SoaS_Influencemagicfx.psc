Scriptname SoaS_Influencemagicfx extends ActiveMagicEffect

Actor property playerRef auto
Faction property InfluencedFaction auto
SoaS_Core property Core auto

int originalRelationshipRank = 0

Event OnEffectStart(Actor target, Actor Caster)    
    if(target.IsInFaction(InfluencedFaction))
        return
    endif
    Debug.Notification(target.GetDisplayName() + " now thinks better of you")
    int newRank = target.GetRelationshipRank(playerRef) + 1
    PrintRank(newRank, target)
    target.SetRelationshipRank(playerRef, newRank)
    Core.InfluenceActor(target)
    target.AddtoFaction(InfluencedFaction)
EndEvent

Event OnEffectFinish(Actor target, Actor Caster)
    Debug.Notification(target.GetDisplayName() +" remembers your influence and likes you less now")
    int newRank = (target.GetRelationshipRank(playerRef) - 2)
    PrintRank(newRank, target)
    target.SetRelationshipRank(playerRef, newRank)
    Core.UnInfluenceActor(target)
    target.RemoveFromFaction(InfluencedFaction)
endEvent

Function PrintRank(int rank, Actor target)
    MiscUtil.PrintConsole("SoaS: Target " + target.GetDisplayName() + " now has relationship rank " + rank)
endFunction