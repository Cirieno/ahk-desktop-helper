#Include "..\libs\vartypes.lib.ahk"


/**
 * Wraps a string in the specified characters
 *
 * @function Strings.wrap | StrWrap
 * @param {(string|number)} val
 * @param {number} [mode=0] - 1 = parentheses, 2 = square-brackets, 3 = braces, 4 = angle-brackets, 5 = double-quotes, 6 = single-quotes, 7 = backticks
 * @param {(string|number)} [strStart=""]
 * @param {(string|number)} [strEnd=strStart]
 * @returns {string}
 */


doTests_StrWrap() {
	str1 := "ABC123"


	;#region Function calls
	assert(
		StrWrap(str1, 1) == "(ABC123)",
		"StrWrap(str1, 1) failed"
	)

	assert(
		StrWrap(str1, 4) == "<ABC123>",
		"StrWrap(str1, 4) failed"
	)

	assert(
		StrWrap(str1, 5) == "`"ABC123`"",
		"StrWrap(str1, 5) failed"
	)

	assert(
		StrWrap(str1, , "x") == "xABC123x",
		"StrWrap(str1, , 'x') failed"
	)

	assert(
		StrWrap(str1, , "x", "y") == "xABC123y",
		"StrWrap(str1, , 'x', 'y') failed"
	)
	;#endregion


	assert(condition, message := "") {
		if (!condition) {
			throw message
		}
	}
	MsgBox("Strings.wrap - All tests passed",, " T2")
}
doTests_StrWrap()
