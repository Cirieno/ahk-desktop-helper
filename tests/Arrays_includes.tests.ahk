#Include "..\libs\vartypes.lib.ahk"


/**
 * Checks if an array contains a given value
 *
 * @function Arrays.includes | ArrIncludes
 * @param {array} val - (not required if called on an instance)
 * @param {(string|number)} needle
 * @param {boolean} [caseSense=false]
 * @param {number} [indexStart=1] - positive numbers from left, negative numbers from right
 * @param {boolean} [clamp=false] - fix index to between 1 and val.length
 * @returns {boolean}
 *
 * This function is type-sensitive
 */


doTests_ArrIncludes() {
	arr1 := ["A", "B", "C", , "E", 1, 2, 3]
	arr2 := [true, false, ignore, null, [], Map(), {}]


	;#region Instance calls
	try {
		arr1.includes()
		assert(false, "arr1.includes() should have thrown an error")
	}

	try {
		arr1.includes(arr1)
		assert(false, "arr1.includes(arr1) should have thrown an error")
	}

	assert(
		typeCompare(arr1.includes("B"), true),
		"arr1.includes('B') failed"
	)

	assert(
		typeCompare(arr1.includes("b"), true),
		"arr1.includes('b') failed"
	)

	assert(
		typeCompare(arr1.includes("b", true), false),
		"arr1.includes('b', true) failed"
	)

	assert(
		typeCompare(arr1.includes("B", , 3), false),
		"arr1.includes('B', , 3) failed"
	)

	try {
		arr1.includes("B", , 30)
		assert(false, "arr1.includes('B', , 30) should have thrown an error")
	}

	try {
		arr1.includes("B", , -30)
		assert(false, "arr1.includes('B', , -30) should have thrown an error")
	}

	assert(
		typeCompare(arr1.includes("B", , 30, true), false),
		"arr1.includes('B', , 30, true) failed"
	)

	assert(
		typeCompare(arr1.includes("B", , -30, true), true),
		"arr1.includes('B', , -30, true) failed"
	)
	;#endregion


	;#region Function calls
	try {
		Arrays.includes()
		assert(false, "Arrays.includes() should have thrown an error")
	}

	try {
		Arrays.includes(arr1)
		assert(false, "Arrays.includes(arr1) should have thrown an error")
	}

	assert(
		typeCompare(Arrays.includes(arr1, "B"), true),
		"Arrays.includes(arr1, 'B') failed"
	)

	assert(
		typeCompare(Arrays.includes(arr1, "b"), true),
		"Arrays.includes(arr1, 'b') failed"
	)

	assert(
		typeCompare(Arrays.includes(arr1, "b", true), false),
		"Arrays.includes(arr1, 'b', true) failed"
	)

	assert(
		typeCompare(Arrays.includes(arr1, "B", , 3), false),
		"Arrays.includes(arr1, 'B', , 3) failed"
	)

	try {
		Arrays.includes(arr1, "B", , 30)
		assert(false, "Arrays.includes(arr1, 'B', , 30) should have thrown an error")
	}

	try {
		Arrays.includes(arr1, "B", , -30)
		assert(false, "Arrays.includes(arr1, 'B', , -30) should have thrown an error")
	}

	assert(
		typeCompare(Arrays.includes(arr1, "B", , 30, true), false),
		"Arrays.includes(arr1, 'B', , 30, true) failed"
	)

	assert(
		typeCompare(Arrays.includes(arr1, "B", , -30, true), true),
		"Arrays.includes(arr1, 'B', , -30, true) failed"
	)
	;#endregion


	assert(
		condition, message := "") {
			if (!condition) {
				throw message
			}
	}
	MsgBox("Arrays.includes - All tests passed",, " T2")
}
doTests_ArrIncludes()
