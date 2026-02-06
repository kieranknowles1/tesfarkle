Scriptname FARGameScript extends Quest Conditional

int Property Bet Auto
int Property TargetScore Auto
MiscObject Property Gold001 Auto

ReferenceAlias Property Table Auto
FARPlayer Property Player Auto
FARPlayer Property Opponent Auto
ReferenceAlias Property PlayerChair Auto
ReferenceAlias Property OpponentChair Auto
ReferenceAlias Property EndCallback Auto

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
; Last player went bust
bool Property Bust = false Auto Conditional
int Property LastRollScore Auto Conditional

; How many times has either player had a round?
; Includes the current round
int Property RoundNumber Auto

Scene Property FARGameEndTurn Auto
Scene Property FARGameEnd Auto

ReferenceAlias Property CurrentPlayerAlias Auto ; Used for messages
FARPlayer currentPlayer ; Tracking who's turn it is
FARPlayer nextPlayer

bool Function IsSitting(Actor akActor, ObjectReference chair, float epsilon = 32.0)
    float distance = akActor.GetDistance(chair)
    return distance < epsilon
EndFunction

GlobalVariable Property FARTutorialShown Auto
Message Property FARTutorial1 Auto
Message Property FARTutorial2 Auto

Function ShowTutorial()
    FARTutorial1.Show()
    FARTutorial2.Show()
    FARTutorialShown.SetValue(1.0)
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
; - aiValue2: Target score
; Manual setup:
; EndCallback: Object to receive events at the end of a game, extends FAREndGameHandler
Event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akRef1, ObjectReference akRef2, int aiValue1, int aiValue2)
    Bet = aiValue1
    TargetScore = aiValue2

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

    if FARTutorialShown.GetValue() == 0.0
        ShowTutorial()
    endif

    BeginRound()
EndFunction

Function EndRound(int score)
    if score > 0
        Bust = false
        FARPlayerScored.Show(score)
    else
        Bust = true
        ; Let the player see their rolls first
        Utility.Wait(1.25)
        FARPlayerBust.Show()
    endif

    if currentPlayer.TotalScore >= TargetScore
        EndGame(currentPlayer)
        return
    else
        ; Wait until the end turn scene finishes, then continue
        FARGameEndTurn.Start()
        while FARGameEndTurn.IsPlaying()
            Utility.Wait(0.25)
        endwhile
    endif

    ; Swap players, and run another round
    FARPlayer tmp = currentPlayer
    currentPlayer = nextPlayer
    nextPlayer = tmp

    BeginRound()
EndFunction

Function BeginRound()
    RoundNumber += 1
    CurrentPlayerAlias.ForceRefTo(currentPlayer.GetReference())
    FARTurnStart.Show()
    ; Debug.Trace("Begin round for " + currentPlayer)
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
    bool gameWasStarted = GameActive
    GameActive = false

    ; Mark quest as complete or failed
    if winner == Player
        SetStage(210)
    else
        SetStage(200)
    endif

    FAREndGameHandler callback = EndCallback.GetReference() as FAREndGameHandler
    if callback
        callback.OnGameEnd(winner)
    endif

    ; Don't stop the quest - the scene playing dialogue will do that for us
    ; If we resigned before starting, skip any dialogue that would have played and stop the 
    ; quest immediatly
    if gameWasStarted
        FARGameEnd.Start()
    else
        Stop()
    endif
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