Scriptname FARScoringKCD extends FARScoring  

; Scoring based on KCD rules

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

; Populate output variables based on what the roll scores, can used directly for AI
; logic, or indirectly via IsBust and ScoreSelection
Function ScoreStats(int[] rollsIn) ; override
    ; We mutate rolls in ScoreRun, create a copy to avoid touching the original
    int[] rolls = new int[6]
    FARArrayUtil.Copy(rollsIn, rolls)
    BestScore = 0
    BestDice = 0
    BestSelection = new bool[6]
    FewestScore = 0
    FewestDice = 9999 ; We want to minimise this
    FewestSelection = new bool[6]

    ; Try to score a run, which will be worth more, removing its dice
    ; from consideration if it's found
    ScoreRun(rolls, 1, 6, 1500, 1, 100) \
      || ScoreRun(rolls, 2, 6, 750, 5, 50) \
      || ScoreRun(rolls, 1, 5, 500, 1, 100)

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
                FARArrayUtil.SetMaskBits(rolls, FewestSelection, face, needed)
            endif

            BestScore += value
            BestDice += count
            FARArrayUtil.SetMaskBits(rolls, BestSelection, face, count)
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
bool Function ScoreRun(int[] rolls, int start, int end, int value, int loneFace, int loneValue)
    int i = start
    ; Debug.Trace("Check run " + start + " " + end)
    while i <= end
        if FARArrayUtil.Count(rolls, i) == 0
            ; We don't have a run
            ; Debug.Trace("No run " + start + " " + end + " missing " + i)
            return false
        endif
        i += 1
    endwhile

    ; Remove the used dice so that face scoring ignores them
    ; while still counting them as selected by assinging them > 6
    FARArrayUtil.SetMaskBits(rolls, FewestSelection, loneFace, 1)
    i = start
    while i <= end
        int idx = FARArrayUtil.ReplaceFirst(rolls, i, i + 10)
        BestSelection[idx] = true
        i += 1
    endwhile

    ; Score
    BestDice += (end - start) + 1
    BestScore = value
    ; A run always contains either a one or a five, so we can score that on its own
    FewestDice = 1
    FewestScore = loneValue
    ; Debug.Trace("Found run of len " + BestDice + " worth " + BestScore)
    return true
EndFunction