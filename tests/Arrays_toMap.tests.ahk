#Include "..\libs\vartypes.lib.ahk"


/**
 * Turns an array into a map object
 *
 * @function Arrays.toMap | ArrToMap
 * @param {array} val - (not required if called on an instance)
 * @returns {map}
 *
 * map(key, val) = (el, null)
 * unless el is an array in which case map(key, val) = (el[1], el[2])
 */


doTests_ArrToMap() {
	arr1 := ["A", "B", "C", , "E", 1, 2, 3]
	arr2 := [true, false, ignore, null, [], Map(), {}]
	arr3 := [["A", 1], ["B", 2], ["C", 3], , ["E", 5], [1, 1], [2, 2], [3, 3]]


	;#region Instance calls
	map1 := arr1.toMap()
	assert(
		map1.has("B") && map1.has("2"),
		"arr1.toMap() failed"
	)

	map3 := arr3.toMap()
	assert(
		map3.has("B") && map3.get("B") == 2,
		"arr3.toMap() failed"
	)
	;#endregion


	;#region Function calls
	map1 := Arrays.toMap(arr1)
	assert(
		map1.has("B") && map1.has("2"),
		"Arrays.toMap(arr1) failed"
	)

	map3 := Arrays.toMap(arr3)
	assert(
		map3.has("B") && map3.get("B") == 2,
		"Arrays.toMap(arr3) failed"
	)
	;#endregion


	assert(condition, message := "") {
		if (!condition) {
			throw message
		}
	}
	MsgBox("Arrays.toMap - All tests passed",, " T2")
}
doTests_ArrToMap()
