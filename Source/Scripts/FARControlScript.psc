Scriptname FARControlScript extends Quest  

Keyword Property FARStartup Auto

Function StartGame(Actor opponent, int bet, int targetScore)
    bool ok = FARStartup.SendStoryEventAndWait(akRef1=opponent, aiValue1=bet, aiValue2=targetScore)
    if !ok
        Debug.TraceStack("Failed to start quest")
    endif
EndFunction