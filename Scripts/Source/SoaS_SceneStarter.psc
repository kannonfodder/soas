ScriptName SoaS_SceneStarter extends Quest

bool sceneStarting = false
Actor property playerRef auto
Actor target1 
Actor target2
float startDistance = 150.0
int mode ;0 = startup 1 = scene started
int startAttemptCounter = 0

function StartSceneProximity(Actor target)
    if(!SetupTarget(target))
        return 
    endIf
    if(sceneStarting == false)
        mode = 0
        RegisterForSingleUpdate(3.0)
        sceneStarting = true
        startAttemptCounter = 0
    endif
endFunction

bool function CanSeduceMore()
    return target1 == none || target2 == none
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
        if(startAttemptCounter > 90)
            cleanUp()
            MiscUtil.PrintConsole("SoaS: Scene start failed aborting")
            return
        elseif (target1 && playerRef.GetDistance(target1) > startDistance || (target2 && playerRef.GetDistance(target2) > startDistance))
            RegisterForSingleUpdate(1)
            startAttemptCounter += 1
            return
        endif
    endif

    OsexIntegrationMain ostim = game.GetFormFromFile(0x000801, "Ostim.esp") as OsexIntegrationMain	
    if(target1 != none)
        if(target2 != none)
            ostim.StartScene(playerRef, target1, zThirdActor = target2)
            ostim.AddSceneMetadata("SoaS")
        else
            ostim.StartScene(playerRef, target1)
            ostim.AddSceneMetadata("SoaS")
        endif
        
    endif
    cleanUp()
endEvent

function cleanUp()
    sceneStarting = false
    target1 = none
    target2 = none
endFunction

