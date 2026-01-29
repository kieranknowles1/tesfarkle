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
    FARGameScript gameControl = GetOwningQuest() as FARGameScript
    ; Prevent us from going bust on the first throw
    NextRoll(forceNotBust = gameControl.RoundNumber <= 2)
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
    gameControl.LastRollScore = score
    return score
EndFunction

; The dialogue menu does not close until OnEnd fragments finish,
; so use an event to detach from that thread
string updateAction
Event OnUpdate()
    if updateAction == "Roll"
        int score = ScoreSelectedDice()
        if score > 0
            NextRoll(playScene = true)
        else
            FARSelectionInvalid.Show()
        endif
    elseif updateAction == "Pass"
        int score = ScoreSelectedDice()
        if score > 0
            EndTurn(roundScore)
        else
            FARSelectionInvalid.Show()
        endif
    endif
EndEvent

; Score current selection, then reroll
Function ScoreAndReroll()
    updateAction = "Roll"
    RegisterForSingleUpdate(0.0)
EndFunction

; Score current selection, then pass
Function ScoreAndPass()
    updateAction = "Pass"
    RegisterForSingleUpdate(0.0)
EndFunction

Function NextRoll(bool playScene = false, bool forceNotBust = false)
    if activeDice <= 0
        activeDice = 6
    endif
    FARGameScript gameControl = GetOwningQuest() as FARGameScript
    int[] rolls = RollDice(activeDice, forceNotBust = forceNotBust)
    gameControl.ShowRolls(rolls)
    
    FARScoring scoring = GetOwningQuest() as FARScoring
    if scoring.IsBust(rolls)
        EndTurn(0)
        return
    endif
    if playScene
        FARGameRollDice.Start()
    endif
EndFunction