Scriptname FARGameScript extends Quest  

int Property Bet Auto
MiscObject Property Gold001 Auto

ReferenceAlias Property Table Auto

Message Property FARHeadsPlayerFirst Auto
Message Property FARTailsOpponentFirst Auto

Event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akRef1, ObjectReference akRef2, int aiValue1, int aiValue2)
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
    
    StartGame()
EndFunction

Function StartGame()
    Actor player = Game.GetPlayer()
    SetObjectiveCompleted(0, true)
    player.RemoveItem(Gold001, bet)
    
    FARTableScript tableRef = Table.GetReference() as FARTableScript
    
    bool heads = Utility.RandomInt(0, 1) == 1
    if heads
        FARHeadsPlayerFirst.Show()
    else 
        FARTailsOpponentFirst.Show()
    endif
    tableRef.SpawnDecor(heads)
EndFunction

Function Resign()
    if IsObjectiveDisplayed(0) && !IsObjectiveCompleted(0)
        SetObjectiveFailed(0, true)
    endif

    Stop()
    ; TODO: Fail the quest
EndFunction