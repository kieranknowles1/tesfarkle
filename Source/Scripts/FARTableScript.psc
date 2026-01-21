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

; Show rolled dice, anything <= 0 is considered unused
Function ShowDice(int[] rolls)
    ClearRolls()

    diceRefs = new FARDieScript[6]
    int i = 0
    while i < diceRefs.Length
        if rolls[i] > 0
            diceRefs[i] = SpawnAtNode(DiceBases[rolls[i] - 1], "Dice" + i) as FARDieScript
            diceRefs[i].Table = self
            diceRefs[i].Align()
        endif
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

int[] Function GetSelection()
    int[] out = new int[6]
    int i = 0
    while i < diceRefs.Length
        Debug.Trace("roll " + diceRefs[i].Value + " " + diceRefs[i].Selected)
        if diceRefs[i].Selected
            out[i] = diceRefs[i].Value
        endif
        i += 1
    endwhile
    return out
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