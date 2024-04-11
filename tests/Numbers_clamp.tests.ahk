#Include "..\libs\vartypes.lib.ahk"



/**
 * Forces a number to be within a range
 *
 * @function Numbers.clamp | NumClamp
 * @param {number} val
 * @param {number} min
 * @param {number} max
 * @return {number}
 */



doTests_NumClamp() {
	;#region Function calls
	assert(
		typeCompare(NumClamp(5, 1, 10), 5),
		"NumClamp(5, 1, 10) failed"
	)

	assert(
		typeCompare(NumClamp(0, 1, 10), 1),
		"NumClamp(0, 1, 10) failed"
	)

	assert(
		typeCompare(NumClamp(100, 1, 10), 10),
		"NumClamp(100, 1, 10) failed"
	)

	assert(
		typeCompare(NumClamp(-100, 1, 10), 1),
		"NumClamp(-100, 1, 10) failed"
	)

	assert(
		typeCompare(NumClamp(5.71, 1, 10), 5.71),
		"NumClamp(5.71, 1, 10) failed"
	)

	try {
		NumClamp("5", 1, 10)
		assert(false, "NumClamp('5', 1, 10) failed")
	}
	;#endregion



	assert(condition, message := "") {
		if (!condition) {
			throw message
		}
	}
	MsgBox("Numbers.clamp - All tests passed",, " T3")
}
doTests_NumClamp()
