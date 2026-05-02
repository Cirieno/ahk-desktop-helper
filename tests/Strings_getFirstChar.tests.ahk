#Include "..\libs\vartypes.lib.ahk"


/**
 * Returns the first character in a string
 *
 * @function Strings.getFirstChar | StrFirstChar
 * @param {(string|number)} val
 * @returns {(string|null)}
 */


doTests_StrFirstChar() {
	str1 := "ABCDE12345"


	;#region Function calls
	assert(
		StrFirstChar(str1) == "A",
		"StrFirstChar(str1) failed"
	)

	assert(
		StrFirstChar(12345) == "1",
		"StrFirstChar(12345) failed"
	)

	assert(
		typeCompare(StrFirstChar(""), null),
		"StrFirstChar('') failed"
	)

	try {
		StrFirstChar([])
		assert(false, "StrFirstChar([]) should have thrown an error")
	}
	;#endregion Function calls


	assert(condition, message := "") {
		if (!condition) {
			throw message
		}
	}
	FileAppend("Strings.getFirstChar: All tests passed`n", "*")
}
doTests_StrFirstChar()
