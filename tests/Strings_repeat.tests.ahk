#Include "..\libs\vartypes.lib.ahk"


/**
 * Repeats a string a specified number of times
 *
 * @function Strings.repeat | StrRepeat
 * @param {(string|number)} val
 * @param {number} [count=1]
 * @returns {string}
 */


doTests_StrRepeat() {
	str1 := "ABC"


	;#region Function calls
	assert(
		StrRepeat(str1) == "ABC",
		"StrRepeat(str1) failed"
	)

	assert(
		StrRepeat(str1, 3) == "ABCABCABC",
		"StrRepeat(str1, 3) failed"
	)

	assert(
		StrRepeat(123, 2) == "123123",
		"StrRepeat(123, 2) failed"
	)

	assert(
		StrRepeat(str1, 0) == "",
		"StrRepeat(str1, 0) failed"
	)

	try {
		StrRepeat([], 2)
		assert(false, "StrRepeat([], 2) should have thrown an error")
	}

	try {
		StrRepeat(str1, "2")
		assert(false, "StrRepeat(str1, '2') should have thrown an error")
	}
	;#endregion Function calls


	assert(condition, message := "") {
		if (!condition) {
			throw message
		}
	}
	FileAppend("Strings.repeat: All tests passed`n", "*")
}
doTests_StrRepeat()
