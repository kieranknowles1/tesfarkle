Scriptname FARDieScript extends ObjectReference  

int Property Value Auto
EffectShader Property FARSelectedDieGlowFXS Auto

FARTableScript Property Table Auto

bool __selected = false
bool Property Selected
    bool function get()
        return __selected
    endfunction
    function set(bool newVal)
        __selected = newVal
        if __selected
            FARSelectedDieGlowFXS.Play(self)
        else
            FARSelectedDieGlowFXS.Stop(self)
        endif
    endfunction
endproperty

Event OnActivate(ObjectReference akActionRef)
    Selected = !Selected
EndEvent

; Set rotation such that the face worth "Value" points is on top
Function Align()
    float yaw = Utility.RandomFloat(0, 360)

    ; Align the die based on the value on top with random yaw
    ; and weep that we don't have quaternions which would make
    ; things easier, we could just multiply by the yaw quaternion
    ; after rotation

    ; As a hack, these faces use a different texture with rearranged faces
    ; to avoid the issue entirely and save me the maths
    if Value == 1
        SetAngle(180, 0, yaw)
    elseif Value == 2
        SetAngle(270, yaw, 0)
    elseif Value == 3
        ; Face position swapped with 6 in texture
        SetAngle(0, 0, yaw)
    elseif Value == 4
        ; Face position swapped with 1 in texture
        SetAngle(180, 0, yaw)
    elseif Value == 5
        SetAngle(90, yaw, 0)
    elseif Value == 6
        SetAngle(0, 0, yaw)
    endif
EndFunction