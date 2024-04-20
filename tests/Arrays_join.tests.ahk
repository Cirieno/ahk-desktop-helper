#Include "..\libs\vartypes.lib.ahk"



/**
 * Concatenates all elements of an array into a string
 *
 * @function Arrays.join | ArrJoin
 * @param {array} val - (not required if called on an instance)
 * @param {string} [separator=""]
 * @param {boolean} [clean=false] - remove empty elements from the output (ignored if debugMode > 0)
 * @param {number} [debugMode=0] - 0 = off, 1 = tokenize non-stringable elements, 2 = also tokenize Boolean values
 * @returns {string}
 */



doTests_ArrJoin() {
	arr1 := ["A", "B", "C", , "E", 1, 2, 3]
	arr2 := [true, false, ignore, null, [], Map(), {}]



	;#region Instance calls
	assert(
		typeCompare(arr1.join(), "ABCE123"),
		"arr1.join() failed"
	)

	assert(
		typeCompare(arr1.join(":"), "A:B:C::E:1:2:3"),
		"arr1.join(':') failed"
	)

	assert(
		typeCompare(arr1.join(":", true), "A:B:C:E:1:2:3"),
		"arr1.join(':', true) failed"
	)

	assert(
		typeCompare(arr2.join(), "10-1"),
		"arr2.join() failed"
	)

	assert(
		typeCompare(arr2.join(":"), "1:0:-1::::"),
		"arr2.join(':') failed"
	)

	assert(
		typeCompare(arr2.join(":", true), "1:0:-1"),
		"arr2.join(':', true) failed"
	)

	assert(
		typeCompare(arr2.join(":", , 1), "1:0:-1:<Null>:<Array>:<Map>:<Object>"),
		"arr2.join(':', , 1) failed"
	)

	assert(
		typeCompare(arr2.join(":", , 2), "<True>:<False>:<Ignore>:<Null>:<Array>:<Map>:<Object>"),
		"arr2.join(':', , 2) failed"
	)
	;#endregion



	;#region Function calls
	try {
		Arrays.join()
		assert(false, "Arrays.join() should have thrown an error")
	}

	assert(
		typeCompare(Arrays.join(arr1), "ABCE123"),
		"Arrays.join(arr1) failed"
	)

	assert(
		typeCompare(Arrays.join(arr1, ":"), "A:B:C::E:1:2:3"),
		"Arrays.join(arr1, ':') failed"
	)

	assert(
		typeCompare(Arrays.join(arr1, ":", true), "A:B:C:E:1:2:3"),
		"Arrays.join(arr1, ':', true) failed"
	)

	assert(
		typeCompare(Arrays.join(arr2), "10-1"),
		"Arrays.join(arr2) failed"
	)

	assert(
		typeCompare(Arrays.join(arr2, ":"), "1:0:-1::::"),
		"Arrays.join(arr2, ':') failed"
	)

	assert(
		typeCompare(Arrays.join(arr2, ":", true), "1:0:-1"),
		"Arrays.join(arr2, ':', true) failed"
	)

	assert(
		typeCompare(Arrays.join(arr2, ":", , 1), "1:0:-1:<Null>:<Array>:<Map>:<Object>"),
		"Arrays.join(arr2, ':', , 1) failed"
	)

	assert(
		typeCompare(Arrays.join(arr2, ":", , 2), "<True>:<False>:<Ignore>:<Null>:<Array>:<Map>:<Object>"),
		"Arrays.join(arr2, ':', , 2) failed"
	)
	;#endregion



	assert(condition, message := "") {
		if (!condition) {
			throw message
		}
	}
	MsgBox("Arrays.join - All tests passed",, " T2")
}
doTests_ArrJoin()
