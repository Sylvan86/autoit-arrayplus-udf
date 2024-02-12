This UDF contains functions to make the handling of arrays more effective and elegant.
Besides functions which are inspired by Python's range-create and its array-slicing, most of the functions are based on the principle of being able to specify user-defined functions for subtasks.

E.g. with the classic _ArraySort() it is not possible to sort "naturally" or to sort 2D arrays by multiple columns or instead by string length or or or...
With these functions here you can usually realize this in only one function call.

Also the possibility to display arrays nicely formatted as string (quasi the counterpart to _ArrayDisplay) was missing until now.

The function list of the UDF:
| Function | description |
|---- | --- |
| ***creation*** |
|_ArrayCreate               | create 1D/2D-arrays or Array-In-Arrays in one code-line; supports python-like range-syntax for creating sequences |
|_ArrayRangeCreate()        | create a sequence as 1D-array - mainly helper function for _ArrayCreate |
| ***manipulation and conversion*** | |
|_ArraySlice                | python style array slicing to extract ranges, rows, columns, single values |
|_ArrayAddGeneratedColumn   | adds generated values as a column (like "generated column" in SQL) |
|_Array1DTo2D               | convert a 1D-array into a 2D-array and take over the values to the first column (for inverted case - extract a row or column from 2D-array - use _ArraySlice) |
|_Array2dToAinA             | convert 2D-array into a array-in-array |
|_ArrayAinATo2d             | convert array-in-array into a 2D array |
|_Array2String              | print a 1D/2D-array to console or variable clearly arranged |
|_ArrayAlignDec             | align a 1D-array or a column of a 2D-array at the decimal point or right aligned |
|_ArrayJoin                 | sql-like joins for AutoIt-Arrays |
|_ArrayMap                  | apply a function to every element of a array ("map" the function) |
|_ArrayReduce               | reduce the elements of a array to one value with an external function |
|_ArrayFilter               | filter the elements of an array with a external function |
|_ArrayDeleteByCondition    | delete all empty string elements or which fulfil a user-defined condition inside an array |
|_ArrayDeleteMultiValues()  | removes elements that appear more than once in the string. (not only the duplicates) |
|_ArrayRotate               | rotates the elements of a 1D-Array or the rows of a 2D-Array |
| ***sorting*** |
|_ArraySortFlexible         | sort an array with a user-defined sorting rule |
|_ArraySortInsertion        | sort an array with a user-defined sorting rule with the insertion-sort algorithm |
|_ArraySortSelection        | sort an array with a user-defined sorting rule with the selection-sort algorithm (minimal number of swaps) |
|_ArrayIsSorted             | checks whether an Array is already sorted (by using a user comparison function) |
|_ArrayHeapSortBinary       | sort an array with Binary-Min-Heap-Sort algorithm (by using a user comparison function) |
|_ArrayHeapSortTernary      | sort an array with Ternary-Min-Heap-Sort algorithm (by using a user comparison function) |
|_ArrayMergeSorted          | merges a sorted array or one value into a sorted array so that the sorting is preserved |
| ***searching*** |
|_ArrayBinarySearchFlex     | performs a binary search for an appropriately sorted array using an individual comparison function |
| _ArrayFindSortedPos       | find the insertion position of an element in a sorted array. |
|_ArrayGetMax               | determine the element with the maximum value by using a user comparison function |
|_ArrayGetMin               | determine the element with the minimum value by using a user comparison function |
|_ArrayMinMax               | returns min and max value and their indices of a 1D array or all/specific column of a 2D array |
|_ArrayGetNthBiggestElement | determine the nth biggest element (e.g.: median value) in an unsorted array without sorting it (faster) |

Therefore, here are a few code examples for selected functions:

**_ArrayCreate():**
<details>
<summary>example for _ArrayCreate()</summary>

```AutoIt
;  example 1 - create 2D array inline with standard AutoIt-syntax
_ArrayDisplay(_ArrayCreate("[[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12], [13, 14, 15]]"))

;  example 2 - create array-in-array inline with standard AutoIt-syntax
_ArrayDisplay(_ArrayCreate("[[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12], [13, 14, 15]]", Default, True))

;  example 3 - create array of 20 elements with standard value set to "test"
_ArrayDisplay(_ArrayCreate(":19", "test"))

;  example 4 - create array of 20 elements with their value set to the square of their current value
_ArrayDisplay(_ArrayCreate(":19", "$A * $A"))

;  example 5 - create array inline with a sequence
_ArrayDisplay(_ArrayCreate("2:20:0.5"))

;  example 6 - create array inline with a sequence and calc the square root of every element:
_ArrayDisplay(_ArrayCreate("2:20:0.5", sin))

;  example 7 - number of steps instead of step size
_ArrayDisplay(_ArrayCreate("2:20|10"), "2:20|10")

;  example 8 - inclusive vs. exclusive borders
_ArrayDisplay(_ArrayCreate("0:5"), "0:5")
_ArrayDisplay(_ArrayCreate("[0:5]"), "[0:5]")
_ArrayDisplay(_ArrayCreate("(0:5"), "(0:5")
_ArrayDisplay(_ArrayCreate("(0:5)"), "(0:5)")
_ArrayDisplay(_ArrayCreate("[0:5)"), "[0:5)")
```

</details>

**_ArraySlice():**
<details>
<summary>example for _ArraySlice()</summary>

```AutoIt
Global $aExample1D = _ArrayRangeCreate(1, 20)
Global $aExample2D[5][3] = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12], [13, 14, 15]]

; example 1 - extract specific range from 1D-array
$aSliced = _ArraySlice($aExample1D, "5:15")
_ArrayDisplay($aSliced, "example 1")

; example 2 - extract specific 4 specific elements (included the second last) from 1D-array
$aSliced = _ArraySlice($aExample1D, "6, 2,12, -2")
_ArrayDisplay($aSliced, "example 2")

; example 3 - invert order of 1D-Array
$aSliced = _ArraySlice($aExample1D, "::-1")
_ArrayDisplay($aSliced, "example 3")

; example 4 - extract row #2 as 1D-Array
$aSliced = _ArraySlice($aExample2D, "[1][:]")
_ArrayDisplay($aSliced, "example 4")

; example 5 - extract last row as 1D-Array
$aSliced = _ArraySlice($aExample2D, "[-1][:]")
_ArrayDisplay($aSliced, "example 5" )

; example 6 - extract second last column as 1D-Array
$aSliced = _ArraySlice($aExample2D, "[:][-2]")
_ArrayDisplay($aSliced, "example 6")

; example 7 - rearrange columns and delete first row
$aSliced = _ArraySlice($aExample2D, "[1:][1,2,0]")
_ArrayDisplay($aSliced, "example 7")

; example 8 - return 3 specific rows and invert column order:
$aSliced = _ArraySlice($aExample2D, "[3,1,4][::-1]")
_ArrayDisplay($aSliced, "example 8")
```

</details>

**_Array2String():**
<details>
<summary>example for _Array2String()</summary>

```AutoIt
Global $aCSVRaw[5][4] = [[1, 2, 20.65, 3], [4, 5, 9, 6], [7, 8, 111111111.8, 9], [10, 11, 100.2, 12], [13, 14, 23.765, 15]]

;  example 1- print 2D-array to console with header and values aligned at decimal point:
ConsoleWrite(_Array2String($aCSVRaw, "Col. 1, Col. 2, Col. 3, Col. 4"))

;  example 2 - simple unaligned output without borders and header:
ConsoleWrite(_Array2String($aCSVRaw, Default, " ", Default, 0))

;  example 3 - print 2D-array and use first row as header:
ConsoleWrite(_Array2String($aCSVRaw, True))
```

</details>

**_ArraySortFlexible():**
<details>
<summary>example for _ArraySortFlexible()</summary>

```AutoIt
Global $a_Array = StringSplit("image20.jpg;image1.jpg;image11.jpg;image2.jpg;image3.jpg;image10.jpg;image12.jpg;image21.jpg;image22.jpg;image23.jpg", ";", 3)
_ArrayDisplay($a_Array, "unsorted Array")

; example 1 - normal sort of a 1D-array
_ArraySortFlexible($a_Array)
_ArrayDisplay($a_Array, "normal sorted array")

; example 2 - natural sort of a 1D-array
_ArraySortFlexible($a_Array, __ap_cb_comp_Natural)
_ArrayDisplay($a_Array, "natural sorted array")

; example 3 - sort Array with short string based user defined comparison function:
_ArraySortFlexible($a_Array, "$A > $B ? 1 : $A < $B ? -1 : 0")
_ArrayDisplay($a_Array, "sorted")

;  example 4 - sort 2D-array column-wise over all columns:
; create sample random 2D-array
Global $Array[1000][10]
For $i = 0 To 999
    For $j = 0 To 9
        $Array[$i][$j] = Chr(Random(65, 90, 1))
    Next
Next
_ArrayDisplay($Array, "unsorted 2D-array")
_ArraySortFlexible($Array, _SortByColumns)
_ArrayDisplay($Array, "sorted 2D-array")

; own compare function which compares all columns step by step ($A/B = row 1/2 as 1D-arrays with their column values as elements)
Func _SortByColumns(ByRef $A, ByRef $B)
    For $i = 0 To UBound($A) -1
        If $A[$i] > $B[$i] Then Return 1
        If $A[$i] < $B[$i] Then Return -1
    Next
    Return 0
EndFunc
```

</details>

**_ArrayBinarySearchFlex():**
<details>
<summary>example for _ArrayBinarySearchFlex()</summary>

```AutoIt
Local $a_Array = ["BASF", "Allianz", "Volkswagen", "BMW", "Bayer", "Telekom", "Post", "Linde"]
_ArraySortFlexible($a_Array)

;  example 1 - search all values starting with "B"
$a_Founds = _ArrayBinarySearchFlex($a_Array, "B", _myCompare)
If Not @error Then _ArrayDisplay($a_Founds)

Func _myCompare(Const $sS, Const $sO)
	Return StringRegExp($sO, '^' & $sS) = 1 ? 0 : -StringCompare($sO, $sS)
EndFunc   ;==>_myCompare

; example 2 - variant with string as user defined function:
$a_Founds = _ArrayBinarySearchFlex($a_Array, "", "StringRegExp($B, '^B') = 1 ? 0 : -StringCompare('B', $B)")
If Not @error Then _ArrayDisplay($a_Founds)
```

</details>

**_ArrayGetNthBiggestElement():**
<details>
<summary>example for _ArrayGetNthBiggestElement()</summary>

```AutoIt
Global $a_Array[] = [2, 6, 8, 1, 1, 5, 8, 9, 31, 41, 163, 13, 67, 12, 74, 17, 646, 16, 74, 12, 35, 98, 12, 43]

;  example 1 - get the median value without sorting the array
ConsoleWrite("median: " & _ArrayGetNthBiggestElement($a_Array) & @CRLF)
_ArrayDisplay($a_Array)

;  example 2 - get the third highest value:
ConsoleWrite("#3 highest: " & _ArrayGetNthBiggestElement($a_Array, UBound($a_Array) - 3) & @CRLF)
_ArrayDisplay($a_Array)

;  example 3 - get the 5 lowest elements, and sort them (should be faster than a complete sorting):
_ArrayGetNthBiggestElement($a_Array, 5) ; partition the array in one side lower than the 5th lowest value and the right side higher than this value
$a_Array = _ArraySlice($a_Array, ":4")
_ArraySort($a_Array)
_ArrayDisplay($a_Array, "5 lowest values")
```

</details>