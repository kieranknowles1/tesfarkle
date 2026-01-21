Scriptname FARGameScript extends Quest Conditional

int Property Bet Auto
int Property TargetScore Auto
MiscObject Property Gold001 Auto

ReferenceAlias Property Table Auto
FARPlayer Property Player Auto
FARPlayer Property Opponent Auto

Message Property FARHeadsPlayerFirst Auto
Message Property FARTailsOpponentFirst Auto
Message Property FARTurnStart Auto
Message Property FARGameWon Auto

Message Property FARPlayerBust Auto
Message Property FARPlayerScored Auto
Message Property FARGameState Auto

; Used to condition dialogue based on whos turn it is
bool Property PlayerTurnActive = false Auto Conditional

ReferenceAlias Property CurrentPlayerAlias Auto ; Used for messages
bool gameActive = false
FARPlayer currentPlayer ; Tracking who's turn it is
FARPlayer nextPlayer

Event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akRef1, ObjectReference akRef2, int aiValue1, int aiValue2)
    bet = aiValue1

    ; "Sit down"
    SetObjectiveDisplayed(0, true)
EndEvent

Function PlayerReady()
    if gameActive
        return
    endif

    if Player.GetReference().GetItemCount(Gold001) < bet
        ; TODO: If player no longer has gold, NPC should complain and refuse to continue
        return
    endif
    
    ; Don't block getting up as it would also hide the crosshair
    ; Game.DisablePlayerControls(abActivate = false)
    StartGame()
EndFunction

Function StartGame()
    gameActive = true
    SetObjectiveCompleted(0, true)
    Player.GetReference().RemoveItem(Gold001, bet)
    
    FARTableScript tableRef = Table.GetReference() as FARTableScript

    Player.TotalScore = 0
    Opponent.TotalScore = 0
    
    bool heads = Utility.RandomInt(0, 1) == 1
    if heads
        FARHeadsPlayerFirst.Show()
        currentPlayer = Player
        nextPlayer = Opponent
    else 
        FARTailsOpponentFirst.Show()
        currentPlayer = Opponent
        nextPlayer = Player
    endif
    tableRef.SpawnDecor(heads)

    BeginRound()
EndFunction

Function EndRound(int score)
    if score > 0
        FARPlayerScored.Show(score)
    else
        FARPlayerBust.Show()
    endif

    FARPlayer tmp = currentPlayer
    currentPlayer = nextPlayer
    nextPlayer = currentPlayer

    ; TODO: Check for win
    BeginRound()
EndFunction

Function BeginRound()
    currentPlayerAlias.ForceRefTo(currentPlayer.GetReference())
    FARTurnStart.Show()
    Debug.Trace("Begin round for " + currentPlayer)
    PlayerTurnActive = currentPlayer as FARHumanPlayer != none
    currentPlayer.RoundScore = 0
    currentPlayer.OnTurnBegin()
EndFunction

Function EndGame(FARPlayer winner)
    currentPlayer.ForceRefTo(winner.GetReference())
    FARGameWon.Show()
    winner.GetReference().AddItem(Gold001, Bet * 2)

    (Table.GetReference() as FARTableScript).Cleanup()
    gameActive = false
EndFunction

Function DisplayScores()
    ; Bet: %.0f
    ; Target score: %.0f

    ; <Alias=Player>
    ; Round: %.0f
    ; Selection: %.0f
    ; Banked: %.0f

    ; <Alias=Opponent>
    ; Round: %.0f
    ; Selection: %.0f
    ; Banked: %.0f
    FARScoringKCD scoring = (self as form) as FARScoringKCD
    FARTableScript tableRef = Table.GetReference() as FARTableScript
    FARGameState.Show(Bet, TargetScore, \
        Player.RoundScore, scoring.ScoreSelection(tableRef.GetSelection()), Player.TotalScore,\
        Opponent.RoundScore, 0, Opponent.TotalScore)
EndFunction

Function Resign()
    if IsObjectiveDisplayed(0) && !IsObjectiveCompleted(0)
        SetObjectiveFailed(0, true)
    endif

    EndGame(Opponent)

    ; Mark quest as failed
    SetStage(200)
    Stop()
EndFunction

Function ShowRolls(int[] rolls)
    (Table.GetReference() as FARTableScript).ShowDice(rolls)
EndFunction