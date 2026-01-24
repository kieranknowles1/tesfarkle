Scriptname FARHumanPlayer extends FARPlayer  

Message Property FARSelectionInvalid Auto
ReferenceAlias Property PlayerChair Auto

Event OnSit(ObjectReference akFurniture)
    if akFurniture == PlayerChair.GetReference()
        (GetOwningQuest() as FARGameScript).PlayerReady()
    endif
EndEvent

; Abort game if player walks away
Event OnLocationChange(Location akOldLoc, Location akNewLoc)
    (GetOwningQuest() as FARGameScript).Resign()
EndEvent

int activeDice
Function OnTurnBegin() ; Override
    activeDice = 6
    roundScore = 0
    ; Debug.Trace("Player turn begin")
    NextRoll()
EndFunction

; Score all selected dice, then add to round score
int Function ScoreSelectedDice()
    FARGameScript gameControl = GetOwningQuest() as FARGameScript
    FARScoring scoring = GetOwningQuest() as FARScoring

    FARTableScript table = gameControl.Table.GetReference() as FARTableScript
    int[] selection = table.GetSelection()
    int score = scoring.ScoreSelection(selection)

    if score > 0
        roundScore += score
        activeDice -= scoring.BestDice
    endif
    gameControl.SelectionValid = score > 0
    return score
EndFunction

; Score current selection, then reroll
Function ScoreAndReroll()
    int score = ScoreSelectedDice()
    if score > 0
        NextRoll()
    else
        FARSelectionInvalid.Show()
    endif

EndFunction

; Score current selection, then pass
Function ScoreAndPass()
    int score = ScoreSelectedDice()
    if score > 0
        EndTurn(roundScore)
    else
        FARSelectionInvalid.Show()
    endif
EndFunction

Function NextRoll()
    if activeDice <= 0
        activeDice = 6
    endif
    FARGameScript gameControl = GetOwningQuest() as FARGameScript
    int[] rolls = RollDice(activeDice)
    gameControl.ShowRolls(rolls)
    
    FARScoring scoring = GetOwningQuest() as FARScoring
    if scoring.IsBust(rolls)
        EndTurn(0)
    endif
EndFunction