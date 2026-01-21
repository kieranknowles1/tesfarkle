Scriptname FARArrayUtil

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

; Replace the first instance of `value` with `replace`
; Runs in O(n) time
Function ReplaceFirst(int[] arr, int value, int replace) global
    int i = 0
    while i < arr.Length
        if arr[i] == value
            arr[i] = value
            return
        endif
        i += 1
    endwhile
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