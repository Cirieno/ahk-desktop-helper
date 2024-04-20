#Include "..\libs\vartypes.lib.ahk"



/**
 * Reverses the order of the elements in an array
 *
 * @function Arrays.reverse | ArrReverse
 * @param {array} val - (not required if called on an instance)
 * @returns {array}
 */



doTests_ArrReverse() {
	arr1 := ["A", "B", "C", , "E", 1, 2, 3]
	arr2 := [true, false, ignore, null, [], Map(), {}]



	;#region Instance calls
	arr3 := arr1.clone()
	assert(
		typeCompare(arr3.reverse().join(), "321ECBA"),
		"arr3.reverse() failed"
	)
	;#endregion



	;#region Function calls
	arr3 := arr1.clone()
	assert(
		typeCompare(Arrays.reverse(arr3).join(), "321ECBA"),
		"Arrays.reverse(arr3) failed"
	)
	;#endregion



	assert(condition, message := "") {
		if (!condition) {
			throw message
		}
	}
	MsgBox("Arrays.reverse - All tests passed",, " T2")
}
doTests_ArrReverse()
