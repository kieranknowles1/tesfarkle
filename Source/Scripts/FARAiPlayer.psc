Scriptname FARAiPlayer extends FARPlayer

; NPC player implementation. Ported from `farkle.py/AiPlayer`

; AI parameters - determines what kind of risks we'll take
float Property RerollRiskBase = 500.0 Auto
float Property RerollRiskExponent = 0.75 Auto

; How likely are we to take everything then reroll
float Property TakeAllBase = 500.0 Auto
float Property TakeAllExponent = 2.0 Auto

Function OnTurnBegin()
    FARGameScript gameState = GetOwningQuest() as FARGameScript
    FARScoringKCD scoring = GetOwningQuest() as FARScoringKCD

    int activeDice = 6
    RoundScore = 0

    bool rolling = true
    while rolling
        if activeDice == 0 ; Start again with a full hand after a full house
            activeDice = 6
        endif
        ; TODO: Display rolls
        int[] rolls = RollDice(activeDice)
        if scoring.IsBust(rolls)
            Debug.Trace("Bust!")
            EndTurn(0)
            return
        endif

        ; Populate vars for deciding what to do
        scoring.ScoreStats(rolls)

        rolling = WillRoll(activeDice)

        ; If we have a full house, are going to stop rolling, or "choose to", take
        ; everything we can
        ; TODO: Display selection
        int handScore
        if !rolling || WillTakeAll(activeDice)
            handScore = scoring.BestScore
            activeDice -= scoring.BestDice
            Debug.Trace("Take it all " + handScore)
        else
            handScore = scoring.FewestScore
            activeDice -= scoring.FewestDice
            Debug.Trace("Take as little as possible " + handScore)
        endif
        RoundScore += handScore
    endwhile

     Debug.Trace("Bank")
     EndTurn(RoundScore)
EndFunction

; Do we want to roll again, considering our current position and latest roll?
bool Function WillRoll(int activeDice)
    FARGameScript gameState = GetOwningQuest() as FARGameScript
    FARScoringKCD scoring = GetOwningQuest() as FARScoringKCD
    
    ; Always roll at least once
    if RoundScore == 0
        Debug.Trace("Haven't rolled yet")
        return true
    endif

    ; We've won, no need to roll again
    if RoundScore + TotalScore >= gameState.TargetScore
        Debug.Trace("I won!")
        return false
    endif

    int potential = RoundScore + scoring.BestScore
    ; Modify risk of going bust based on our current score
    float riskMult = (potential as float) / RerollRiskBase

    int nextRollDice = activeDice - scoring.BestDice
    if nextRollDice == 0
        nextRollDice = 6
    endif

    float risk = scoring.GetBustChance(nextRollDice)

    float rerollChance = Math.pow(1.0 - (riskMult * risk), RerollRiskExponent)
    Debug.Trace("Thinking about reroll " + rerollChance)
    return Utility.RandomFloat(0.0, 1.0) < rerollChance
EndFunction

bool Function WillTakeAll(int activeDice)
    FARGameScript gameState = GetOwningQuest() as FARGameScript
    FARScoringKCD scoring = GetOwningQuest() as FARScoringKCD
    
    int scoreIfTaken = TotalScore + RoundScore + scoring.BestScore
    ; If we'd win, take it
    if scoreIfTaken >= gameState.TargetScore
        return true
    endif

    ; If we have a full house, take it
    if scoring.BestDice >= activeDice
        return true
    endif

    float chance = Math.pow(scoring.BestScore / TakeAllBase, TakeAllExponent)
    return Utility.RandomFloat(0.0, 1.0) < chance
EndFunction