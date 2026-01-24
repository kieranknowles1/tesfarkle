Scriptname FARScoring extends Quest

; Base class for a score system, allowing for easy extension to multiple rulesets

; This is not thread safe, as there's no good way to return multiple values from a
; function which the AI implementation relies on. Call a function then read the below
; properties for the "return" value

; Output parameters for scoring

; What's the highest amount we can score, and with how many dice?
int Property BestScore Auto
int Property BestDice Auto
; Mask of which dice are selected, used to give feedback on AI behaviour
bool[] Property BestSelection Auto

; What's the best we can score, while using as few dice as possible?
; I.e., prioritise one -> five -> three of a kind
int Property FewestScore Auto
int Property FewestDice Auto
bool[] Property FewestSelection Auto

Function ScoreStats(int[] rolls)
    Debug.TraceStack("Abstract function called")
EndFunction

float Function GetBustChance(int dice)
    Debug.TraceStack("Abstract function called")
EndFunction

bool Function IsBust(int[] rolls)
    ScoreStats(rolls)
    return BestScore == 0
EndFunction

; Get the score of a selection, or zero if one or more dice are not consumed
; in scoring
; Any entries <= 0 are considered not selected
int Function ScoreSelection(int[] selected)
    ScoreStats(selected)
    ; Array lengths are compile time!!!
    int selectedDice = FARArrayUtil.CountGreaterThan(selected, 0)
    ; Debug.Trace(selectedDice + " of " + BestDice + " used")

    if BestDice == selectedDice
        return BestScore
    else
        ; Not all dice were used
        return 0
    endif
EndFunction