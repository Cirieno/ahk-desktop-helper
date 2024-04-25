#Include "..\libs\vartypes.lib.ahk"


/**
 * Pads a string on the left side
 *
 * @function Strings.padLeft | StrPadLeft
 * @param {(string|number)} val
 * @param {number} [length=1]
 * @param {(string|number)} [strStart=" "]
 * @returns {string}
 */


doTests_StrPadLeft() {
	str1 := "ABC123"


	;#region Function calls
	assert(
		StrPadLeft(str1) == "ABC123",
		"StrPadLeft(str1) failed"
	)

	assert(
		StrPadLeft(str1, 3) == "ABC123",
		"StrPadLeft(str1, 3) failed"
	)

	assert(
		StrPadLeft(str1, 10) == "    ABC123",
		"StrPadLeft(str1, 10) failed"
	)

	assert(
		StrPadLeft(str1, 10, "x") == "xxxxABC123",
		"StrPadLeft(str1, 10, 'x') failed"
	)

	assert(
		StrPadLeft(str1, 10, 0) == "0000ABC123",
		"StrPadLeft(str1, 10, 0) failed"
	)

	assert(
		StrPadLeft(str1, 10, "xyz") == "xyzxABC123",
		"StrPadLeft(str1, 10, 'xyz') failed"
	)
	;#endregion


	assert(condition, message := "") {
		if (!condition) {
			throw message
		}
	}
	MsgBox("Strings.padLeft - All tests passed",, " T2")
}
doTests_StrPadLeft()
