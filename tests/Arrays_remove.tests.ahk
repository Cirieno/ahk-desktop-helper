#Include "..\libs\vartypes.lib.ahk"


/**
 * Returns the index of the first occurrence of a given value in an array
 *
 * @function Arrays.remove | ArrRemove
 * @param {array} val - (not required if called on an instance)
 * @param {(string|number)} needle
 * @param {boolean} [caseSense=false]
 * @param {number} [indexStart=1] - positive numbers from left, negative numbers from right
 * @param {boolean} [clamp=false] - fix index to between 1 and val.length
 * @returns {(integer|null)}
 *
 * This function is type-sensitive
 */


doTests_ArrRemove() {
	arr1 := ["A", "B", "C", , "E", 1, 2, 3]
	arr2 := [true, false, ignore, null, [], Map(), {}]


	;#region Instance calls
	arr3 := arr1.clone()
	try {
		arr3.remove()
		assert(false, "arr3.remove() should have thrown an error")
	}

	arr3 := arr1.clone()
	try {
		arr3.remove(arr3)
		assert(false, "arr3.remove(arr3) should have thrown an error")
	}

	arr3 := arr1.clone()
	assert(
		typeCompare(arr3.remove("B").join(), "ACE123"),
		"arr3.remove('B') failed"
	)

	arr3 := arr1.clone()
	assert(
		typeCompare(arr3.remove("b").join(), "ACE123"),
		"arr3.remove('b') failed"
	)

	arr3 := arr1.clone()
	assert(
		typeCompare(arr3.remove("b", true).join(), "ABCE123"),
		"arr3.remove('b', true) failed"
	)

	arr3 := arr1.clone()
	assert(
		typeCompare(arr3.remove("B", , 3).join(), "ABCE123"),
		"arr3.remove('B', , 3) failed"
	)

	arr3 := arr1.clone()
	try {
		arr3.remove("B", , 30)
		assert(false, "arr3.remove('B', , 30) should have thrown an error")
	}

	arr3 := arr1.clone()
	try {
		arr3.remove("B", , -30)
		assert(false, "arr3.remove('B', , -30) should have thrown an error")
	}

	arr3 := arr1.clone()
	assert(
		typeCompare(arr3.remove("B", , 30, true).join(), "ABCE123"),
		"arr3.remove('B', , 30, true) failed"
	)

	arr3 := arr1.clone()
	assert(
		typeCompare(arr3.remove("B", , -30, true).join(), "ACE123"),
		"arr3.remove('B', , -30, true) failed"
	)
	;#endregion


	;#region Function calls
	arr3 := arr1.clone()
	try {
		Arrays.remove()
		assert(false, "Arrays.remove() should have thrown an error")
	}

	arr3 := arr1.clone()
	try {
		Arrays.remove(arr3)
		assert(false, "Arrays.remove(arr3) should have thrown an error")
	}

	arr3 := arr1.clone()
	assert(
		typeCompare(Arrays.remove(arr3, "B").join(), "ACE123"),
		"Arrays.remove(arr3, 'B') failed"
	)

	arr3 := arr1.clone()
	assert(
		typeCompare(Arrays.remove(arr3, "b").join(), "ACE123"),
		"Arrays.remove(arr3, 'b') failed"
	)

	arr3 := arr1.clone()
	assert(
		typeCompare(Arrays.remove(arr3, "b", true).join(), "ABCE123"),
		"Arrays.remove(arr3, 'b', true) failed"
	)

	arr3 := arr1.clone()
	assert(
		typeCompare(Arrays.remove(arr3, "B", , 3).join(), "ABCE123"),
		"Arrays.remove(arr3, 'b', , 3) failed"
	)

	arr3 := arr1.clone()
	try {
		Arrays.remove(arr3, "B", , 30)
		assert(false, "Arrays.remove(arr3, 'B', , 30) should have thrown an error")
	}

	arr3 := arr1.clone()
	try {
		Arrays.remove(arr3, "B", , -30)
		assert(false, "Arrays.remove(arr3, 'B', , -30) should have thrown an error")
	}

	arr3 := arr1.clone()
	assert(
		typeCompare(Arrays.remove(arr3, "B", , 30, true).join(), "ABCE123"),
		"Arrays.remove(arr3, 'B', , 30, true) failed"
	)

	arr3 := arr1.clone()
	assert(
		typeCompare(Arrays.remove(arr3, "B", , -30, true).join(), "ACE123"),
		"Arrays.remove(arr3, 'B', , -30, true) failed"
	)
	;#endregion


	assert(condition, message := "") {
		if (!condition) {
			throw message
		}
	}
	MsgBox("Arrays.remove - All tests passed",, " T2")
}
doTests_ArrRemove()
