#Include "..\libs\vartypes.lib.ahk"



/**
 * Returns a section of a string
 *
 * @function Strings.slice | StrSlice
 * @param {(string|number)} val
 * @param {number} [indexStart=1] - positive numbers from left, negative numbers from right
 * @param {number} [indexEnd=val.length] - positive numbers from left, negative numbers from right
 * @param {boolean} [clamp=false] - fix index to between 1 and val.length
 * @returns {array}
 */



doTests_StrSlice() {
	str1 := "ABCE123"



	;#region Function calls
	try {
		Strings.slice()
		assert(false, "Strings.slice() should have thrown an error")
	}

	assert(
		typeCompare(Strings.slice(str1), "ABCE123"),
		"Strings.slice(str1) failed"
	)

	assert(
		typeCompare(Strings.slice(str1, 3), "CE123"),
		"Strings.slice(str1, 3) failed"
	)

	assert(
		typeCompare(Strings.slice(str1, 3, 5), "CE1"),
		"Strings.slice(str1, 3, 5) failed"
	)

	assert(
		typeCompare(Strings.slice(str1, -3), "123"),
		"Strings.slice(str1, -3) failed"
	)

	assert(
		typeCompare(Strings.slice(str1, -3, -1), "12"),
		"Strings.slice(str1, -3, -1) failed"
	)

	try {
		Strings.slice(str1, -30)
		assert(false, "Strings.slice(str1, -30) should have thrown an error")
	}

	assert(
		typeCompare(Strings.slice(str1, 30, , true), "3"),
		"Strings.slice(str1, 30, , true) failed"
	)

	assert(
		typeCompare(Strings.slice(str1, , 30, true), "ABCE123"),
		"Strings.slice(str1, , 30, true) failed"
	)
	;#endregion



	assert(condition, message := "") {
		if (!condition) {
			throw message
		}
	}
	MsgBox("Strings.slice - All tests passed",, " T2")
}
doTests_StrSlice()
