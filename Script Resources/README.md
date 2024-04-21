**EMSounds.bas Public Routines**

Inititialization:
```
EMSInit (TableObj)
```

General purpose spatial sound functions:
```
EMSPlaySoundAtVolumePanAndFade (SoundName, Volume, Pan, Fade)
EMSPlaySoundAtVolumeForObject (SoundName, Volume, ForObj)
EMSPlaySoundAtVolumeForActiveBall (SoundName, Volume)
EMSPlaySoundExistingAtVolumePanAndFade (SoundName, Volume, Pan, Fade)
EMSPlaySoundExistingAtVolumeForActiveBall (SoundName, Volume)
EMSPlaySoundLoopedAtVolumeForObject (SoundName, LoopCount, Volume, ForObj)
```

Game begin sounds:
```
EMSPlayCoinSound ()
EMSPlayStartupSound ()
EMSPlayPlungerPullSound (PlungerObj)
EMSPlayPlungerReleaseBallSound (PlungerObj)
EMSPlayPlungerReleaseNoBallSound (PlungerObj)
EMSPlayStartBallSound (Which)
EMSPlayBallReleaseSound ()
EMSPlayRotateThroughPlayersSound ()
```

Flipper sounds:
```
EMSPlayLeftFlipperActivateSound (FlipperObj)
EMSPlayRightFlipperActivateSound (FlipperObj)
EMSPlayLeftFlipperDeactivateSound (FlipperObj)
EMSPlayRightFlipperDeactivateSound (FlipperObj)
EMSPlayLeftFlipperCollideSound (Parm)
EMSPlayRightFlipperCollideSound (Parm)
EMSStopBuzzSounds ()
```

Playfield sounds:
```
EMSPlayMetalHitSound ()
EMSPlayGateHitSound ()
EMSPlayDrainSound (DrainObj)
EMSPlayRubberHitSound ()
EMSPlayLeftSlingshotSound (Sling)
EMSPlayRightSlingshotSound(Sling)
EMSPlayTopBumperSound (BumperObj)
EMSPlayMiddleBumperSound (BumperObj)
EMSPlayBottomBumperSound (BumperObj)
EMSPlaySensorSound ()
EMSPlayTargetHitSound ()
EMSPlayDropTargetResetSound ()
```

Other sounds:
```
EMSPlayClickSound ()
EMSPlayChimeSound (ChimeNum)
EMSPlayBellSound (BellNum)
EMSPlayKnockerSound ()
EMSPlayMotorLeerSound ()
EMSPlayNudgeSound ()
```


**EMSounds_Extra.bas Routines**

*- requires code from EMSounds.bas*

*- copy over routines as needed*
```
EMSPlayStartButtonSound ()
EMSPlayPostHitSound ()
EMSPlayPinHitSound ()
EMSPlayRolloverSound()
EMSPlaySaucerLockSound ()
EMSPlaySaucerKickSound (scenario, saucerObj)
EMSPlaySpinnerSound (SpinnerObj)
EMSPlayVariTargetSound ()
EMSPlayRotoStartSound ()
```
