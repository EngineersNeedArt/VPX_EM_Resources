'==================================================================================================
'											  Ball Shadow
'==================================================================================================

Dim BallShadow
BallShadow = Array (BallShadow1, BallShadow2, BallShadow3, BallShadow4, BallShadow5)

Sub BallShadowUpdate_timer ()
	Dim BallsOnTable, B
	BallsOnTable = GetBalls
	
	' Hide shadow of deleted balls.
	If UBound(BallsOnTable) < (NumberOfBalls - 1) Then
		For B = (UBound(BallsOnTable) + 1) To (NumberOfBalls - 1)
			BallShadow(B).Visible = 0
		Next
	End If
	
	' Exit if no balls on the table.
	If UBound(BallsOnTable) = -1 Then Exit Sub
	
	' Render the shadow for each ball.
	For B = 0 To UBound(BallsOnTable)
		If BallsOnTable(B).X < TableWidth / 2 Then
			BallShadow(B).X = ((BallsOnTable(B).X) - (Ballsize / 16) + ((BallsOnTable(B).X - (TableWidth / 2)) / 17))	' + 13
		Else
			BallShadow(B).X = ((BallsOnTable(B).X) + (Ballsize / 16) + ((BallsOnTable(B).X - (TableWidth / 2)) / 17))	' - 13
		End If
		BallShadow(B).Y = BallsOnTable(B).Y + 10
		If BallsOnTable(B).Z > 20 Then
			BallShadow(B).Visible = 1
		Else
			BallShadow(B).Visible = 0
		End If
	Next
End Sub
