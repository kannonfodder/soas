Scriptname SoaS_Enable extends ActiveMagicEffect
{Enables SoaS on the player}
SoaS_Core property core auto

event OnEffectStart(Actor akTarget, Actor akCaster)
    if(akTarget == Game.GetPlayer())
        core.Register()
        Debug.Notification("You feel the power of Lilith course through you")
    endif
endEvent

