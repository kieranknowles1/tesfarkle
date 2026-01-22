Scriptname FARArrayUtil

; Global utility functions for working with arrays

; Get the number of instances of `value` in `arr`
; Runs in O(n) time
int function Count(int[] arr, int value) global
    int i = 0
    int count = 0
    while i < arr.Length
        if arr[i] == value
            count += 1
        endif
        i += 1
    endwhile
    return count
endfunction

; Set up to N bits of mask true based on where arr == value
; Runs in O(n) time
Function SetMaskBits(int[] arr, bool[] mask, int value, int max) global
    int i = 0
    int replaced = 0

    while i < arr.Length && replaced < max
        if arr[i] == value && mask[i] == false
            mask[i] = true
            replaced += 1
        endif
        i += 1
    endwhile
EndFunction

; Replace the first instance of `value` with `replace`
; Runs in O(n) time
; Returns index of the replaced value, or -1 on failure
int Function ReplaceFirst(int[] arr, int value, int replace) global
    int i = 0
    while i < arr.Length
        if arr[i] == value
            arr[i] = value
            return i
        endif
        i += 1
    endwhile
    return -1
EndFunction

; Get the number of entries greater than `value`
; Runs in O(n) time
int Function CountGreaterThan(int[] arr, int value) global
    int i = 0
    int greater = 0
    while i < arr.Length
        if arr[i] > value
            greater += 1
        endif
        i += 1
    endwhile
    return greater
EndFunction