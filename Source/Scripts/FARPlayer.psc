Scriptname FARPlayer extends ReferenceAlias

; Interface for both human and AI players
; See FARHumanPlayer and FARAiPlayer for implementation

Function OnTurnBegin()
    Debug.Trace("Abstract function called")
EndFunction

Function EndTurn(int score)
    (GetOwningQuest() as FARGameScript).EndRound(score)
EndFunction