Scriptname FARHumanPlayer extends FARPlayer  

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
Function OnTurnBegin()
    Debug.Trace("Player turn begin")
    activeDice = 6
    NextRoll()
EndFunction

Function NextRoll()
    FARGameScript gameControl = GetOwningQuest() as FARGameScript
    int[] rolls = RollDice(activeDice)
    gameControl.ShowRolls(rolls)
EndFunction