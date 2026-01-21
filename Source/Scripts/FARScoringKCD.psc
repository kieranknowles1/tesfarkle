Scriptname FARScoringKCD extends Quest  

; Scoring based on KCD rules, implemented in its own script for easy extension
; to multiple rulesets.

; This is not thread safe, as there's no good way to return multiple values from a
; function which the AI implementation relies on. Call a function then read the below
; properties for the "return" value

; What's the highest amount we can score, and with how many dice?
int Property BestScore Auto
int Property BestDice Auto

; What's the best we can score, while using as few dice as possible?
; I.e., prioritise one -> five -> three of a kind
int Property FewestScore Auto
int Property FewestDice Auto

; What is the chance of busting given a specific number of dice are rolled
; in the range 0..1. Used by AI to calculate risk of rerolling
float Function GetBustChance(int dice)
    ; See analysis.py for combinatorial analysis behind these values
    ; Calculating in Papyrus would be slow and add unnecessary complexity
    if dice == 1
        return 0.667
    elseif dice == 2
        return 0.444
    elseif dice == 3
        return 0.278
    elseif dice == 4
        return 0.157
    elseif dice == 5
        return 0.077
    elseif dice == 6
        return 0.031
    else
        Debug.Trace("More than 6 dice is not supported")
    endif
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

; Populate output variables based on what the roll scores, can used directly for AI
; logic, or indirectly via IsBust and ScoreSelection
Function ScoreStats(int[] rolls)
    BestScore = 0
    BestDice = 0
    FewestScore = 0
    FewestDice = 9999 ; We want to minimise this

    ; Try to score a run, which will be worth more, removing its dice
    ; from consideration if it's found
    ScoreRun(rolls, 1, 6, 1500, 100) \
      || ScoreRun(rolls, 2, 6, 750, 50) \
      || ScoreRun(rolls, 1, 5, 500, 100)

    ; Score three of kind, ones, and fives
    ; Any dice participating in a run are already blanked out
    int face = 1
    while face <= 6
        int count = FARArrayUtil.Count(rolls, face)
        int value = FaceValue(face, count)
        ; Debug.Trace("Check face " + face + " " + count + " worth " + value)
        if value > 0
            ; Debug.Trace("Score face " + face)
            int needed
            if face == 1 || face == 5
                needed = 1
            else
                needed = 3
            endif

            ; Score as few as possible while getting as many points as possible
            if needed < FewestDice || (needed == FewestDice && (FaceValue(face, needed) > FewestScore))
                FewestDice = needed
                FewestScore = FaceValue(face, needed)
            endif

            BestScore += value
            BestDice += count
        endif

        face += 1
    endwhile

    ; Debug.Trace("scores " + BestScore + " " + BestDice + " " + FewestScore + " " + FewestDice)
EndFunction

; Convention - `used` dice are replaced with their negative to track their values
; and let other function skip them

; Private functions

int Function FaceValue(int face, int count)
    if count >= 3
        ; 3 or more of a kind worth
        ; face * 100, *2 for 4, *4 for 5, *8 for 6
        ; except for 3 ones which are worth 1000
        int base = 100 * face
        if face == 1
            base = 1000
        endif
        int mult = Math.pow(2, count - 3) as int
        return base * mult
    endif

    ; Lone ones/fives
    ; 100 points per one, 50 per five
    int loneValue
    if face == 1
        loneValue = 100
    elseif face == 5
        loneValue = 50
    endif

    if loneValue > 0
        return loneValue * count
    endif
    return 0 ; No score from this face
EndFunction


; Score a run of start..end, if it is present, and remove
; the relavent dice
bool Function ScoreRun(int[] rolls, int start, int end, int value, int loneValue)
    int i = start
    while i <= end
        if FARArrayUtil.Count(rolls, i) == 0
            ; We don't have a run
            ; Debug.Trace("No run " + start + " " + end)
            return false
        endif
        i += 1
    endwhile

    ; Remove the used dice so that face scoring ignores them
    i = start
    while i <= end
        FARArrayUtil.ReplaceFirst(rolls, i, -i)
        i += 1
    endwhile

    ; Score
    BestDice += (end - start) + 1
    BestScore = value
    ; A run always contains either a one or a five, so we can score that on its own
    FewestDice = 1
    FewestScore = loneValue
    return true
EndFunction