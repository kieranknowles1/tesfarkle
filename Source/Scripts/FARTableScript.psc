Scriptname FARTableScript extends ObjectReference

; Dice table, acts as the presentation and input layer
; Does not handle any game logic

; Using six base objects, one for each face value, saves us from
; having to shuffle aliases to label them and allows for the two-texture
; workaround
Activator[] Property DiceBases Auto
Static Property FARCoin Auto
Static Property FARBet Auto

FARDieScript[] diceRefs
ObjectReference coinRef
ObjectReference betRef

; TODO: Don't spawn anything until a game begins
Event OnCellAttach()
    SpawnDecor(Utility.RandomInt(0, 1) == 1)

    int[] rolls = new int[6]
    int i = 0
    while i < rolls.Length
        rolls[i] = Utility.RandomInt(1, 6)
        i += 1
    endwhile
    SpawnDice(rolls)
EndEvent

Event OnCellDetach()
    Cleanup()
EndEvent

Function SpawnDecor(bool flipHeads)
    Cleanup()

    betRef = SpawnAtNode(FARBet, "Bet")

    coinRef = SpawnAtNode(FARCoin, "Coin")
    if !flipHeads
        coinRef.SetAngle(180, 0, 0)
    endIf
EndFunction

Function SpawnDice(int[] rolls)
    ClearRolls()

    diceRefs = new FARDieScript[6]
    int i = 0
    while i < diceRefs.Length
        diceRefs[i] = SpawnAtNode(DiceBases[rolls[i]], "Dice" + i) as FARDieScript
        diceRefs[i].Align()
        i += 1
    endwhile

EndFunction

ObjectReference Function SpawnAtNode(Form base, string node)
    ObjectReference ref = PlaceAtMe(base)
    ref.MoveToNode(self, node)
    return ref
EndFunction

Function DisableAndDelete(ObjectReference ref)
    if ref == none
        return
    endif

    ref.Disable()
    ref.Delete()
EndFunction

Function ClearRolls()
    int i = 0
    while diceRefs && i < diceRefs.Length
        DisableAndDelete(diceRefs[i])
        diceRefs[i] = none
        i += 1
    endwhile
EndFunction

Function Cleanup()
    DisableAndDelete(coinRef)
    coinRef = none
    DisableAndDelete(betRef)
    betRef = none   

    ClearRolls()
EndFunction