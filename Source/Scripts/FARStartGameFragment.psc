;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname FARStartGameFragment Extends TopicInfo Hidden

int Property BetAmount Auto
int Property TargetScore Auto

;BEGIN FRAGMENT Fragment_1
Function Fragment_1(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; Shared TIF for "start game with X bet"
; should be added via xEdit
(GetOwningQuest() as FARControlScript).StartGame(akSpeaker, BetAmount, TargetScore)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
