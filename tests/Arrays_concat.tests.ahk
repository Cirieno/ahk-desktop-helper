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
	;#endregion Instance calls


	;#region Function calls
	arr3 := Arrays.concat(arr1, arr2)
	assert(
		typeCompare(arr3.get(10), false),
		"Arrays.concat(arr1, arr2) failed"
	)
	;#endregion Function calls


	assert(condition, message := "") {
		if (!condition) {
			throw message
		}
	}
	FileAppend("Arrays.concat: All tests passed`n", "*")
}
doTests_ArrConcat()
