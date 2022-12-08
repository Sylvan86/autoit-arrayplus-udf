#include "ArrayPlus.au3"




Global $aArray[] = [1,2,3,4,5]
_Array1DTo2D($aArray, 3)
_ArrayDisplay($aArray)





#Region _ArrayCreate()
;  example 1 - create 2D array inline with standard AutoIt-syntax
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
Global $aExample1D = _ArrayRangeCreate(1, 20)
Global $aExample2D[5][3] = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12], [13, 14, 15]]

;  ; example 1 - extract specific range from 1D-array
;  $aSliced = _ArraySlice($aExample1D, "5:15")
;  _ArrayDisplay($aSliced, "example 1")

;  ; example 2 - extract specific 4 specific elements (included the second last) from 1D-array
;  $aSliced = _ArraySlice($aExample1D, "6, 2,12, -2")
;  _ArrayDisplay($aSliced, "example 2")

;  ; example 3 - invert order of 1D-Array
;  $aSliced = _ArraySlice($aExample1D, "::-1")
;  _ArrayDisplay($aSliced, "example 3")

;  example 4 - extract row #2 as 1D-Array
;  $aSliced = _ArraySlice($aExample2D, "[:]")
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


#Region _ArrayMinMax()()
; example 1 - 1D-Array
;  Global $aArray1D[30]
;  For $i = 0 To 29
;  	$aArray1D[$i] = Random(1, 1000, 1)
;  Next
;  _ArrayDisplay($aArray1D)
;  $aMinMax = _ArrayMinMax($aArray1D)
;  _ArrayDisplay($aMinMax)

; example 2 - process all columns of 2D-Array
;  Global $N = 15, $M = 5
;  Global $aArray2D[$N][$M]
;  For $i = 0 To $N - 1
;  	For $j = 0 To $M - 1
;  		$aArray2D[$i][$j] = Random(1, 100, 1) * 10 ^ $j
;  	Next
;  Next
;  _ArrayDisplay($aArray2D)
;  $aMinMax = _ArrayMinMax($aArray2D)
;  _ArrayDisplay($aMinMax)
#endRegion
