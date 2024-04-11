global Numbers := prototype__Numbers()
class prototype__Numbers {
	between(val, min, max, inclusive := true, clamp := false) {
		funcName := "Numbers.between"

		if (!isNumber(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is not a Number")
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

		return (inclusive ? (val >= min && val <= max) : (val > min && val < max))
	}



	clamp(val, min, max) {
		funcName := "Numbers.clamp"

		if (!isNumber(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is not a Number")
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

		return (val < min ? min : (val > max ? max : val))
	}
}



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
NumBetween := ObjBindMethod(Numbers, "between")



/**
 * Forces a number to be within a range
 *
 * @function Numbers.clamp | NumClamp
 * @param {number} val
 * @param {number} min
 * @param {number} max
 * @return {number}
 */
NumClamp := ObjBindMethod(Numbers, "clamp")
