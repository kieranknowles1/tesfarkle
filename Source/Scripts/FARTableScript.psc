Scriptname FARTableScript extends ObjectReference  

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
    SpawnRefs()
EndEvent

Event OnCellDetach()
    Cleanup()
EndEvent

Function SpawnRefs()
    Cleanup()

    diceRefs = new FARDieScript[6]
    int i = 0
    while i < diceRefs.Length
        diceRefs[i] = SpawnAtNode(DiceBases[i], "Dice" + i) as FARDieScript
        diceRefs[i].Align()
        i += 1
    endwhile
    coinRef = SpawnAtNode(FARCoin, "Coin")
    betRef = SpawnAtNode(FARBet, "Bet")
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

Function Cleanup()
    DisableAndDelete(coinRef)
    coinRef = none
    DisableAndDelete(betRef)
    betRef = none   

    int i = 0
    while diceRefs && i < diceRefs.Length
        DisableAndDelete(diceRefs[i])
        diceRefs[i] = none
        i += 1
    endwhile
EndFunction