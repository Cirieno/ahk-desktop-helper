#Include "..\libs\vartypes.lib.ahk"


/**
 * Checks if number is within a range
 *
 * @function Numbers.between | NumBetween
 * @param {number} val
 * @param {number} min
 * @param {number} max
 * @param {boolean} [inclusive=true]
 * @return {boolean}
 */


doTests_NumBetween() {
	;#region Function calls
	assert(
		NumBetween(5, 1, 10) == true,
		"NumBetween(5, 1, 10) failed"
	)

	assert(
		NumBetween(5.71, 1, 10.99) == true,
		"NumClamp(5.71, 1, 10.99) failed"
	)

	assert(
		NumBetween(50, 1, 10) == false,
		"NumBetween(50, 1, 10) failed"
	)

	assert(
		NumBetween(-50, 1, 10) == false,
		"NumBetween(-50, 1, 10) failed"
	)

	assert(
		NumBetween(10, 1, 10, false) == false,
		"NumClamp(10, 1, 10, false) failed"
	)

	try {
		NumBetween("5", 1, 10)
		assert(false, "NumClamp(null, 1, 10) failed")
	}

	try {
		NumBetween(null, 1, 10)
		assert(false, "NumClamp(null, 1, 10) failed")
	}
	;#endregion


	assert(condition, message := "") {
		if (!condition) {
			throw message
		}
	}
	MsgBox("Numbers.between - All tests passed",, " T2")
}
doTests_NumBetween()
