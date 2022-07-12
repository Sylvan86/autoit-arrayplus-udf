#include "ArrayPlus.au3"

#Region _ArrayCreate()
;  ;  example 1 - create 2D array inline with standard AutoIt-syntax
;  _ArrayDisplay(_ArrayCreate("[[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12], [13, 14, 15]]"))

;  ;  example 2 - create array-in-array inline with standard AutoIt-syntax but
;  _ArrayDisplay(_ArrayCreate("[[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12], [13, 14, 15]]", Default, True))

;  ;  example 3 - create array of 20 elements with standard value set to "test"
;  _ArrayDisplay(_ArrayCreate(":19", "test"))

;  ;  example 4 - create array inline with a sequence
;  _ArrayDisplay(_ArrayCreate("2:20:0.5"))

;  ;  example 5 - create array inline with a sequence and calc the square root of every element:
;  _ArrayDisplay(_ArrayCreate("2:20:0.5", sin))

;  ;  example 6 - number of steps instead of step size
;  _ArrayDisplay(_ArrayCreate("2:20|10"), "2:20|10")

;  example 7 - inclusive vs. exclusive borders
;  _ArrayDisplay(_ArrayCreate("0:5"), "0:5")
;  _ArrayDisplay(_ArrayCreate("[0:5]"), "[0:5]")
;  _ArrayDisplay(_ArrayCreate("(0:5"), "(0:5")
;  _ArrayDisplay(_ArrayCreate("(0:5)"), "(0:5)")
;  _ArrayDisplay(_ArrayCreate("[0:5)"), "[0:5)")
#EndRegion _ArrayCreate()

#Region _ArraySlice()
;  Global $aExample1D = _ArrayRangeCreate(1, 20)
;  Global $aExample2D[5][3] = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12], [13, 14, 15]]

;  ; example 1 - extract specific range from 1D-array
;  $aSliced = _ArraySlice($aExample1D, "5:15")
;  _ArrayDisplay($aSliced, "example 1")

;  ; example 2 - extract specific 4 specific elements (included the second last) from 1D-array
;  $aSliced = _ArraySlice($aExample1D, "6, 2,12, -2")
;  _ArrayDisplay($aSliced, "example 2")

;  ; example 3 - invert order of 1D-Array
;  $aSliced = _ArraySlice($aExample1D, "::-1")
;  _ArrayDisplay($aSliced, "example 3")

;  ;  example 4 - extract row #2 as 1D-Array
;  $aSliced = _ArraySlice($aExample2D, "[1][:]")
;  _ArrayDisplay($aSliced, "example 4")

;  ;  example 5 - extract last row as 1D-Array
;  $aSliced = _ArraySlice($aExample2D, "[-1][:]")
;  _ArrayDisplay($aSliced, "example 5" )

;  ;  example 6 - extract second last column as 1D-Array
;  $aSliced = _ArraySlice($aExample2D, "[:][-2]")
;  _ArrayDisplay($aSliced, "example 6")

;  ;  example 7 - rearrange columns and delete first row
;  $aSliced = _ArraySlice($aExample2D, "[1:][1,2,0]")
;  _ArrayDisplay($aSliced, "example 7")

;  ;  example 8 - return 3 specific rows and invert column order:
;  $aSliced = _ArraySlice($aExample2D, "[3,1,4][::-1]")
;  _ArrayDisplay($aSliced, "example 8")
#EndRegion _ArraySlice()

#Region __Array2String()
;  Global $aCSVRaw[5][4] = [[1, 2, 20.65, 3], [4, 5, 9, 6], [7, 8, 111111111.8, 9], [10, 11, 100.2, 12], [13, 14, 23.765, 15]]

;  example 1- print 2D-array to console with header and values aligned at decimal point:
;  ConsoleWrite(_Array2String($aCSVRaw, "Col. 1, Col. 2, Col. 3, Col. 4"))

; example 2 - simple unaligned output without borders and header:
;  ConsoleWrite(_Array2String($aCSVRaw, Default, " ", Default, 0))

; example 3 - print 2D-array and use first row as header:
;  ConsoleWrite(_Array2String($aCSVRaw, True))
#EndRegion __Array2String()

#Region _ArraySortFlexible()
;  Global $a_Array = StringSplit("image20.jpg;image1.jpg;image11.jpg;image2.jpg;image3.jpg;image10.jpg;image12.jpg;image21.jpg;image22.jpg;image23.jpg", ";", 3)
;  _ArrayDisplay($a_Array, "unsorted Array")

;  ; example 1 - normal sort of a 1D-array
;  _ArraySortFlexible($a_Array)
;  _ArrayDisplay($a_Array, "normal sorted array")

;  ; example 2 - natural sort of a 1D-array
;  _ArraySortFlexible($a_Array, __MyNaturalCompare)
;  _ArrayDisplay($a_Array, "natural sorted array")

;  ;  example 3 - sort 2D-array column-wise over all columns:
;  ; create sample random 2D-array
;  Global $Array[1000][10]
;  For $i = 0 To 999
;      For $j = 0 To 9
;          $Array[$i][$j] = Chr(Random(65, 90, 1))
;      Next
;  Next
;  _ArrayDisplay($Array, "unsorted 2D-array")
;  _ArraySortFlexible($Array, _SortByColumns)
;  _ArrayDisplay($Array, "sorted 2D-array")

;  ; Comparison function as wrapper for StrCmpLogicalW which sorts like the explorer (more intuitively if numerical values occur in the strings)
;  Func __MyNaturalCompare(Const ByRef $A, Const ByRef $B)
;      Local Static $h_DLL_Shlwapi = DllOpen("Shlwapi.dll")
;      Local $a_Ret = DllCall($h_DLL_Shlwapi, "int", "StrCmpLogicalW", "wstr", $A, "wstr", $B)
;      If @error Then Return SetError(1, @error, 0)
;      If Not IsString($A) Or Not IsString($B) Then Return $A > $B ? 1 : $A < $B ? -1 : 0
;      Return $a_Ret[0]
;  EndFunc   ;==>MyCompare

;  ; own compare function which compares all columns step by step ($A/B = row 1/2 as 1D-arrays with their column values as elements)
;  Func _SortByColumns(ByRef $A, ByRef $B)
;      For $i = 0 To UBound($A) -1
;          If $A[$i] > $B[$i] Then Return 1
;          If $A[$i] < $B[$i] Then Return -1
;      Next
;      Return 0
;  EndFunc
#EndRegion _ArraySortFlexible()


#Region _ArrayBinarySearchFlex()
;  Local $a_Array = ["BASF", "Allianz", "Volkswagen", "BMW", "Bayer", "Telekom", "Post", "Linde"]
;  _ArraySortFlexible($a_Array)

;  ;  example 1 - search all values starting with "B"
;  $a_Founds = _ArrayBinarySearchFlex($a_Array, _myCompare, "B")
;  If Not @error Then _ArrayDisplay($a_Founds)

;  Func _myCompare(Const $sS, Const $sO)
;  	Return StringRegExp($sO, '^' & $sS) = 1 ? 0 : -StringCompare($sO, $sS)
;  EndFunc   ;==>_myCompare
#EndRegion _ArrayBinarySearchFlex()


#Region _ArrayGetNthBiggestElement()
;  Global $a_Array[] = [2, 6, 8, 1, 1, 5, 8, 9, 31, 41, 163, 13, 67, 12, 74, 17, 646, 16, 74, 12, 35, 98, 12, 43]

;  example 1 - get the median value without sorting the array
;  ConsoleWrite("median: " & _ArrayGetNthBiggestElement($a_Array) & @CRLF)
;  _ArrayDisplay($a_Array)

;  example 2 - get the third highest value:
;  ConsoleWrite("#3 highest: " & _ArrayGetNthBiggestElement($a_Array, UBound($a_Array) - 3) & @CRLF)
;  _ArrayDisplay($a_Array)

; example 3 - get the 5 lowest elements, and sort them (should be faster than a complete sorting):
;  _ArrayGetNthBiggestElement($a_Array, 5)	; partition the array in one side lower than the 5th lowest value and the right side higher than this value
;  $a_Array = _ArraySlice($a_Array, ":4")
;  _ArraySort($a_Array)
;  _ArrayDisplay($a_Array, "5 lowest values")
#EndRegion _ArrayGetNthBiggestElement()

#Region _ArrayReduce()
;  Global $aArray = _ArrayCreate("1:2")
;  _ArrayDisplay($aArray)

;  ;  example 1 - calculate squaresum of array
;  $sqSum = _ArrayReduce($aArray, __sqSum)
;  MsgBox(0, "square sum", $sqSum)

;  Func __sqSum(ByRef $sum, $val)
;  	$sum += $val*$val
;  EndFunc
#EndRegion _ArrayReduce()



;  ;  create 2D-Array
;  Global Const $N = 15, $M = 5
;  Global $aArray2D[$N][$M]
;  For $i = 0 To $N - 1
;  	For $j = 0 To $M - 1
;  		$aArray2D[$i][$j] = Random(1, 100, 1) * 10 ^ $j
;  	Next
;  Next
;  _ArrayMinMax($aArray2D)



;  ; create 1D-Array
;  Global Const $N = 30, $M = 5
;  Global $aArray1D[$N]
;  For $i = 0 To $N -1
;  	$aArray1D[$i] = Random(1,1000, 1)
;  Next
;  _ArrayMinMax($aArray1D)



Func _ArrayMinMax(ByRef $aArray, $iColumn = Default)
	Local Enum $eMin, $eMax, $eMinInd, $eMaxInd

	Switch UBound($aArray, 0)
		Case 1
			Local $aRet[4]
			$aRet[$eMin] = $aArray[0]
			$aRet[$eMax] = $aArray[0]
			$aRet[$eMinInd] = 0
			$aRet[$eMaxInd] = 0

			For $i = 1 To UBound($aArray) - 1
				If $aArray[$i] < $aRet[$eMin] Then
					$aRet[$eMin] = $aArray[$i]
					$aRet[$eMinInd] = $i
				ElseIf $aArray[$i] > $aRet[$eMax] Then
					$aRet[$eMax] = $aArray[$i]
					$aRet[$eMaxInd] = $i
				EndIf
			Next
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
			Else
				If $iColumn > $nC Then Return SetError(1, $iColumn, Null)
				Local $aRet[4]
				$aRet[$eMin] = $aArray[0][$iColumn]
				$aRet[$eMax] = $aArray[0][$iColumn]
				$aRet[$eMinInd] = 0
				$aRet[$eMaxInd] = 0

				For $i = 1 To $nR - 1
					If $aArray[$i][$iColumn] < $aRet[$eMin] Then
						$aRet[$eMin] = $aArray[$i][$iColumn]
						$aRet[$eMinInd] = $i
					ElseIf $aArray[$i][$iColumn] > $aRet[$eMax] Then
						$aRet[$eMax] = $aArray[$i][$iColumn]
						$aRet[$eMaxInd] = $i
					EndIf
				Next
			EndIf

			_ArrayDisplay($aRet)
			Return $aRet
		Case Else
			Return SetError(1, UBound($aArray, 0), Null)

	EndSwitch
EndFunc   ;==>_ArrayMinMax






;  ; Gibt den Inhalt einer Variablen auf der Kommandozeile aus - egal ob Skalar, Array, Map, Dictionary, Struct etc.
;  Func _var2console(ByRef $vVar, Const $vAdditionalInfo = Default, Const $sSuffix = @CRLF)
;  	If IsArray($vVar) Then
;  		;  Noch unterscheiden ob Array-In-Array
;  		ConsoleWrite(_Array2String($vVar))
;  	EndIf
;  	If IsMap($vVar) Then
;  		;  Unterscheiden ob Integer oder String-Map
;  	EndIf
;  	If ObjName($vVar) == "Scripting.Dictionary" Then
;  	If IsDllStruct($vVar) Then ; hier die Struct-Definition aus $vAdditionalInfo verwenden
;  	If IsFunc($vVar) Then FuncName($vVar)
;  	If IsObj($vVar) Then ObjName,
;  	;  Oder:
;  	Switch VarGetType($vVar)

;  EndFunc


;  Func _ArrayMinMax()

;  EndFunc



;  Global $a_Array[] = ["Name1", "Name2", "Name3", "Name2", "Name3", "Name4", "Name2"]


;  Global $a_Max = _ArrayModalwert($a_Array, 1)
;  _ArrayDisplay($a_Max, "Elemente mit maximalen Vorkommen")


; #FUNCTION# ======================================================================================
; Name ..........: _ArrayModalwert()
; Description ...: Bestimmt den Modalwert in einem Array
; Syntax ........: _ArrayModalwert(ByRef $a_Inp, Const[ $i_Start = 0, Const[ $s_Delim = "|"]])
; Parameters ....: ByRef $a_Inp - 1D-Array mit Stichprobenmenge
; Const $i_Start - [optional] Start Array-Index; gewöhnlich auf 0 oder 1 gesetzt (Standard = 0) (default:0)
; Const $s_Delim - [optional] Wenn "|" in den einzelnen Elementen vorkommt: ändern (default:"|")
; Return values .: Success: Array[0]: Anzahl an Vorkommen, Array[1..n]: häufigst vorgekommene Elemente
; Failure: Return 0 und setzt @error
; =================================================================================================
Func _ArrayModalwert(ByRef $a_Inp, Const $i_Start = 0, Const $s_Delim = "|")
	Local $o_Dict = ObjCreate("Scripting.Dictionary")
	Local $i_CMax = 1, $i_C, $s_Mods
	; Array durchgehen und Vorkommen von Werten zählen:
	If Not IsArray($a_Inp) Then Return SetError(1, 0, 0)
	For $x = $i_Start To UBound($a_Inp) - 1
		$o_Dict($a_Inp[$x]) += 1
	Next
	; Werte mit maximalen Vorkommen ermitteln:
	For $i In $o_Dict.Keys
		$i_C = $o_Dict($i)
		If $i_C = $i_CMax Then
			$s_Mods &= $i & $s_Delim
		ElseIf $i_C > $i_CMax Then
			$i_CMax = $i_C
			$s_Mods = $i & $s_Delim
		EndIf
	Next
	Local $a_Return = StringSplit(StringTrimRight($s_Mods, 1), $s_Delim)
	$a_Return[0] = $i_CMax
	Return $a_Return
EndFunc   ;==>_ArrayModalwert

; löscht Elemente, welche mehrmals vorkommen
Func _ArrayDeleteDuplicates(ByRef $aArray)
	Local $oCount = ObjCreate("Scripting.Dictionary")
	
	For $i In $aArray
		$oCount($i) += 1
	Next
	
	Local $iR = 0, $aRet[UBound($aArray)]
	For $i In $aArray
		If $oCount($i) = 1 Then
			$aRet[$iR] = $i
			$iR += 1
		EndIf
	Next
	
	ReDim $aRet[$iR]
	Return $aRet
EndFunc   ;==>_ArrayDeleteDuplicates







;  ;  Global $s_String = BinaryToString(InetRead("https://pastebin.com/raw/w3SgtP9Q"))

;  $sString = FileRead("C:\Users\at2\Documents\Programmierung\AutoIt\Test\Test.sv")
;  $a_Splitted = _StringSplit2D($sString)

;  $a_Splitted[2][8] *= -1
;  $a_Splitted[5][7] *= -1

;  For $i = 1 TO UBound($a_Splitted) - 1
;  	$a_Splitted[$i][2] = Number($a_Splitted[$i][2])
;  	$a_Splitted[$i][3] = StringStripWS($a_Splitted[$i][3], 3)
;  	$a_Splitted[$i][7] = Number($a_Splitted[$i][7])
;  	$a_Splitted[$i][8] = Number($a_Splitted[$i][8])
;  Next
;  ;  _ArrayDisplay($a_Splitted)
;  ConsoleWrite(_Array2String($a_Splitted, True, " | ", 3))

;  Func _StringSplit2D(ByRef $sString, $sDelim = @CRLF, $sDelim2 = ",", $i_Start = 0)
;  	Local $a_FirstDim = StringSplit($sString, $sDelim, 3)
;  	Local $a_Out[UBound($a_FirstDim)][1]
;  	Local $a_Line, $i_2DMax = 1


;  	For $i = $i_Start To UBound($a_FirstDim) - 1
;  		$a_Line = StringSplit($a_FirstDim[$i], $sDelim2, 3)
;  		If UBound($a_Line) > $i_2DMax Then
;  			$i_2DMax = UBound($a_Line)
;  			ReDim $a_Out[UBound($a_Out)][$i_2DMax]
;  		EndIf
;  		For $j = 0 To UBound($a_Line) - 1
;  			$a_Out[$i][$j] = $a_Line[$j]
;  		Next
;  	Next
;   	Return $a_Out
;  EndFunc



