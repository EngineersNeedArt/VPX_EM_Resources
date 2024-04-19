'==================================================================================================
'											   EM Sounds
'==================================================================================================

Const MASTER_VOLUME = 0.8					'value no greater than 1.
Const PAN_TRANSFORM_EXPONENT = 10			'smaller value, less "spread" of audio channels
Const FADE_TRANSFORM_EXPONENT = 10			'smaller value, less "spread" of audio channels
Const MIN_SOUND_PAN_LEFT = -1.0
Const SOUND_PAN_LEFT = -0.9
Const SOUND_PAN_CENTER = 0.0
Const SOUND_PAN_RIGHT = 0.9
Const MAX_SOUND_PAN_RIGHT = 1.0
Const MIN_SOUND_FADE_NEAR_BACKGLASS = -1.0
Const SOUND_FADE_NEAR_BACKGLASS = -0.9
Const SOUND_FADE_CENTER = 0.0
Const SOUND_FADE_NEAR_PLAYER = 0.9
Const MAX_SOUND_FADE_NEAR_PLAYER = 1.0
Const DONT_LOOP_SOUND = 0
Const LOOP_UNTIL_STOPPED = -1
Const NO_RANDOM_PITCH = 0
Const NO_PITCH_CHANGE = 0
Const DONT_USE_EXISTING_SOUND = 0
Const USE_EXISTING_SOUND = 1
Const DONT_RESTART_SOUND = 0
Const RESTART_SOUND = 1

Dim TableWidth, TableHeight
TableWidth = 1000							'reasonable defaults, 
TableHeight = 2000							'but please call EMSInit() to get real values assigned

' Pass table object, call before any sound is played
Sub EMSInit (TableObj)
	TableWidth = TableObj.Width
	TableHeight = TableObj.Height
End Sub

'---------------------------------------------------------------------------- Play Positional Sound

' Calculates the volume of the sound based on the ball speed
Function EMSVolumeForBall (Ball)
    EMSVolumeForBall = CSng (EMSBallVelocity (Ball) ^2)
End Function

' Scale pan so there is some bleed-over of left/right channels.
' ex: with headphones you don't want the plunger only in the right ear.
Function EMSTransformPan (Pan)
	If Pan > 0 Then
		EMSTransformPan = CSng (Pan ^ PAN_TRANSFORM_EXPONENT)
	Else
		EMSTransformPan = -CSng (Pan ^ PAN_TRANSFORM_EXPONENT)
	End If
End Function

' Determines pan based on X position on table (-1 is table-left, 0 is table-center, 1 is table-right).
Function EMSPanForTableX (X)
    EMSPanForTableX = CSng ((X * 2 / TableWidth) - 1)
	If EMSPanForTableX < MIN_SOUND_PAN_LEFT Then
		EMSPanForTableX = MIN_SOUND_PAN_LEFT
	ElseIf EMSPanForTableX > MAX_SOUND_PAN_RIGHT Then
		EMSPanForTableX = MAX_SOUND_PAN_RIGHT
	End If
End Function

' Scale fade so there is some bleed-over between front/back channels.
Function EMSTransformFade (Fade)
	If Fade > 0 Then
		EMSTransformFade = CSng (Fade ^ FADE_TRANSFORM_EXPONENT)
	Else
		EMSTransformFade = -CSng (Fade ^ FADE_TRANSFORM_EXPONENT)
	End If
End Function

' Determines fade based on Y position on table (-1 is table-far, 0 is table-center, 1 is table-near).
Function EMSFadeForTableY (Y)
    EMSFadeForTableY = CSng ((Y * 2 / TableHeight) - 1)
	If EMSFadeForTableY < MIN_SOUND_FADE_NEAR_BACKGLASS Then
		EMSFadeForTableY = MIN_SOUND_FADE_NEAR_BACKGLASS
	ElseIf EMSFadeForTableY > MAX_SOUND_FADE_NEAR_PLAYER Then
		EMSFadeForTableY = MAX_SOUND_FADE_NEAR_PLAYER
	End If
End Function

' Plays sound SoundName at level Volume specifying pan of Pan and fade of Fade.
Sub EMSPlaySoundAtVolumePanAndFade (SoundName, Volume, Pan, Fade)
	PlaySound SoundName, DONT_LOOP_SOUND, Volume * MASTER_VOLUME, Pan, NO_RANDOM_PITCH, NO_PITCH_CHANGE, DONT_USE_EXISTING_SOUND, DONT_RESTART_SOUND, Fade
End Sub

' Plays sound SoundName at level Volume specifying pan and fade based on the position of ForObj on the table.
Sub EMSPlaySoundAtVolumeForObject (SoundName, Volume, ForObj)
	Dim Pan
	Pan = EMSTransformPan (EMSPanForTableX (ForObj.X))
	Dim fade
	Fade = EMSTransformFade (EMSFadeForTableY (ForObj.Y))
	EMSPlaySoundAtVolumePanAndFade SoundName, Volume, Pan, Fade
End Sub

' Plays sound SoundName at level Volume specifying pan and fade based on the position of the active ball on the table.
Sub EMSPlaySoundAtVolumeForActiveBall (SoundName, Volume)
	Dim Pan
	Pan = EMSTransformPan (EMSPanForTableX (ActiveBall.X))
	Dim Fade
	Fade = EMSTransformFade (EMSFadeForTableY (ActiveBall.Y))
	EMSPlaySoundAtVolumePanAndFade SoundName, Volume, Pan, Fade
End Sub

' Plays an existing sound SoundName at level Volume specifying pan of Pan and fade of Fade.
Sub EMSPlaySoundExistingAtVolumePanAndFade (SoundName, Volume, Pan, Fade)
	PlaySound soundName, DONT_LOOP_SOUND, Volume * MASTER_VOLUME, Pan, NO_RANDOM_PITCH, NO_PITCH_CHANGE, USE_EXISTING_SOUND, DONT_RESTART_SOUND, Fade
End Sub

' Plays an existing sound SoundName at level Volume specifying pan and fade based on the position of the active ball on the table.
Sub EMSPlaySoundExistingAtVolumeForActiveBall (SoundName, Volume)
	Dim Pan
	Pan = EMSTransformPan (EMSPanForTableX (ActiveBall.X))
	Dim Fade
	Fade = EMSTransformFade (EMSFadeForTableY (ActiveBall.Y))
	EMSPlaySoundExistingAtVolumePanAndFade SoundName, Volume, Pan, Fade
End Sub

' Loops a sound SoundName LoopCount times at level Volume specifying pan and fade based on the position of ForObj on the table.
Sub EMSPlaySoundLoopedAtVolumeForObject (SoundName, LoopCount, Volume, ForObj)
	Dim Pan
	Pan = EMSTransformPan (EMSPanForTableX (ForObj.X))
	Dim Fade
	Fade = EMSTransformFade (EMSFadeForTableY (ForObj.Y))
	PlaySound SoundName, LoopCount, Volume * MASTER_VOLUME, Pan, NO_RANDOM_PITCH, NO_PITCH_CHANGE, DONT_USE_EXISTING_SOUND, RESTART_SOUND, Fade
End Sub

'------------------------------------------------------------------------------------- Ball Rolling

'Calculates the ball speed.
Function EMSBallVelocity (Ball)
    EMSBallVelocity = Int (Sqr ((Ball.VelX ^ 2) + (Ball.VelY ^ 2)))
End Function

Const ROLLING_SOUND_SCALAR = 0.22

' Calculates the roll volume of the sound based on the ball speed.
Function EMSVolumePlayfieldRoll (Ball)
	EMSVolumePlayfieldRoll = ROLLING_SOUND_SCALAR * 0.0005 * CSng (EMSBallVelocity (Ball) ^ 3)
End Function

' Calculates the roll pitch of the sound based on the ball speed.
Function EMSPitchPlayfieldRoll (Ball)
	EMSPitchPlayfieldRoll = EMSBallVelocity (Ball) ^ 2 * 15
End Function

' Calculates the pitch of the sound based on the ball speed.
Function EMSPitch (Ball)
    EMSPitch = EMSBallVelocity (Ball) * 20
End Function

Const NumberOfBalls = 5
Const NumberOfLockedBalls = 0

ReDim Rolling (NumberOfBalls)
InitRolling

Sub InitRolling
	Dim I
	For I = 0 To NumberOfBalls
		Rolling(I) = False
	Next
End Sub

Sub RollingSoundTimer_Timer ()
	Dim BOT, B
	BOT = GetBalls
    
	' Stop the sound of deleted balls.
	For B = UBound (BOT) + 1 To NumberOfBalls
		Rolling(B) = False
		StopSound ("BallRoll_" & B)
	Next
	
	' Exit the Sub If no balls on the table.
	If UBound (BOT) = -1 Then Exit Sub
	
	' Play the rolling sound For each ball.
	For B = 0 To UBound (BOT)
		If EMSBallVelocity (BOT(B)) > 1 AND BOT(B).z < 30 Then
			Rolling(B) = True
			Dim Pan
			Pan = EMSTransformPan (EMSPanForTableX (BOT(B).X))
			Dim Fade
			Fade = EMSTransformFade (EMSFadeForTableY (BOT(B).Y))
			PlaySound ("BallRoll_" & B), LOOP_UNTIL_STOPPED, EMSVolumePlayfieldRoll (BOT(B)) * 1.1 * MASTER_VOLUME, Pan, NO_RANDOM_PITCH, EMSPitchPlayfieldRoll (BOT(B)), USE_EXISTING_SOUND, DONT_RESTART_SOUND, Fade
		Else
			If Rolling(b) = True Then
				StopSound ("BallRoll_" & B)
				Rolling(B) = False
			End If
		End If
	Next
End Sub

Sub OnBallBallCollision (Ball1, Ball2, Velocity)
	PlaySound ("BallCollide"), 0, CSng (Velocity) ^ 2 / 2000, AudioPan (Ball1), 0, Pitch (Ball1), 0, 0, AudioFade (Ball1)
End Sub

'------------------------------------------------------------------------------------- Start Sounds

Const COIN_VOLUME = 1.0						'volume level; range [0, 1]

Sub EMSPlayCoinSound ()
	EMSPlaySoundAtVolumePanAndFade ("Coin_In_" & Int (Rnd * 3) + 1), COIN_VOLUME, SOUND_PAN_CENTER, EMSTransformFade(SOUND_FADE_NEAR_PLAYER)
End Sub

Const STARTUP_VOLUME = 1.0					'volume level; range [0, 1]

Sub EMSPlayStartupSound ()
	EMSPlaySoundAtVolumePanAndFade "startup_norm", STARTUP_VOLUME, SOUND_PAN_CENTER, EMSTransformFade (SOUND_FADE_NEAR_BACKGLASS)
End Sub

Const PLUNGER_PULL_VOLUME = 0.8				'volume level; range [0, 1]

Sub EMSPlayPlungerPullSound (PlungerObj)
	EMSPlaySoundAtVolumeForObject "Plunger_Pull_1", PLUNGER_PULL_VOLUME, PlungerObj
End Sub

Const PLUNGER_RELEASE_VOLUME = 0.8			'volume level; range [0, 1]

Sub EMSPlayPlungerReleaseBallSound (PlungerObj)
	EMSPlaySoundAtVolumeForObject "Plunger_Release_Ball", PLUNGER_RELEASE_VOLUME, PlungerObj
End Sub

Sub EMSPlayPlungerReleaseNoBallSound (PlungerObj)
	EMSPlaySoundAtVolumeForObject "Plunger_Release_No_Ball", PLUNGER_RELEASE_VOLUME, PlungerObj
End Sub

Const START_BALL_VOLUME = 0.4				'volume level; range [0, 1]

Sub EMSPlayStartBallSound (Which)
	Dim SoundName
	If Which = 0 Then
		SoundName = "StartBall1"
	Else
		SoundName = "StartBall2-5"
	End If
	EMSPlaySoundAtVolumePanAndFade SoundName, START_BALL_VOLUME, SOUND_PAN_CENTER, EMSTransformFade (SOUND_FADE_NEAR_PLAYER)
End Sub

Const BALL_RELEASE_VOLUME = 1.0				'volume level; range [0, 1]

Sub EMSPlayBallReleaseSound ()
	EMSPlaySoundAtVolumePanAndFade ("BallRelease" & Int (Rnd * 7) + 1), BALL_RELEASE_VOLUME, EMSTransformPan (SOUND_PAN_RIGHT), EMSTransformFade (SOUND_FADE_NEAR_PLAYER)
End Sub

Const ROTATE_THROUGH_PLAYERS_VOLUME = 0.8	'volume level; range [0, 1]

Sub EMSPlayRotateThroughPlayersSound ()
	EMSPlaySoundAtVolumePanAndFade "RotateThruPlayers", ROTATE_THROUGH_PLAYERS_VOLUME, SOUND_PAN_CENTER, EMSTransformFade (SOUND_FADE_NEAR_PLAYER)
End Sub

'----------------------------------------------------------------------------------- Flipper Sounds

Const FLIPPER_UP_ATTACK_MIN_VOLUME = 0.010	'volume level; range [0, 1]
Const FLIPPER_UP_ATTACK_MAX_VOLUME = 0.635	'volume level; range [0, 1]
Const FLIPPER_UP_VOLUME = 1.0				'volume level; range [0, 1]
Const FLIPPER_BUZZ_VOLUME = 0.05			'volume level; range [0, 1]

Dim FlipperLeftHitParm, FlipperRightHitParm
FlipperLeftHitParm = FLIPPER_UP_VOLUME		'sound helper; not configurable
FlipperRightHitParm = FLIPPER_UP_VOLUME		'sound helper; not configurable

Sub EMSPlayLeftFlipperUpAttackSound (FlipperObj)
	Dim SoundLevel
	SoundLevel = Rnd () * (FLIPPER_UP_ATTACK_MAX_VOLUME - FLIPPER_UP_ATTACK_MIN_VOLUME) + FLIPPER_UP_ATTACK_MIN_VOLUME
	EMSPlaySoundAtVolumeForObject SoundFX ("Flipper_Attack-L01", DOFFlippers), SoundLevel, FlipperObj
End Sub

Sub EMSPlayRightFlipperUpAttackSound (FlipperObj)
	Dim SoundLevel
	SoundLevel = Rnd () * (FLIPPER_UP_ATTACK_MAX_VOLUME - FLIPPER_UP_ATTACK_MIN_VOLUME) + FLIPPER_UP_ATTACK_MIN_VOLUME
	EMSPlaySoundAtVolumeForObject SoundFX ("Flipper_Attack-R01", DOFFlippers), SoundLevel, FlipperObj
End Sub

Sub EMSPlayLeftFlipperUpSound (FlipperObj)
	EMSPlaySoundAtVolumeForObject SoundFX ("Flipper_L0" & Int (Rnd * 9) + 1, DOFFlippers), FlipperLeftHitParm, FlipperObj
End Sub

Sub EMSPlayRightFlipperUpSound (FlipperObj)
	EMSPlaySoundAtVolumeForObject SoundFX("Flipper_R0" & Int (Rnd * 9) + 1, DOFFlippers), FlipperRightHitParm, FlipperObj
End Sub

Const FLIPPER_REFLIP_VOLUME = 0.8			'volume level; range [0, 1]

Sub EMSPlayLeftFlipperReflipSound (FlipperObj)
	EMSPlaySoundAtVolumeForObject SoundFX ("Flipper_ReFlip_L0" & Int (Rnd * 3) + 1, DOFFlippers), FLIPPER_REFLIP_VOLUME, FlipperObj
End Sub

Sub EMSPlayRightFlipperReflipSound (FlipperObj)
	EMSPlaySoundAtVolumeForObject SoundFX ("Flipper_ReFlip_R0" & Int (Rnd * 3) + 1, DOFFlippers), FLIPPER_REFLIP_VOLUME, FlipperObj
End Sub

Const REFLIP_ANGLE = 20

Sub EMSPlayLeftFlipperActivateSound (FlipperObj)
	If FlipperObj.Currentangle < FlipperObj.EndAngle + REFLIP_ANGLE Then 
		EMSPlayLeftFlipperReflipSound FlipperObj
	Else 
		EMSPlayLeftFlipperUpAttackSound FlipperObj
		EMSPlayLeftFlipperUpSound FlipperObj
	End If
	EMSPlaySoundLoopedAtVolumeForObject "buzzL", LOOP_UNTIL_STOPPED, FLIPPER_BUZZ_VOLUME, FlipperObj
End Sub

Sub EMSPlayRightFlipperActivateSound (FlipperObj)
	If FlipperObj.Currentangle < FlipperObj.EndAngle + REFLIP_ANGLE Then 
		EMSPlayRightFlipperReflipSound FlipperObj
	Else 
		EMSPlayRightFlipperUpAttackSound FlipperObj
		EMSPlayRightFlipperUpSound FlipperObj
	End If
	EMSPlaySoundLoopedAtVolumeForObject "buzz", LOOP_UNTIL_STOPPED, FLIPPER_BUZZ_VOLUME, FlipperObj
End Sub

Const FLIPPER_DEACTIVATE_VOLUME = 0.45			'volume level; range [0, 1]

Sub EMSPlayLeftFlipperDeactivateSound (FlipperObj)
	EMSPlaySoundAtVolumeForObject SoundFX ("Flipper_Left_Down_" & Int (Rnd * 7) + 1, DOFFlippers), FLIPPER_DEACTIVATE_VOLUME, FlipperObj
	StopSound "buzzL"
End Sub

Sub EMSPlayRightFlipperDeactivateSound (FlipperObj)
	EMSPlaySoundAtVolumeForObject SoundFX ("Flipper_Right_Down_" & Int (Rnd * 8) + 1, DOFFlippers), FLIPPER_DEACTIVATE_VOLUME, FlipperObj
	StopSound "buzz"
End Sub

Const RUBBER_FLIPPER_SOUND_SCALAR = 0.015	'volume multiplier; must not be zero

Sub EMSPlayLeftFlipperCollideSound (Parm)
	FlipperLeftHitParm = Parm / 10
	If FlipperLeftHitParm > 1 Then
		FlipperLeftHitParm = 1
	End If
	FlipperLeftHitParm = FLIPPER_UP_VOLUME * FlipperLeftHitParm
	EMSPlaySoundAtVolumeForActiveBall ("Flipper_Rubber_" & Int (Rnd * 7) + 1), Parm  * RUBBER_FLIPPER_SOUND_SCALAR
End Sub

Sub EMSPlayRightFlipperCollideSound (Parm)
	FlipperRightHitParm = Parm / 10
	If FlipperRightHitParm > 1 Then
		FlipperRightHitParm = 1
	End If
	FlipperRightHitParm = FLIPPER_UP_VOLUME * FlipperRightHitParm
	EMSPlaySoundAtVolumeForActiveBall ("Flipper_Rubber_" & Int (Rnd * 7) + 1), Parm  * RUBBER_FLIPPER_SOUND_SCALAR
End Sub

Sub EMSStopBuzzSounds ()
	StopSound "buzzL"
	StopSound "buzz"
End Sub

'--------------------------------------------------------------------------------- Playfield Sounds

Const METAL_IMPACT_SOUND_SCALAR = 0.025

Sub EMSPlayMetalHitSound ()
	EMSPlaySoundAtVolumeForActiveBall ("Metal_Touch_" & Int (Rnd * 13) + 1), EMSVolumeForBall (ActiveBall) * METAL_IMPACT_SOUND_SCALAR
End Sub

Const GATE_HIT_VOLUME = 0.1					'volume level; range [0, 1]

Sub EMSPlayGateHitSound ()
	EMSPlaySoundAtVolumeForActiveBall ("gate4"), GATE_HIT_VOLUME
End Sub

Const DRAIN_VOLUME = 0.8					'volume level; range [0, 1]

Sub EMSPlayDrainSound (DrainObj)
	EMSPlaySoundAtVolumeForObject ("Drain_" & Int (Rnd * 11) + 1), DRAIN_VOLUME, DrainObj
End Sub

Const RUBBER_STRONG_SOUND_SCALAR = 0.011	'volume multiplier; must not be zero
Const RUBBER_WEAK_SOUND_SCALAR = 0.015		'volume multiplier; must not be zero

Sub EMSPlayRubberHitSound ()
	Dim FinalSpeedSquared
	FinalSpeedSquared = (ActiveBall.VelX * ActiveBall.VelX) + (ActiveBall.VelY * ActiveBall.VelY)
	If FinalSpeedSquared > 25 Then			'strong
		Dim SoundIndex
		SoundIndex = Int (Rnd * 10) + 1
		If SoundIndex > 9 Then
			EMSPlaySoundAtVolumeForActiveBall "Rubber_1_Hard", EMSVolumeForBall (ActiveBall) * RUBBER_STRONG_SOUND_SCALAR * 0.6
		Else
			EMSPlaySoundAtVolumeForActiveBall ("Rubber_Strong_" & Int (SoundIndex)), EMSVolumeForBall (ActiveBall) * RUBBER_STRONG_SOUND_SCALAR
		End If
	Else									'weak
		EMSPlaySoundAtVolumeForActiveBall ("Rubber_" & Int (Rnd * 9) + 1), EMSVolumeForBall (ActiveBall) * RUBBER_WEAK_SOUND_SCALAR
	End If
End Sub

Const SLINGSHOT_VOLUME = 0.95				'volume level; range [0, 1]

Sub EMSPlayLeftSlingshotSound (Sling)
	EMSPlaySoundAtVolumeForObject SoundFX ("Sling_L" & Int(Rnd * 10) + 1, DOFContactors), SLINGSHOT_VOLUME, Sling
End Sub

Sub EMSPlayRightSlingshotSound(Sling)
	EMSPlaySoundAtVolumeForObject SoundFX ("Sling_R" & Int(Rnd * 8) + 1, DOFContactors), SLINGSHOT_VOLUME, Sling
End Sub

Const BUMPER_SOUND_SCALAR = 6.0				'volume multiplier; must not be zero

Sub EMSPlayTopBumperSound (BumperObj)
	EMSPlaySoundAtVolumeForObject SoundFX ("Bumpers_Top_" & Int (Rnd * 5) + 1, DOFContactors), EMSVolumeForBall (ActiveBall) * BUMPER_SOUND_SCALAR, BumperObj
End Sub

Sub EMSPlayMiddleBumperSound (BumperObj)
	EMSPlaySoundAtVolumeForObject SoundFX ("Bumpers_Middle_" & Int (Rnd * 5) + 1, DOFContactors), EMSVolumeForBall (ActiveBall) * BUMPER_SOUND_SCALAR, BumperObj
End Sub

Sub EMSPlayBottomBumperSound (BumperObj)
	EMSPlaySoundAtVolumeForObject SoundFX ("Bumpers_Bottom_" & Int (Rnd * 5) + 1, DOFContactors), EMSVolumeForBall (ActiveBall) * BUMPER_SOUND_SCALAR, BumperObj
End Sub

Const SENSOR_VOLUME = 1.0					'volume level; range [0, 1]

Sub EMSPlaySensorSound ()
	EMSPlaySoundAtVolumeForActiveBall "sensor", SENSOR_VOLUME
End Sub

Const TARGET_SOUND_SCALAR = 0.025			'volume multiplier; must not be zero

Sub EMSPlayTargetHitSound ()
	Dim FinalSpeedSquared
	FinalSpeedSquared = (Activeball.VelX * Activeball.VelX + Activeball.VelY * Activeball.VelY)
	If FinalSpeedSquared > 100 Then
		EMSPlaySoundAtVolumeForActiveBall SoundFX ("Target_Hit_" & Int(Rnd * 4) + 5, DOFTargets), EMSVolumeForBall (ActiveBall) * 0.45 * TARGET_SOUND_SCALAR
	Else 
		EMSPlaySoundAtVolumeForActiveBall SoundFX ("Target_Hit_" & Int(Rnd * 4) + 1, DOFTargets), EMSVolumeForBall (ActiveBall) * TARGET_SOUND_SCALAR
	End If
End Sub

Const DROP_TARGET_RESET_VOLUME = 1.0		'volume level; range [0, 1]

Sub EMSPlayDropTargetResetSound ()
	EMSPlaySoundAtVolumePanAndFade "dropsup", DROP_TARGET_RESET_VOLUME, SOUND_PAN_CENTER, SOUND_FADE_CENTER
End Sub

'------------------------------------------------------------------------------------- Other Sounds

Const CLICK_VOLUME = 1.0					'volume level; range [0, 1]

Sub EMSPlayClickSound ()
	EMSPlaySoundAtVolumePanAndFade "click", CLICK_VOLUME, SOUND_PAN_CENTER, SOUND_FADE_CENTER
End Sub

Const CHIME_VOLUME = 1.0					'volume level; range [0, 1]
Const CHIME_PAN = 0.5

Sub EMSPlayChimeSound (ChimeNum)
	Dim SoundName
	Select Case ChimeNum
		Case 0
			If (Rnd * 2) > 0 Then
				SoundName = "SJ_Chime_10a"
			Else
				SoundName = "SJ_Chime_10b"
			End If
		Case 1
			If (Rnd * 2) > 0 Then
				SoundName = "SJ_Chime_100a"
			Else
				SoundName = "SJ_Chime_100b"
			End If
		Case 2
			If (Rnd * 2) > 0 Then
				SoundName = "SJ_Chime_1000a"
			Else
				SoundName = "SJ_Chime_1000b"
			End If
		Case Else
			Exit Sub
	End Select
	EMSPlaySoundAtVolumePanAndFade SoundName, CHIME_VOLUME, EMSTransformPan (CHIME_PAN), SOUND_FADE_CENTER
End Sub

Const BELL_VOLUME = 0.25					'volume level; range [0, 1]
Const BELL_PAN = 0.5

Sub EMSPlayBellSound (BellNum)
	Select Case BellNum
		Case 0
			EMSPlaySoundAtVolumePanAndFade "SpinACard_10_Point_Bell", BELL_VOLUME, EMSTransformPan (SOUND_PAN_RIGHT), SOUND_FADE_CENTER
		Case 1
			EMSPlaySoundAtVolumePanAndFade "SpinACard_100_Point_Bell", BELL_VOLUME, EMSTransformPan (SOUND_PAN_RIGHT), SOUND_FADE_CENTER
		Case 2
			EMSPlaySoundExistingAtVolumePanAndFade "SpinACard_1000_Point_Bell", BELL_VOLUME, EMSTransformPan (BELL_PAN), SOUND_FADE_CENTER
	End Select
End Sub

Const KNOCKER_VOLUME = 1.0					'volume level; range [0, 1]

Sub EMSPlayKnockerSound ()
	EMSPlaySoundAtVolumePanAndFade "Knocker_1", KNOCKER_VOLUME, SOUND_PAN_CENTER, EMSTransformFade (SOUND_FADE_NEAR_BACKGLASS)
End Sub

Const MOTOR_LEER_VOLUME = 1.0				'volume level; range [0, 1]

Sub EMSPlayMotorLeerSound ()
	EMSPlaySoundAtVolumePanAndFade "MotorLeer", MOTOR_LEER_VOLUME, SOUND_PAN_CENTER, EMSTransformFade (SOUND_FADE_NEAR_BACKGLASS)
End Sub

'==================================================================================================
'											 End EM Sounds
'==================================================================================================