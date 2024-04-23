Const START_BUTTON_VOLUME = 1.0				'volume level; range [0, 1]

Sub EMSPlayStartButtonSound ()
	EMSPlaySoundAtVolumePanAndFade "Start_Button", START_BUTTON_VOLUME, EMSTransformPan (-0.5), SOUND_FADE_NEAR_PLAYER
End Sub

Const BALL_LIFTER_VOLUME = 1.0				'volume level; range [0, 1]

Sub EMsPlayBallLifterSound ()
	EMPlaySoundAtVolumePanAndFade "BallLift", BALL_LIFTER_VOLUME, EMSTransformPan (0.5), EMSTransformFade (kSoundFadeNearPlayer)
End Sub

Sub EMsPlayBallLiftReleaseSound ()
	EMPlaySoundAtVolumePanAndFade "BallLiftDown", BALL_LIFTER_VOLUME, EMSTransformPan (0.5), EMSTransformFade (kSoundFadeNearPlayer)
End Sub

Const POST_SOUND_SCALAR = 0.1				'volume level; range [0, 1]

Sub EMSPlayPostHitSound ()
	Dim FinalSpeedSquared
  	FinalSpeedSquared = (Activeball.VelX * Activeball.VelX) + (Activeball.VelY * Activeball.VelY)
 	If FinalSpeedSquared > 256 Then
		EMSPlaySoundAtVolumeForActiveBall "fx_rubber2", EMSVolumeForBall (ActiveBall) * POST_SOUND_SCALAR
	ElseIf FinalSpeedSquared >= 36 Then
 		EMSPlayRubberHitSound
 	End If
End Sub

Const PIN_HIT_VOLUME = 1.0					'volume level; range [0, 1]

Sub EMSPlayPinHitSound ()
	EMSPlaySoundAtVolumeForActiveBall "pinhit_low", PIN_HIT_VOLUME
End Sub

Const ROLLOVER_VOLUME = 0.25				'volume level; range [0, 1]

Sub EMSPlayRolloverSound()
	EMSPlaySoundAtVolumeForActiveBall ("Rollover_" & Int (Rnd * 4) + 1), ROLLOVER_VOLUME
End Sub

Const SAUCER_LOCK_VOLUME = 0.8				'volume level; range [0, 1]

Sub EMSPlaySaucerLockSound ()
	EMSPlaySoundAtVolumeForActiveBall ("Saucer_Enter_" & Int (Rnd * 2) + 1), SAUCER_LOCK_VOLUME
End Sub

Const SAUCER_KICK_VOLUME = 0.8				'volume level; range [0, 1]

Sub EMSPlaySaucerKickSound (scenario, saucerObj)
	Select Case scenario
		Case 0: EMSPlaySoundAtVolumeForObject SoundFX ("Saucer_Empty", DOFContactors), SAUCER_KICK_VOLUME, saucerObj
		Case 1: EMSPlaySoundAtVolumeForObject SoundFX ("Saucer_Kick", DOFContactors), SAUCER_KICK_VOLUME, saucerObj
	End Select
End Sub

Const SPINNER_VOLUME = 1.0					'volume level; range [0, 1]

Sub EMSPlaySpinnerSound (SpinnerObj)
	EMSPlaySoundAtVolumeForObject "Spinner", SPINNER_VOLUME, SpinnerObj
End Sub

Const VARI_TARGET_VOLUME = 1.0				'volume level; range [0, 1]

Sub EMSPlayVariTargetSound ()
	EMSPlaySoundAtVolumeForActiveBall "VariTarget", VARI_TARGET_VOLUME
End Sub

Const ROTO_START_VOLUME = 1.0				'volume level; range [0, 1]

Sub EMSPlayRotoStartSound ()
	EMSPlaySoundAtVolumePanAndFade "RotoStart", ROTO_START_VOLUME, EMSTransformPan (-0.5), EMSTransformFade (SOUND_FADE_NEAR_BACKGLASS)
End Sub
