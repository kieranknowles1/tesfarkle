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