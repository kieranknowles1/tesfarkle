Scriptname FARControlScript extends Quest  

Keyword Property FARStartup Auto

Function StartGame(Actor opponent, int bet)
    bool ok = FARStartup.SendStoryEventAndWait(akRef1=opponent, aiValue1=bet)
    if !ok
        Debug.Trace("Failed to start quest")
    endif
EndFunction