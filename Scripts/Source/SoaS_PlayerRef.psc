Scriptname SoaS_PlayerRef extends ReferenceAlias

SoaS_Core Property Core auto
SoaS_UI Property SoaSUI auto

Event OnPlayerLoadGame()
    Core.Maintenance()
    SoaSUI.Maintenance()
endEvent