#Include "..\libs\vartypes.lib.ahk"


/**
 * Returns the last character in a string
 *
 * @function Strings.getLastChar | StrLastChar
 * @param {(string|number)} val
 * @returns {(string|null)}
 */


doTests_StrLastChar() {
	str1 := "ABCDE12345"


	;#region Function calls
	assert(
		StrLastChar(str1) == "5",
		"StrLastChar(str1) failed"
	)

	assert(
		StrLastChar(12345) == "5",
		"StrLastChar(12345) failed"
	)

	assert(
		typeCompare(StrLastChar(""), null),
		"StrLastChar('') failed"
	)

	try {
		StrLastChar(Map())
		assert(false, "StrLastChar(Map()) should have thrown an error")
	}
	;#endregion Function calls


	assert(condition, message := "") {
		if (!condition) {
			throw message
		}
	}
	FileAppend("Strings.getLastChar: All tests passed`n", "*")
}
doTests_StrLastChar()
