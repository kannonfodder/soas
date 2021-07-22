Scriptname SoaS_Disable extends ActiveMagicEffect
{Enables SoaS on the player}
SoaS_Core property core auto

event OnEffectStart(Actor akTarget, Actor akCaster)
    if(akTarget == Game.GetPlayer())
        core.DisableMod()
        Debug.Notification("You feel Lilith's power, and curse, lift from you")
    endif
endEvent

