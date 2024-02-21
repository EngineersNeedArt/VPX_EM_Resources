'==================================================================================================
'											   EM Sounds
'==================================================================================================

Const kMasterVolume = 0.8					'value no greater than 1.
Const kPanScalar = 0.2						'smaller value, less "spread" of audio channels
Const kFadeScalar = 0.25					'smaller value, less "spread" of audio channels
Const kMinSoundPanLeft = -1.0
Const kSoundPanLeft = -0.9
Const kSoundPanCenter = 0.0
Const kSoundPanRight = 0.9
Const kMaxSoundPanRight = 1.0
Const kMinSoundFadeNearBackglass = -1.0
Const kSoundFadeNearBackglass = -0.9
Const kSoundFadeCenter = 0.0
Const kSoundFadeNearPlayer = 0.9
Const kMaxSoundFadeNearPlayer = 1.0
Const kDontLoopSound = 0
Const kLoopUntilStopped = -1
Const kNoRandomPitch = 0
Const kNoPitchChange = 0
Const kDontUseExistingSound = 0
Const kUseExistingSound = 1
Const kNoRestartSound = 0
Const kRestartSound = 1

Dim tablewidth, tableheight
tablewidth = 1000							'reasonable defaults, 
tableheight = 2000							'but please call EMSoundInit() to get real values assigned

' Pass table object, call before any sound is played
Sub EMSoundInit(tableObject)
	tableheight = tableObject.height
	tablewidth = tableObject.width
End Sub

' Calculates the volume of the sound based on the ball speed
Function EMVolumeForBall(ball)
    EMVolumeForBall = Csng(EMBallVelocity(ball) ^2)
End Function

' Scale pan so there is some bleed-over of left/right channels.
' ex: with headphones you don't want the plunger only in the right ear.
Function EMTransformPan(pan)
	EMTransformPan = pan * kPanScalar
End Function

' Determines pan based on x position on table (-1 is table-left, 0 is table-center, 1 is table-right).
Function EMPanForTableX(x)
    EMPanForTableX = Csng((x * 2 / tablewidth) - 1)
	If EMPanForTableX < kMinSoundPanLeft Then
		EMPanForTableX = kMinSoundPanLeft
	ElseIf EMPanForTableX > kMaxSoundPanRight Then
		EMPanForTableX = kMaxSoundPanRight
	End If
End Function

' Scale fade so there is some bleed-over between front/back channels.
Function EMTransformFade(fade)
	EMTransformFade = fade * kFadeScalar
End Function

' Determines fade based on y position on table (-1 is table-far, 0 is table-center, 1 is table-near).
Function EMFadeForTableY(y)
    EMFadeForTableY = Csng((y * 2 / tableheight) - 1)
	If EMFadeForTableY < kMinSoundFadeNearBackglass Then
		EMFadeForTableY = kMinSoundFadeNearBackglass
	ElseIf EMFadeForTableY > kMaxSoundFadeNearPlayer Then
		EMFadeForTableY = kMaxSoundFadeNearPlayer
	End If
End Function

Sub EMPlaySoundAtVolumePanAndFade (soundName, soundVolume, soundPan, soundFade)
	PlaySound soundName, kDontLoopSound, soundVolume * kMasterVolume, soundPan, kNoRandomPitch, kNoPitchChange, kDontUseExistingSound, kNoRestartSound, soundFade
End Sub

Sub EMPlaySoundAtVolumeForObject (soundName, soundVolume, forObj)
	Dim pan
	pan = EMPanForTableX (forObj.x)
	pan = EMTransformPan (pan)
	Dim fade
	fade = EMFadeForTableY (forObj.y)
	fade = EMTransformFade (fade)
	EMPlaySoundAtVolumePanAndFade soundName, soundVolume, pan, fade
End Sub

Sub EMPlaySoundAtVolumeForActiveBall(soundName, soundVolume)
	Dim pan
	pan = EMPanForTableX (ActiveBall.x)
	pan = EMTransformPan (pan)
	Dim fade
	fade = EMFadeForTableY (ActiveBall.y)
	fade = EMTransformFade (fade)
	EMPlaySoundAtVolumePanAndFade soundName, soundVolume, pan, fade
End Sub

Sub EMPlaySoundExistingAtVolumePanAndFade(soundName, soundVolume, soundPan, soundFade)
	PlaySound soundName, kDontLoopSound, soundVolume * kMasterVolume, soundPan, kNoRandomPitch, kNoPitchChange, kUseExistingSound, kNoRestartSound, soundFade
End Sub

Sub EMPlaySoundExistingAtVolumeForBall(soundName, soundVolume)
	Dim pan
	pan = EMPanForTableX (ActiveBall.x)
	pan = EMTransformPan (pan)
	Dim fade
	fade = EMFadeForTableY (ActiveBall.y)
	fade = EMTransformFade (fade)
	EMPlaySoundExistingAtVolumePanAndFade soundName, soundLevel, pan, fade
End Sub

Sub EMPlaySoundLoopedAtVolumeForObject(soundName, loopCount, soundVolume, forObj)
	Dim pan
	pan = EMPanForTableX (forObj.x)
	pan = EMTransformPan (pan)
	Dim fade
	fade = EMFadeForTableY (forObj.y)
	fade = EMTransformFade (fade)
	PlaySound soundName, loopCount, soundVolume * kMasterVolume, pan, kNoRandomPitch, kNoPitchChange, kDontUseExistingSound, kRestartSound, fade
End Sub

'------------------------------------------------------------------------------------- Ball Rolling

Function EMBallVelocity(ball) 'Calculates the ball speed
    EMBallVelocity = INT(SQR((ball.VelX ^2) + (ball.VelY ^2)))
End Function

Dim RollingSoundScalar
RollingSoundScalar = 0.22

Function EMVolPlayfieldRoll(ball) ' Calculates the roll volume of the sound based on the ball speed
	EMVolPlayfieldRoll = RollingSoundScalar * 0.0005 * Csng(EMBallVelocity(ball) ^3)
End Function

Function EMPitchPlayfieldRoll(ball) ' Calculates the roll pitch of the sound based on the ball speed
	EMPitchPlayfieldRoll = EMBallVelocity(ball) ^2 * 15
End Function

Function EMPitch(ball) ' Calculates the pitch of the sound based on the ball speed
    EMPitch = EMBallVelocity(ball) * 20
End Function

Const tnob = 5		'total number of balls
Const lob = 0		'number of locked balls

ReDim rolling(tnob)
InitRolling

Sub InitRolling
	Dim i
	For i = 0 To tnob
		rolling(i) = False
	Next
End Sub

Sub RollingSoundTimer_Timer()
	Dim BOT, b
	BOT = GetBalls
    
	' stop the sound of deleted balls
	For b = UBound(BOT) + 1 To tnob
		rolling(b) = False
		StopSound("BallRoll_" & b)
	Next
	
	' exit the Sub If no balls on the table
	If UBound(BOT) = -1 Then Exit Sub
	
	' play the rolling sound For each ball
	For b = 0 To UBound(BOT)
		If EMBallVelocity(BOT(b)) > 1 AND BOT(b).z < 30 Then
			rolling(b) = True
			Dim pan
			pan = EMPanForTableX (BOT(b).x)
			pan = EMTransformPan (pan)
			Dim fade
			fade = EMFadeForTableY (BOT(b).y)
			fade = EMTransformFade (fade)
			PlaySound ("BallRoll_" & b), kLoopUntilStopped, EMVolPlayfieldRoll(BOT(b)) * 1.1 * kMasterVolume, pan, kNoRandomPitch, EMPitchPlayfieldRoll(BOT(b)), kUseExistingSound, kNoRestartSound, fade
		Else
			If rolling(b) = True Then
				StopSound("BallRoll_" & b)
				rolling(b) = False
			End If
		End If
	Next
End Sub

'------------------------------------------------------------------------------------- Start Sounds

Dim CoinSoundLevel
CoinSoundLevel = 1							'volume level; range [0, 1]

Sub EMPlayCoinSound()
	EMPlaySoundAtVolumePanAndFade ("Coin_In_" & Int(Rnd * 3) + 1), CoinSoundLevel, kSoundPanCenter, EMTransformFade(kSoundFadeNearPlayer)
End Sub

Dim StartButtonLevel
StartButtonLevel = 1.0						'volume level; range [0, 1]

Sub EMPlayStartButttonSound()
	EMPlaySoundAtVolumePanAndFade "Start_Button", StartButtonLevel, kSoundPanLeft, kSoundFadeNearPlayer
End Sub

Dim StartupSoundLevel
StartupSoundLevel = 1						'volume level; range [0, 1]

Sub EMPlayStartupSound()
	EMPlaySoundAtVolumePanAndFade "startup_norm", StartupSoundLevel, kSoundPanCenter, EMTransformFade(kSoundFadeNearBackglass)
End Sub

Dim PlungerPullSoundLevel
PlungerPullSoundLevel = 0.8					'volume level; range [0, 1]

Sub EMPlayPlungerPullSound(plungerObj)
	EMPlaySoundAtVolumeForObject "Plunger_Pull_1", PlungerPullSoundLevel, plungerObj	
End Sub

Dim PlungerReleaseSoundLevel
PlungerReleaseSoundLevel = 0.8				'volume level; range [0, 1]

Sub EMPlayPlungerReleaseBallSound(plungerObj)
	EMPlaySoundAtVolumeForObject "Plunger_Release_Ball", PlungerReleaseSoundLevel, plungerObj	
End Sub

Dim StartBallSoundLevel
StartBallSoundLevel = 0.4					'volume level; range [0, 1]

Sub EMPlayStartBallSound(which)
	Dim sndName
	If which=0 Then
		sndName = "StartBall1"
	Else
		sndName = "StartBall2-5"
	End If
	EMPlaySoundAtVolumePanAndFade sndName, StartBallSoundLevel, kSoundPanCenter, EMTransformFade(kSoundFadeNearPlayer)
End Sub

Dim BallReleaseSoundLevel
BallReleaseSoundLevel = 1.0					'volume level; range [0, 1]

Sub EMPlayBallReleaseSound()
	EMPlaySoundAtVolumePanAndFade ("BallRelease" & Int(Rnd * 7) + 1), BallReleaseSoundLevel, EMTransformPan(kSoundPanRight), EMTransformFade(kSoundFadeNearPlayer)
End Sub

Dim RotateThroughPlayersSoundLevel
RotateThroughPlayersSoundLevel = 0.8		'volume level; range [0, 1]

Sub EMPlayRotateThroughPlayersSound
	EMPlaySoundAtVolumePanAndFade "RotateThruPlayers", RotateThroughPlayersSoundLevel, kSoundPanCenter, EMTransformFade(kSoundFadeNearPlayer)
End Sub

'----------------------------------------------------------------------------------- Flipper Sounds

Dim FlipperUpAttackMinimumSoundLevel, FlipperUpAttackMaximumSoundLevel
FlipperUpAttackMinimumSoundLevel = 0.010	'volume level; range [0, 1]
FlipperUpAttackMaximumSoundLevel = 0.635	'volume level; range [0, 1]

Dim FlipperUpSoundLevel
FlipperUpSoundLevel = 1.0					'volume level; range [0, 1]

Dim FlipperLeftHitParm, FlipperRightHitParm
FlipperLeftHitParm = FlipperUpSoundLevel	'sound helper; not configurable
FlipperRightHitParm = FlipperUpSoundLevel	'sound helper; not configurable

Dim FlipperBuzzSoundLevel
FlipperBuzzSoundLevel = 0.05				'volume level; range [0, 1]

Sub EMPlayLeftFlipperUpAttackSound (flipperObj)
	Dim soundLevel
	soundLevel = Rnd() * (FlipperUpAttackMaximumSoundLevel-FlipperUpAttackMinimumSoundLevel) + FlipperUpAttackMinimumSoundLevel
	EMPlaySoundAtVolumeForObject SoundFX("Flipper_Attack-L01", DOFFlippers), soundLevel, flipperObj	
	EMPlaySoundLoopedAtVolumeForObject "buzzL", kLoopUntilStopped, FlipperBuzzSoundLevel, flipperObj
End Sub

Sub EMPlayRightFlipperUpAttackSound (flipperObj)
	Dim soundLevel
	soundLevel = Rnd() * (FlipperUpAttackMaximumSoundLevel-FlipperUpAttackMinimumSoundLevel) + FlipperUpAttackMinimumSoundLevel
	EMPlaySoundAtVolumeForObject SoundFX("Flipper_Attack-R01", DOFFlippers), soundLevel, flipperObj
	EMPlaySoundLoopedAtVolumeForObject "buzz", kLoopUntilStopped, FlipperBuzzSoundLevel, flipperObj
End Sub

Sub EMPlayLeftFlipperUpSound (flipperObj)
	EMPlaySoundAtVolumeForObject SoundFX("Flipper_L0" & Int(Rnd * 9) + 1, DOFFlippers), FlipperLeftHitParm, flipperObj
End Sub

Sub EMPlayRightFlipperUpSound (flipperObj)
	EMPlaySoundAtVolumeForObject SoundFX("Flipper_R0" & Int(Rnd * 9) + 1, DOFFlippers), FlipperRightHitParm, flipperObj
End Sub

Dim FlipperReflipSoundLevel
FlipperReflipSoundLevel = 0.8				'volume level; range [0, 1]

Sub EMPlayLeftFlipperReflipSound (flipperObj)
	EMPlaySoundAtVolumeForObject SoundFX("Flipper_ReFlip_L0" & Int(Rnd * 3) + 1, DOFFlippers), FlipperReflipSoundLevel, flipperObj
End Sub

Sub EMPlayRightFlipperReflipSound (flipperObj)
	EMPlaySoundAtVolumeForObject SoundFX("Flipper_ReFlip_R0" & Int(Rnd * 3) + 1, DOFFlippers), FlipperReflipSoundLevel, flipperObj
End Sub

Dim FlipperDownSoundLevel
FlipperDownSoundLevel = 0.45				'volume level; range [0, 1]

Sub EMPlayLeftFlipperDownSound(flipperObj)
	EMPlaySoundAtVolumeForObject SoundFX("Flipper_Left_Down_" & Int(Rnd * 7) + 1, DOFFlippers), FlipperDownSoundLevel, flipperObj
	StopSound "buzzL"
End Sub

Sub EMPlayRightFlipperDownSound(flipperObj)
	EMPlaySoundAtVolumeForObject SoundFX("Flipper_Right_Down_" & Int(Rnd * 8) + 1, DOFFlippers), FlipperDownSoundLevel, flipperObj
	StopSound "buzz"
End Sub

Dim RubberFlipperSoundScalar
RubberFlipperSoundScalar = 0.015			'volume multiplier; must not be zero

Sub EMPlayLeftFlipperCollideSound(parm)
	FlipperLeftHitParm = parm / 10
	If FlipperLeftHitParm > 1 Then
		FlipperLeftHitParm = 1
	End If
	FlipperLeftHitParm = FlipperUpSoundLevel * FlipperLeftHitParm
	EMPlaySoundAtVolumeForActiveBall ("Flipper_Rubber_" & Int(Rnd * 7) + 1), parm  * RubberFlipperSoundScalar
End Sub

Sub EMPlayRightFlipperCollideSound(parm)
	FlipperRightHitParm = parm / 10
	If FlipperRightHitParm > 1 Then
		FlipperRightHitParm = 1
	End If
	FlipperRightHitParm = FlipperUpSoundLevel * FlipperRightHitParm
	EMPlaySoundAtVolumeForActiveBall ("Flipper_Rubber_" & Int(Rnd * 7) + 1), parm  * RubberFlipperSoundScalar
End Sub

Sub EMStopBuzzSounds()
	StopSound "buzzL"
	StopSound "buzz"
End Sub

'--------------------------------------------------------------------------------- Playfield Sounds

Dim MetalImpactSoundScalar
MetalImpactSoundScalar = 0.025

Sub EMPlayMetalHitSound
	EMPlaySoundAtVolumeForActiveBall ("Metal_Touch_" & Int(Rnd * 13) + 1), EMVolumeForBall(ActiveBall) * MetalImpactSoundScalar
End Sub

Dim GateHitSoundLevel
GateHitSoundLevel = 0.1						'volume level; range [0, 1]

Sub EMPlayGateHitSound()
	EMPlaySoundAtVolumeForActiveBall ("gate4"), GateHitSoundLevel
End Sub

Dim DrainSoundLevel
DrainSoundLevel = 0.8						'volume level; range [0, 1]

Sub EMPlayDrainSound(drainObj)
	EMPlaySoundAtVolumeForObject ("Drain_" & Int(Rnd * 11) + 1), DrainSoundLevel, drainObj
End Sub

Dim RubberStrongSoundScalar, RubberWeakSoundScalar
RubberStrongSoundScalar = 0.011				'volume multiplier; must not be zero
RubberWeakSoundScalar = 0.015				'volume multiplier; must not be zero

Sub EMPlayRubberHitSound()
	Dim finalspeedSquared
	finalspeedSquared = (activeball.velx * activeball.velx) + (activeball.vely * activeball.vely)
	If finalspeedSquared > 25 Then			'strong
		Dim soundIndex
		soundIndex = Int(Rnd * 10) + 1
		If soundIndex > 9 Then
			EMPlaySoundAtVolumeForActiveBall "Rubber_1_Hard", EMVolumeForBall(ActiveBall) * RubberStrongSoundScalar * 0.6
		Else
			EMPlaySoundAtVolumeForActiveBall ("Rubber_Strong_" & Int(soundIndex)), EMVolumeForBall(ActiveBall) * RubberStrongSoundScalar
		End If
	Else									'weak
		EMPlaySoundAtVolumeForActiveBall ("Rubber_" & Int(Rnd * 9) + 1), EMVolumeForBall(ActiveBall) * RubberWeakSoundScalar
	End If
End Sub

Dim PostSoundScalar
PostSoundScalar = 0.1						'volume level; range [0, 1]

Sub EMPlayPostHitSound()
	Dim finalspeedSquared
  	finalspeedSquared = (activeball.velx * activeball.velx) + (activeball.vely * activeball.vely)
 	If finalspeedSquared > 256 Then
		EMPlaySoundAtVolumeForActiveBall "fx_rubber2", EMVolumeForBall(ActiveBall) * PostSoundScalar
	ElseIf finalspeedSquared >= 36 Then
 		EMPlayRubberHitSound()
 	End If
End Sub

Dim SaucerLockSoundLevel
SaucerLockSoundLevel = 0.8					'volume level; range [0, 1]

Sub EMPlaySaucerLockSound()
	EMPlaySoundAtVolumeForActiveBall ("Saucer_Enter_" & Int(Rnd * 2) + 1), SaucerLockSoundLevel
End Sub

Dim SaucerKickSoundLevel
SaucerKickSoundLevel = 0.8					'volume level; range [0, 1]

Sub EMPlaySaucerKickSound(scenario, saucerObj)
	Select Case scenario
		Case 0: EMPlaySoundAtVolumeForObject SoundFX("Saucer_Empty", DOFContactors), SaucerKickSoundLevel, saucerObj
		Case 1: EMPlaySoundAtVolumeForObject SoundFX("Saucer_Kick", DOFContactors), SaucerKickSoundLevel, saucerObj
	End Select
End Sub

Dim SlingshotSoundLevel
SlingshotSoundLevel = 0.95					'volume level; range [0, 1]

Sub EMPlayLeftSlingshotSound(sling)
	EMPlaySoundAtVolumeForObject SoundFX("Sling_L" & Int(Rnd * 10) + 1, DOFContactors), SlingshotSoundLevel, Sling
End Sub

Sub EMPlayRightSlingshotSound(sling)
	EMPlaySoundAtVolumeForObject SoundFX("Sling_R" & Int(Rnd * 8) + 1, DOFContactors), SlingshotSoundLevel, Sling
End Sub

Dim BumperSoundScalar
BumperSoundScalar = 6.0						'volume multiplier; must not be zero

Sub EMPlayTopBumperSound(bumperObj)
	EMPlaySoundAtVolumeForObject SoundFX("Bumpers_Top_" & Int(Rnd * 5) + 1,DOFContactors), EMVolumeForBall(ActiveBall) * BumperSoundScalar, bumperObj
End Sub

Sub EMPlayMiddleBumperSound(bumperObj)
	EMPlaySoundAtVolumeForObject SoundFX("Bumpers_Middle_" & Int(Rnd * 5) + 1,DOFContactors), EMVolumeForBall(ActiveBall) * BumperSoundScalar, bumperObj
End Sub

Dim RolloverSoundLevel
RolloverSoundLevel = 0.25					'volume level; range [0, 1]

Sub EMPlayRolloverSound()
	EMPlaySoundAtVolumeForActiveBall ("Rollover_" & Int(Rnd * 4) + 1), RolloverSoundLevel
End Sub

Dim SensorSoundLevel
SensorSoundLevel = 1.0						'volume level; range [0, 1]

Sub EMPlaySensorSound()
	EMPlaySoundAtVolumeForActiveBall "sensor", SensorSoundLevel
End Sub

Dim ScoopExitSoundLevel
ScoopExitSoundLevel = 1.0					'volume level; range [0, 1]

Sub EMPlayScoopExitSound()
	EMPlaySoundAtVolumeForActiveBall "scoopexit", ScoopExitSoundLevel
End Sub

Dim TargetSoundScalar
TargetSoundScalar = 0.025					'volume multiplier; must not be zero

Sub EMPlayTargetHitSound()
	Dim finalspeedSquared
	finalspeedSquared = (activeball.velx * activeball.velx + activeball.vely * activeball.vely)
	If finalspeedSquared > 100 Then
		EMPlaySoundAtVolumeForActiveBall SoundFX("Target_Hit_" & Int(Rnd * 4) + 5, DOFTargets), EMVolumeForBall(ActiveBall) * 0.45 * TargetSoundScalar
	Else 
		EMPlaySoundAtVolumeForActiveBall SoundFX("Target_Hit_" & Int(Rnd * 4) + 1, DOFTargets), EMVolumeForBall(ActiveBall) * TargetSoundScalar
	End If	
End Sub

Dim DropTargetResetSoundLevel
DropTargetResetSoundLevel = 1.0				'volume level; range [0, 1]

Sub EMPlayDropTargetResetSound()
	EMPlaySoundAtVolumePanAndFade "dropsup", DropTargetResetSoundLevel, kSoundPanCenter, kSoundFadeCenter
End Sub

Dim PinHitSoundLevel
PinHitSoundLevel = 1.0						'volume level; range [0, 1]

Sub EMPlayPinHitSound()
	EMPlaySoundAtVolumeForActiveBall "pinhit_low", PinHitSoundLevel
End Sub

Dim SpinnerSoundLevel
SpinnerSoundLevel = 1.0						'volume level; range [0, 1]

Sub EMPlaySpinnerSound (spinnerObj)
	EMPlaySoundAtVolumeForObject "Spinner", SpinnerSoundLevel, spinnerObj	
End Sub

'------------------------------------------------------------------------------------- Other Sounds

Dim ClickLevel
ClickLevel = 1.0							'volume level; range [0, 1]

Sub EMPlayClickSound()
	EMPlaySoundAtVolumePanAndFade "click", ClickLevel, kSoundPanCenter, kSoundFadeCenter
End Sub

Dim RotoStartLevel
RotoStartLevel = 1.0						'volume level; range [0, 1]

Sub EMPlayRotoStartSound()
	EMPlaySoundAtVolumePanAndFade "RotoStart", RotoStartLevel, EMTransformPan(kSoundPanLeft), EMTransformFade(kSoundFadeNearBackglass)
End Sub

Dim VariTargetLevel
VariTargetLevel = 1.0						'volume level; range [0, 1]

Sub EMPlayVariTargetSound()
	EMPlaySoundAtVolumeForActiveBall "fx_solenoidoff", VariTargetLevel
End Sub

Dim ChimeLevel
ChimeLevel = 0.5							'volume level; range [0, 1]

Sub EMPlayChimeSound(chimeNum)
	Dim sndName
	Select Case chimeNum
		Case 0
			If (Rnd * 2) > 0 Then
				sndName = "SJ_Chime_10a"
			Else
				sndName = "SJ_Chime_10b"
			End If
		Case 1
			If (Rnd * 2) > 0 Then
				sndName = "SJ_Chime_100a"
			Else
				sndName = "SJ_Chime_100b"
			End If
		Case 2
			If (Rnd * 2) > 0 Then
				sndName = "SJ_Chime_1000a"
			Else
				sndName = "SJ_Chime_1000b"
			End If
		Case Else
			Exit Sub
	End Select
	EMPlaySoundAtVolumePanAndFade sndName, ChimeLevel, EMTransformPan(kSoundPanRight), kSoundFadeCenter
End Sub

Dim BellLevel
BellLevel = 0.25							'volume level; range [0, 1]

Sub EMPlayBellSound(bellNum)
	Select Case bellNum
		Case 0
			EMPlaySoundAtVolumePanAndFade "SpinACard_10_Point_Bell", BellLevel, EMTransformPan(kSoundPanRight), kSoundFadeCenter
		Case 1
			EMPlaySoundAtVolumePanAndFade "SpinACard_100_Point_Bell", BellLevel, EMTransformPan(kSoundPanRight), kSoundFadeCenter
		Case 2
			EMPlaySoundExistingAtVolumePanAndFade "SpinACard_1000_Point_Bell", BellLevel, EMTransformPan(kSoundPanRight), kSoundFadeCenter
	End Select
End Sub

Dim KnockerSoundLevel
KnockerSoundLevel = 1.0						'volume level; range [0, 1]

Sub EMPlayKnockerSound()
	EMPlaySoundAtVolumePanAndFade "Knocker_1", KnockerSoundLevel, kSoundPanCenter, EMTransformFade(kSoundFadeNearBackglass)
End Sub

Dim MotorLeerSoundLevel
MotorLeerSoundLevel = 1.0					'volume level; range [0, 1]

Sub EMPlayMotorLeerSound()
	EMPlaySoundAtVolumePanAndFade "MotorLeer", MotorLeerSoundLevel, kSoundPanCenter, EMTransformFade(kSoundFadeNearBackglass)
End Sub

Dim MotorPauseSoundLevel
MotorPauseSoundLevel = 1.0					'volume level; range [0, 1]

Sub EMPlayMotorPauseSound()
	EMPlaySoundAtVolumePanAndFade "MotorPause", MotorPauseSoundLevel, kSoundPanCenter, EMTransformFade(kSoundFadeNearBackglass)
End Sub

'==================================================================================================
'											 End EM Sounds
'==================================================================================================
