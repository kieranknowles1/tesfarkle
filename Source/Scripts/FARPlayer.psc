Scriptname FARPlayer extends ReferenceAlias

; Interface for both human and AI players
; See FARHumanPlayer and FARAiPlayer for implementation

; How many points has this player scored in the current round?
; Reset before turn begins
int Property RoundScore Auto
; How many points has this player banked in total?
; Reset at game begin
int Property TotalScore Auto

Scene Property FARGameRollDice Auto

; Abstract event, called by FARGameScript when the other player ends their turn
Function OnTurnBegin()
    Debug.TraceStack("Abstract function called")
EndFunction

; Finish this player's turn and bank points, if we didn't go bust
; A score of 0 is considered bust
Function EndTurn(int score)
    TotalScore += score
    (GetOwningQuest() as FARGameScript).EndRound(score)
    RoundScore = 0
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