#Include "..\libs\vartypes.lib.ahk"



/**
 * Creates a new array from an iterable or array-like object
 *
 * @function Arrays.from | ArrFrom
 * @param {(string|number|map|object|array)} val
 * @param {number} [mode=3] - 1 = values, 2 = keys, 3 = both
 * @returns {array}
 *
 * Param [mode = both] returns an array of [key, value] items from a Map or Object
 *
 * Param [mode] has no effect on Strings or Arrays
 */



doTests_ArrFrom() {
	map1 := Map("A", 1, "B", 2, "C", 3)
	str1 := "[A,B,C,D,E]"
	obj1 := { A: 1, B: 2, C: 3 }



	;#region Function calls
	arr1 := Arrays.from(map1)
	assert(
		arr1[1][1] == "A" && arr1[1][2] == 1,
		"Arrays.from(map1) failed"
	)

	arr1 := Arrays.from(map1, 1)
	assert(
		arr1[2] == 2,
		"Arrays.from(map1, 1) failed"
	)

	arr1 := Arrays.from(map1, 2)
	assert(
		arr1[3] == "C",
		"Arrays.from(map1, 2) failed"
	)

	arr1 := Arrays.from(str1)
	assert(
		arr1[4] == "D",
		"Arrays.from(str1) failed"
	)

	arr1 := Arrays.from(obj1)
	assert(
		arr1[1][1] == "A" && arr1[1][2] == 1,
		"Arrays.from(obj1) failed"
	)

	arr1 := Arrays.from(obj1, 1)
	assert(
		arr1[2] == 2,
		"Arrays.from(obj1, 1) failed"
	)

	arr1 := Arrays.from(obj1, 2)
	assert(
		arr1[3] == "C",
		"Arrays.from(obj1, 2) failed"
	)
	;#endregion



	assert(condition, message := "") {
		if (!condition) {
			throw message
		}
	}
	MsgBox("Arrays.from - All tests passed",, " T3")
}
doTests_ArrFrom()
