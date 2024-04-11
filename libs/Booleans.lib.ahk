global Booleans := prototype__Booleans()
class prototype__Booleans {
	__New() {
		values := [
			[1, 0],
			["1", "0"],
			["true", "false"],
			["on", "off"],
			["yes", "no"],
			["enabled", "disabled"],
			["active", "deactive"],
			["open", "closed"],
			["up", "down"],
			["in", "out"],
			["high", "low"],
			["positive", "negative"],
			["success", "failure"],
			["pass", "fail"],
			["start", "stop"],
			["good", "bad"]
		]

		this.trueValues := []
		this.falseValues := []

		for ii, val in values {
			this.trueValues.Push(val[1])
			this.falseValues.Push(val[2])
		}
	}



	toString(val, mode := 1) {
		funcName := "Booleans.toString"

		if (!isBoolean(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is not a Boolean")
		}
		if (!isNumber(mode)) {
			throw Error(StrWrap(funcName, 2) . " — Param <mode> is not a Number")
		}
		if (!NumBetween(mode, 1, this.trueValues.Length - 2)) {
			throw Error(StrWrap(funcName, 2) . " — Param <mode> is not in range 1-" . this.trueValues.Length - 2)
		}

		T := this.trueValues.slice(3)
		F := this.falseValues.slice(3)

		return (val ? T[mode] : F[mode])
	}
}



/**
 * Returns a string representation of val
 *
 * @function Booleans.toString
 * @param {boolean} val
 * @param {number} [mode=1] - from 1 to 15
 * @returns {string}
 *
 * modes: 1 = "true | false", 2 = "on | off", 3 = "yes | no",
 * 4 = "enabled | disabled", 5 = "active | deactive", 6 = "open | closed",
 * 7 = "up | down", 8 = "in | out", 9 = "high | low",
 * 10 = "positive | negative", 11 = "success | failure", 12 = "pass | fail",
 * 13 = "start | stop", 14 = "good | bad"
 */
BoolToString := ObjBindMethod(Booleans, "toString")
