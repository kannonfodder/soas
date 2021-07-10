ScriptName SoaS_SceneStarter extends Quest

bool sceneStarting = false
Actor property playerRef auto
Actor target1 
Actor target2

function StartSceneDelay(Actor target)
    if(target1 == none)
        target1 = target
    elseif (target2 == none)
        target2 = target
    endif

    if(sceneStarting == false)
        RegisterForSingleUpdate(3.0)
        sceneStarting = true
    endif
endfunction

event onUpdate()
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

