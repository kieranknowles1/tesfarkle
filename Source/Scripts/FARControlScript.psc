Scriptname FARControlScript extends Quest  

Keyword Property FARStartup Auto

Function StartGame(Actor opponent, int bet)
    Debug.Notification(opponent)
    bool ok = FARStartup.SendStoryEventAndWait(akRef1=opponent, aiValue1=bet)
    if ok
        Debug.Notification("Started")
    else
        Debug.Notification("Error")
    endif
EndFunction