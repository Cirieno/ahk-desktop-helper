#Include "..\libs\vartypes.lib.ahk"



/**
 * Returns the item at the specified index
 *
 * @function Arrays.at | ArrAt
 * @param {array} [val] - (not required if called on an instance)
 * @param {number} [index=1] - positive numbers from left, negative numbers from right
 * @param {boolean} [clamp=false] - fix index to between 1 and val.length
 * @returns {(any|null)}
 */



doTests_ArrAt() {
	arr1 := ["A", "B", "C", , "E", 1, 2, 3]
	arr2 := [true, false, ignore, null, [], Map(), {}]



	;#region Instance calls
	assert(
		typeCompare(arr1.at(), "A"),
		"arr1.at() failed"
	)

	assert(
		typeCompare(arr1.at(3), "C"),
		"arr1.at(3) failed"
	)

	assert(
		typeCompare(arr1.at(-3), 1),
		"arr1.at(-3) failed"
	)

	try {
		assert(arr1.at(30))
		assert(false, "arr1.at(30) should have thrown an error")
	}

	try {
		assert(arr1.at(-30))
		assert(false, "arr1.at(-30) should have thrown an error")
	}

	assert(
		typeCompare(arr1.at(30, true), 3),
		"arr1.at(30, true) failed"
	)

	assert(
		typeCompare(arr1.at(-30, true), "A"),
		"arr1.at(-30, true) failed"
	)
	;#endregion



	;#region Function calls
	try {
		Arrays.at()
		assert(false, "Arrays.at() should have thrown an error")
	}

	assert(
		typeCompare(Arrays.at(arr1), "A"),
		"Arrays.at(arr1) failed"
	)

	assert(
		typeCompare(Arrays.at(arr1, 3), "C"),
		"Arrays.at(arr1, 3) failed"
	)

	assert(
		typeCompare(Arrays.at(arr1, -3), 1),
		"Arrays.at(arr1, -3) failed"
	)

	try {
		assert(Arrays.at(arr1, 30))
		assert(false, "Arrays.at(arr1, 30) should have thrown an error")
	}

	try {
		assert(Arrays.at(arr1, -30))
		assert(false, "Arrays.at(arr1, -30) should have thrown an error")
	}

	assert(
		typeCompare(Arrays.at(arr1, 30, true), 3),
		"Arrays.at(arr1, 30, true) failed"
	)

	assert(
		typeCompare(Arrays.at(arr1, -30, true), "A"),
		"Arrays.at(arr1, -30, true) failed"
	)
	;#endregion



	assert(condition, message := "") {
		if (!condition) {
			throw message
		}
	}
	MsgBox("Arrays.at - All tests passed",, " T2")
}
doTests_ArrAt()
