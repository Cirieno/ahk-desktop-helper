#Include "..\libs\vartypes.lib.ahk"



/**
 * Returns a shallow copy of a portion of an array
 *
 * @function Arrays.slice | ArrSlice
 * @param {array} val - (not required if called on an instance)
 * @param {number} [indexStart=1] - positive numbers from left, negative numbers from right
 * @param {number} [indexEnd=val.length] - positive numbers from left, negative numbers from right
 * @param {boolean} [clamp=false] - fix index to between 1 and val.length
 * @returns {array}
 */



doTests_ArrSlice() {
	arr1 := ["A", "B", "C", , "E", 1, 2, 3]
	arr2 := [true, false, ignore, null, [], Map(), {}]



	;#region Instance calls
	arr3 := arr1.clone()
	assert(
		typeCompare(arr3.slice().join(), "ABCE123"),
		"arr3.slice() failed"
	)

	arr3 := arr1.clone()
	assert(
		typeCompare(arr3.slice(3).join(), "CE123"),
		"arr3.slice(3) failed"
	)

	arr3 := arr1.clone()
	assert(
		typeCompare(arr3.slice(3, 5).join(), "CE"),
		"arr3.slice(3, 5) failed"
	)

	arr3 := arr1.clone()
	assert(
		typeCompare(arr3.slice(-3).join(), "123"),
		"arr3.slice(-3) failed"
	)

	arr3 := arr1.clone()
	assert(
		typeCompare(arr3.slice(-3, -1).join(), "12"),
		"arr3.slice(-3, -1) failed"
	)

	arr3 := arr1.clone()
	try {
		arr3.slice(-30).join()
		assert(false, "arr3.slice(-30) should have thrown an error")
	}

	arr3 := arr1.clone()
	assert(
		typeCompare(arr3.slice(30, , true).join(), "3"),
		"arr3.slice(30, , true) failed"
	)

	arr3 := arr1.clone()
	assert(
		typeCompare(arr3.slice(, 30, true).join(), "ABCE123"),
		"arr3.slice(, 30, true) failed"
	)
	;#endregion



	;#region Function calls
	arr3 := arr1.clone()
	assert(
		typeCompare(Arrays.slice(arr3).join(), "ABCE123"),
		"Arrays.slice(arr3) failed"
	)

	arr3 := arr1.clone()
	assert(
		typeCompare(Arrays.slice(arr3, 3).join(), "CE123"),
		"Arrays.slice(arr3, 3) failed"
	)

	arr3 := arr1.clone()
	assert(
		typeCompare(Arrays.slice(arr3, 3, 5).join(), "CE"),
		"Arrays.slice(arr3, 3, 5) failed"
	)

	arr3 := arr1.clone()
	assert(
		typeCompare(Arrays.slice(arr3, -3).join(), "123"),
		"Arrays.slice(arr3, -3) failed"
	)

	arr3 := arr1.clone()
	assert(
		typeCompare(Arrays.slice(arr3, -3, -1).join(), "12"),
		"Arrays.slice(arr3, -3, -1) failed"
	)

	arr3 := arr1.clone()
	try {
		Arrays.slice(arr3, -30).join()
		assert(false, "Arrays.slice(arr3, -30) should have thrown an error")
	}

	arr3 := arr1.clone()
	assert(
		typeCompare(Arrays.slice(arr3, 30, , true).join(), "3"),
		"Arrays.slice(arr3, 30, , true) failed"
	)

	arr3 := arr1.clone()
	assert(
		typeCompare(Arrays.slice(arr3, , 30, true).join(), "ABCE123"),
		"Arrays.slice(arr3, , 30, true) failed"
	)
	;#endregion



	assert(condition, message := "") {
		if (!condition) {
			throw message
		}
	}
	MsgBox("Arrays.slice - All tests passed",, " T2")
}
doTests_ArrSlice()
