#Include "..\libs\vartypes.lib.ahk"


/**
 * Returns the character at the specified position in a string
 *
 * @function Strings.charAt | StrCharAt
 * @param {(string|number)} val
 * @param {number} [index=1] - positive numbers from left, negative numbers from right
 * @param {boolean} [clamp=false] - fix index to between 1 and val.length
 * @returns {(string|null)}
 */


doTests_StrCharAt() {
	str1 := "ABCDE12345"


	;#region Function calls
	assert(
		StrCharAt(str1, 2) == "B",
		"StrCharAt(str1, 2) failed"
	)

	assert(
		StrCharAt(str1, -2) == "4",
		"StrCharAt(str1, -2) failed"
	)

	try {
		StrCharAt(str1, -30)
		assert( false, "StrCharAt(str1, -30) failed" )
	}

	assert(
		StrCharAt(str1, -30, true) == "A",
		"StrCharAt(str1, -30, true) failed"
	)

	assert(
		StrCharAt(str1, 30, true) == "5",
		"StrCharAt(str1, 30, true) failed"
	)
	;#endregion


	assert(condition, message := "") {
		if (!condition) {
			throw message
		}
	}
	MsgBox("Strings.charAt - All tests passed",, " T2")
}
doTests_StrCharAt()
