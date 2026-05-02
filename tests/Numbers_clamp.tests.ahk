#Include "..\libs\vartypes.lib.ahk"


/**
 * Forces a number to be within a range
 *
 * @function Numbers.clamp | NumClamp
 * @param {number} val
 * @param {number} min
 * @param {number} max
 * @returns {number}
 */


doTests_NumClamp() {
	;#region Function calls
	assert(
		NumClamp(5, 1, 10) == 5,
		"NumClamp(5, 1, 10) failed"
	)

	assert(
		NumClamp(0, 1, 10) == 1,
		"NumClamp(0, 1, 10) failed"
	)

	assert(
		NumClamp(100, 1, 10) == 10,
		"NumClamp(100, 1, 10) failed"
	)

	assert(
		NumClamp(-100, 1, 10) == 1,
		"NumClamp(-100, 1, 10) failed"
	)

	assert(
		NumClamp(5.71, 1, 10) == 5.71,
		"NumClamp(5.71, 1, 10) failed"
	)

	try {
		NumClamp("5", 1, 10)
		assert(false, "NumClamp('5', 1, 10) should have thrown a TypeError")
	} catch TypeError {
		assert(true)
	}

	try {
		NumClamp(5, 10, 1)
		assert(false, "NumClamp(5, 10, 1) should have thrown a ValueError")
	} catch ValueError {
		assert(true)
	}
	;#endregion Function calls


	assert(condition, message := "") {
		if (!condition) {
			throw message
		}
	}
	FileAppend("Numbers.clamp: All tests passed`n", "*")
}
doTests_NumClamp()
