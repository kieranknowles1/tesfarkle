Scriptname FARGameScript extends Quest  

int Property Bet Auto
MiscObject Property Gold001 Auto

Event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akRef1, ObjectReference akRef2, int aiValue1, int aiValue2)
    Debug.Notification("Start Game")
    bet = aiValue1

    ; "Sit down"
    SetObjectiveDisplayed(0, true)
EndEvent

Function PlayerReady()
    Actor player = Game.GetPlayer()
    if player.GetItemCount(Gold001) < bet
        ; TODO: If player no longer has gold, NPC should complain and refuse to continue
        return
    endif
    player.RemoveItem(Gold001, bet)

    SetObjectiveCompleted(0, true)

    ; TODO: Start game, flip coin, place bets
EndFunction

Function Resign()
    if IsObjectiveDisplayed(0) && !IsObjectiveCompleted(0)
        SetObjectiveFailed(0, true)
    endif

    Stop()
    ; TODO: Fail the quest
EndFunction