'==================================================================================================
'											  Ball Shadow
'==================================================================================================

Dim BallShadow
BallShadow = Array (BallShadow1, BallShadow2, BallShadow3, BallShadow4, BallShadow5)

Sub BallShadowUpdate_timer ()
	Dim BOT, B
	BOT = GetBalls
	
	' Hide shadow of deleted balls.
	If UBound(BOT) < (NumberOfBalls - 1) Then
		For B = (UBound(BOT) + 1) To (NumberOfBalls - 1)
			BallShadow(B).Visible = 0
		Next
	End If
	
	' Exit if no balls on the table.
	If UBound(BOT) = -1 Then Exit Sub
	
	' Render the shadow for each ball.
	For B = 0 To UBound(BOT)
		If BOT(B).X < TableWidth / 2 Then
			BallShadow(B).X = ((BOT(B).X) - (Ballsize / 16) + ((BOT(B).X - (TableWidth / 2)) / 17))	' + 13
		Else
			BallShadow(B).X = ((BOT(B).X) + (Ballsize / 16) + ((BOT(B).X - (TableWidth / 2)) / 17))	' - 13
		End If
		BallShadow(B).Y = BOT(B).Y + 10
		If BOT(B).Z > 20 Then
			BallShadow(B).Visible = 1
		Else
			BallShadow(B).Visible = 0
		End If
	Next
End Sub
