Scriptname FARHangryEndHandler extends FAREndGameHandler

Actor Property PlayerRef Auto
LeveledItem Property FARHangrySnacks Auto

Function OnGameEnd(FARPlayer winner)
    if winner.GetReference() == PlayerRef
        winner.GetReference().AddItem(FARHangrySnacks)
    endif
EndFunction