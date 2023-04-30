#include-once
#include <Array.au3>
#include <File.au3>


; #INDEX# =======================================================================================================================
; Title .........: ArrayPlus-UDF
; Version .......: 0.3
; AutoIt Version : 3.3.16.1
; Language ......: english (german maybe by accident)
; Description ...: advanced helpers for array handling
; Author(s) .....: AspirinJunkie
; Last changed ..: 2022-12-14
; Link ..........: https://autoit.de/thread/87723-arrayplus-udf-weitere-helferlein-für-den-täglichen-umgang-mit-arrays
; License .......: This work is free.
;                  You can redistribute it and/or modify it under the terms of the Do What The Fuck You Want To Public License, Version 2,
;                  as published by Sam Hocevar.
;                  See http://www.wtfpl.net/ for more details.
; ===============================================================================================================================


; #CURRENT# =====================================================================================================================
;  ---- creation ------
;  _ArrayCreate                 - create 1D/2D-arrays or Array-In-Arrays in one code-line; supports python-like range-syntax for creating sequences
;  _ArrayRangeCreate()          - create a sequence as 1D-array - mainly helper function for _ArrayCreate

;  ---- manipulation and conversion ----
;  _ArraySlice                  - python style array slicing to extract ranges, rows, columns, single values
;  _Array1DTo2D                 - convert a 1D-array into a 2D-array and take over the values to the first column (for inverted case - extract a row or column from 2D-array - use _ArraySlice)
;  _Array2dToAinA               - convert 2D-array into a array-in-array
;  _ArrayAinATo2d               - convert array-in-array into a 2D array
;  _Array2String                - print a 1D/2D-array to console or variable clearly arranged
;  _ArrayAlignDec               - align a 1D-array or a column of a 2D-array at the decimal point or right aligned
;  _ArrayMap                    - apply a function to every element of a array ("map" the function)
;  _ArrayReduce                 - reduce the elements of a array to one value with an external function
;  _ArrayFilter                 - filter the elements of an array with a external function
;  _ArrayDeleteByCondition      - delete all empty string elements or elements which fulfil a user-defined condition inside an array
;  _ArrayDeleteMultiValues()    - removes elements that appear more than once in the string. (not only the duplicates)

;  ---- sorting ----
;  _ArraySortFlexible           - sort an array with a user-defined sorting rule
;  _ArraySortInsertion          - sort an array with a user-defined sorting rule with the insertion-sort algorithm
;  _ArraySortSelection          - sort an array with a user-defined sorting rule with the selection-sort algorithm (minimal number of swaps)
;  _ArrayIsSorted               - checks whether an Array is already sorted (by using a user comparison function)
;  _ArrayHeapSortBinary         - sort an array with Binary-Min-Heap-Sort algorithm (by using a user comparison function)
;  _ArrayHeapSortTernary        - sort an array with Ternary-Min-Heap-Sort algorithm (by using a user comparison function)

;  ---- searching ----
;  _ArrayBinarySearchFlex       - performs a binary search for an appropriately sorted array using an individual comparison function
;  _ArrayGetMax                 - determine the element with the maximum value by using a user comparison function
;  _ArrayGetMin                 - determine the element with the minimum value by using a user comparison function
;  _ArrayMinMax                 - returns min and max value and their indices of a 1D array or all/specific column of a 2D array
;  _ArrayGetNthBiggestElement   - determine the nth biggest element (e.g.: median value) in an unsorted array without sorting it (faster)
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; __ap_cb_comp_Normal
; __ap_cb_comp_Natural
; __ap_cb_comp_String
; __ap_swap
; __ap_PartitionHoare
; __ap_ArrayDualPivotQuicksort
; _2Sort
; __2Sort
; _3Sort
; __3Sort
; _4Sort
; __4Sort
; _5Sort
; __5Sort
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $sAPLUS_CBSTRING = "" ; global variable used in __ap_cb_comp_String():
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Enum Step *2 $A2S_BORDERS, $A2S_ALIGNDEC, $A2S_CENTERHEADENTRIES, $A2S_FIRSTROWHEADER, $A2S_TOCONSOLE, $A2S_CHECK_ARRAY_IN_ARRAY
; ===============================================================================================================================

; #FUNCTION# ======================================================================================
; Name ..........: _Array2String()
; Description ...: print a 1D/2D-array to console or variable clearly arranged
; Syntax ........: _Array2String($aArray[, $sHeader = Default[, $cSep = " | "[, $iDecimals = Default[, $dFlags = $A2S_BORDERS + $A2S_ALIGNDEC + $A2S_CENTERHEADENTRIES[, $cRowSep = @CRLF]]]]])
; Parameters ....: $aArray    - 1D or 2D array to be printed
;                  $sHeader   - [optional] $sHeader = Default: no header to print (default:Default)
;                  |$sHeader = True:     first row = header values
;                  |$sHeader = comma separated string: header values
;                  $cSep      - [optional] column separater string (default:" | ")
;                  $iDecimals - [optional] number of decimal places to round for floating point values (default:Default)
;                  $dFlags    - [optional] Bitmask for serveral options: (default:$A2S_BORDERS + $A2S_ALIGNDEC + $A2S_CENTERHEADENTRIES)
;                  |(1) $A2S_BORDERS - print table borders
;                  |(2) $A2S_ALIGNDEC - align numbers at the decimal point
;                  |(4) $A2S_CENTERHEADENTRIES - header entries are centered instead of right aligned
;                  |(8) $A2S_FIRSTROWHEADER - first row = header (concurrenct with $sHeader = True)
;                  |(16) $A2S_TOCONSOLE - table is also printed to console
;                  |(32) $A2S_CHECK_ARRAY_IN_ARRAY - table is also printed to console
;                  $cRowSep   - [optional] row separator string (default:@CRLF)
; Return values .: Success: the string form of the array
;                  Failure
; Author ........: aspirinjunkie
; Modified ......: 2022-06-20
; Related .......: __ap_stringCenter, _ArrayAlignDec
; Example .......: Yes
;                  Global $aCSVRaw[5][4] = [[1, 2, 20.65, 3], [4, 5, 4.1, 6], [7, 8, 111111111.8, 9], [10, 11, 100.2, 12], [13, 14, 23.765, 15]]
;                  ConsoleWrite(_Array2String($aCSVRaw, "Col. 1, Col. 2, Col. 3, Col. 4"))
; =================================================================================================
Func _Array2String($aArray, $sHeader = Default, $cSep = " | ", $iDecimals = Default, $dFlags = $A2S_BORDERS + $A2S_ALIGNDEC + $A2S_CENTERHEADENTRIES, $cRowSep = @CRLF)
	Local $nR = UBound($aArray, 1), $sOut = ""

	; if option is set, then check if array is a array-in-array and convert to 2D-array
	If BitAND($dFlags, $A2S_CHECK_ARRAY_IN_ARRAY) And UBound($aArray, 0) = 1 Then
		; check if array is a array-in-array
		Local $bAInA = False
		For $i = 0 To UBound($aArray) - 1
			If IsArray($aArray[$i]) Then 
				$bAInA = True
				ExitLoop
			EndIf
		Next
		If $bAInA Then $aArray = _ArrayAinATo2d($aArray)
	EndIf

	Local $nC = UBound($aArray, 2)

	If UBound($aArray, 0) = 1 Then ; 1D-array

		If BitAND($dFlags, $A2S_ALIGNDEC) Then _ArrayAlignDec($aArray)

		For $i = 0 To UBound($aArray) - 1
			$sOut &= $aArray[$i] & $cRowSep
		Next
	Else ; 2D-array
		Local $aSizes[$nC], $vTemp, $aTmp

		; determine column widths
		If BitAND($dFlags, $A2S_ALIGNDEC) Then
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
			If (IsBool($sHeader) And $sHeader = True) Or BitAND($dFlags, $A2S_FIRSTROWHEADER) Then ; first row = header row
				$dFlags = BitOR($dFlags, $A2S_FIRSTROWHEADER)
				$aHeader = _ArraySlice($aArray, "[0][:]")
			Else
				$aHeader = StringRegExp($sHeader, '\h*([^,]*[^\h,])', 3)
			EndIf

			If UBound($aHeader) <> $nC Then Return SetError(1, UBound($aHeader), Null)

			For $iH = 0 To UBound($aHeader) - 1
				If StringLen($aHeader[$iH]) > $aSizes[$iH] Then $aSizes[$iH] = StringLen($aHeader[$iH])

				$sOut &= BitAND($dFlags, $A2S_CENTERHEADENTRIES) ? _
						__ap_stringCenter($aHeader[$iH], $aSizes[$iH]) & ($iH = $nC - 1 ? "" : $cSep) : _
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
		For $iR = (BitAND($dFlags, $A2S_FIRSTROWHEADER) ? 1 : 0) To $nR - 1
			For $iC = 0 To $nC - 1

				If BitAND($dFlags, $A2S_ALIGNDEC) Then
					$sOut &= StringFormat("% " & $aSizes[$iC] & "s", $aArray[$iR][$iC]) & ($iC = $nC - 1 ? "" : $cSep)
				Else
					$sOut &= StringFormat("%" & $aSizes[$iC] & "s", $aArray[$iR][$iC]) & ($iC = $nC - 1 ? "" : $cSep)
				EndIf
			Next
			$sOut &= @CRLF
		Next

		; lower border
		If BitAND($dFlags, $A2S_BORDERS) Then
			Local $sBorder = ""
			For $iC = 0 To $nC - 1
				For $i = 1 To $aSizes[$iC] + ($iC = $nC - 1 ? 0 : StringLen($cSep))
					$sBorder &= "="
				Next
			Next
			$sOut = $sBorder & @CRLF & $sOut & $sBorder & @CRLF
		EndIf
	EndIf

	If BitAND($dFlags, $A2S_TOCONSOLE) Then ConsoleWrite($sOut)
	Return $sOut

EndFunc   ;==>_Array2String

; #FUNCTION# ======================================================================================
; Name ..........: _ArrayAlignDec()
; Description ...: align a 1D-array or a column of a 2D-array at the decimal point or right aligned
; Syntax ........: _ArrayAlignDec(ByRef $aArray[, $iColumn = Default[, $iDecimals = Default[, $bTrailingZeros = False]]])
; Parameters ....: ByRef $aArray   - 1D or 2D array which values should be char-wise aligned
;                  |values processed directly in-place
;                  $iColumn        - [optional] If $aArray = 2D-array: column which should be processed (default:Default)
;                  $iDecimals      - [optional] number of decimal places to round for floating point values (default:Default)
;                  $bTrailingZeros - [optional] If true: add trailing zeros to decimal part if necessary (default:False)
; Return values .: Success: Return calculated column width; @extended = number of decimal digits
;                  Failure
; Author ........: aspirinjunkie
; Modified ......: 2022-06-20
; Remarks .......: every array element is converted into a string type
; Example .......: Yes
;                  Local $aArray[] = [20.65, 4.1, 9999999, 10000.2, 100.2, 'Test', 23.765]
;                  _ArrayAlignDec($aArray)
;                  For $sElement in $aArray
;                     ConsoleWrite($sElement & @CRLF)
;                  Next
; =================================================================================================
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

; #FUNCTION# ======================================================================================
; Name ..........: _ArraySlice()
; Description ...: python style array slicing to extract ranges, rows, columns, single values
; Syntax ........: _ArraySlice(Const ByRef $aArray, Const $sSliceString)
; Parameters ....: Const ByRef $aArray - 1D/2D input array to be sliced
;                  Const $sSliceString - slice logic with basic form "[x]" or "x" for 1D-array and "[x][y]" for 2D-array where x/y could be one of these:
;                  |start - single value/row/column
;                  |start:end  - range definition from-to
;                  |start:end:step - every step element in range start:end
;                  |start/end/step are optional so to only turn order of values for example: [::-1]
;                  |
;                  |if start/end = negative - counting backwards from the end
;                  |if step = negative - value order is inverted
;                  |
;                  |comma separated integer list - return only specific values/rows/columns
;                  |
;                  |single value: return scalar variable for 1D array, 1D-array with the chosen row/column for 2D-arrays - you can extract single rows or columns e.g.: [:][2] or [3][:]
; Return values .: Success: return scalar variable / 1D-array or 2D-array
;                  Failure: null and set error to:
;                  |@error = 1: $aArray != 1D/2D-array
;                  |@error = 2: invalid value in $sSliceString (first dimension group)
;                  |@error = 3: invalid value in $sSliceString (second dimension group)
; Author ........: aspirinjunkie
; Modified ......: 2022-06-20
; Example .......: Yes
;                  Global $aCSVRaw[5][3] = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12], [13, 14, 15]]
;                  ; return 3 specific rows and inverted column order:
;                  $aSliced = _ArraySlice($aCSVRaw, "[1,3,4][::-1]")
;                  _ArrayDisplay($aSliced)
; =================================================================================================
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
				Return SetExtended(UBound($aRet), $aRet)
			Else
				Local $aRet[$iN1], $iC = 0

				For $i = $iStart1 To $iStop1 Step $iStep1
					$aRet[$iC] = $aArray[$i]
					$iC += 1
				Next
				Return SetExtended($iN1, $aRet)
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
					Return SetExtended($iN2, $aRet)

				Case IsKeyword($iStop2) = 2    ; a single column
					If IsArray($aIndices1) Then ; case for list of indices in first dim
						Local $aRet[UBound($aIndices1)], $iC = 0
						For $iIndex1 In $aIndices1
							$aRet[$iC] = $aArray[$iIndex1][$iStart2]
							$iC += 1
						Next
						Return SetExtended(UBound($aRet), $aRet)
					Else ; case for array range in first dim
						Local $aRet[$iN1], $iC = 0
						For $i = $iStart1 To $iStop1 Step $iStep1
							$aRet[$iC] = $aArray[$i][$iStart2]
							$iC += 1
						Next
						Return SetExtended($iN1, $aRet)
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
							Return SetExtended(UBound($aRet), $aRet)

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
							Return SetExtended(UBound($aRet), $aRet)

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
							Return SetExtended($iN1, $aRet)

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
							Return SetExtended($iN1, $aRet)
					EndSelect
			EndSelect
	EndSwitch
EndFunc   ;==>_ArraySlice

; #FUNCTION# ======================================================================================
; Name ..........: _ArrayCreate()
; Description ...: create 1D/2D-arrays or Array-In-Arrays in one code-line; supports python-like range-syntax for creating sequences
; Syntax ........: _ArrayCreate($sArrayDef[, $vDefault = Default[, $bArrayInArray = False]])
; Parameters ....: $sArrayDef     - String with either a normal AutoIt-Array definition syntax
;                  |or a "start:stop:step"-syntax like Pythons "range"-command
;                  |border chars: "[" for inclusive borders and "(" for exclusive borders - example: "(0:4]" --> [1,2,3,4];     "[0:4)" --> [0,1,2,3]
;                  |no border char defaults to inclusive border
;                  |step size delimiter can be ":" for a step size and "|" for the number of steps - example "1:5:2" --> [1,3,5];   "1:5|3" --> [1,3,5]
;                  $vDefault      - [optional] If $sArrayDef = range syntax: (default:Default)
;                  |$vDefault = variant type: default value for array elements
;                  |$vDefault = Function: firstly sequence is build as defined in $sArrayDef, then this value is passed to this function and overwrite value in the array element (see example)
;                               If string then the value is parsed as AutoIt-Code. The variable name for the current element should be named "$A"  inside the code
;                  $bArrayInArray - [optional] if True and $sArrayDef is a AutoIt 2D-array definition, then a array-in-array is created instead (default:False)
; Return values .: Success: the arrayy
;                  Failure: Null and set error to:
;                  |@error = 1: invalid value in $sArrayDef
;                  |@error = 2: invald value in $sArrayDef (mixed)
; Author ........: aspirinjunkie
; Modified ......: 2022-07-12
; Remarks .......: useful to create arrays directly in function parameters
; Example .......: Yes
;                  _ArrayDisplay(_ArrayCreate("2:20:0.5", sqrt))
;                  _ArrayDisplay(_ArrayCreate("[[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12], [13, 14, 15]]"))
; =================================================================================================
Func _ArrayCreate($sArrayDef, $vDefault = Default, $bArrayInArray = False)
	Local $aRE = StringRegExp($sArrayDef, '(?x)^\s*[\[\(]?\s*(\-? (?:0|[1-9]\d*) (?:\.\d+)? (?:[eE][-+]?\d+)? | ):(?>(\-? (?:0|[1-9]\d*) (?:\.\d+)? (?:[eE][-+]?\d+)? | ))?(?>[:\|](\-? (?:0|[1-9]\d*) (?:\.\d+)? (?:[eE][-+]?\d+)? | ))?\s*[\]\)]?\s*$', 3)

	If Not @error Then ; Array-range
		Local $nRE = UBound($aRE)

		Local $iStart = ($nRE < 1 Or $aRE[0] == "") ? 0 : Number($aRE[0])
		Local $iStop = ($nRE < 2 Or $aRE[1] == "") ? 0 : Number($aRE[1])
		Local $iStep = ($nRE < 3 Or $aRE[2] == "") ? 1 : Number($aRE[2])

		If StringInStr($sArrayDef, "|", 1) Then ; number of steps instead of step size
			Local $nSteps = $iStep
			If Not StringIsDigit($nSteps) Or $nSteps < 1 Then Return SetError(3, $nSteps, Null)

			$iStep = ($iStop - $iStart) / ($nSteps - 1 + (StringInStr($sArrayDef, "(", 1) ? 1 : 0) + (StringInStr($sArrayDef, ")", 1) ? 1 : 0))
		EndIf

		; handle exclusive range borders
		If StringInStr($sArrayDef, "(", 1) Then $iStart += $iStep
		If StringInStr($sArrayDef, ")", 1) Then $iStop -= $iStep

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

			Return SetExtended(UBound($aRet), $aRet)
		Else ; 1D-Array or array-in-array
			Local $aRet[UBound($aVals)]

			For $i = 0 To UBound($aVals) - 1
				If StringRegExp($aVals[$i], '^\s*\[') Then
					$aRet[$i] = _ArrayCreate($aVals[$i], $vDefault, True)
				Else
					$aRet[$i] = Execute($aVals[$i])
				EndIf
			Next
			Return SetExtended(UBound($aRet), $aRet)
		EndIf

	EndIf
EndFunc   ;==>_ArrayCreate


; #FUNCTION# ======================================================================================
; Name ..........: _ArrayRangeCreate()
; Description ...: create a sequence as 1D-array - mainly helper function for _ArrayCreate
; Syntax ........: _ArrayRangeCreate(Const $nStart, Const $nStop, Const[ $nStep = 1, Const[ $vDefault = Default]])
; Parameters ....: Const $nStart   - first value of sequence
;                  Const $nStop    - max value of sequence
;                  Const $nStep    - [optional] step between to values (default:1)
;                  Const $vDefault - [optional] $vDefault = variant type: default value for array elements (default:Default)
;                  |$vDefault = Function: firstly sequence is build as defined in $sArrayDef, then this value is passed to this function and overwrite value in the array element (see example)
; Return values .: Success: the sequence as error
;                  Failure: Null and set @error to:
;                  |@error = 1: $nStart is not a number
;                  |@error = 2: $nStop is not a number
;                  |@error = 3: $nStep is not a number
; Author ........: aspirinjunkie
; Modified ......: 2022-06-22
; Example .......: Yes
;                  #include <Array.au3>
;                  _ArrayDisplay(_ArrayRangeCreate(5,24, 2))
; =================================================================================================
Func _ArrayRangeCreate($nStart, $nStop, $nStep = 1, $vDefault = Default)
	If Not IsNumber($nStart) Then Return SetError(1, 0, Null)
	If Not IsNumber($nStop) Then Return SetError(2, 0, Null)
	If Not IsNumber($nStep) Then Return SetError(3, 0, Null)

	Local $bCbIsString = False

	If StringInStr($vDefault, "$A") Then ; custom filter function directly as a string
		Local $bBefore = Opt("ExpandEnvStrings", 1)
		$sAPLUS_CBSTRING = $vDefault
		$vDefault = __ap_cb_comp_String
		$bCbIsString = True
	EndIf

	Local $iN = ($nStop - $nStart) / $nStep + 1
	Local $aRange[$iN] = [(($vDefault = Default) ? $nStart : (IsFunc($vDefault) ? $vDefault($nStart) : $vDefault))]
	Local $nCurrent = $nStart

	For $i = 1 To $iN - 1
		$nCurrent += $nStep
		$aRange[$i] = $vDefault = Default ? $nCurrent : (IsFunc($vDefault) ? $vDefault($nCurrent) : $vDefault)
	Next

	If $bCbIsString Then Opt("ExpandEnvStrings", $bBefore)
	Return SetExtended($iN, $aRange)
EndFunc   ;==>_ArrayRangeCreate

; #FUNCTION# ======================================================================================
; Name ..........: _Array1DTo2D()
; Description ...: convert a 1D-array into a 2D-array and take over the values to the first column
; Syntax ........: _Array1DTo2D(ByRef $aArray, Const $nCols[, $bInPlace = True])
; Parameters ....: ByRef $aArray - 1D input array
;                  Const $nCols  - number of columns (size of 2nd dimension) in the target 2D-array
;                  $bInPlace     - [optional] If True: overwrite $aArray (default:True)
;                  |If False: return 2D-array and leave $aArray as is
; Return values .: Success
;                  |$bInPlace = False: True
;                  |$bInPlace = True: the result 2D-array
;                  Failure: Null and set @error
; Author ........: aspirinjunkie
; Modified ......: 2022-06-27
; Remarks .......: for inverted case - extract a column from 2D-array - use _ArraySlice($Array, "[:][N]")
; Example .......: Yes
;                  Global $aArray[] = [1,2,3,4,5]
;                  _Array1DTo2D($aArray, 3)
;                  _ArrayDisplay($aArray)
; =================================================================================================
Func _Array1DTo2D(ByRef $aArray, Const $nCols, $bInPlace = True)
	If $nCols < 1 Then Return SetError(1, $nCols, Null)

	Local $nElems = UBound($aArray)
	Local $aTmp[$nElems][$nCols]

	For $i = 0 To $nElems - 1
		$aTmp[$i][0] = $aArray[$i]
	Next

	If $bInPlace Then
		$aArray = $aTmp
		Return SetExtended($nElems, True)
	Else
		Return SetExtended($nElems, $aTmp)
	EndIf
EndFunc   ;==>_Array1DTo2D


; #FUNCTION# ======================================================================================
; Name ..........: _Array2dToAinA()
; Description ...: Convert a 2D array into a Arrays in Array
; Syntax ........: _Array2dToAinA(ByRef $A)
; Parameters ....: $A             - the 2D-Array  which should be converted
; Return values .: Success: a Arrays in Array build from the input array
;                  Failure: False
;                     @error = 1: $A is'nt an 2D array
; Author ........: AspirinJunkie
; =================================================================================================
Func _Array2dToAinA(ByRef $A)
	If UBound($A, 0) <> 2 Then Return SetError(1, UBound($A, 0), False)
	Local $N = UBound($A), $u = UBound($A, 2)
	Local $a_Ret[$N]

	For $i = 0 To $N - 1
		Local $t[$u]
		For $j = 0 To $u - 1
			$t[$j] = $A[$i][$j]
		Next
		$a_Ret[$i] = $t
	Next
	Return SetExtended($N, $a_Ret)
EndFunc   ;==>_Array2dToAinA

; #FUNCTION# ======================================================================================
; Name ..........: _ArrayAinATo2d()
; Description ...: Convert a Arrays in Array into a 2D array
; Syntax ........: _ArrayAinATo2d(ByRef $A)
; Parameters ....: $A             - the arrays in array which should be converted
; Return values .: Success: a 2D Array build from the input array
;                  Failure: Null
;                     @error = 1: $A is'nt an 1D array
;                            = 2: $A is empty
;                            = 3: first element isn't a array
; Author ........: AspirinJunkie
; =================================================================================================
Func _ArrayAinATo2d(ByRef $A)
	If UBound($A, 0) <> 1 Then Return SetError(1, UBound($A, 0), Null)
	Local $N = UBound($A)
	If $N < 1 Then Return SetError(2, $N, Null)
	Local $u = UBound($A[0])
	If $u < 1 Then Return SetError(3, $u, Null)

	Local $a_Ret[$N][$u]

	For $i = 0 To $N - 1
		Local $t = $A[$i]
		If UBound($t) > $u Then ReDim $a_Ret[$N][UBound($t)]
		For $j = 0 To UBound($t) - 1
			$a_Ret[$i][$j] = $t[$j]
		Next
	Next
	Return SetExtended($N, $a_Ret)
EndFunc   ;==>_ArrayAinATo2d

; #FUNCTION# ======================================================================================
; Name ..........: _ArrayMap
; Description ...: apply a function to every element of a array ("map" the function)
; Syntax ........: _ArrayMap(ByRef $a_Array, Const $cb_Func, Const $b_Withcount = False, Const $b_Overwrite = True, Const $b_CBWithIndex = False, $d_EndIndex = Default)
; Parameters ....: $a_Array       - the "semi-dynamic"-Array (needs an array with number of elements in $a_Array[0])
;                  $cb_Func       - function variable points to a function of a form function($value) or if $b_CBWithIndex: function($value, $index)
;  								    If string then the value is parsed as AutoIt-Code. The variable name for the current element should be named "$A"  inside the code
;                  $b_Withcount   - Set true if the number of elements are written in the first element of $a_Array
;                  $b_Overwrite   - If true: $a_Array gets overwritten; If false: no changes to $a_Array - new array will returned
;                  $b_CBWithIndex - If true: $cb_Func has the form "function(element-value, element-index)"
;                  $b_EndIndex    - the end index until the elements should be processed
; Return values .: Success: $b_Overwrite=True: True; Else: the converted semi-dynamic array
;                  Failure: False
;                     @error = 1: $a_Array is'nt an array
; Author ........: AspirinJunkie
; =================================================================================================
Func _ArrayMap(ByRef $a_Array, $cb_Func = Default, Const $b_Withcount = False, Const $b_Overwrite = True, Const $b_CBWithIndex = False, $d_EndIndex = Default)
	Local $bCbIsString = False
	If Not IsArray($a_Array) Then Return SetError(1, 0, False)
	Local Const $d_Start = $b_Withcount ? 1 : 0
	If $d_EndIndex = Default Then $d_EndIndex = UBound($a_Array) - 1

	If IsString($cb_Func) Then ; comparison function directly as a string
		Local $bBefore = Opt("ExpandEnvStrings", 1)
		$sAPLUS_CBSTRING = $cb_Func
		$cb_Func = __ap_cb_comp_String
		$bCbIsString = True
	EndIf

	If $b_CBWithIndex Then
		If $b_Overwrite Then
			For $i = $d_Start To $d_EndIndex
				$a_Array[$i] = $cb_Func($a_Array[$i], $i)
			Next
			If $bCbIsString Then Opt("ExpandEnvStrings", $bBefore)
			Return True
		Else
			Local $a_Ret[UBound($a_Array)] = [$a_Array[0]]
			For $i = $d_Start To $d_EndIndex
				$a_Ret[$i] = $cb_Func($a_Array[$i], $i)
			Next
			If $bCbIsString Then Opt("ExpandEnvStrings", $bBefore)
			Return $a_Ret
		EndIf
	Else
		If $b_Overwrite Then
			For $i = $d_Start To $d_EndIndex
				$a_Array[$i] = $cb_Func($a_Array[$i])
			Next
			If $bCbIsString Then Opt("ExpandEnvStrings", $bBefore)
			Return True
		Else
			Local $a_Ret[UBound($a_Array)] = [$a_Array[0]]
			For $i = $d_Start To $d_EndIndex
				$a_Ret[$i] = $cb_Func($a_Array[$i])
			Next
			If $bCbIsString Then Opt("ExpandEnvStrings", $bBefore)
			Return $a_Ret
		EndIf
	EndIf
EndFunc   ;==>_ArrayMap


; #FUNCTION# ======================================================================================
; Name ..........: _ArrayFilter
; Description ...: filter the elements of an array with a external function
; Syntax ........: _ArrayFilter(ByRef $a_Array, Const $cb_Func, Const $b_Withcount = False, Const $b_Overwrite = True, $d_EndIndex = Default, Const $b_IsDynArray = False)
; Parameters ....: $a_Array       - the "semi-dynamic"-Array (needs an array with number of elements in $a_Array[0])
;                  $cb_Func       - function variable points to a function of a form function($value)
;                                   the function return True for the elements which should retain in the array
;  								    If string then the value is parsed as AutoIt-Code. The variable name for the current element should be named "$A"  inside the code
;                                   example: _ArrayFilter($a_Array, 'StringLeft($A, 1) = "B"')
;                  $b_Withcount   - Set true if the number of elements are written in the first element of $a_Array
;                  $b_Overwrite   - If true: $a_Array gets overwritten; If false: no changes to $a_Array - new array will returned
;                  $b_EndIndex    - the end index until the elements should be processed
; Return values .: Success: $b_Overwrite=True: True; Else: the filtered array
;                  Failure: False
;                     @error = 1: $a_Array is'nt an array
;                              5: invalid value for $d_EndIndex
; Author ........: AspirinJunkie
; =================================================================================================
Func _ArrayFilter(ByRef $a_Array, $cb_Func, Const $b_Withcount = False, Const $b_Overwrite = True, $d_EndIndex = Default)
	If Not IsArray($a_Array) Then Return SetError(1, 0, False)
	Local Const $w = UBound($a_Array)
	Local $d_Start = Int(Not ($b_Withcount = False))
	Local $d_x = $d_Start ; counter for filtered elements
	Local $bCbIsString = False

	If $d_EndIndex = Default Then $d_EndIndex = $w - 1
	$d_EndIndex = Int($d_EndIndex)
	If $d_EndIndex < 1 Or $d_EndIndex >= $w Then Return SetError(5, 0, False)

	Local $2D = False
	If UBound($a_Array, 0) = 2 Then
		Local $2D = True
		$a_Array = _Array2dToAinA($a_Array)
	EndIf

	If IsString($cb_Func) Then ; custom filter function directly as a string
		Local $bBefore = Opt("ExpandEnvStrings", 1)
		$sAPLUS_CBSTRING = $cb_Func
		$cb_Func = __ap_cb_comp_String
		$bCbIsString = True
	EndIf

	If $b_Overwrite Then
		For $i = $d_Start To $d_EndIndex
			If $cb_Func($a_Array[$i]) Then
				If $i > $d_x Then $a_Array[$d_x] = $a_Array[$i]
				$d_x += 1
			EndIf
		Next
		If $b_Withcount Then $a_Array[0] = $d_x - 1
		If $bCbIsString Then Opt("ExpandEnvStrings", $bBefore)
		ReDim $a_Array[$d_x]
		If $2D Then $a_Array = _ArrayAinATo2d($a_Array)
		Return SetExtended($d_x, True)
	Else
		Local $a_Ret[$w]
		For $i = $d_Start To $d_EndIndex
			If $cb_Func($a_Array[$i]) Then
				$a_Ret[$d_x] = $a_Array[$i]
				$d_x += 1
			EndIf
		Next
		If $b_Withcount Then $a_Ret[0] = $d_x - 1
		If $bCbIsString Then Opt("ExpandEnvStrings", $bBefore)
		ReDim $a_Ret[$d_x]
		If $2D Then $a_Array = _ArrayAinATo2d($a_Array)
		Return SetExtended($d_x, $a_Ret)
	EndIf
EndFunc   ;==>_ArrayFilter

; #FUNCTION# ======================================================================================
; Name ..........: _ArrayDeleteByCondition
; Description ...: delete all empty string elements or which fulfil a user-defined condition inside an array
; Syntax ........: _ArrayDeleteByCondition(ByRef $aArray, Const $cbFunc = Default)
; Parameters ....: $a_Array       - the array where the elements should get deleted
;                  $cb_Func       - function variable points to a function of a form function($value)
;                                   the function return True for the elements which should get deleted from the array
;                                   If string then the value is parsed as AutoIt-Code.
;                                   The value inside the code for the current element should be named "$A"
;                                   example: _ArrayDeleteByCondition($a_Array, 'StringLeft($A, 1) = "B"')
; Return values .: -
; Author ........: AspirinJunkie
; =================================================================================================
Func _ArrayDeleteByCondition(ByRef $aArray, $cbFunc = Default)
	Local $iC = 0, $N = UBound($aArray), $bCbIsString = False

	If IsString($cbFunc) Then ; comparison function directly as a string
		Local $bBefore = Opt("ExpandEnvStrings", 1)
		$sAPLUS_CBSTRING = $cbFunc
		$cbFunc = __ap_cb_comp_String
		$bCbIsString = True
	EndIf

	Local $2D = False
	If UBound($aArray, 0) = 2 Then
		Local $2D = True
		$aArray = _Array2dToAinA($aArray)
	EndIf

	If IsFunc($cbFunc) Then
		For $i = 0 To $N - 1
			If $cbFunc($aArray[$i]) Then
				$iC += 1
			Else
				$aArray[$i - $iC] = $aArray[$i]
			EndIf
		Next
	Else ; default: delete all empty elements
		For $i = 0 To $N - 1
			If $aArray[$i] = "" Then
				$iC += 1
			Else
				$aArray[$i - $iC] = $aArray[$i]
			EndIf
		Next
	EndIf

	If $bCbIsString Then Opt("ExpandEnvStrings", $bBefore)

	ReDim $aArray[$N - $iC]
	If $2D Then $aArray = _ArrayAinATo2d($aArray)
	Return SetExtended(UBound($aArray), True)
EndFunc   ;==>_ArrayDeleteByCondition

; #FUNCTION# ======================================================================================
; Name ..........: _ArrayDeleteMultiValues()
; Description ...: Removes elements that appear more than once in the string. (not only the duplicates)
; Syntax ........: _ArrayDeleteMultiValues(ByRef $aArray)
; Parameters ....: ByRef $aArray - the 1D-array
; Return values .: Success: 1D array, cleaned by the elements which appear several times in the string
;                  Failure: Null and set @error to:
;                  |@error = 1: $aArray != 1D-array
; Author ........: aspirinjunkie
; Modified ......: 2022-07-12
; Example .......: Yes
;                  Global $a_Array[] = ["Name1", "Name2", "Name3", "Name2", "Name3", "Name4", "Name2"]
;                  $aFiltered = _ArrayDeleteMultiValues($a_Array)
;                  _ArrayDisplay($aFiltered)
; =================================================================================================
Func _ArrayDeleteMultiValues(ByRef $aArray)
	Local $mCount[]

	If UBound($aArray, 0) <> 1 Then Return SetError(1, UBound($aArray, 0), Null)

	For $i In $aArray
		$mCount[$i] += 1
	Next

	Local $iR = 0, $aRet[UBound($aArray)]
	For $i In $aArray
		If $mCount[$i] = 1 Then
			$aRet[$iR] = $i
			$iR += 1
		EndIf
	Next

	ReDim $aRet[$iR]
	Return SetExtended($iR, $aRet)
EndFunc   ;==>_ArrayDeleteDuplicates


; #FUNCTION# ======================================================================================
; Name ..........: _ArrayReduce
; Description ...: reduce the elements of a array to one value with an external function
; Syntax ........: _ArrayReduce(ByRef Const $a_Array, Const $cb_Func, Const $b_Withcount = False, $d_EndIndex = Default)
; Parameters ....: $a_Array       - the array
;                  $cb_Func       - function variable points to a function of a form "function(ByRef Reduced-Value, value)"
;                                   the function incrementally change the ReduceValue with the values
;                  $b_Withcount   - Set true if the number of elements are written in the first element of $a_Array
;                  $b_EndIndex    - the end index until the elements should be processed
; Return values .: Success: the reduced value
;                  Failure: False
;                     @error = 1: $a_Array is'nt an array
;                              2: invalid array size
; Author ........: AspirinJunkie
; =================================================================================================
Func _ArrayReduce(ByRef Const $a_Array, $cb_Func, Const $b_Withcount = False, $d_EndIndex = Default)
	Local $bCbIsString = False
	If Not IsArray($a_Array) Then Return SetError(1, 0, False)
	Local Const $w = UBound($a_Array)
	Local $d_Start = Int(Not ($b_Withcount = False))
	If $w < $d_Start Then Return SetError(2, 0, False)
	Local $f_x = 0

	If IsString($cb_Func) Then ; comparison function directly as a string
		Local $bBefore = Opt("ExpandEnvStrings", 1)
		$sAPLUS_CBSTRING = $cb_Func
		$cb_Func = __ap_cb_comp_String
		$bCbIsString = True
	EndIf

	If $d_EndIndex = Default Then $d_EndIndex = $w - 1
	$d_EndIndex = Int($d_EndIndex)
	If $d_EndIndex < 1 Or $d_EndIndex >= $w Then Return SetError(2, 0, False)

	For $i = $d_Start To $d_EndIndex
		$cb_Func($f_x, $a_Array[$i])
	Next

	If $bCbIsString Then Opt("ExpandEnvStrings", $bBefore)
	Return $f_x
EndFunc   ;==>_ArrayReduce

; #FUNCTION# ======================================================================================
; Name ..........: _ArrayGetMax
; Description ...: determine the element with the maximum value by using a user comparison function
; Syntax ........: _ArrayGetMax(ByRef $a_A, [Const $cb_Func = Default, [Const $d_Start = 0, [Const $d_End = UBound($a_A) - 1]]])
; Parameters ....: $a_A       	  - the array (1D or 2D)
;                  $cb_Func       - function variable points to a function of a form "[1|0|-1] function(value, value)"
;                                   the function compares two values a,and b for a>b/a=b/a<b
;                                   an example is the AutoIt-Function "StringCompare".
; 									For 2D-Arrays you can use form $a[...] vs. $b[...] inside the user function.
;                                   If string then the value is parsed as AutoIt-Code. The both values for comparison should be named "$A" and "$B"
;                  $d_Start   	  - index of the array where the search should start
;                  $d_End   	  - index of the array where the search should stop
; Return values .: Success: maximum value of the array
;                  Failure: -1
;                     @error = 1: $a_A is'nt an array or is empty
;                              2: wrong value for $d_Start (<0 or >$d_end)
;                              3: $d_End > Array size
; Author ........: AspirinJunkie
; =================================================================================================
Func _ArrayGetMax(ByRef $a_A, $cb_Func = Default, Const $d_Start = 0, Const $d_End = UBound($a_A) - 1)
	If $cb_Func = Default Then Return _ArrayMax($a_A)
	Local $bCbIsString = False

	If (Not IsArray($a_A)) Or ($d_End = -1) Then Return SetError(1, UBound($a_A), -1)
	If $d_Start < 0 Or $d_Start > $d_End Then Return SetError(2, $d_Start, -1)
	If $d_End > (UBound($a_A) - 1) Then Return SetError(3, $d_Start, -1)

	If IsString($cb_Func) Then ; comparison function directly as a string
		Local $bBefore = Opt("ExpandEnvStrings", 1)
		$sAPLUS_CBSTRING = $cb_Func
		$cb_Func = __ap_cb_comp_String
		$bCbIsString = True
	EndIf

	If UBound($a_A, 2) > 1 Then ; 2D-Array should be convert into an array-in-array for better handling in $cb_Func
		Local $a_B = _Array2dToAinA($a_A)

		Local $a_Max = $a_B[$d_Start]
		For $i = $d_Start + 1 To $d_End
			If $cb_Func($a_B[$i], $a_Max) = 1 Then $a_Max = $a_B[$i]
		Next
	Else
		Local $a_Max = $a_A[0]
		For $i = $d_Start + 1 To $d_End
			If $cb_Func($a_A[$i], $a_Max) = 1 Then $a_Max = $a_A[$i]
		Next
	EndIf

	If $bCbIsString Then Opt("ExpandEnvStrings", $bBefore)

	Return $a_Max
EndFunc   ;==>_ArrayGetMax



; #FUNCTION# ======================================================================================
; Name ..........: _ArrayGetMin
; Description ...: determine the element with the minimum value by using a user comparison function
; Syntax ........: _ArrayGetMin(ByRef $a_A, [$cb_Func = Default, [Const $d_Start = 0, [Const $d_End = UBound($a_A) - 1]]])
; Parameters ....: $a_A       	  - the array (1D or 2D)
;                  $cb_Func       - function variable points to a function of a form "[1|0|-1] function(value, value)"
;                                   the function compares two values a,and b for a>b/a=b/a<b
;                                   an example is the AutoIt-Function "StringCompare".
; 									For 2D-Arrays you can use form $a[...] vs. $b[...] inside the user function.
;                  $d_Start   	  - index of the array where the search should start
;                  $d_End   	  - index of the array where the search should stop
; Return values .: Success: Minimum value of the array
;                  Failure: -1
;                     @error = 1: $a_A is'nt an array or is empty
;                              2: wrong value for $d_Start (<0 or >$d_end)
;                              3: $d_End > Array size
; Author ........: AspirinJunkie
; =================================================================================================
Func _ArrayGetMin(ByRef $a_A, $cb_Func = Default, Const $d_Start = 0, Const $d_End = UBound($a_A) - 1)
	If $cb_Func = Default Then Return _ArrayMin($a_A)
	Local $bCbIsString = False

	If (Not IsArray($a_A)) Or ($d_End = -1) Then Return SetError(1, UBound($a_A), -1)
	If $d_Start < 0 Or $d_Start > $d_End Then Return SetError(2, $d_Start, -1)
	If $d_End > (UBound($a_A) - 1) Then Return SetError(3, $d_Start, -1)

	If IsString($cb_Func) Then ; comparison function directly as a string
		Local $bBefore = Opt("ExpandEnvStrings", 1)
		$sAPLUS_CBSTRING = $cb_Func
		$cb_Func = __ap_cb_comp_String
		$bCbIsString = True
	EndIf

	If UBound($a_A, 2) > 1 Then ; 2D-Array should be convert into an array-in-array for better handling in $cb_Func
		Local $a_B = _Array2dToAinA($a_A)

		Local $a_Min = $a_B[$d_Start]
		For $i = $d_Start + 1 To $d_End
			If $cb_Func($a_B[$i], $a_Min) = -1 Then $a_Min = $a_B[$i]
		Next
	Else
		Local $a_Min = $a_A[0]
		For $i = $d_Start + 1 To $d_End
			If $cb_Func($a_A[$i], $a_Min) = -1 Then $a_Min = $a_A[$i]
		Next
	EndIf

	If $bCbIsString Then Opt("ExpandEnvStrings", $bBefore)

	Return $a_Min
EndFunc   ;==>_ArrayGetMin


; #FUNCTION# ======================================================================================
; Name ..........: _ArrayMinMax()
; Description ...: Returns min and max value and their indices of a 1D array or all/specific column of a 2D array
; Syntax ........: _ArrayMinMax(ByRef $aArray[, $iColumn = Default[, $cbFunc = Default]])
; Parameters ....: ByRef $aArray - the array (1D or 2D)
;                  $iColumn      - [optional] If 2D-array: the column whose min/max values are to be determined. (default:Default)
;                  |If Default and $aArray = 2D-array: Min/Max-values/indices for every column
;                  $cbFunc      - [optional] function variable points to a function of a form "[1|0|-1] function(value, value)" (default:Default)
;                                   If string then the value is parsed as AutoIt-Code. The both values for comparison should be named "$A" and "$B"
;                  |the function compares two values a,and b for a>b/a=b/a<b
;                  |an example is the AutoIt-Function "StringCompare".
; Return values .: Success: min/max values and their indices
;                  |For 1D-array or 2D-Array with $icolumn set: return 1D-Array: [<min val>, <max val>, <min index>, <max index>]
;                  |For 2D-Array and $iColumn = Default: return 2D-Array: [[<min val n>, <max val n>, <min index n>, <max index n>], ...]
;                  Failure: return Null and set @error:
;                  |@error = 1: $aArray != 1D/2D-Array
;                  |@error = 2: invalid value for $cbFunc
;                  |@error = 3: invalid value for $iColumn
; Author ........: aspirinjunkie
; Modified ......: 2022-07-12
; Example .......: Yes
;                  Global $aArray1D[30]
;                  For $i = 0 To 29
;                      $aArray1D[$i] = Random(1, 1000, 1)
;                  Next
;                  _ArrayDisplay($aArray1D)
;                  $aMinMax = _ArrayMinMax($aArray1D)
;                  _ArrayDisplay($aMinMax)
; =================================================================================================
Func _ArrayMinMax(ByRef $aArray, $iColumn = Default, $cbFunc = Default)
	Local Enum $eMin, $eMax, $eMinInd, $eMaxInd
	Local $bCbIsString = False

	If IsString($cbFunc) Then ; comparison function directly as a string
		Local $bBefore = Opt("ExpandEnvStrings", 1)
		$sAPLUS_CBSTRING = $cbFunc
		$cbFunc = __ap_cb_comp_String
		$bCbIsString = True
	EndIf

	If $cbFunc <> Default And (Not IsFunc($cbFunc)) Then Return SetError(2, 0, Null)

	Switch UBound($aArray, 0)
		Case 1
			Local $aRet[4]
			$aRet[$eMin] = $aArray[0]
			$aRet[$eMax] = $aArray[0]
			$aRet[$eMinInd] = 0
			$aRet[$eMaxInd] = 0

			If $cbFunc = Default Then
				For $i = 1 To UBound($aArray) - 1
					If $aArray[$i] < $aRet[$eMin] Then
						$aRet[$eMin] = $aArray[$i]
						$aRet[$eMinInd] = $i
					ElseIf $aArray[$i] > $aRet[$eMax] Then
						$aRet[$eMax] = $aArray[$i]
						$aRet[$eMaxInd] = $i
					EndIf
				Next
			Else ; user defined comparison function
				For $i = 1 To UBound($aArray) - 1
					If $cbFunc($aArray[$i], $aRet[$eMin]) = -1 Then
						$aRet[$eMin] = $aArray[$i]
						$aRet[$eMinInd] = $i
					ElseIf $cbFunc($aArray[$i], $aRet[$eMax]) = 1 Then
						$aRet[$eMax] = $aArray[$i]
						$aRet[$eMaxInd] = $i
					EndIf
				Next
			EndIf

			If $bCbIsString Then Opt("ExpandEnvStrings", $bBefore)
			Return $aRet
		Case 2
			Local $nR = UBound($aArray), $nC = UBound($aArray, 2)

			If $iColumn = Default Then
				Local $aRet[4][$nC]

				For $i = 0 To $nC - 1
					$aRet[$eMin][$i] = $aArray[0][$i]
					$aRet[$eMax][$i] = $aArray[0][$i]
					$aRet[$eMinInd][$i] = 0
					$aRet[$eMaxInd][$i] = 0
				Next

				If $cbFunc = Default Then ; normal comparison
					For $i = 1 To $nR - 1
						For $j = 0 To $nC - 1
							If $aArray[$i][$j] < $aRet[$eMin][$j] Then
								$aRet[$eMin][$j] = $aArray[$i][$j]
								$aRet[$eMinInd][$j] = $i
							ElseIf $aArray[$i][$j] > $aRet[$eMax][$j] Then
								$aRet[$eMax][$j] = $aArray[$i][$j]
								$aRet[$eMaxInd][$j] = $i
							EndIf
						Next
					Next
				Else ; user defined comparison
					For $i = 1 To $nR - 1
						For $j = 0 To $nC - 1
							If $cbFunc($aArray[$i][$j], $aRet[$eMin][$j]) = -1 Then
								$aRet[$eMin][$j] = $aArray[$i][$j]
								$aRet[$eMinInd][$j] = $i
							ElseIf $cbFunc($aArray[$i][$j], $aRet[$eMax][$j]) = 1 Then
								$aRet[$eMax][$j] = $aArray[$i][$j]
								$aRet[$eMaxInd][$j] = $i
							EndIf
						Next
					Next
				EndIf
			Else
				If $iColumn > $nC Then Return SetError(3, $iColumn, Null)
				Local $aRet[4]
				$aRet[$eMin] = $aArray[0][$iColumn]
				$aRet[$eMax] = $aArray[0][$iColumn]
				$aRet[$eMinInd] = 0
				$aRet[$eMaxInd] = 0

				If $cbFunc = Default Then ; normal comparison
					For $i = 1 To $nR - 1
						If $aArray[$i][$iColumn] < $aRet[$eMin] Then
							$aRet[$eMin] = $aArray[$i][$iColumn]
							$aRet[$eMinInd] = $i
						ElseIf $aArray[$i][$iColumn] > $aRet[$eMax] Then
							$aRet[$eMax] = $aArray[$i][$iColumn]
							$aRet[$eMaxInd] = $i
						EndIf
					Next
				Else ; user defined comparison
					For $i = 1 To $nR - 1
						If $cbFunc($aArray[$i][$iColumn], $aRet[$eMin]) = -1 Then
							$aRet[$eMin] = $aArray[$i][$iColumn]
							$aRet[$eMinInd] = $i
						ElseIf $cbFunc($aArray[$i][$iColumn] > $aRet[$eMax]) = 1 Then
							$aRet[$eMax] = $aArray[$i][$iColumn]
							$aRet[$eMaxInd] = $i
						EndIf
					Next
				EndIf
			EndIf

			If $bCbIsString Then Opt("ExpandEnvStrings", $bBefore)
			Return $aRet
		Case Else
			Return SetError(1, UBound($aArray, 0), Null)

	EndSwitch
EndFunc   ;==>_ArrayMinMax

; #FUNCTION# ======================================================================================
; Name ..........: _ArrayGetNthBiggestElement
; Description ...: determine the nth biggest element in an unsorted array without sorting it (faster)
;                  one possible application is the fast calculation of the median-value
; Syntax ........: _ArrayGetNthBiggestElement(ByRef $a_A, $d_Nth, $i_Min, $i_Max, Const $cb_Func)
; Parameters ....: $a_A           - the array
;                  $d_Nth         - the theoretical position of the wanted value if the array is sorted
;                  $i_Min         - the start index for the partitioning range in the array
;                  $i_Max         - the end index for the partitioning range in the array
;                  $cb_Func       - function variable points to a function of a form "[1|0|-1] function(value, value)"
;                                   the function compares two values a,and b for a>b/a=b/a<b
;                                   an example is the AutoIt-Function "StringCompare".
;                                   if $cb_Func = Defaul the normal AutoIt-datatype-comparison is used
;  								    If string then the value is parsed as AutoIt-Code. The both values for comparison should be named "$A" and "$B"
; Return values .: the value of the nth biggest value
; Author ........: AspirinJunkie
; =================================================================================================
Func _ArrayGetNthBiggestElement(ByRef $a_A, $d_Nth = (UBound($a_A) = 1) ? 0 : Floor((UBound($a_A) - 1) / 2), $i_Min = 0, $i_Max = UBound($a_A) - 1, $cb_Func = Default)
	Local $bCbIsString = False

	If IsString($cb_Func) Then ; comparison function directly as a string
		Local $bBefore = Opt("ExpandEnvStrings", 1)
		$sAPLUS_CBSTRING = $cb_Func
		$cb_Func = __ap_cb_comp_String
		$bCbIsString = True
	EndIf

	If $cb_Func = Default Then
		Do
			Local $iMiddle = Floor(($i_Max + $i_Min) / 2)
			Local $A = $a_A[$i_Min], $b = $a_A[$i_Max], $c = $a_A[$iMiddle]

			; calculate the pivot element by median(Array[min], Array[middle], Array[max])
			Local $p_Value = $A > $b ? $A > $c ? $c > $b ? $c : $b : $A : $A > $c ? $A : $c > $b ? $b : $c ; = Median(a,b,c)
			Local $p_Index = $p_Value = $A ? $i_Min : $p_Value = $b ? $i_Max : $iMiddle ; = Index(p_Value)

			; move the pivot-element to the end of the array
			If $p_Index < $i_Max Then
				$a_A[$p_Index] = $a_A[$i_Max]
				$a_A[$i_Max] = $p_Value
			EndIf

			Local $i_PivotPos = __ap_PartitionHoare($a_A, $i_Min, $i_Max, $p_Value)

			If $i_PivotPos = $d_Nth Then
				Return $a_A[$i_PivotPos]
			ElseIf $i_PivotPos > $d_Nth Then
				$i_Max = $i_PivotPos - 1
			Else
				$i_Min = $i_PivotPos + 1
			EndIf
		Until 0
	Else ; if using a individual comparison function
		Do
			Local $iMiddle = Floor(($i_Max + $i_Min) / 2)
			Local $A = $a_A[$i_Min], $b = $a_A[$i_Max], $c = $a_A[$iMiddle]

			; calculate the pivot element by median(Array[min], Array[middle], Array[max])
			Local $p_Value = $cb_Func($A, $b) = 1 ? $cb_Func($A, $c) = 1 ? $cb_Func($c, $b) = 1 ? $c : $b : $A : $cb_Func($A, $c) = 1 ? $A : $cb_Func($c, $b) = 1 ? $b : $c ; = Median(a,b,c)
			Local $p_Index = $cb_Func($p_Value, $A) = 0 ? $i_Min : $cb_Func($p_Value, $b) = 0 ? $i_Max : $iMiddle ; = Index(p_Value)
			; move the pivot-element to the end of the array
			If $p_Index < $i_Max Then
				$a_A[$p_Index] = $a_A[$i_Max]
				$a_A[$i_Max] = $p_Value
			EndIf

			Local $i_PivotPos = __ap_PartitionHoare($a_A, $i_Min, $i_Max, $p_Value, $cb_Func)

			If $i_PivotPos = $d_Nth Then
				If $bCbIsString Then Opt("ExpandEnvStrings", $bBefore)
				Return $a_A[$i_PivotPos]
			ElseIf $i_PivotPos > $d_Nth Then
				$i_Max = $i_PivotPos - 1
			Else
				$i_Min = $i_PivotPos + 1
			EndIf
		Until 0
	EndIf
EndFunc   ;==>_ArrayGetNthBiggestElement

; #FUNCTION# ======================================================================================
; Name ..........: _ArraySortFlexible
; Description ...: sort an array with a user-defined sorting rule by choosing from Quicksort/Dual-Pivot-Quicksort/Insertion-Sort
; Syntax ........:_ArraySortFlexible(ByRef $a_Array, [$cb_Func = Default, [Const $i_Min = 0, [Const $i_Max = UBound($a_Array) - 1, [Const $b_MedianPivot = True, [Const $b_InsSort = True, [Const $d_SmallThreshold = 25, {Const $b_First = True}]]]]]])
; Parameters ....: $a_Array       - the array which should be sorted (by reference means direct manipulating of the array - no copy)
;                  $cb_Func       - function variable points to a function of a form "[1|0|-1] function(value, value)"
;                                   the function compares two values a,and b for a>b/a=b/a<b
;                                   an example is the AutoIt-Function "StringCompare".
;                                   If the default value is used this functions gets only a wrapper for the optimized _ArraySort()-function
;                                   If string then the value is parsed as AutoIt-Code. The both values for comparison should be named "$A" and "$B"
;  								       example: _ArraySortFlexible($a_Array, "StringCompare($A, $B)")
;                                               _ArraySortFlexible($a_Array, "$A > $B ? 1 : $A < $B ? -1 : 0")
;                  $i_Min         - the start index for the sorting range in the array
;                  $i_Max         - the end index for the sorting range in the array
;                  $b_MedianPivot - If True: pivot-element is median(first,last,middle) Else: pivot = list[Random]
;                  $b_InsSort     - If True: if length(list) < $d_SmallThreshold then insertion sort is used instead of recursive quicksort
;                  $d_SmallThreshold - the threshold-value for $b_InsSort (value=15 determined empirical)
;                  {$b_First}     - don't touch - for internal use only (checks if call is sub-call or user-call)
; Return values .: Success: True  - array is sorted now
;                  Failure: False
;                     @error = 1: $a_Array is'nt an array
;                              2: invalid value for $i_Min
;                              3: invalid value for $i_Max
;                              4: invalid combination of $i_Min and $i_Max
;                              5: invalid value for $cb_Func
; Author ........: AspirinJunkie
; Related .......: __ap_cb_comp_Normal(), __ap_PartitionHoare, __ap_ArrayDualPivotQuicksort
; Remarks .......: for sorting the quicksort-algorithm is used with hoare's algorithm for partitioning
;                  algorithm is a unstable sorting algorithm
; =================================================================================================
Func _ArraySortFlexible(ByRef $a_Array, $cb_Func = Default, Const $i_Min = 0, $i_Max = UBound($a_Array) - 1, Const $b_DualPivot = True, Const $b_MedianPivot = True, Const $b_InsSort = True, Const $d_SmallThreshold = 25, Const $b_First = True)
	Local $bCbIsString = False

	If $i_Max = 0 Then $i_Max = UBound($a_Array) - 1

	If IsString($cb_Func) Then ; comparison function directly as a string
		Local $bBefore = Opt("ExpandEnvStrings", 1)
		$sAPLUS_CBSTRING = $cb_Func
		$cb_Func = __ap_cb_comp_String
		$bCbIsString = True
	ElseIf $cb_Func = Default Then
		$cb_Func = __ap_cb_comp_Normal
	EndIf

	If $b_First Then
		If $cb_Func = Default Then Return _ArraySort($a_Array, 0, 0, 0, 0, 1)
		If UBound($a_Array, 0) = 2 Then
			Local $2D = True
			$a_Array = _Array2dToAinA($a_Array)
		Else
			Local $2D = False
		EndIf
		; error-handling:
		If Not IsArray($a_Array) Then Return SetError(1, 0, False)
		If Not IsInt($i_Min) Or $i_Min < 0 Then Return SetError(2, $i_Min, False)
		If Not IsInt($i_Max) Or $i_Max > UBound($a_Array) - 1 Then Return SetError(3, $i_Min, False)
		If $i_Min > $i_Max Then Return SetError(4, $i_Max - $i_Min, False)
		If Not IsFunc($cb_Func) Then Return SetError(5, 0, False)
	EndIf

	; choose the sorting-algorithm:
	If $b_DualPivot Then ; Dual-Pivot-Quicksort
		__ap_ArrayDualPivotQuicksort($a_Array, $cb_Func, $i_Min, $i_Max)
	ElseIf $b_InsSort And (($i_Max - $i_Min) < $d_SmallThreshold) Then ; insertion-sort:
		Switch $i_Max - $i_Min + 1
			Case 2
				__2Sort($cb_Func, $a_Array[$i_Min], $a_Array[$i_Max])
			Case 3
				__3Sort($cb_Func, $a_Array[$i_Min], $a_Array[$i_Min + 1], $a_Array[$i_Max])
			Case 4
				__4Sort($cb_Func, $a_Array[$i_Min], $a_Array[$i_Min + 1], $a_Array[$i_Min + 2], $a_Array[$i_Max])
			Case 5
				__5Sort($cb_Func, $a_Array[$i_Min], $a_Array[$i_Min + 1], $a_Array[$i_Min + 2], $a_Array[$i_Min + 3], $a_Array[$i_Max])
			Case Else ; Insertion Sort
				Local $t1, $t2
				For $i = $i_Min + 1 To $i_Max
					$t1 = $a_Array[$i]
					For $j = $i - 1 To $i_Min Step -1
						$t2 = $a_Array[$j]
						If $cb_Func($t1, $t2) <> -1 Then ExitLoop
						$a_Array[$j + 1] = $t2
					Next
					$a_Array[$j + 1] = $t1
				Next
		EndSwitch
	Else ; Quicksort:
		; the pivot element which divides the list in two separate lists (values < pivot -> left list, values > pivot -> right list); here pivot=list[random] to minimize the probability of worst case. Other solution is median(iMin, iMiddle, iMax) 			Das Trennelement (alles was kleiner ist - links davon, alles was gr��er ist - rechts davon), Hier Random damit Worst-Case unwahrscheinlich wird
		If $b_MedianPivot Then ; pivot = median(iMin, iMiddle, iMax)
			Local Const $iMiddle = Floor(($i_Max + $i_Min) / 2)
			Local Const $A = $a_Array[$i_Min], $b = $a_Array[$i_Max], $c = $a_Array[$iMiddle]
			Local $p_Value = $cb_Func($A, $b) = 1 ? $cb_Func($A, $c) = 1 ? $cb_Func($c, $b) = 1 ? $c : $b : $A : $cb_Func($A, $c) = 1 ? $A : $cb_Func($c, $b) = 1 ? $b : $c ; = Median(a,b,c)
			Local $p_Index = $p_Value = $A ? $i_Min : $p_Value = $b ? $i_Max : $iMiddle ; = Index(p_Value)
		Else ; pivot=list[random]
			Local $p_Index = Random($i_Min, $i_Max, 1)
			Local $p_Value = $a_Array[$p_Index]
		EndIf

		; move the pivot-element to the end of the array
		If $p_Index < $i_Max Then
			$a_Array[$p_Index] = $a_Array[$i_Max]
			$a_Array[$i_Max] = $p_Value
		EndIf

		Local $i = __ap_PartitionHoare($a_Array, $i_Min, $i_Max, $p_Value, $cb_Func)
		; sort the left list (if length > 1) :
		If $i_Min < $i - 1 Then _ArraySortFlexible($a_Array, $cb_Func, $i_Min, $i - 1, False, False)
		; recursively sort the right list (if length > 1):
		If $i_Max > $i + 1 Then _ArraySortFlexible($a_Array, $cb_Func, $i + 1, $i_Max, False, False)
	EndIf

	If $bCbIsString Then Opt("ExpandEnvStrings", $bBefore)
	If $b_First And $2D Then $a_Array = _ArrayAinATo2d($a_Array)
	Return True
EndFunc   ;==>_ArraySortFlexible

; #FUNCTION# ======================================================================================
; Name ..........: _ArrayIsSorted
; Description ...: checks whether an Array is already sorted
; Syntax ........: _ArrayIsSorted(ByRef $a_Array, [Const $i_Min = 0, [Const $i_Max = UBound($a_Array) - 1)]])
; Parameters ....: $a_Array       - the "semi-dynamic"-Array (needs an array with number of elements in $a_Array[0])
;                  $cb_Func       - function variable points to a function of a form "function(ByRef Reduced-Value, value)"
;                                   the function incrementally change the ReduceValue with the values
;  								    If string then the value is parsed as AutoIt-Code. The both values for comparison should be named "$A" and "$B"
;                  $b_Withcount   - Set true if the number of elements are written in the first element of $a_Array
;                  $b_Overwrite   - If true: $a_Array gets overwritten; If false: no changes to $a_Array - new array will returned
;                  $b_EndIndex    - the end index until the elements should be processed
; Return values .: Success: the reduced value
;                  Failure: False
;                     @error = 1: $a_Array is'nt an array
;                              2: invalid array size
; Author ........: AspirinJunkie
; =================================================================================================
Func _ArrayIsSorted(ByRef $a_Array, Const $i_Min = 0, Const $i_Max = UBound($a_Array) - 1, $cb_Func = Default)
	Local $bCbIsString = False

	If Not IsArray($a_Array) Then Return SetError(1, 0, False)
	If $i_Min > $i_Max Then Return SetError(2, $i_Max - $i_Min, False)
	If Not IsInt($i_Min) Or $i_Min < 0 Then Return SetError(3, $i_Min, False)
	If Not IsInt($i_Max) Or $i_Max > UBound($a_Array) - 1 Then Return SetError(4, $i_Min, False)

	If IsString($cb_Func) Then ; comparison function directly as a string
		Local $bBefore = Opt("ExpandEnvStrings", 1)
		$sAPLUS_CBSTRING = $cb_Func
		$cb_Func = __ap_cb_comp_String
		$bCbIsString = True
	EndIf

	If UBound($a_Array, 0) = 2 Then
		Local $2D = True
		$a_Array = _Array2dToAinA($a_Array)
	Else
		Local $2D = False
	EndIf

	For $i = $i_Min + 1 To $i_Max
		If $cb_Func = Default Then ; normal autoit-comparison
			If $a_Array[$i] < $a_Array[$i - 1] Then Return False
		Else ; user-defined comparison
			If $cb_Func($a_Array[$i], $a_Array[$i - 1]) = -1 Then Return False
		EndIf
	Next

	If $bCbIsString Then Opt("ExpandEnvStrings", $bBefore)
	If $2D Then $a_Array = _ArrayAinATo2d($a_Array)
	Return True
EndFunc   ;==>_ArrayIsSorted

; #FUNCTION# ======================================================================================
; Name ..........: _ArrayBinarySearchFlex
; Description ...: performs a binary search for an appropriately sorted array using an individual comparison function
; Syntax ........: _ArrayBinarySearchFlex(ByRef $A, $cb_Func, $sS, [$iMi = 0, [$iMa = UBound($A) - 1]])
; Parameters ....: $a_Array       - The sorted array to search in
;                  $cb_Func       - function variable points to a function of a form "[1|0|-1] function(value, value)"
;                                   The function has two tasks:
;                                     * Check whether the second parameter corresponds to a defined pattern (then ret value = 0).
;                                     * Check whether a pattern searched for would be greater or smaller than the second parameter.
;                                   the first parameter a value can be passed to the function through $sS to make it more dynamic.
;  								    If string then the value is parsed as AutoIt-Code. The both values for comparison should be named "$A" and "$B", where $A = $sS and $B is the current element for comparison
;                                   example: _ArrayBinarySearchFlex($a_Array, "StringRegExp($B, '^B') = 1 ? 0 : -StringCompare('B', $B)")
;                  $sS          - a value to be passed to $cb_Func to make it more dynamic
;                  $iMi         - the start index of the search area
;                  $iMa         - the end index of the search area
; Return values .: Success:     Array with matches + index of first match in @extended
;                  Failure:    empty array if no match ( + @error = 1), else undefined + @error
;                     @error = 1: No match found (return value = empty array)
;                              2: invalid return value of cb_Func
;                              3: invalid value for $A (no array)
;                              4: invalid value for $$cb_Func (no function)
;                              5: invalid value for $iMi
;                              6: invalid value for $iMa
;                              7: $iMa < $iMi
; Author ........: AspirinJunkie
; Example:         Local $a_Array = ["BASF", "Allianz", "Volkswagen", "BMW", "Bayer", "Telekom", "Post", "Linde"]
;                  _ArraySortFlexible($a_Array)
;
;                  $a_Founds = _ArrayBinarySearchFlex($a_Array, _myCompare, "B")
;                  If Not @error Then _ArrayDisplay($a_Founds)
;
;                  Func _myCompare(Const $sS, Const $sO)
;                  	Return StringRegExp($sO, '^' & $sS) = 1 ? 0 : -StringCompare($sO, $sS)
;                  EndFunc   ;==>_myCompare
; =================================================================================================
Func _ArrayBinarySearchFlex(ByRef $A, $cb_Func, $sS = Default, $iMi = 0, $iMa = UBound($A) - 1)
	Local $i, $e, $bCbIsString = False
	Local $aP[3] = ['CallArgArray', $sS]

	If Not IsArray($A) Then Return SetError(3)

	If Not IsInt($iMi) Or $iMi < 0 Or $iMi >= UBound($A) Then Return SetError(5, $iMi)
	If Not IsInt($iMa) Or $iMa < 0 Or $iMa >= UBound($A) Then Return SetError(6, $iMa)
	If $iMa < $iMi Then Return SetError(7)

	If IsString($cb_Func) Then ; comparison function directly as a string
		Local $bBefore = Opt("ExpandEnvStrings", 1)
		$sAPLUS_CBSTRING = $cb_Func
		$cb_Func = __ap_cb_comp_String
		$bCbIsString = True
	EndIf

	If Not IsFunc($cb_Func) Then Return SetError(4)

	While $iMi <= $iMa
		$i = Floor(($iMa + $iMi) / 2)
		$e = $A[$i]
		$aP[2] = $e

		Switch Call($cb_Func, $aP)
			Case 0 ; match!
				; now lookaround to see if there are more matches
				$iMi = $i
				Do
					$iMi -= 1
					If $iMi < 0 Then ExitLoop
					$aP[2] = $A[$iMi]
				Until Call($cb_Func, $aP) <> 0
				$iMi += 1

				$iMa = $i
				Do
					$iMa += 1
					If $iMa >= UBound($A) Then ExitLoop
					$aP[2] = $A[$iMa]
				Until Call($cb_Func, $aP) <> 0
				$iMa -= 1

				; build return array
				Local $aR[$iMa - $iMi + 1]
				For $i = 0 To UBound($aR) - 1
					$aR[$i] = $A[$iMi]
					$iMi += 1
				Next
				Return SetExtended($iMi, $aR)
			Case -1
				$iMa = $i - 1
			Case 1
				$iMi = $i + 1
			Case Else
				Return SetError(2)
		EndSwitch
	WEnd

	If $bCbIsString Then Opt("ExpandEnvStrings", $bBefore)

	Local $aR = []
	Return SetError(1, 0, $aR)
EndFunc   ;==>_ArrayBinarySearchFlex

; #FUNCTION# ======================================================================================
; Name ..........: _ArraySortInsertion
; Description ...: sort an array with a user-defined sorting rule with the insertion-sort algorithm
; Syntax ........:_ArraySortInsertion(ByRef $A, [$cb_Func = Default, [Const $i_Min = 0, [Const $i_Max = UBound($a_Array) - 1,{Const $b_First = True}]]])
; Parameters ....: $a_Array       - the array (1D/2D) which should be sorted (by reference means direct manipulating of the array - no copy)
;                  $cb_Func       - function variable points to a function of a form "[1|0|-1] function(value, value)"
;                                   the function compares two values a,and b for a>b/a=b/a<b
;                                   an example is the AutoIt-Function "StringCompare".
;                                   If the default value is used this functions gets only a wrapper for the optimized _ArraySort()-function
;  								    If string then the value is parsed as AutoIt-Code. The both values for comparison should be named "$A" and "$B"
;                                   example: _ArraySortInsertion($a_Array, "StringCompare($A, $B)")
;                                            _ArraySortInsertion($a_Array, "$A > $B ? 1 : $A < $B ? -1 : 0")
;                  $i_Min         - the start index for the sorting range in the array
;                  $i_Max         - the end index for the sorting range in the array
; Return values .: Success: True  - array is sorted now
; Author ........: AspirinJunkie
; Related .......: __cb_NormalComparison()
; Remarks .......: Algorithm is a stable sorting algorithm
; =================================================================================================
Func _ArraySortInsertion(ByRef $A, $cb_Func = Default, Const $i_Min = 0, Const $i_Max = UBound($A) - 1)
	Local $t1, $t2, $bCbIsString = False

	If UBound($A, 0) = 2 Then
		Local $2D = True
		$A = _Array2dToAinA($A)
	Else
		Local $2D = False
	EndIf

	If IsString($cb_Func) Then ; comparison function directly as a string
		Local $bBefore = Opt("ExpandEnvStrings", 1)
		$sAPLUS_CBSTRING = $cb_Func
		$cb_Func = __ap_cb_comp_String
		$bCbIsString = True
	ElseIf $cb_Func = Default Then
		$cb_Func = __ap_cb_comp_Normal
	EndIf

	For $i = $i_Min + 1 To $i_Max
		$t1 = $A[$i]
		For $j = $i - 1 To $i_Min Step -1
			$t2 = $A[$j]
			If $cb_Func($t1, $t2) <> -1 Then ExitLoop
			$A[$j + 1] = $t2
		Next
		$A[$j + 1] = $t1
	Next

	If $bCbIsString Then Opt("ExpandEnvStrings", $bBefore)

	If $2D Then $A = _ArrayAinATo2d($A)
	Return True
EndFunc   ;==>_ArraySortInsertion

; #FUNCTION# ======================================================================================
; Name ..........: _ArraySortSelection
; Description ...: sort an array with a user-defined sorting rule with the selection-sort (variant OSSA) algorithm
;                  This algorithm has a minimum number of swaps, so mostly only needed for cases where the number of swaps are highly expensive.
;                  See the function here therefore mainly as a template for own special implementations.
; Syntax ........: _ArraySortSelection(ByRef $A, [$cb_Func = Default, [Const $i_Min = 0, [Const $i_Max = UBound($a_Array) - 1,{Const $b_First = True}]]])
; Parameters ....: $a_Array       - the array which should be sorted (by reference means direct manipulating of the array - no copy)
;                  $cb_Func       - function variable points to a function of a form "[1|0|-1] function(value, value)"
;                                   the function compares two values a,and b for a>b/a=b/a<b
;                                   an example is the AutoIt-Function "StringCompare".
;  								    If string then the value is parsed as AutoIt-Code. The both values for comparison should be named "$A" and "$B"
;                                   example: _ArraySortSelection($a_Array, "StringCompare($A, $B)")
;                                            _ArraySortSelection($a_Array, "$A > $B ? 1 : $A < $B ? -1 : 0")
;                  $i_Min         - the start index for the sorting range in the array
;                  $i_Max         - the end index for the sorting range in the array
; Return values .: Success: True  - array is sorted now
; Author ........: AspirinJunkie
; Related .......: __ap_cb_comp_Normal()
; Remarks .......: special implementation OSSA from https://www.researchgate.net/publication/272609538_Optimized_Selection_Sort_Algorithm_is_faster_than_Insertion_Sort_Algorithm_a_Comparative_Study
;                  and fixed from here: https://stackoverflow.com/questions/39798057/optimized-selection-sort-algorithm-ossa-how-to-fix-it
; =================================================================================================
Func _ArraySortSelection(ByRef $A, $cb_Func = Default, Const $i_Min = 0, Const $i_Max = UBound($A) - 1)
	Local $bCbIsString = False

	If IsString($cb_Func) Then ; comparison function directly as a string
		Local $bBefore = Opt("ExpandEnvStrings", 1)
		$sAPLUS_CBSTRING = $cb_Func
		$cb_Func = __ap_cb_comp_String
		$bCbIsString = True
	ElseIf $cb_Func = Default Then
		$cb_Func = __ap_cb_comp_Normal
	EndIf

	Local $k = $i_Min, _
			$N = $i_Max, _
			$iL, $iS, _
			$vS, $vL, $vT

	For $i = $N To $k Step -1
		$iL = $k
		$iS = $k

		; determine index of largest and smallest element of sub-set
		For $j = $k To $i
			If $cb_Func($A[$j], $A[$iL]) = 1 Then $iL = $j
			If $cb_Func($A[$j], $A[$iS]) = -1 Then $iS = $j
		Next

		; swap smallest element to $i and largest to $k
		$vS = $A[$iS]
		$vL = $A[$iL]
		If $iS = $i Then
			If $iL <> $k Then $A[$iL] = $A[$k]
		ElseIf $iL = $k Then
			$A[$iS] = $A[$i]
		Else
			$A[$iS] = $A[$k]
			$A[$iL] = $A[$i]
		EndIf

		$A[$k] = $vS
		$A[$i] = $vL

		$k += 1
		If $i <= $k Then ExitLoop
	Next

	If $bCbIsString Then Opt("ExpandEnvStrings", $bBefore)
EndFunc   ;==>_ArraySortSelection


; #FUNCTION# ======================================================================================
; Name ..........: _ArrayHeapSortBinary
; Description ...: sort an array with Binary-Min-Heap-Sort algorithm
; Syntax ........: _ArrayHeapSortBinary(ByRef $A, [$cb_Func = Default, [$iMax = UBound($A) - 1]])
; Parameters ....: $A             - the [0]-based array which should be sorted
;                  $cb_Func       - function variable points to a function of a form "[1|0|-1] function(value, value)"
;                                   the function compares two values a,and b for a>b/a=b/a<b
;                                   an example is the AutoIt-Function "StringCompare".
;                                   If the default value is used this functions gets only a wrapper for the optimized _ArraySort()-function
;  								    If string then the value is parsed as AutoIt-Code. The both values for comparison should be named "$A" and "$B"
;                  $iMax          - the end index until the array should get sorted
; Return values .: Success: True  - array is sorted now
;                  Failure: False
;                     @error = 1: $a_Array is'nt an array
;                              2: invalid value for $iMax
;                              3: $cb_Func isn't a function-variable
; Author ........: AspirinJunkie
; =================================================================================================
Func _ArrayHeapSortBinary(ByRef $A, $cb_Func = Default, $iMax = UBound($A) - 1)
	Local $N = $iMax + 1, $bCbIsString = False
	Local $k, $S, $j

	If IsString($cb_Func) Then ; comparison function directly as a string
		Local $bBefore = Opt("ExpandEnvStrings", 1)
		$sAPLUS_CBSTRING = $cb_Func
		$cb_Func = __ap_cb_comp_String
		$bCbIsString = True
	EndIf
	If $cb_Func = Default Then $cb_Func = __ap_cb_comp_Normal

	; error-handling:
	If Not IsArray($A) Then Return SetError(1, 0, False)
	If $iMax >= UBound($A) Then Return SetError(2, 0, False)
	If Not IsFunc($cb_Func) Then Return SetError(3, 0, False)

	For $i = Floor($N / 2) To 0 Step -1
		$j = $i
		; ------------ create a binary heap for the range i-n:
		$k = $i * 2 + 1
		$S = $A[$i]
		While $k < $N
			If $k + 1 < $N And $cb_Func($A[$k], $A[$k + 1]) = -1 Then $k += 1
			If $cb_Func($S, $A[$k]) <> -1 Then ExitLoop
			$A[$j] = $A[$k]
			$j = $k
			$k = $j * 2 + 1
		WEnd
		$A[$j] = $S
	Next

	For $N = $N - 1 To 0 Step -1
		$S = $A[$N]
		$A[$N] = $A[0]
		$A[0] = $S

		; ------------ create a binary heap for the the range 0-n:
		$j = 0
		$k = 1
		While $k < $N
			If $k + 1 < $N And $cb_Func($A[$k], $A[$k + 1]) = -1 Then $k += 1
			If $cb_Func($S, $A[$k]) <> -1 Then ExitLoop
			$A[$j] = $A[$k]
			$j = $k
			$k = $j * 2 + 1
		WEnd
		$A[$j] = $S
	Next
	If $bCbIsString Then Opt("ExpandEnvStrings", $bBefore)
	Return True
EndFunc   ;==>_ArrayHeapSortBinary


; #FUNCTION# ======================================================================================
; Name ..........: _ArrayHeapSortTernary
; Description ...: sort an array with Ternary-Min-Heap-Sort algorithm
; Syntax ........: _ArrayHeapSortTernary(ByRef $A, [$cb_Func = Default, [$iMax = UBound($A) - 1]])
; Parameters ....: $A             - the [0]-based array which should be sorted
;                  $cb_Func       - function variable points to a function of a form "[1|0|-1] function(value, value)"
;                                   the function compares two values a,and b for a>b/a=b/a<b
;                                   an example is the AutoIt-Function "StringCompare".
;                                   If the default value is used this functions gets only a wrapper for the optimized _ArraySort()-function
;  								    If string then the value is parsed as AutoIt-Code. The both values for comparison should be named "$A" and "$B"
;                  $iMax          - the end index until the array should get sorted
; Return values .: Success: True  - array is sorted now
;                  Failure: False
;                     @error = 1: $a_Array is'nt an array
;                              2: invalid value for $iMax
;                              3: $cb_Func isn't a function-variable
; Author ........: AspirinJunkie
; =================================================================================================
Func _ArrayHeapSortTernary(ByRef $A, $cb_Func = Default, $iMax = UBound($A) - 1)
	Local $N = $iMax + 1
	Local $i, $j, $S
	Local $k, $m, $r, $x, $y, $z, $bCbIsString = False

	If IsString($cb_Func) Then ; comparison function directly as a string
		Local $bBefore = Opt("ExpandEnvStrings", 1)
		$sAPLUS_CBSTRING = $cb_Func
		$cb_Func = __ap_cb_comp_String
		$bCbIsString = True
	EndIf
	If $cb_Func = Default Then $cb_Func = __ap_cb_comp_Normal

	; error-handling:
	If Not IsArray($A) Then Return SetError(1, 0, False)
	If $iMax >= UBound($A) Then Return SetError(2, 0, False)
	If Not IsFunc($cb_Func) Then Return SetError(3, 0, False)

	For $i = Floor($N / 3) To 0 Step -1
		;----- Heapify($A, $i, $n) -------
		$j = $i
		$k = $i * 3 + 1
		$S = $A[$j]

		While $k < $N
			$m = $k + 1
			$r = $m + 1
			$x = $A[$k]

			If $r < $N Then
				$y = $A[$m]
				$z = $A[$r]
				$k = $cb_Func($x, $y) <> -1 ? $cb_Func($x, $z) <> -1 ? $k : $r : $cb_Func($y, $z) <> -1 ? $m : $r ; max child of i
			ElseIf $m < $N Then
				If $cb_Func($x, $A[$m]) = -1 Then $k = $m
			EndIf

			If $cb_Func($S, $A[$k]) <> -1 Then ExitLoop
			$A[$j] = $A[$k]
			$j = $k
			$k = $j * 3 + 1
		WEnd
		$A[$j] = $S
	Next

	For $N = $N - 1 To 0 Step -1
		; swap(A, 0, i)
		$S = $A[$N]
		$A[$N] = $A[0]
		$A[0] = $S

		;-------- Heapify($A, 0, $n) ---------
		$i = 0
		$k = 1
		While $k < $N
			$m = $k + 1
			$r = $m + 1
			$x = $A[$k]

			If $r < $N Then
				$y = $A[$m]
				$z = $A[$r]
				$k = $cb_Func($x, $y) <> -1 ? $cb_Func($x, $z) <> -1 ? $k : $r : $cb_Func($y, $z) <> -1 ? $m : $r ; max child of i
			ElseIf $m < $N Then
				If $cb_Func($x, $A[$m]) = -1 Then $k = $m
			EndIf

			If $cb_Func($S, $A[$k]) <> -1 Then ExitLoop
			$A[$i] = $A[$k]
			$i = $k
			$k = $i * 3 + 1
		WEnd
		$A[$i] = $S
	Next

	If $bCbIsString Then Opt("ExpandEnvStrings", $bBefore)
	Return True
EndFunc   ;==>_ArrayHeapSortTernary

#EndRegion

#Region Helper functions

; #FUNCTION# ======================================================================================
; Name ..........: __ap_cb_comp_Normal
; Description ...: helper function which provides a standard AutoIt-comparison for flexible sorting
; Syntax ........: __ap_cb_comp_Normal(ByRef Const $A, ByRef Const $B)
; Parameters ....: $a             - the first value
;                  $b             - the second value
; Return values .:  1: a > b
;                   0: a = b
;                  -1: a < b
; Author ........: AspirinJunkie
; =================================================================================================
Func __ap_cb_comp_Normal(ByRef Const $A, ByRef Const $b)
	Return $A > $b ? 1 : $A = $b ? 0 : -1
EndFunc   ;==>__ap_cb_comp_Normal

; #FUNCTION# ======================================================================================
; Name ..........: __ap_cb_comp_Natural
; Description ...: helper function which provides a explorer-like comparison for natural sorting
;                  (more intuitively if numerical values occur in the strings)
; Syntax ........: __ap_cb_comp_Natural(ByRef Const $A, ByRef Const $B)
; Parameters ....: $A             - the first value
;                  $B             - the second value
; Return values .:  1: a > b
;                   0: a = b
;                  -1: a < b
; Author ........: AspirinJunkie
; =================================================================================================
Func __ap_cb_comp_Natural(Const $A, Const $B)
    Local Static $h_DLL_Shlwapi = DllOpen("Shlwapi.dll")
    Local $a_Ret = DllCall($h_DLL_Shlwapi, "int", "StrCmpLogicalW", "wstr", $A, "wstr", $B)
    If @error Then Return SetError(1, @error, 0)
    If Not IsString($A) Or Not IsString($B) Then Return $A > $B ? 1 : $A < $B ? -1 : 0
    Return $a_Ret[0]
EndFunc   ;==>MyCompare

; #FUNCTION# ======================================================================================
; Name ..........: __ap_cb_comp_String
; Description ...: helper function which executes a comparison function in the string within the variable $sAPLUS_CBSTRING
; Syntax ........: __ap_cb_comp_String(Const $A, Const $B)
; Parameters ....: $a             - the first value
;                  $b             - the second value
; Return values .:  string in $sAPLUS_CBSTRING should execute to the following return values:
;                   1: a > b
;                   0: a = b
;                  -1: a < b
; Related .......: global Variable named $sAPLUS_CBSTRING
; Remarks .......: for using this function set Opt("ExpandEnvStrings", 1) before calling
; Author ........: AspirinJunkie
; =================================================================================================
Func __ap_cb_comp_String(ByRef $A, Const $b = Default)
	Local $vRet = Execute($sAPLUS_CBSTRING)
	Return $vRet
EndFunc

; #FUNCTION# ======================================================================================
; Name ..........: __ap_swap
; Description ...: helper function for swap two values inside an array
; Syntax ........: __ap_swap(ByRef Const $a, ByRef Const $b)
; Parameters ....: $a             - the array
;                  $i             - index of value 1
;                  $j             - index of value 2
; Return values .: -
; Author ........: AspirinJunkie
; =================================================================================================
Func __ap_swap(ByRef $A, Const $i, Const $j)
	Local Const $t = $A[$i]
	$A[$i] = $A[$j]
	$A[$j] = $t
EndFunc   ;==>__ap_swap

; #FUNCTION# ======================================================================================
; Name ..........: __ap_PartitionHoare
; Description ...: helper function for partitioning inside the quicksort-function
;                  there exists several algorithms for this.
; Syntax ........: __ap_PartitionHoare(ByRef $a_Array, Const $i_Min, Const $i_Max, Const $p_Value, Const $cb_Func)
; Parameters ....: $a_Array       - the array
;                  $i_Min         - the start index for the partitioning range in the array
;                  $i_Max         - the end index for the partitioning range in the array
;                  $p_Value       - the value of the pivot-element
;                  $cb_Func       - function variable points to a function of a form "[1|0|-1] function(value, value)"
;                                   the function compares two values a,and b for a>b/a=b/a<b
;                                   an example is the AutoIt-Function "StringCompare".
; Return values .: the position of the pivot-element
; Author ........: AspirinJunkie
; =================================================================================================
Func __ap_PartitionHoare(ByRef $a_Array, Const $i_Min, Const $i_Max, Const $p_Value, Const $cb_Func = Default)
	; divide the array in two separate lists in dependency of the pivot-element
	; there are several algorithms to reach this (here used: "Quickselect / Hoare's selection algorithm" - see "Lomuto's algorithm")
	Local $i = $i_Min - 1
	Local $j = $i_Max + 1
	Local $t

	If $cb_Func = Default Then
		Do
			; start from right and go left until the next element which is smaller than pivot:
			Do
				$j -= 1
			Until $a_Array[$j] < $p_Value Or $j = $i_Min
			; start from left and go right until the next element which is greater than pivot:
			Do
				$i += 1
			Until $a_Array[$i] > $p_Value Or $i = $i_Max

			; swap if elements are on the wrong side of the lists
			If $i < $j Then
				$t = $a_Array[$j]
				$a_Array[$j] = $a_Array[$i]
				$a_Array[$i] = $t
			EndIf
		Until $i >= $j

		; swap with pivot-element if pivot is at the wrong list-side:
		If $a_Array[$i] > $p_Value Then
			$a_Array[$i_Max] = $a_Array[$i]
			$a_Array[$i] = $p_Value
		EndIf
	Else     ; if using a individual comparison function
		Do
			; start from right and go left until the next element which is smaller than pivot:
			Do
				$j -= 1
			Until $cb_Func($a_Array[$j], $p_Value) = -1 Or $j = $i_Min
			; start from left and go right until the next element which is greater than pivot:
			Do
				$i += 1
			Until $cb_Func($a_Array[$i], $p_Value) = 1 Or $i = $i_Max
			; swap if elements are on the wrong side of the lists
			If $i < $j Then
				$t = $a_Array[$j]
				$a_Array[$j] = $a_Array[$i]
				$a_Array[$i] = $t
			EndIf
		Until $i >= $j

		; swap with pivot-element if pivot is at the wrong list-side:
		If $cb_Func($a_Array[$i], $p_Value) = 1 Then
			$a_Array[$i_Max] = $a_Array[$i]
			$a_Array[$i] = $p_Value
		EndIf
	EndIf

	Return $i
EndFunc   ;==>__ap_PartitionHoare


; #FUNCTION# ======================================================================================
; Name ..........: __ap_ArrayDualPivotQuicksort
; Description ...: sort an array with the Dual-Pivot-Quicksort from Vladimir Yaroslavskiy
; Syntax ........:__ap_ArrayDualPivotQuicksort(ByRef $A, [$cb_Func = Default, [Const $left = 0, [Const $right = UBound($a_Array) - 1, Const $d_SmThr = 25, [Const $b_MedQuant = True, {Const $b_First = True}]]]]])
; Parameters ....: $A             - the array which should be sorted (by reference means direct manipulating of the array - no copy)
;                  $cb_Func       - function variable points to a function of a form "[1|0|-1] function(value, value)"
;                                   the function compares two values a,and b for a>b/a=b/a<b
;                                   an example is the AutoIt-Function "StringCompare".
;                                   If the default value is used this functions gets only a wrapper for the optimized _ArraySort()-function
;                  $left          - the start index for the sorting range in the array
;                  $right         - the end index for the sorting range in the array
;                  $div           - factor for calculating the pivots positions - normally dont't change this value
;                  $d_SmThr       - the threshold-value for $b_InsSort (value=35 determined empirical)
;                  $b_MedQuant    - if true the dual-pivot-elements are estimated by an more robust approach which should lead to more similar sized subarrays
;                  {$b_First}     - don't touch - for internal use only (checks if call is sub-call or user-call)
; Return values .: Success: True  - array is sorted now
;                  Failure: False
;                     @error = 1: $a_Array is'nt an array
;                              2: invalid value for $i_Min
;                              3: invalid value for $i_Max
;                              4: invalid combination of $i_Min and $i_Max
;                              5: invalid value for $cb_Func
; Author ........: AspirinJunkie
; Related .......: __ap_cb_comp_Normal()
; =================================================================================================
Func __ap_ArrayDualPivotQuicksort(ByRef $A, $cb_Func = Default, Const $left = 0, Const $right = UBound($A) - 1, $div = 3, Const $d_SmThr = 47, Const $b_MedQuant = False, Const $b_First = True)
	Local $d_Len = $right - $left
	Local $k, $t
	Local $t1, $t2 ; variables for insertion-sort

	If $b_First Then
		If $cb_Func = Default Then Return _ArraySort($A, 0, 0, 0, 0, 1)
		; error-handling:
		If Not IsArray($A) Then Return SetError(1, 0, False)
		If Not IsInt($left) Or $left < 0 Then Return SetError(2, $left, False)
		If Not IsInt($right) Or $right > UBound($A) - 1 Then Return SetError(3, $right, False)
		If $left >= $right Then Return SetError(4, $right - $left, False)
		If Not IsFunc($cb_Func) Then Return SetError(5, 0, False)
	EndIf

;~ 	; other sort-methods if range is small enough:
	Switch $d_Len + 1
		Case 2
			If $cb_Func($A[$left], $A[$right]) = 1 Then
				Local $t = $A[$right]
				$A[$right] = $A[$left]
				$A[$left] = $t
			EndIf
			Return True
		Case 3
			__3Sort($cb_Func, $A[$left], $A[$left + 1], $A[$right])
			Return True
		Case 4
			__4Sort($cb_Func, $A[$left], $A[$left + 1], $A[$left + 2], $A[$right])
			Return True
		Case 5
			__5Sort($cb_Func, $A[$left], $A[$left + 1], $A[$left + 2], $A[$left + 3], $A[$right])
			Return True
		Case 6 To $d_SmThr ; Insertion Sort
			For $i = $left + 1 To $right
				$t1 = $A[$i]
				For $j = $i - 1 To $left Step -1
					$t2 = $A[$j]
					If $cb_Func($t1, $t2) <> -1 Then ExitLoop
					$A[$j + 1] = $t2
				Next
				$A[$j + 1] = $t1
			Next
			Return True
	EndSwitch

	; ------------ estimate the two pivot-elements --------------------------
	If $b_MedQuant And $d_Len > $d_SmThr Then ; by 25% and 75%-quantiles of five
		Local $d_third = Floor($d_Len / 3)
		; Estimate the 25% / 75% -quantils better:
		Local $aIn[5] = [$left, Floor($left + $d_third), Floor($left + 0.5 * $d_Len), Floor($right - $d_third), $right]
		Local $aMp[5] = [$A[$aIn[0]], $A[$aIn[1]], $A[$aIn[2]], $A[$aIn[3]], $A[$aIn[4]]]
		___5Sort($cb_Func, $aMp)
		; find indices in source-array for sorted 5-array:
		For $i = 0 To 4
			If $cb_Func($A[$aIn[$i]], $aMp[1]) = 0 Then Local $m1 = $aIn[$i]
			If $cb_Func($A[$aIn[$i]], $aMp[3]) = 0 Then Local $m2 = $aIn[$i]
		Next
	Else ; simple by choosing at actual index 25% and 75%
		Local $d_third = Floor($d_Len / $div)
		;"medians" (at index 25% and 75%)
		Local $m1 = $left + $d_third
		Local $m2 = $right - $d_third

		If $m1 <= $left Then $m1 = $left + 1
		If $m2 >= $right Then $m2 = $right - 1
	EndIf

	; ensure that m1 < m2 and move them to the outer fields
	If $cb_Func($A[$m1], $A[$m2]) = -1 Then
		__ap_swap($A, $m1, $left)
		__ap_swap($A, $m2, $right)
	Else
		__ap_swap($A, $m1, $right)
		__ap_swap($A, $m2, $left)
	EndIf

	; pivots:
	Local $pivot1 = $A[$left]
	Local $pivot2 = $A[$right]

	; pointers:
	Local $less = $left + 1
	Local $great = $right - 1

	; sorting:
	$k = $less
	Do
		; move elements < pivot1 to the beginning of the array
		If $cb_Func($A[$k], $pivot1) = -1 Then
			; __ap_swap($A, $k, $less)
			$t = $A[$k]
			$A[$k] = $A[$less]
			$A[$less] = $t
			$less += 1
			; move elements > pivot1 to the end of the array
		ElseIf $cb_Func($A[$k], $pivot2) = 1 Then
			While $k < $great And $cb_Func($A[$great], $pivot2) = 1
				$great -= 1
			WEnd
			;__ap_swap($A, $k, $great)
			$t = $A[$k]
			$A[$k] = $A[$great]
			$A[$great] = $t
			$great -= 1
			If $cb_Func($A[$k], $pivot1) = -1 Then
				;__ap_swap($A, $k, $less)
				$t = $A[$k]
				$A[$k] = $A[$less]
				$A[$less] = $t
				$less += 1
			EndIf
		EndIf
		$k += 1
	Until $k > $great

	; swaps
	Local $dist = $great - $less
	If $dist < 13 Then $div += 1
	__ap_swap($A, $less - 1, $left)
	__ap_swap($A, $great + 1, $right)

	; subarrays
	If ($less - 2 - $left) > 0 Then __ap_ArrayDualPivotQuicksort($A, $cb_Func, $left, $less - 2, $div, $d_SmThr, $b_MedQuant, False)
	If ($right - ($great + 2)) > 0 Then __ap_ArrayDualPivotQuicksort($A, $cb_Func, $great + 2, $right, $div, $d_SmThr, $b_MedQuant, False)

	; equal elements
	If ($dist > ($d_Len - 13)) And ($cb_Func($pivot2, $pivot1) <> 0) Then
		$k = $less
		Do
			If $cb_Func($A[$k], $pivot1) = 0 Then
				;__ap_swap($A, $k, $less)
				$t = $A[$k]
				$A[$k] = $A[$less]
				$A[$less] = $t
				$less += 1
			ElseIf $cb_Func($A[$k], $pivot2) = 0 Then
				;__ap_swap($A, $k, $great)
				$t = $A[$k]
				$A[$k] = $A[$great]
				$A[$great] = $t
				$great -= 1
				If $cb_Func($A[$k], $pivot1) = 0 Then
					;__ap_swap($A, $k, $less)
					$t = $A[$k]
					$A[$k] = $A[$less]
					$A[$less] = $t
					$less += 1
				EndIf
			EndIf
			$k += 1
		Until $k > $great
	EndIf

	; the middle subarray
	If $cb_Func($pivot1, $pivot2) = -1 And $great - $less > 0 Then __ap_ArrayDualPivotQuicksort($A, $cb_Func, $less, $great, $div, $d_SmThr, $b_MedQuant, False)
	Return True
EndFunc   ;==>__ap_ArrayDualPivotQuicksort

; #FUNCTION# ======================================================================================
; Name ..........: _2Sort()
; Description ...: sorts two values with minimal count of comparisons
; Syntax ........: _2Sort(ByRef $A, ByRef $B)
; Parameters ....: $A, $B       - the values to be sorted
; Return values .: Success: -
;                  Failure: -
; Author ........: AspirinJunkie
; =================================================================================================
Func _2Sort(ByRef $A, ByRef $b)
	If $A > $b Then
		Local $t = $b
		$b = $A
		$A = $t
	EndIf
EndFunc   ;==>_2Sort
; #FUNCTION# ======================================================================================
; Name ..........: __2Sort()
; Description ...: sorts two values with minimal count of comparisons and custom comparison function
; Syntax ........:__2Sort(Const $f, ByRef $A, ByRef $b)
; Parameters ....: $A, $B       - the values to be sorted
; Return values .: Success: -
;                  Failure: -
; Author ........: AspirinJunkie
; =================================================================================================
Func __2Sort(Const $f, ByRef $A, ByRef $b)
	If $f($A, $b) = 1 Then
		Local $t = $b
		$b = $A
		$A = $t
	EndIf
EndFunc   ;==>__2Sort

; #FUNCTION# ======================================================================================
; Name ..........: _3Sort()
; Description ...: sorts three values with minimal count of comparisons
; Syntax ........: _3Sort(ByRef $A, ByRef $B, ByRef $C)
; Parameters ....: $A, $B, $C      - the values to be sorted
; Return values .: Success: -
;                  Failure: -
; Author ........: AspirinJunkie
; =================================================================================================
Func _3Sort(ByRef $A, ByRef $b, ByRef $c)
	Local $t
	If $b > $A Then
		If $b > $c Then
			If $c > $A Then     ; (A, C, B)
				$t = $b
				$b = $c
				$c = $t
			Else     ; (C, A, B)
				$t = $A
				$A = $c
				$c = $b
				$b = $t
			EndIf
		EndIf
	Else
		If $c > $A Then     ; (B, A, C)
			$t = $A
			$A = $b
			$b = $t
		ElseIf $c > $b Then     ; (B, C, A)
			$t = $A
			$A = $b
			$b = $c
			$c = $t
		Else     ; (C, B, A)
			$t = $A
			$A = $c
			$c = $t
		EndIf
	EndIf
EndFunc   ;==>_3Sort


; #FUNCTION# ======================================================================================
; Name ..........: __3Sort()
; Description ...: sorts three values with minimal count of comparisons and custom comparison function
; Syntax ........: __3Sort(Const $f, ByRef $A, ByRef $b, ByRef $c)
; Parameters ....: $f 			- the comparison function
;					$A, $B, $C  - the values to be sorted
; Return values .: Success: -
;                  Failure: -
; Author ........: AspirinJunkie
; =================================================================================================
Func __3Sort(Const $f, ByRef $A, ByRef $b, ByRef $c)
	Local $t
	If $f($b, $A) = 1 Then
		If $f($b, $c) = 1 Then
			If $f($c, $A) = 1 Then     ; (A, C, B)
				$t = $b
				$b = $c
				$c = $t
			Else     ; (C, A, B)
				$t = $A
				$A = $c
				$c = $b
				$b = $t
			EndIf
		EndIf
	Else
		If $f($c, $A) = 1 Then     ; (B, A, C)
			$t = $A
			$A = $b
			$b = $t
		ElseIf $f($c, $b) = 1 Then     ; (B, C, A)
			$t = $A
			$A = $b
			$b = $c
			$c = $t
		Else     ; (C, B, A)
			$t = $A
			$A = $c
			$c = $t
		EndIf
	EndIf
EndFunc   ;==>__3Sort

; #FUNCTION# ======================================================================================
; Name ..........: _4Sort()
; Description ...: sorts four values with minimal count of comparisons
; Syntax ........: _4Sort(ByRef $A, ByRef $B, ByRef $C, ByRef $D)
; Parameters ....: $A, $B, $C, $D  - the values to be sorted
; Return values .: Success: -
;                  Failure: -
; Author ........: AspirinJunkie
; =================================================================================================
Func _4Sort(ByRef $A, ByRef $b, ByRef $c, ByRef $d)
	Local $t

	If $A > $c Then
		$t = $c
		$c = $A
		$A = $t
	EndIf
	If $b > $d Then
		$t = $b
		$b = $d
		$d = $t
	EndIf
	If $A > $b Then
		$t = $A
		$A = $b
		$b = $t
	EndIf
	If $c > $d Then
		$t = $c
		$c = $d
		$d = $t
	EndIf
	If $b > $c Then
		$t = $c
		$c = $b
		$b = $t
	EndIf
EndFunc   ;==>_4Sort

; #FUNCTION# ======================================================================================
; Name ..........: __4Sort()
; Description ...: sorts four values with minimal count of comparisons and custom comparison function
; Syntax ........: __4Sort(Const $f, ByRef $A, ByRef $b, ByRef $c, ByRef $D)
; Parameters ....: $f 			   - the comparison function
;                  $A, $B, $C, $D  - the values to be sorted
; Return values .: Success: -
;                  Failure: -
; Author ........: AspirinJunkie
; =================================================================================================
Func __4Sort(Const $f, ByRef $A, ByRef $b, ByRef $c, ByRef $d)
	Local $t

	If $f($A, $c) = 1 Then
		$t = $c
		$c = $A
		$A = $t
	EndIf
	If $f($b, $d) = 1 Then
		$t = $b
		$b = $d
		$d = $t
	EndIf
	If $f($A, $b) = 1 Then
		$t = $A
		$A = $b
		$b = $t
	EndIf
	If $f($c, $d) = 1 Then
		$t = $c
		$c = $d
		$d = $t
	EndIf
	If $f($b, $c) = 1 Then
		$t = $c
		$c = $b
		$b = $t
	EndIf
EndFunc   ;==>__4Sort

; #FUNCTION# ======================================================================================
; Name ..........: _5Sort()
; Description ...: sorts five values with minimal count of comparisons
; Syntax ........: _5Sort(ByRef $A, ByRef $B, ByRef $C, ByRef $D, ByRef $E)
; Parameters ....: $A, $B, $C, $D, $D  - the values to be sorted
; Return values .: Success: -
;                  Failure: -
; Author ........: AspirinJunkie
; =================================================================================================
Func _5Sort(ByRef $A, ByRef $b, ByRef $c, ByRef $d, ByRef $e)
	Local $t

	If $A < $b Then     ; if a < b:      a, b = b, a
		$t = $b
		$b = $A
		$A = $t
	EndIf
	If $c < $d Then     ; if c < d:      c, d = d, c
		$t = $c
		$c = $d
		$d = $t
	EndIf
	If $A < $c Then     ; if a < c:      a, b, c, d = c, d, a, b
		$t = $c
		$c = $A
		$A = $t
		$t = $d
		$d = $b
		$b = $t
	EndIf

	If $e < $c Then     ;~    if e < c:
		If $e > $d Then     ; if e > d:  d, e = e, d
			$t = $d
			$d = $e
			$e = $t
		EndIf
	ElseIf $e < $A Then     ; if e < a:  c, d, e = e, c, d
		$t = $c
		$c = $e
		$e = $d
		$d = $t
	Else     ;~         else:      a, c, d, e = e, a, c, d
		$t = $A
		$A = $e
		$e = $d
		$d = $c
		$c = $t
	EndIf

	If $b < $d Then     ; if b < d:
		If $b < $e Then     ; if b < e:  return b, e, d, c, a
			$t = $A
			$A = $b
			$b = $e
			$e = $t
			$t = $c
			$c = $d
			$d = $t
		Else     ; else:      return e, b, d, c, a
			$t = $A
			$A = $e
			$e = $t
			$t = $c
			$c = $d
			$d = $t
		EndIf
	Else
		If $b < $c Then     ; if b < c:  return e, d, b, c, a
			$t = $A
			$A = $e
			$e = $t
			$t = $b
			$b = $d
			$d = $c
			$c = $t
		Else     ; else:      return e, d, c, b, a
			$t = $A
			$A = $e
			$e = $t
			$t = $b
			$b = $d
			$d = $t
		EndIf
	EndIf
EndFunc   ;==>_5Sort

; #FUNCTION# ======================================================================================
; Name ..........: __5Sort()
; Description ...: sorts five values with minimal count of comparisons and custom comparison function
; Syntax ........: __5Sort(Const $f, ByRef $A, ByRef $b, ByRef $c, ByRef $D, ByRef $E)
; Parameters ....: $f 			      - the comparison function
;                  $A, $B, $C, $D, $D - the values to be sorted
; Return values .: Success: -
;                  Failure: -
; Author ........: AspirinJunkie
; =================================================================================================
Func __5Sort(Const $f, ByRef $A, ByRef $b, ByRef $c, ByRef $d, ByRef $e)
	Local $t

	If $f($A, $b) = -1 Then     ; if a < b:      a, b = b, a
		$t = $b
		$b = $A
		$A = $t
	EndIf
	If $f($c, $d) = -1 Then     ; if c < d:      c, d = d, c
		$t = $c
		$c = $d
		$d = $t
	EndIf
	If $f($A, $c) = -1 Then     ; if a < c:      a, b, c, d = c, d, a, b
		$t = $c
		$c = $A
		$A = $t
		$t = $d
		$d = $b
		$b = $t
	EndIf

	If $f($e, $c) = -1 Then     ;~    if e < c:
		If $f($e, $d) = 1 Then     ; if e > d:  d, e = e, d
			$t = $d
			$d = $e
			$e = $t
		EndIf
	ElseIf $f($e, $A) = -1 Then     ; if e < a:  c, d, e = e, c, d
		$t = $c
		$c = $e
		$e = $d
		$d = $t
	Else     ;~         else:      a, c, d, e = e, a, c, d
		$t = $A
		$A = $e
		$e = $d
		$d = $c
		$c = $t
	EndIf

	If $f($b, $d) = -1 Then     ; if b < d:
		If $f($b, $e) = -1 Then     ; if b < e:  return b, e, d, c, a
			$t = $A
			$A = $b
			$b = $e
			$e = $t
			$t = $c
			$c = $d
			$d = $t
		Else     ; else:      return e, b, d, c, a
			$t = $A
			$A = $e
			$e = $t
			$t = $c
			$c = $d
			$d = $t
		EndIf
	Else
		If $f($b, $c) = -1 Then     ; if b < c:  return e, d, b, c, a
			$t = $A
			$A = $e
			$e = $t
			$t = $b
			$b = $d
			$d = $c
			$c = $t
		Else     ; else:      return e, d, c, b, a
			$t = $A
			$A = $e
			$e = $t
			$t = $b
			$b = $d
			$d = $t
		EndIf
	EndIf
EndFunc   ;==>__5Sort

; #FUNCTION# ======================================================================================
; Name ..........: ___5Sort()
; Description ...: sorts an 5-value Array with minimal count of comparisons and custom comparison function
; Syntax ........: ___5Sort(Const $f, ByRef $A)
; Parameters ....: $f 			- the comparison function
;                  $A 			- the 5 element array
; Return values .: Success: -
;                  Failure: -
; Author ........: AspirinJunkie
; =================================================================================================
Func ___5Sort(Const $f, ByRef $A)
	Local $t

	If $f($A[0], $A[1]) = -1 Then ; if a < b:      a, b = b, a
		$t = $A[1]
		$A[1] = $A[0]
		$A[0] = $t
	EndIf
	If $f($A[2], $A[3]) = -1 Then ; if c < d:      c, d = d, c
		$t = $A[2]
		$A[2] = $A[3]
		$A[3] = $t
	EndIf
	If $f($A[0], $A[2]) = -1 Then ; if a < c:      a, b, c, d = c, d, a, b
		$t = $A[2]
		$A[2] = $A[0]
		$A[0] = $t
		$t = $A[3]
		$A[3] = $A[1]
		$A[1] = $t
	EndIf

	If $f($A[4], $A[2]) = -1 Then ;~    if e < c:
		If $f($A[4], $A[3]) = 1 Then ; if e > d:  d, e = e, d
			$t = $A[3]
			$A[3] = $A[4]
			$A[4] = $t
		EndIf
	ElseIf $f($A[4], $A[0]) = -1 Then ; if e < a:  c, d, e = e, c, d
		$t = $A[2]
		$A[2] = $A[4]
		$A[4] = $A[3]
		$A[3] = $t
	Else ;~         else:      a, c, d, e = e, a, c, d
		$t = $A[0]
		$A[0] = $A[4]
		$A[4] = $A[3]
		$A[3] = $A[2]
		$A[2] = $t
	EndIf

	If $f($A[1], $A[3]) = -1 Then ; if b < d:
		If $f($A[1], $A[4]) = -1 Then ; if b < e:  return b, e, d, c, a
			Local $b[5] = [$A[1], $A[4], $A[3], $A[2], $A[0]]
			$A = $b
		Else ; else:      return e, b, d, c, a
			Local $b[5] = [$A[4], $A[1], $A[3], $A[2], $A[0]]
			$A = $b
		EndIf
	Else
		If $f($A[1], $A[2]) = -1 Then ; if b < c:  return e, d, b, c, a
			Local $b[5] = [$A[4], $A[3], $A[1], $A[2], $A[0]]
			$A = $b
		Else ; else:      return e, d, c, b, a
			Local $b[5] = [$A[4], $A[3], $A[2], $A[1], $A[0]]
			$A = $b
		EndIf
	EndIf
EndFunc   ;==>___5Sort


; #FUNCTION# ======================================================================================
; Name ..........: __ap_stringCenter()
; Description ...: helper function to print a string centered
; Syntax ........: __ap_stringCenter($sString[, $nChars = Default])
; Parameters ....: $sString - the string to be centered. If string is surrounded by spaces and $nchars = Default, the StringLen with spaces is used as target width
;                  $nChars  - [optional] target width - must be > than StringLen($sString) (default:Default)
; Return values .: Success: the centered (by surrounding spaces) string
;                  Failure: Null and set @error to
;                  |1: $nChars invalid value; @extended = $nChars
; Author ........: aspirinjunkie
; Modified ......: 2022-06-20
; Example .......: Yes
;                  ConsoleWrite("|" & __ap_stringCenter("test", 10) & "|" & @CRLF)
;                  ConsoleWrite("|" & __ap_stringCenter("     test ") & "|" & @CRLF)
; =================================================================================================
Func __ap_stringCenter($sString, $nChars = Default)
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
EndFunc   ;==>__ap_stringCenter

#EndRegion Helper functions from Dynarray-UDF
