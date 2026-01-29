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
    FARScoring scoring = GetOwningQuest() as FARScoring
    FARTableScript table = gameState.Table.GetReference() as FARTableScript

    int activeDice = 6
    RoundScore = 0

    bool rolling = true
    while rolling
        if activeDice == 0 ; Start again with a full hand after a full house
            activeDice = 6
        endif
        int[] rolls = RollDice(activeDice)
        ; Populate vars for deciding what to do
        scoring.ScoreStats(rolls)
        
        ; Forbid the AI from winning on the first round of the game if the player
        ; hasn't rolled yet by forcing a bust
        if gameState.RoundNumber == 1 && HasWon()
            rolls = RollBust(activeDice)
        endif
        
        table.ShowDice(rolls)
        if scoring.IsBust(rolls)
            ; Debug.Trace("Bust!")
            EndTurn(0)
            return
        endif
        FARGameRollDice.Start()


        rolling = WillReroll(activeDice)

        ; Think for a moment before selecting
        Utility.Wait(Utility.RandomFloat(1.0, 2.0))

        ; If we have a full house, are going to stop rolling, or "choose to", take
        ; everything we can
        int handScore
        if !rolling || WillTakeAll(activeDice)
            table.ShowSelection(scoring.BestSelection)
            handScore = scoring.BestScore
            activeDice -= scoring.BestDice
            ; Debug.Trace("Take it all " + handScore)
        else
            table.ShowSelection(scoring.FewestSelection)
            handScore = scoring.FewestScore
            activeDice -= scoring.FewestDice
            ; Debug.Trace("Take as little as possible " + handScore)
        endif
        ; Let the player see the AI's selection
        Utility.Wait(Utility.RandomFloat(1.25, 1.5))
        RoundScore += handScore
        gameState.LastRollScore = handScore
    endwhile

    ; Debug.Trace("Bank")
    EndTurn(RoundScore)
EndFunction

; Will we win immediatly with our latest roll?
bool Function HasWon()
    FARGameScript gameState = GetOwningQuest() as FARGameScript
    FARScoring scoring = GetOwningQuest() as FARScoring

    return RoundScore + TotalScore + scoring.BestScore >= gameState.TargetScore
EndFunction

; Do we want to roll again, considering our current position and latest roll?
bool Function WillReroll(int activeDice)
    FARGameScript gameState = GetOwningQuest() as FARGameScript
    FARScoring scoring = GetOwningQuest() as FARScoring

    ; We've won, no need to roll again
    if HasWon()
        ; Debug.Trace("I won!")
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
    ; Debug.Trace("Thinking about reroll " + rerollChance)
    return Utility.RandomFloat(0.0, 1.0) < rerollChance
EndFunction

bool Function WillTakeAll(int activeDice)
    FARGameScript gameState = GetOwningQuest() as FARGameScript
    FARScoring scoring = GetOwningQuest() as FARScoring
    
    ; If we'd win, take it
    if HasWon()
        return true
    endif

    ; If we have a full house, take it
    if scoring.BestDice >= activeDice
        return true
    endif

    float chance = Math.pow(scoring.BestScore / TakeAllBase, TakeAllExponent)
    return Utility.RandomFloat(0.0, 1.0) < chance
EndFunction