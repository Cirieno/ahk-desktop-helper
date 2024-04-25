#Include "..\libs\vartypes.lib.ahk"


/**
 * Pads a string on the right side
 *
 * @function Strings.padRight | StrPadRight
 * @param {(string|number)} val
 * @param {number} [length=1]
 * @param {(string|number)} [strEnd=" "]
 * @returns {string}
 */


doTests_StrPadRight() {
	str1 := "ABC123"


	;#region Function calls
	assert(
		StrPadRight(str1) == "ABC123",
		"StrPadRight(str1) failed"
	)

	assert(
		StrPadRight(str1, 3) == "ABC123",
		"StrPadRight(str1, 3) failed"
	)

	assert(
		StrPadRight(str1, 10) == "ABC123    ",
		"StrPadRight(str1, 10) failed"
	)

	assert(
		StrPadRight(str1, 10, "x") == "ABC123xxxx",
		"StrPadRight(str1, 10, 'x') failed"
	)

	assert(
		StrPadRight(str1, 10, 0) == "ABC1230000",
		"StrPadRight(str1, 10, 0) failed"
	)

	assert(
		StrPadRight(str1, 10, "xyz") == "ABC123xyzx",
		"StrPadRight(str1, 10, 'xyz') failed"
	)
	;#endregion


	assert(condition, message := "") {
		if (!condition) {
			throw message
		}
	}
	MsgBox("Strings.padRight - All tests passed",, " T2")
}
doTests_StrPadRight()
