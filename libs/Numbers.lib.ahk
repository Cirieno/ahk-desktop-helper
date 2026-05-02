/**********************************************************
 * @type {AHKLibrary}
 * @name Numbers Utils
 * @author Rob McInnes (Cirieno)
 * @file Numbers.lib.ahk
 *********************************************************/


global Numbers := prototype__Numbers()
class prototype__Numbers {
	between(_number, minValue, maxValue, inclusive := true) {
		funcName := "Numbers.between"

		if (!isNumber(_number)) {
			throw TypeError(StrWrap(funcName, 2) . " — Param <_number> is not a Number")
		}
		if (!isNumber(minValue)) {
			throw TypeError(StrWrap(funcName, 2) . " — Param <min> is not a Number")
		}
		if (!isNumber(maxValue)) {
			throw TypeError(StrWrap(funcName, 2) . " — Param <max> is not a Number")
		}
		if (!isBoolean(inclusive)) {
			throw TypeError(StrWrap(funcName, 2) . " — Param <inclusive> is not a Boolean")
		}
		if (minValue > maxValue) {
			throw ValueError(StrWrap(funcName, 2) . " — Param <min> is greater than Param <max>")
		}

		return (inclusive ? (_number >= minValue && _number <= maxValue) : (_number > minValue && _number < maxValue))
	}


	clamp(_number, minValue, maxValue) {
		funcName := "Numbers.clamp"

		if (!isNumber(_number)) {
			throw TypeError(StrWrap(funcName, 2) . " — Param <_number> is not a Number")
		}
		if (!isNumber(minValue)) {
			throw TypeError(StrWrap(funcName, 2) . " — Param <min> is not a Number")
		}
		if (!isNumber(maxValue)) {
			throw TypeError(StrWrap(funcName, 2) . " — Param <max> is not a Number")
		}
		if (minValue > maxValue) {
			throw ValueError(StrWrap(funcName, 2) . " — Param <min> is greater than Param <max>")
		}

		return Min(Max(_number, minValue), maxValue)
	}
}


/**
 * Checks if number is within a range
 *
 * @function Numbers.between | NumBetween
 * @param {number} _number
 * @param {number} minValue
 * @param {number} maxValue
 * @param {boolean} [inclusive=true]
 * @returns {boolean}
 */
NumBetween := ObjBindMethod(Numbers, "between")


/**
 * Forces a number to be within a range
 *
 * @function Numbers.clamp | NumClamp
 * @param {number} _number
 * @param {number} minValue
 * @param {number} maxValue
 * @returns {number}
 */
NumClamp := ObjBindMethod(Numbers, "clamp")
