#Include "..\libs\vartypes.lib.ahk"



/**
 * Returns the index of the first occurrence of a given value in an array
 *
 * @function Arrays.indexOf | ArrIndexOf
 * @param {array} val - (not required if called on an instance)
 * @param {(string|number)} needle
 * @param {boolean} [caseSense=false]
 * @param {number} [indexStart=1] - positive numbers from left, negative numbers from right
 * @param {boolean} [clamp=false] - fix index to between 1 and val.length
 * @returns {(integer|null)}
 *
 * This function is type-sensitive
 */



doTests_ArrIndexOf() {
	arr1 := ["A", "B", "C", , "E", 1, 2, 3]
	arr2 := [true, false, ignore, null, [], Map(), {}]



	;#region Instance calls
	try {
		arr1.indexOf()
		assert(false, "arr1.indexOf() should have thrown an error")
	}

	try {
		arr1.indexOf(arr1)
		assert(false, "arr1.indexOf(arr1) should have thrown an error")
	}

	assert(
		typeCompare(arr1.indexOf("B"), 2),
		"arr1.indexOf('B') failed"
	)

	assert(typeCompare(arr1.indexOf("b"), 2),
		"arr1.indexOf('b') failed"
	)

	assert(
		typeCompare(arr1.indexOf("b", true), null),
		"arr1.indexOf('b', true) failed"
	)

	assert(
		typeCompare(arr1.indexOf("B", , 3), null),
		"arr1.indexOf('B', , 3) failed"
	)

	try {
		arr1.indexOf("B", , 30)
		assert(false, "arr1.indexOf('B', , 30) should have thrown an error")
	}

	try {
		arr1.indexOf("B", , -30)
		assert(false, "arr1.indexOf('B', , -30) should have thrown an error")
	}

	assert(
		typeCompare(arr1.indexOf("B", , 30, true), null),
		"arr1.indexOf('B', , 30, true) failed"
	)

	assert(
		typeCompare(arr1.indexOf("B", , -30, true), 2),
		"arr1.indexOf('B', , -30, true) failed"
	)
	;#endregion



	;#region Function calls
	try {
		Arrays.indexOf()
		assert(false, "Arrays.indexOf() should have thrown an error")
	}

	try {
		Arrays.indexOf(arr1)
		assert(false, "Arrays.indexOf(arr1) should have thrown an error")
	}

	assert(
		typeCompare(Arrays.indexOf(arr1, "B"), 2),
		"Arrays.indexOf(arr1, 'B') failed"
	)

	assert(
		typeCompare(Arrays.indexOf(arr1, "b"), 2),
		"Arrays.indexOf(arr1, 'b') failed"
	)

	assert(
		typeCompare(Arrays.indexOf(arr1, "b", true), null),
		"Arrays.indexOf(arr1, 'b', true) failed"
	)

	assert(
		typeCompare(Arrays.indexOf(arr1, "B", , 3), null),
		"Arrays.indexOf(arr1, 'B', , 3) failed"
	)

	try {
		Arrays.indexOf(arr1, "B", , 30)
		assert(false, "Arrays.indexOf(arr1, 'B', , 30) should have thrown an error")
	}

	try {
		Arrays.indexOf(arr1, "B", , -30)
		assert(false, "Arrays.indexOf(arr1, 'B', , -30) should have thrown an error")
	}

	assert(
		typeCompare(Arrays.indexOf(arr1, "B", , 30, true), null),
		"Arrays.indexOf(arr1, 'B', , 30, true) failed"
	)

	assert(
		typeCompare(Arrays.indexOf(arr1, "B", , -30, true), 2),
		"Arrays.indexOf(arr1, 'B', , -30, true) failed"
	)
	;#endregion



	assert(condition, message := "") {
		if (!condition) {
			throw message
		}
	}
	MsgBox("Arrays.indexOf - All tests passed",, " T2")
}
doTests_ArrIndexOf()
