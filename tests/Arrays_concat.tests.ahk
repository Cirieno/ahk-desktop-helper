#Include "..\libs\vartypes.lib.ahk"



/**
 * Joins (n) arrays and returns a new array
 *
 * @function Arrays.concat | ArrConcat
 * @param {...array} vals
 * @returns {array}
 */



doTests_ArrConcat() {
	arr1 := ["A", "B", "C", , "E", 1, 2, 3]
	arr2 := [true, false, ignore, null, [], Map(), {}]



	;#region Instance calls
	arr3 := arr1.concat(arr2)
	assert(
		typeCompare(arr3.get(11), -1),
		"arr1.concat(arr2) failed"
	)
	;#endregion



	;#region Function calls
	arr3 := Arrays.concat(arr1, arr2)
	assert(
		typeCompare(arr3.get(10), false),
		"Arrays.concat(arr1, arr2) failed"
	)
	;#endregion



	assert(condition, message := "") {
		if (!condition) {
			throw message
		}
	}
	MsgBox("Arrays.concat - All tests passed",, " T2")
}
doTests_ArrConcat()
