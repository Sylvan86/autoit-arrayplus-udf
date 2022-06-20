#include-once
#include <Array.au3>
#include <File.au3>


Global Enum Step *2 $A2C_BORDERS, $A2C_ALIGNDEC, $A2C_CENTERHEADENTRIES, $A2C_FIRSTROWHEADER, $A2C_TOCONSOLE



;  Func _ArrayDisplay(Const ByRef $aArray, $sTitle = Default, $sArrayRange = Default, $iFlags = Default, $vUser_Separator = Default, $sHeader = Default, $iMax_ColWidth = Default)

;  Global $aCSVRaw
;  _FileReadToArray("TempOessterreich.txt", $aCSVRaw, 4, @TAB)
;  _ArrayDisplay($aCSVRaw)


;  Global $aCSVRaw[5][3] = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12], [13, 14, 15]]
;  Global $aCSVRaw[] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
;  $aSliced = _ArraySlice($aCSVRaw, "6,8,9,6")

;  $aSliced = _ArraySlice($aCSVRaw, "[1,-2,4,2][1]")
;  $aSliced = _ArraySlice($aCSVRaw, "[1,3,5][2,1,0]")
;  ConsoleWrite(UBound($aSliced, 0) & @TAB & UBound($aSliced, 1) & @TAB & UBound($aSliced, 2) & @CRLF)
;  _ArrayDisplay($aSliced)
;  ConsoleWrite($aSliced & @CRLF)




;  _ArrayAlignDec(_ArrayCreate("[20.65, 4.1, 9999999, 10000.2, 100.2, 'Test', 23.765]"), Default, 2)


Func __stringCenter($sString, $nChars = Default)
	If $nChars = Default Then
		$nChars = StringLen($sString)
	EndIf
	$sString = StringStripWS($sString, 3)
	Local $nString = StringLen($sString)

	If $nChars < $nString Or $nChars < 1 Then Return SetError(1, $nChars, Null)

	Return StringFormat("%" & Ceiling(($nChars - $nString) / 2) & "s%" & _
			$nString & "s%" & _
			Floor(($nChars - $nString) / 2) & "s", _
			"", $sString, "")
EndFunc   ;==>__stringCenter

Func _ArrayAlignDec(ByRef $aArray, $iColumn = Default, $iDecimals = Default, $bTrailingZeros = False)
	Local $aParts, $nN = UBound($aArray), $nMaxReal, $nMaxDec = 0, $nMaxCol, $vVal, $nReal, $nDec

	; determine sizes:
	For $i = 0 To $nN - 1
		$vVal = ($iColumn = Default) ? $aArray[$i] : $aArray[$i][$iColumn]

		If IsFloat($vVal) Then
			$aParts = StringSplit($vVal, ".", 3)
			If StringLen($aParts[0]) > $nMaxReal Then $nMaxReal = StringLen($aParts[0])
			If StringLen($aParts[1]) > $nMaxDec Then $nMaxDec = StringLen($aParts[1])
		ElseIf IsInt($vVal) Then
			If $nMaxReal < StringLen($vVal) Then $nMaxReal = StringLen($vVal)
			If $nMaxCol < StringLen($vVal) Then $nMaxCol = StringLen($vVal)
		Else
			If $nMaxCol < StringLen($vVal) Then $nMaxCol = StringLen($vVal)
		EndIf
	Next
	If ($iDecimals <> Default) And ($iDecimals < $nMaxDec) Then $nMaxDec = $iDecimals
	If $nMaxDec > 0 And ($nMaxCol < ($nMaxReal + 1 + $nMaxDec)) Then $nMaxCol = $nMaxReal + 1 + $nMaxDec
	If $nMaxDec > 0 And ($nMaxCol > ($nMaxReal + 1 + $nMaxDec)) Then $nMaxReal = $nMaxCol - 1 - $nMaxDec

	For $i = 0 To $nN - 1
		$vVal = ($iColumn = Default) ? $aArray[$i] : $aArray[$i][$iColumn]

		If IsFloat($vVal) Then
			$vVal = StringFormat("%" & $nMaxReal + 1 + $nMaxDec & "." & $nMaxDec & "f", $vVal)
			If Not $bTrailingZeros Then $vVal = StringRegExpReplace($vVal, '(0(?=0*$))', ' ')

			If $iColumn = Default Then
				$aArray[$i] = $vVal
			Else
				$aArray[$i][$iColumn] = $vVal
			EndIf

		ElseIf IsInt($vVal) And $nMaxDec > 0 Then
			$vVal = StringFormat("% " & $nMaxReal & "s%-" & $nMaxDec + 1 & "s", $vVal, " ")
			If $iColumn = Default Then
				$aArray[$i] = $vVal
			Else
				$aArray[$i][$iColumn] = $vVal
			EndIf
		Else
			$vVal = StringFormat("% " & $nMaxCol & "s", $vVal)
			If $iColumn = Default Then
				$aArray[$i] = $vVal
			Else
				$aArray[$i][$iColumn] = $vVal
			EndIf
		EndIf
	Next

	Return SetExtended($nMaxDec, $nMaxCol)
EndFunc   ;==>_ArrayAlignDec


Func _Array2String($aArray, $sHeader = Default, $cSep = " | ", $iDecimals = Default, $dFlags = $A2C_BORDERS + $A2C_ALIGNDEC + $A2C_CENTERHEADENTRIES, $cRowSep = @CRLF) 
	Local $nR = UBound($aArray, 1), $nC = UBound($aArray, 2), $sOut = ""

	If UBound($aArray, 0) = 1 Then ; 1D-array

		If BitAND($dFlags, $A2C_ALIGNDEC) Then _ArrayAlignDec($aArray)

		For $i = 0 To UBound($aArray) - 1
			$sOut &= $aArray[$i] & $cRowSep
		Next
	Else ; 2D-array
		Local $aSizes[$nC], $vTemp, $aTmp

		; determine column widths
		If BitAND($dFlags, $A2C_ALIGNDEC) Then
			For $iC = 0 To $nC - 1
				$aSizes[$iC] = _ArrayAlignDec($aArray, $iC, $iDecimals)
			Next
		Else
			For $iC = 0 To $nC - 1
				For $iR = 0 To $nR - 1
					$vTemp = (IsFloat($aArray[$iR][$iC]) And $iDecimals <> Default) ? StringFormat("%." & $iDecimals & "f", $aArray[$iR][$iC]) : $aArray[$iR][$iC]
					If StringLen($vTemp) > $aSizes[$iC] Then $aSizes[$iC] = StringLen($vTemp)
				Next
			Next
		EndIf

		If $sHeader <> Default Then ; header treatment
			Local $aHeader
			If (IsBool($sHeader) And $sHeader = True) Or BitAND($dFlags, $A2C_FIRSTROWHEADER) Then ; first row = header row
				$dFlags = BitOR($dFlags, $A2C_FIRSTROWHEADER)
				$aHeader = _ArraySlice($aArray, "[0][:]")
			Else
				$aHeader = StringRegExp($sHeader, '\h*([^,]*[^\h,])', 3)
			EndIf

			If UBound($aHeader) <> $nC Then Return SetError(1, UBound($aHeader), Null)

			For $iH = 0 To UBound($aHeader) - 1
				If StringLen($aHeader[$iH]) > $aSizes[$iH] Then $aSizes[$iH] = StringLen($aHeader[$iH])

				$sOut &= BitAND($dFlags, $A2C_CENTERHEADENTRIES) ? _
						__stringCenter($aHeader[$iH], $aSizes[$iH]) & ($iH = $nC - 1 ? "" : $cSep) : _
						StringFormat("% " & $aSizes[$iH] & "s", $aHeader[$iH]) & ($iH = $nC - 1 ? "" : $cSep)
			Next
			$sOut &= @CRLF

			; header seperator
			For $iC = 0 To $nC - 1
				For $i = 1 To $aSizes[$iC] + ($iC = $nC - 1 ? 0 : StringLen($cSep))
					$sOut &= "-"
				Next
			Next
			$sOut &= @CRLF
		EndIf

		;  print data
		For $iR = (BitAND($dFlags, $A2C_FIRSTROWHEADER) ? 1 : 0) To $nR - 1
			For $iC = 0 To $nC - 1

				If BitAND($dFlags, $A2C_ALIGNDEC) Then
					$sOut &= StringFormat("% " & $aSizes[$iC] & "s", $aArray[$iR][$iC]) & ($iC = $nC - 1 ? "" : $cSep)
				Else
					$sOut &= StringFormat("%" & $aSizes[$iC] & "s", $aArray[$iR][$iC]) & ($iC = $nC - 1 ? "" : $cSep)
				EndIf
			Next
			$sOut &= @CRLF
		Next

		; lower border
		If BitAND($dFlags, $A2C_BORDERS) Then
			Local $sBorder = ""
			For $iC = 0 To $nC - 1
				For $i = 1 To $aSizes[$iC] + ($iC = $nC - 1 ? 0 : StringLen($cSep))
					$sBorder &= "="
				Next
			Next
			$sOut = $sBorder & @CRLF & $sOut & $sBorder & @CRLF
		EndIf
	EndIf

	If BitAND($dFlags, $A2C_TOCONSOLE) Then ConsoleWrite($sOut)
	Return $sOut

EndFunc   ;==>_Array2String






; Python-like array slicing
Func _ArraySlice(Const ByRef $aArray, Const $sSliceString)
	Local $nDims = UBound($aArray, 0), _
			$nN1 = UBound($aArray, 1), _
			$nN2 = UBound($aArray, 2)

	Local $aDimGroups = StringRegExp($sSliceString, '^\s*(?>\[([^\[]*)\]\s*(?>\[([^\[]*)\])?|\[?([^\[]*)\]?\s*$)\s*$', 3)
	Local $nGroups, $sGroup1, $sGroup2
	Switch UBound($aDimGroups)
		Case 1
			$nGroups = 1
			$sGroup1 = $aDimGroups[0]
		Case 2
			$nGroups = 2
			$sGroup1 = $aDimGroups[0]
			$sGroup2 = $aDimGroups[1]
		Case 3
			$nGroups = 1
			$sGroup1 = $aDimGroups[2]
		Case Else
			Return SetError(1, UBound($aDimGroups), Null)
	EndSwitch

	Local $iStart1, $iStop1, $iStep1, $iStart2, $iStop2, $iStep2, $aIndices1, $aIndices2

	; process first dimension group:
	Local $aRE = StringRegExp($sGroup1, '(?x)^\s*(\-?\d+|^\s*(?=:))(?>\:(\-?\d+|(?<=:)))?(?>\:(\-?\d+|(?<=:)))?\s*$', 3)
	If @error Then
		If Not StringRegExp($sGroup1, '^\s*(\-?\d+)(?:\s*\,\s*\-?\d+)*\s*$') Then Return SetError(2, @error, Null) ; indices list notation
		$aIndices1 = StringSplit($sGroup1, ',', 3)
		For $i = 0 To UBound($aIndices1) - 1
			$aIndices1[$i] = Number($aIndices1[$i])
			If $aIndices1[$i] < 0 Then $aIndices1[$i] += $nN1
			If $aIndices1[$i] >= $nN1 Then Return SetError(3, $aIndices1[$i], Null)
		Next
	Else ; range notation
		$iStep1 = ((UBound($aRE)) < 3 Or ($aRE[2] == "")) ? 1 : Number($aRE[2])
		$iStart1 = ($aRE[0] == "") ? ($iStep1 < 0 ? $nN1 - 1 : 0) : Number($aRE[0])    ; with case check for negative step
		$iStop1 = (UBound($aRE) < 2) ? Null : ($aRE[1] == "") ? ($iStep1 < 0 ? 0 : $nN1 - 1) : Number($aRE[1])
	EndIf

	; process second dimension group:
	If $nGroups = 2 Then
		$aRE = StringRegExp($sGroup2, '(?x)^\s*(\-?\d+|^\s*(?=:))(?>\:(\-?\d+|(?<=:)))?(?>\:(\-?\d+|(?<=:)))?\s*$', 3)
		If @error Then
			If Not StringRegExp($sGroup2, '^\s*(\-?\d+)(?:\s*\,\s*\-?\d+)*\s*$') Then Return SetError(3, @error, Null) ; indices list notation
			$aIndices2 = StringSplit($sGroup2, ',', 3)
			For $i = 0 To UBound($aIndices2) - 1
				$aIndices2[$i] = Number($aIndices2[$i])
				If $aIndices2[$i] < 0 Then $aIndices2[$i] += $nN2
				If $aIndices2[$i] >= $nN2 Then Return SetError(3, $aIndices2[$i], Null)
			Next
		Else ; range notation
			$iStep2 = ((UBound($aRE)) < 3 Or ($aRE[2] == "")) ? 1 : Number($aRE[2])
			$iStart2 = ($aRE[0] == "") ? ($iStep2 < 0 ? $nN2 - 1 : 0) : Number($aRE[0])    ; with case check for negative step
			$iStop2 = (UBound($aRE) < 2) ? Null : ($aRE[1] == "") ? ($iStep2 < 0 ? 0 : $nN2 - 1) : Number($aRE[1])
		EndIf
	EndIf

	If $iStart1 < 0 Then $iStart1 += $nN1
	If $iStop1 < 0 Then $iStop1 += $nN1 - 1
	If $iStart2 < 0 Then $iStart2 += $nN2
	If $iStop2 < 0 Then $iStop2 += $nN2 - 1

	Local $iN1 = ($iStop1 - $iStart1) / $iStep1 + 1, _
			$iN2 = ($iStop2 - $iStart2) / $iStep2 + 1

	Switch UBound($aArray, 0)
		Case 1 ; 1D-Array
			If IsArray($aIndices1) Then
				Local $aRet[UBound($aIndices1)], $iC = 0

				For $i In $aIndices1
					$aRet[$iC] = $aArray[$i]
					$iC += 1
				Next
				Return $aRet
			Else
				Local $aRet[$iN1], $iC = 0

				For $i = $iStart1 To $iStop1 Step $iStep1
					$aRet[$iC] = $aArray[$i]
					$iC += 1
				Next
				Return $aRet
			EndIf

		Case 2 ; 2D-Array
			; check for special cases
			Select
				Case (IsKeyword($iStop1) = 2) And (IsKeyword($iStop2) = 2) ; a single value
					Return $aArray[$iStart1][$iStart2]

				Case IsKeyword($iStop1) = 2    ; a single row
					Local $aRet[$iN2], $iC = 0
					For $i = $iStart2 To $iStop2 Step $iStep2
						$aRet[$iC] = $aArray[$iStart1][$i]
						$iC += 1
					Next
					Return $aRet

				Case IsKeyword($iStop2) = 2    ; a single column
					If IsArray($aIndices1) Then ; case for list of indices in first dim
						Local $aRet[UBound($aIndices1)], $iC = 0
						For $iIndex1 In $aIndices1
							$aRet[$iC] = $aArray[$iIndex1][$iStart2]
							$iC += 1
						Next
						Return $aRet
					Else ; case for array range in first dim
						Local $aRet[$iN1], $iC = 0
						For $i = $iStart1 To $iStop1 Step $iStep1
							$aRet[$iC] = $aArray[$i][$iStart2]
							$iC += 1
						Next
						Return $aRet
					EndIf

				Case Else ; normal 2D slice

					Select  ; index list in both dimensions
						Case IsArray($aIndices2) And IsArray($aIndices1)

							Local $aRet[UBound($aIndices1)][UBound($aIndices2)], $iR = 0, $iC
							For $iIndex1 In $aIndices1
								$iC = 0
								For $iIndex2 In $aIndices2
									$aRet[$iR][$iC] = $aArray[$iIndex1][$iIndex2]
									$iC += 1
								Next
								$iR += 1
							Next
							Return $aRet

							;  index list in dimension 1
						Case IsArray($aIndices1)
							Local $aRet[UBound($aIndices1)][$iN2], $iR = 0, $iC
							For $iIndex1 In $aIndices1
								$iC = 0
								For $j = $iStart2 To $iStop2 Step $iStep2
									$aRet[$iR][$iC] = $aArray[$iIndex1][$j]
									$iC += 1
								Next

								$iR += 1
							Next
							Return $aRet

							;  index list in dimension 2
						Case IsArray($aIndices2)
							Local $aRet[$iN1][UBound($aIndices2)], $iR = 0, $iC
							For $i = $iStart1 To $iStop1 Step $iStep1
								$iC = 0
								For $iIndex2 In $aIndices2
									$aRet[$iR][$iC] = $aArray[$i][$iIndex2]
									$iC += 1
								Next
								$iR += 1
							Next
							Return $aRet

							; range definition only
						Case Else
							Local $aRet[$iN1][$iN2], $iR = 0, $iC

							For $i = $iStart1 To $iStop1 Step $iStep1
								$iC = 0
								For $j = $iStart2 To $iStop2 Step $iStep2
									$aRet[$iR][$iC] = $aArray[$i][$j]
									$iC += 1
								Next

								$iR += 1
							Next
							Return $aRet
					EndSelect
			EndSelect
	EndSwitch
EndFunc   ;==>_ArraySlice







;  $aTest = _ArrayCreate("[[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12], [13, 14, 15]]")
;  $aTest = _ArrayCreate("[[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12], [13, 14, 15]]", Default, True)
;  $aTest = _ArrayCreate("[1, '2 zwei', 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]")
;  $aTest = _ArrayCreate("2:20:0.5", sqrt)
;  _ArrayDisplay($aTest)
Func _ArrayCreate($sArrayDef, $vDefault = Default, $bArrayInArray = False)
	Local $aRE = StringRegExp($sArrayDef, '(?x)^\s*\[?\s*(\-? (?:0|[1-9]\d*) (?:\.\d+)? (?:[eE][-+]?\d+)? | ):(?>(\-? (?:0|[1-9]\d*) (?:\.\d+)? (?:[eE][-+]?\d+)? | ))?(?>:(\-? (?:0|[1-9]\d*) (?:\.\d+)? (?:[eE][-+]?\d+)? | ))?\s*\]?\s*$', 3)

	If Not @error Then ; Array-range
		Local $nRE = UBound($aRE)

		Local $iStart = ($nRE < 1 Or $aRE[0] == "") ? 0 : Number($aRE[0])
		Local $iStop = ($nRE < 2 Or $aRE[1] == "") ? 0 : Number($aRE[1])
		Local $iStep = ($nRE < 3 Or $aRE[2] == "") ? 1 : Number($aRE[2])

		Return _ArrayRangeCreate($iStart, $iStop, $iStep, $vDefault)
	Else
		$sArrayDef = StringRegExpReplace($sArrayDef, '(^\s*\[|\]\s*$)', '')
		Local $aVals = StringRegExp($sArrayDef, '(?sx)(?(DEFINE)   (?<string> ''(?>[^'']+|'''')*'' | "(?>[^"]+|"")*")   (?<value> \s*(?>\g<string> | [^,\[\]]+)\s* )   (?<subarray> \s*\K\[ \g<value>(?:, \g<value>)* \])   (?<outervalue> \g<subarray> | \g<value> ))\g<outervalue>', 3)
		If @error Then Return SetError(1, @error, Null)

		Local $bAllSubArray = True, $bAllScalars = True
		Local $n2Dim = 0

		For $i = 0 To UBound($aVals) - 1
			If StringRegExp($aVals[$i], '^\s*\[') Then
				$bAllScalars = False
				; count elements of second dimension:
				StringRegExpReplace($aVals[$i], '(?sx)(?(DEFINE)   (?<string> ''(?>[^'']+|'''')*'' | "(?>[^"]+|"")*")   (?<value> \s*(?>\g<string> | [^,\[\]]+)\s* ))\g<value>', '')
				If @extended > $n2Dim Then $n2Dim = @extended
			Else ; scalar value
				$bAllSubArray = False
			EndIf
		Next

		; If not Array-In-Array (=1D or 2D-Array) and subvalues are mixed array and scalars then error
		If ($bArrayInArray = False) And Not BitXOR($bAllSubArray, $bAllScalars) Then Return SetError(2, 0, Null)

		If ($n2Dim > 0) And (Not $bArrayInArray) Then ; 2D-array
			Local $aRet[UBound($aVals)][$n2Dim], $aSubVals


			For $i = 0 To UBound($aVals) - 1
				$aSubVals = StringRegExp($aVals[$i], '(?sx)(?(DEFINE)   (?<string> ''(?>[^'']+|'''')*'' | "(?>[^"]+|"")*")   (?<value> \s*(?>\g<string> | [^,\[\]]+)\s* ))\g<value>', 3)
				For $j = 0 To UBound($aSubVals) - 1
					$aRet[$i][$j] = Execute($aSubVals[$j])
				Next
			Next

			Return $aRet
		Else ; 1D-Array or array-in-array
			Local $aRet[UBound($aVals)]

			For $i = 0 To UBound($aVals) - 1
				If StringRegExp($aVals[$i], '^\s*\[') Then
					$aRet[$i] = _ArrayCreate($aVals[$i], $vDefault, True)
				Else
					$aRet[$i] = Execute($aVals[$i])
				EndIf
			Next
			Return $aRet
		EndIf

	EndIf
EndFunc   ;==>_ArrayCreate


Func _ArrayRangeCreate(Const $nStart, Const $nStop, Const $nStep = 1, Const $vDefault = Default)
	If Not IsNumber($nStart) Then Return SetError(1, 0, Null)
	If Not IsNumber($nStop) Then Return SetError(2, 0, Null)
	If Not IsNumber($nStep) Then Return SetError(3, 0, Null)

	Local $iN = ($nStop - $nStart) / $nStep + 1
	Local $aRange[$iN] = [(($vDefault = Default) ? $nStart : (IsFunc($vDefault) ? $vDefault($nStart) : $vDefault))]
	Local $nCurrent = $nStart

	For $i = 1 To $iN - 1
		$nCurrent += $nStep
		$aRange[$i] = $vDefault = Default ? $nCurrent : (IsFunc($vDefault) ? $vDefault($nCurrent) : $vDefault)
	Next
	Return $aRange
EndFunc   ;==>_ArrayRangeCreate

