Scriptname FARDieScript extends ObjectReference  

int Property Value Auto

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