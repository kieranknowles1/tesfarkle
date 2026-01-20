Scriptname FARPlayer extends ReferenceAlias

; Interface for both human and AI players
; See FARHumanPlayer and FARAiPlayer for implementation

Function OnTurnBegin()
    Debug.Trace("Abstract function called")
EndFunction

Function EndTurn(int score)
    (GetOwningQuest() as FARGameScript).EndRound(score)
EndFunction

int[] Function RollDice(int count)
    int[] results = new int[6] ; Array length must be a compile-time constant. WTF

    int i = 0
    while i < count
        results[i] = Utility.RandomInt(1, 6)
        i += 1
    endwhile
    return results
EndFunction