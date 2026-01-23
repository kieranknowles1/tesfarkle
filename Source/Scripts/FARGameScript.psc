Scriptname FARGameScript extends Quest Conditional

int Property Bet Auto
int Property TargetScore Auto
MiscObject Property Gold001 Auto

ReferenceAlias Property Table Auto
FARPlayer Property Player Auto
FARPlayer Property Opponent Auto
ReferenceAlias Property PlayerChair Auto
ReferenceAlias Property OpponentChair Auto

Message Property FARHeadsPlayerFirst Auto
Message Property FARTailsOpponentFirst Auto
Message Property FARTurnStart Auto
Message Property FARGameWon Auto

Message Property FARPlayerBust Auto
Message Property FARPlayerScored Auto
Message Property FARGameState Auto

; Used to condition dialogue based on whos turn it is
bool Property PlayerTurnActive = false Auto Conditional
bool Property GameActive = false Auto Conditional
; The current player's selection will score
bool Property SelectionValid = false Auto Conditional
; The current player's selection will win the game for them
bool Property SelectionWillWin = false Auto Conditional

ReferenceAlias Property CurrentPlayerAlias Auto ; Used for messages
FARPlayer currentPlayer ; Tracking who's turn it is
FARPlayer nextPlayer

bool Function IsSitting(Actor akActor, ObjectReference chair, float epsilon = 32.0)
    float distance = akActor.GetDistance(chair)
    return distance < epsilon
EndFunction

Function SwapAliases(ReferenceAlias a, ReferenceAlias b)
    ObjectReference tmp = a.GetReference()
    a.ForceRefTo(b.GetReference())
    b.ForceRefTo(tmp)
EndFunction

Function OnSelectionChanged(int[] newSelection)
    FARScoring scoring = (self as Quest) as FARScoring
    int score = scoring.ScoreSelection(newSelection)
    SelectionValid = score > 0
    SelectionWillWin = (score + currentPlayer.RoundScore + currentPlayer.TotalScore) >= TargetScore
EndFunction

; Story event usage:
; - akRef1: Opponent
; - aiValue1: Bet amount
Event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akRef1, ObjectReference akRef2, int aiValue1, int aiValue2)
    bet = aiValue1

    Actor playerRef = Player.GetReference() as Actor

    ; Swap seats if someone is already sitting in the other player's assigned chair
    ; to avoid an impromptu game of musical chairs
    if IsSitting(playerRef, OpponentChair.GetReference()) || IsSitting(Opponent.GetReference() as Actor, PlayerChair.GetReference())
        SwapAliases(PlayerChair, OpponentChair)
    endif


    ; Is the player already sitting in their chair (which may have been swapped)? If so, start game immediatly
    if IsSitting(playerRef, PlayerChair.GetReference())
        PlayerReady()
    else
        ; Ask player to sit
        SetObjectiveDisplayed(0, true)
    endif
EndEvent

Function PlayerReady()
    if GameActive
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
    GameActive = true
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
        ; Let the player see their rolls first
        Utility.Wait(1.25)
        FARPlayerBust.Show()
    endif

    if currentPlayer.TotalScore >= TargetScore
        EndGame(currentPlayer)
        return
    endif

    FARPlayer tmp = currentPlayer
    currentPlayer = nextPlayer
    nextPlayer = tmp

    ; Swap players, and run another round
    Utility.Wait(1.5)
    BeginRound()
EndFunction

Function BeginRound()
    CurrentPlayerAlias.ForceRefTo(currentPlayer.GetReference())
    FARTurnStart.Show()
    Debug.Trace("Begin round for " + currentPlayer)
    PlayerTurnActive = currentPlayer as FARHumanPlayer != none
    currentPlayer.RoundScore = 0
    currentPlayer.OnTurnBegin()
EndFunction

Function EndGame(FARPlayer winner)
    if GameActive
        CurrentPlayerAlias.ForceRefTo(winner.GetReference())
        winner.GetReference().AddItem(Gold001, Bet * 2)
        FARGameWon.Show()
    endif

    (Table.GetReference() as FARTableScript).Cleanup()
    GameActive = false

    ; Mark quest as complete or failed
    if winner == Player
        SetStage(210)
    else
        SetStage(200)
    endif
    Stop()
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
    FARScoring scoring = (self as form) as FARScoring
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
EndFunction

Function ShowRolls(int[] rolls)
    (Table.GetReference() as FARTableScript).ShowDice(rolls)
EndFunction