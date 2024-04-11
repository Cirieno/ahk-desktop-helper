#Include "..\libs\vartypes.lib.ahk"



/**
 * Removes the first element from an array and returns the element
 *
 * @function Arrays.shift | ArrShift
 * @param {array} val - (not required if called on an instance)
 * @returns {any}
 */



doTests_ArrShift() {
	arr1 := ["A", "B", "C", , "E", 1, 2, 3]
	arr2 := [true, false, ignore, null, [], Map(), {}]



	;#region Instance calls
	arr3 := arr1.clone()
	el3 := arr3.shift()
	assert(
		el3 == "A" && arr3.get(1) == "B",
		"arr3.shift() failed"
	)
	;#endregion



	;#region Function calls
	arr3 := arr1.clone()
	el3 := ArrShift(arr3)
	assert(
		el3 == "A" && arr3.get(1) == "B",
		"ArrShift(arr3) failed"
	)
	;#endregion



	assert(condition, message := "") {
		if (!condition) {
			throw message
		}
	}
	MsgBox("Arrays.shift - All tests passed",, " T3")
}
doTests_ArrShift()
