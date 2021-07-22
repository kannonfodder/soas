ScriptName SoaS_SceneStarter extends Quest

bool sceneStarting = false
Actor property playerRef auto
Actor target1 
Actor target2
float startDistance = 150.0
int mode 

function StartSceneProximity(Actor target)
    if(!SetupTarget(target))
        return 
    endIf
    if(sceneStarting == false)
        mode = 0
        RegisterForSingleUpdate(3.0)
        sceneStarting = true
    endif
endFunction

bool function SetupTarget(Actor target)
    if(target == target1 || target == target2)
        return false
    endif
    
    if(target1 == none)
        target1 = target
        return true
    elseif (target2 == none)
        target2 = target
        return true
    endif
    return false
endFunction

event onUpdate()
    if(mode == 0)    
        if (target1 && playerRef.GetDistance(target1) > startDistance || (target2 && playerRef.GetDistance(target2) > startDistance))
            MiscUtil.PrintConsole( target1.GetDisplayName() + " is " + playerRef.GetDistance(target1) + " from player")
            if(target2)
                MiscUtil.PrintConsole( target2.GetDisplayName() + " is " + playerRef.GetDistance(target1) + " from player")
            endif
            RegisterForSingleUpdate(1)
            return
        endif
    endif

    OsexIntegrationMain ostim = game.GetFormFromFile(0x000801, "Ostim.esp") as OsexIntegrationMain	
    if(target1 != none)
        if(target2 != none)
            ostim.StartScene(playerRef, target1, zThirdActor = target2)
        else
            ostim.StartScene(playerRef, target1)
        endif
        
    endif
    ;cleanup
    sceneStarting = false
    target1 = none
    target2 = none
endEvent

