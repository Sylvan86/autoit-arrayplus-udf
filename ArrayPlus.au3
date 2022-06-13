#include-once
#include <Array.au3>
#include <File.au3>


;  Func _ArrayDisplay(Const ByRef $aArray, $sTitle = Default, $sArrayRange = Default, $iFlags = Default, $vUser_Separator = Default, $sHeader = Default, $iMax_ColWidth = Default)

;  Global $aCSVRaw
;  _FileReadToArray("TempOessterreich.txt", $aCSVRaw, 4, @TAB)
;  _ArrayDisplay($aCSVRaw)


Global $aCSVRaw[5][3] = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12], [13, 14, 15]]
;  Global $aCSVRaw[] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
;  $aSliced = _ArraySlice($aCSVRaw, "[-5:5:-2]")

;  $aSliced = _ArraySlice($aCSVRaw, "[1,-2,4,2][1]")
$aSliced = _ArraySlice($aCSVRaw, "[:][1,0, -1]")
ConsoleWrite(UBound($aSliced, 0) & @TAB & UBound($aSliced, 1) & @TAB & UBound($aSliced, 2) & @CRLF)
_ArrayDisplay($aSliced)
ConsoleWrite($aSliced & @CRLF)

; Python-like array slicing
Func _ArraySlice(Const ByRef $aArray, Const $sSliceString)
	Local $nDims = UBound($aArray, 0), _
			$nN1 = UBound($aArray, 1), _
			$nN2 = UBound($aArray, 2)

	;  https://stackoverflow.com/a/509295

	; Testen: https://onecompiler.com/python/3y6jbpfgx


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
		$aRE = StringRegExp($sGroup2, '(?x)(\-?\d+|^\s*(?=:))(?>\:(\-?\d+|(?<=:)))?(?>\:(\-?\d+|(?<=:)))?', 3)
		If @error Then Return SetError(2, @error, Null)
		$iStep2 = ((UBound($aRE)) < 3 Or ($aRE[2] == "")) ? 1 : Number($aRE[2])
		$iStart2 = ($aRE[0] == "") ? ($iStep2 < 0 ? $nN2 - 1 : 0) : Number($aRE[0])
		$iStop2 = (UBound($aRE) < 2) ? Null : ($aRE[1] == "") ? ($iStep2 < 0 ? 0 : $nN2 - 1) : Number($aRE[1])
	EndIf

	If $iStart1 < 0 Then $iStart1 += $nN1
	If $iStop1 < 0 Then $iStop1 += $nN1 - 1
	If $iStart2 < 0 Then $iStart2 += $nN2
	If $iStop2 < 0 Then $iStop2 += $nN2 - 1

	Local $iN1 = ($iStop1 - $iStart1) / $iStep1 + 1, _
			$iN2 = ($iStop2 - $iStart2) / $iStep2 + 1

	Switch UBound($aArray, 0)
		Case 1 ; 1D-Array
			Local $aRet[$iN1], $iC = 0

			For $i = $iStart1 To $iStop1 Step $iStep1
				$aRet[$iC] = $aArray[$i]
				$iC += 1
			Next
			Return $aRet
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

					Select
						;  Case IsArray($aIndices2) And IsArray($aIndices1)

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

							;  Case IsArray($aIndices2)
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




Func _Array2Console(Const ByRef $aArray, $sHeader = Default)

EndFunc   ;==>_Array2Console


;  $aTest = _ArrayCreate("[[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12], [13, 14, 15]]")
;  $aTest = _ArrayCreate("[[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12], [13, 14, 15]]", Default, True)
;  $aTest = _ArrayCreate("[1, "2 zwei', 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]")
;  $aTest = _ArrayCreate("2:20:0.5", sqrt)
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


Func _ArrayRangeCreate($nStart, $nStop, $nStep = 1, $vDefault = Default)
	If Not IsNumber($nStart) Then Return SetError(1, 0, Null)
	If Not IsNumber($nStop) Then Return SetError(2, 0, Null)
	If Not IsNumber($nStep) Then Return SetError(3, 0, Null)

	Local $iN = ($nStop - $nStart) / $nStep + 1
	Local $aRange[$iN] = [(($vDefault = Default) ? $nStart : (IsFunc($vDefault) ? $vDefault($nStart) : $vDefault))]
	Local $nCurrent = $nStart

	;  ConsoleWrite($nCurrent & @TAB)
	For $i = 1 To $iN - 1
		$nCurrent += $nStep
		;  ConsoleWrite($nCurrent & @TAB)
		$aRange[$i] = $vDefault = Default ? $nCurrent : (IsFunc($vDefault) ? $vDefault($nCurrent) : $vDefault)
	Next
	;  ConsoleWrite(@CRLF)

	;  _ArrayDisplay($aRange)
	Return $aRange
EndFunc   ;==>_ArrayRangeCreate



Func _ArrayCountIf(ByRef $aArray, Const $fFunc)

	;  If IsString($fFunc) Then

EndFunc   ;==>_ArrayCountIf
