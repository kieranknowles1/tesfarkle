Scriptname FARHumanPlayer extends FARPlayer  

Message Property FARSelectionInvalid Auto
ReferenceAlias Property PlayerChair Auto

Event OnSit(ObjectReference akFurniture)
    if akFurniture == PlayerChair.GetReference()
        (GetOwningQuest() as FARGameScript).PlayerReady()
    endif
EndEvent

Event OnLocationChange(Location akOldLoc, Location akNewLoc)
    (GetOwningQuest() as FARGameScript).Resign()
EndEvent

int activeDice
int roundScore
Function OnTurnBegin()
    activeDice = 6
    roundScore = 0
    Debug.Trace("Player turn begin")
    NextRoll()
EndFunction

; Score current selection, then reroll
Function ScoreAndReroll()
    FARGameScript gameControl = GetOwningQuest() as FARGameScript
    int score = gameControl.ScoreDice(none)
    if score > 0
        roundScore += score
        NextRoll()
    else
        FARSelectionInvalid.Show()
    endif

EndFunction

; Score current selection, then pass
Function ScoreAndPass()
    FARGameScript gameControl = GetOwningQuest() as FARGameScript
    int score = gameControl.ScoreDice(none)
    if score > 0
        roundScore += score
        EndTurn(roundScore)
    else
        FARSelectionInvalid.Show()
    endif
EndFunction

Function NextRoll()
    FARGameScript gameControl = GetOwningQuest() as FARGameScript
    int[] rolls = RollDice(activeDice)
    gameControl.ShowRolls(rolls)
EndFunction