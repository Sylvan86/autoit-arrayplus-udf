#include "ArrayPlus.au3"

Global $aArray[100][3]
Local $t = -1
For $i = 0 To UBound($aArray) - 1
	$t += Random(1, 100, 1) ; random to avoid to create a best-case scenario (entries from 0 to N with Step 1)
	$aArray[$i][0] = $t
	$aArray[$i][1] = "Teststring " & $t
Next
_ArrayDisplay($aArray)

$x = _ArrayInterpolationSearch($aArray, $aArray[80][0])
$ext = @extended
_ArrayDisplay($x, $ext)


Func _ArrayInterpolationSearch(ByRef $aArray, Const $vSearch, Const $nRow = 0, $iFrom = 0, $iTo = UBound($aArray) - 1, Const $bFuzzy = True)
	Local $dx, $dy, $m, $b
	Local $iMatch = -1

	If UBound($aArray, 0) = 1 Then ; 1D-array
		If $vSearch < $aArray[$iFrom] Then Return $bFuzzy ? SetExtended($iFrom, $aArray[$iFrom]) : SetError(1, -1, Null)
		If $vSearch > $aArray[$iTo] Then Return $bFuzzy ? SetExtended($iFrom, $aArray[$iTo]) : SetError(1, -1, Null)

		Do
			$dx = $iTo - $iFrom
			If $dx = 1 Then
				If $aArray[$iTo] = $vSearch Then
					$iMatch = $iTo
				ElseIf $aArray[$iFrom] = $vSearch Then
					$iMatch = $iFrom
				EndIf
				ExitLoop
			EndIf
			If $dx = 0 Then ExitLoop
			$dy = $aArray[$iTo] - $aArray[$iFrom]
			If $dy = 0 Then
				If $aArray[$iFrom] = $vSearch Then
					$iMatch = $iFrom
				EndIf
				ExitLoop
			EndIf
			$m = $dy / $dx
			$b = Int(($vSearch - $aArray[$iFrom]) / $m)
			$p = $iFrom + $b
			If $aArray[$p] = $vSearch Then ; found
				$iMatch = $p
				ExitLoop
			ElseIf $aArray[$p] > $vSearch Then
				$iTo = $p - 1
			Else
				$iFrom = $p + 1
			EndIf
		Until $iFrom > $iTo

		If $iMatch = -1 Then ; no match found
			If $bFuzzy = True Then
				Return Abs($vSearch - $aArray[$iFrom]) <= Abs($vSearch - $aArray[$iTo]) _
						 ? SetExtended($iFrom, $aArray[$iFrom]) _
						 : SetExtended($iTo, $aArray[$iTo])
			Else
				Return SetError(1, -1, Null)
			EndIf
		Else ; match found
			Return SetExtended($iMatch, $aArray[$iMatch])
		EndIf

	Else ; 2D-array
		If $vSearch < $aArray[$iFrom][$nRow] Then Return $bFuzzy ? SetExtended($iFrom, _ArraySlice($aArray, "[" & $iFrom & "][:]")) : SetError(1, -1, Null)
		If $vSearch > $aArray[$iTo][$nRow] Then Return $bFuzzy ? SetExtended($iTo, _ArraySlice($aArray, "[" & $iTo & "][:]")) : SetError(1, -1, Null)

		Do
			$dx = $iTo - $iFrom
			If $dx = 1 Then
				If $aArray[$iTo][$nRow] = $vSearch Then
					$iMatch = $iTo
				ElseIf $aArray[$iFrom][$nRow] = $vSearch Then
					$iMatch = $iFrom
				EndIf
				ExitLoop
			EndIf
			If $dx = 0 Then ExitLoop
			$dy = $aArray[$iTo][$nRow] - $aArray[$iFrom][$nRow]
			If $dy = 0 Then
				If $aArray[$iFrom][$nRow] = $vSearch Then
					$iMatch = $iFrom
				EndIf
				ExitLoop
			EndIf
			$m = $dy / $dx
			$b = Int(($vSearch - $aArray[$iFrom][$nRow]) / $m)
			$p = $iFrom + $b
			If $aArray[$p][$nRow] = $vSearch Then ; found
				$iMatch = $p
				ExitLoop
			ElseIf $aArray[$p][$nRow] > $vSearch Then
				$iTo = $p - 1
			Else
				$iFrom = $p + 1
			EndIf
		Until $iFrom > $iTo

		If $iMatch = -1 Then ; no match found
			If $bFuzzy = True Then
				Return Abs($vSearch - $aArray[$iFrom][$nRow]) <= Abs($vSearch - $aArray[$iTo][$nRow]) _
						 ? SetExtended($iFrom, _ArraySlice($aArray, "[" & $iFrom & "][:]")) _
						 : SetExtended($iTo, _ArraySlice($aArray, "[" & $iTo & "][:]"))
			Else
				Return SetError(1, -1, Null)
			EndIf
		Else ; match found
			Return SetExtended($iMatch, _ArraySlice($aArray, "[" & $iMatch & "][:]"))
		EndIf
	EndIf
EndFunc   ;==>_ArrayInterpolationSearch