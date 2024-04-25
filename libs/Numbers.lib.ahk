global Numbers := prototype__Numbers()
class prototype__Numbers {
	between(_number, min, max, inclusive := true, clamp := false) {
		funcName := "Numbers.between"

		if (!isNumber(_number)) {
			throw Error(StrWrap(funcName, 2) . " — Param <_number> is not a Number")
		}
		if (!isNumber(min)) {
			throw Error(StrWrap(funcName, 2) . " — Param <min> is not a Number")
		}
		if (!isNumber(max)) {
			throw Error(StrWrap(funcName, 2) . " — Param <max> is not a Number")
		}
		if (!isBoolean(inclusive)) {
			throw Error(StrWrap(funcName, 2) . " — Param <inclusive> is not a Boolean")
		}
		if (!isBoolean(clamp)) {
			throw Error(StrWrap(funcName, 2) . " — Param <clamp> is not a Boolean")
		}
		if (min > max) {
			throw Error(StrWrap(funcName, 2) . " — Param <min> is greater than Param <max>")
		}

		return (inclusive ? (_number >= min && _number <= max) : (_number > min && _number < max))
	}


	clamp(_number, min, max) {
		funcName := "Numbers.clamp"

		if (!isNumber(_number)) {
			throw Error(StrWrap(funcName, 2) . " — Param <_number> is not a Number")
		}
		if (!isNumber(min)) {
			throw Error(StrWrap(funcName, 2) . " — Param <min> is not a Number")
		}
		if (!isNumber(max)) {
			throw Error(StrWrap(funcName, 2) . " — Param <max> is not a Number")
		}
		if (min > max) {
			throw Error(StrWrap(funcName, 2) . " — Param <min> is greater than Param <max>")
		}

		return (_number < min ? min : (_number > max ? max : _number))
	}
}


/**
 * Checks if number is within a range
 *
 * @function Numbers.between | NumBetween
 * @param {number} _number
 * @param {number} min
 * @param {number} max
 * @param {boolean} [inclusive=true]
 * @return {boolean}
 */
NumBetween := ObjBindMethod(Numbers, "between")


/**
 * Forces a number to be within a range
 *
 * @function Numbers.clamp | NumClamp
 * @param {number} _number
 * @param {number} min
 * @param {number} max
 * @return {number}
 */
NumClamp := ObjBindMethod(Numbers, "clamp")
