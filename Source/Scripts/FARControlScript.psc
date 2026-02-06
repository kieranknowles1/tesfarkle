Scriptname FARControlScript extends Quest  

Keyword Property FARStartup Auto

ReferenceAlias Property EndGameCallback Auto

Function StartGame(Actor opponent, int bet, int targetScore, FAREndGameHandler endCallback = none)
    bool ok = FARStartup.SendStoryEventAndWait(akRef1=opponent, aiValue1=bet, aiValue2=targetScore)
    if !ok
        Debug.TraceStack("Failed to start quest")
    endif
    EndGameCallback.ForceRefTo(endCallback)
EndFunction