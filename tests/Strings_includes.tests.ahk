#Include "..\libs\vartypes.lib.ahk"


/**
 * Checks if string contains a given value
 *
 * @function Strings.includes | StrIncludes
 * @param {(string|number)} val
 * @param {(string|number)} needle
 * @param {boolean} [caseSense=false]
 * @param {number} [indexStart=1] - positive numbers from left, negative numbers from right
 * @param {boolean} [clamp=false] - fix index to between 1 and val.length
 * @returns {boolean}
 */


doTests_StrIncludes() {
	str1 := "ABC123"


	;#region Function calls
	try {
		Strings.includes()
		assert(false, "Strings.includes() should have thrown an error")
	}

	try {
		Strings.includes(str1)
		assert(false, "Strings.includes(str1) should have thrown an error")
	}

	assert(
		typeCompare(Strings.includes(str1, "B"), true),
		"Strings.includes(str1, 'B') failed"
	)

	assert(
		typeCompare(Strings.includes(str1, "b"), true),
		"Strings.includes(str1, 'b') failed"
	)

	assert(
		typeCompare(Strings.includes(str1, "b", true), false),
		"Strings.includes(str1, 'b', true) failed"
	)

	assert(
		typeCompare(Strings.includes(str1, "B", , 3), false),
		"Strings.includes(str1, 'B', , 3) failed"
	)

	try {
		Strings.includes(str1, "B", , 30)
		assert(false, "Strings.includes(str1, 'B', , 30) should have thrown an error")
	}

	try {
		Strings.includes(str1, "B", , -30)
		assert(false, "Strings.includes(str1, 'B', , -30) should have thrown an error")
	}

	assert(
		typeCompare(Strings.includes(str1, "B", , 30, true), false),
		"Strings.includes(str1, 'B', , 30, true) failed"
	)

	assert(
		typeCompare(Strings.includes(str1, "B", , -30, true), true),
		"Strings.includes(str1, 'B', , -30, true) failed"
	)
	;#endregion


	assert(
		condition, message := "") {
			if (!condition) {
				throw message
			}
	}
	MsgBox("Strings.includes - All tests passed",, " T2")
}
doTests_StrIncludes()
