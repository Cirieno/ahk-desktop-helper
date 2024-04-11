global Strings := prototype__Strings()
class prototype__Strings {
	charAt(val, index := 1, clamp := false) {
		funcName := "Strings.charAt"

		if !(isString(val) || isNumber(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is not a String or Number")
		}
		if (!isNumber(index)) {
			throw Error(StrWrap(funcName, 2) . " — Param <index> is not a Number")
		}
		if (!isBoolean(clamp)) {
			throw Error(StrWrap(funcName, 2) . " — Param <clamp> is not a Boolean")
		}
		if (isEmpty(val)) {
			return null
		}

		val := StrSplit(String(val))

		index := (index < 0 ? (val.length + index + 1) : index)
		(clamp ? index := NumClamp(index, 1, val.length) : ignore)

		if (index < 1) {
			throw Error(StrWrap(funcName, 2) . " target index cannot be less than 1")
		}
		if (index > val.length) {
			throw Error(StrWrap(funcName, 2) . " target index exceeds the length of the array")
		}

		return val[index]
	}



	includes(val, needle, caseSense := false, indexStart := 1, clamp := false) {
		funcName := "Strings.includes"

		if (!isString(val) || isNumber(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is not a String or Number")
		}
		if (!isString(needle) || isNumber(needle)) {
			throw Error(StrWrap(funcName, 2) . " — Param <needle> is not a String or Number")
		}
		if (!isBoolean(caseSense)) {
			throw Error(StrWrap(funcName, 2) . " — Param <caseSense> is not a Boolean")
		}
		if (!isNumber(indexStart)) {
			throw Error(StrWrap(funcName, 2) . " — Param <indexStart> is not a Number")
		}
		if (!isBoolean(clamp)) {
			throw Error(StrWrap(funcName, 2) . " — Param <clamp> is not a Boolean")
		}
		if (isEmpty(val)) {
			return false
		}
		if (isEmpty(needle)) {
			throw Error(StrWrap(funcName, 2) . " — Param <needle> cannot be empty")
		}

		indexStart := (indexStart < 0 ? (StrLen(val) + indexStart + 1) : indexStart)
		indexStart := (clamp ? NumClamp(indexStart, 1, StrLen(val)) : indexStart)

		if (indexStart < 1) {
			throw Error(StrWrap(funcName, 2) . " — Target index cannot be less than 1")
		}
		if (indexStart > StrLen(val)) {
			throw Error(StrWrap(funcName, 2) . " — Target index exceeds the length of the array")
		}

		return (InStr(val, needle, caseSense, indexStart) > 0)
	}



	padLeft(val, length := 1, strStart := " ") {
		funcName := "Strings.padLeft"

		if !(isString(val) || isNumber(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is not a String or Number")
		}
		if (!isNumber(length)) {
			throw Error(StrWrap(funcName, 2) . " — Param <length> is not a Number")
		}
		if !(isString(strStart) || isNumber(strStart)) {
			throw Error(StrWrap(funcName, 2) . " — Param <strStart> is not a String or Number")
		}

		if (length <= StrLen(val)) {
			return String(val)
		}

		val := String(val)
		strStart := String(strStart)

		pad := SubStr(StrRepeat(strStart, length), 1, length - StrLen(val))

		return (pad . val)
	}



	padRight(val, length := 1, strEnd := " ") {
		funcName := "Strings.padRight"

		if !(isString(val) || isNumber(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is not a String or Number")
		}
		if (!isNumber(length)) {
			throw Error(StrWrap(funcName, 2) . " — Param <length> is not a Number")
		}
		if !(isString(strEnd) || isNumber(strEnd)) {
			throw Error(StrWrap(funcName, 2) . " — Param <strEnd> is not a String or Number")
		}

		if (length <= StrLen(val)) {
			return String(val)
		}

		val := String(val)
		strEnd := String(strEnd)

		pad := SubStr(StrRepeat(strEnd, length), 1, length - StrLen(val))

		return (val . pad)
	}



	repeat(val, count := 1) {
		funcName := "Strings.repeat"

		if !(isString(val) || isNumber(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is not a String or Number")
		}
		if (!isNumber(count)) {
			throw Error(StrWrap(funcName, 2) . " — Param <count> is not a Number")
		}

		val := String(val)

		str := ""
		loop count {
			str .= val
		}

		return str
	}



	slice(val, indexStart := 1, indexEnd?, clamp := false) {
		funcName := "Strings.slice"

		indexEnd := (indexEnd ?? StrLen(val))

		if !(isString(val) || isNumber(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is not a String or Number")
		}
		if (!isNumber(indexStart)) {
			throw Error(StrWrap(funcName, 2) . " — Param <indexStart> is not a Number")
		}
		if (IsSet(indexEnd) && !isNumber(indexEnd)) {
			throw Error(StrWrap(funcName, 2) . " — Param <indexEnd> is not a Number")
		}
		if (!isBoolean(clamp)) {
			throw Error(StrWrap(funcName, 2) . " — Param <clamp> is not a Boolean")
		}

		val := StrSplit(String(val))

		indexStart := (indexStart < 0 ? (val.length + indexStart + 1) : indexStart)
		indexStart := (clamp ? NumClamp(indexStart, 1, val.length) : indexStart)

		indexEnd := (indexEnd < 0 ? (val.length + indexEnd) : indexEnd)
		indexEnd := (clamp ? NumClamp(indexEnd, 1, val.length) : indexEnd)

		if (indexStart < 1) {
			throw Error(StrWrap(funcName, 2) . " — Target index <start> cannot be less than 1")
		}
		if (indexStart > val.length) {
			throw Error(StrWrap(funcName, 2) . " — Target index <start> exceeds the length of the array")
		}
		if (indexEnd < 1) {
			throw Error(StrWrap(funcName, 2) . " — Target index <end> cannot be less than 1")
		}
		if (indexEnd > val.length) {
			throw Error(StrWrap(funcName, 2) . " — Target index <end> exceeds the length of the array")
		}
		if (indexStart > indexEnd) {
			throw Error(StrWrap(funcName, 2) . " — Target index <start> cannot be greater than target index <end>")
		}

		arr := [], ii := indexStart
		while (ii <= indexEnd) {
			if (val.has(ii)) {
				arr.push(val.get(ii))
			}
			ii++
		}

		return ArrJoin(arr)
	}



	wrap(val, mode := 0, strStart := "", strEnd?) {
		funcName := "Strings.wrap"

		if !(isString(val) || isNumber(val)) {
			throw Error("[" . funcName . "] — Param <val> is not a String or Number")
		}
		if (!isNumber(mode)) {
			throw Error("[" . funcName . "] — Param <mode> is not a Number")
		}
		if (!NumBetween(mode, 0, 7)) {
			throw Error("[" . funcName . "] — Param <mode> is not in range 0-7")
		}
		if !(isString(val) || isNumber(val)) {
			throw Error("[" . funcName . "] — Param <strStart> is not a String or Number")
		}
		if (IsSet(strEnd) && !(isString(val) || isNumber(val))) {
			throw Error("[" . funcName . "] — Param <strEnd> is not a String or Number")
		}
		strStart := (isNull(strStart) ? "" : strStart)
		strEnd := (strEnd ?? strStart)
		strEnd := (isNull(strEnd) ? "" : strEnd)

		if (isEmpty(strStart) && isEmpty(strEnd)) {
			switch (mode) {
				case 1:
					strStart := "(", strEnd := ")"
				case 2:
					strStart := "[", strEnd := "]"
				case 3:
					strStart := "{", strEnd := "}"
				case 4:
					strStart := "<", strEnd := ">"
				case 5:
					strStart := "`"", strEnd := "`""
				case 6:
					strStart := "'", strEnd := "'"
				case 7:
					strStart := "``", strEnd := "``"
			}
		}

		return (strStart . String(val) . strEnd)
	}
}



/**
 * Returns the character at the specified position in a string
 *
 * @function Strings.charAt | StrCharAt
 * @param {(string|number)} val
 * @param {number} [index=1] - positive numbers from left, negative numbers from right
 * @param {boolean} [clamp=false] - fix index to between 1 and StrLen(val)
 * @returns {(string|null)}
 */
StrCharAt := ObjBindMethod(Strings, "charAt")



/**
 * Checks if a string contains a given value
 *
 * @function Strings.includes | StrIncludes
 * @param {(string|number)} val
 * @param {(string|number)} needle
 * @param {boolean} [caseSense=false]
 * @param {number} [indexStart=1] - positive numbers from left, negative numbers from right
 * @param {boolean} [clamp=false] - fix index to between 1 and StrLen(val)
 * @returns {boolean}
 */
StrIncludes := ObjBindMethod(Strings, "includes")



/**
 * Pads a string on the left side
 *
 * @function Strings.padLeft | StrPadLeft
 * @param {(string|number)} val
 * @param {number} [length=1]
 * @param {(string|number)} [strStart=" "]
 * @returns {string}
 */
StrPadLeft := ObjBindMethod(Strings, "padLeft")



/**
 * Pads a string on the right side
 *
 * @function Strings.padRight | StrPadRight
 * @param {(string|number)} val
 * @param {number} [length=1]
 * @param {(string|number)} [strStart=" "]
 * @returns {string}
 */
StrPadRight := ObjBindMethod(Strings, "padRight")



/**
 * Repeats a string a specified number of times
 *
 * @function Strings.repeat | StrRepeat
 * @param {(string|number)} val
 * @param {number} [count=1]
 * @returns {string}
 */
StrRepeat := ObjBindMethod(Strings, "repeat")



/**
 * Returns a section of a string
 *
 * @function Strings.slice | StrSlice
 * @param {(string|number)} val
 * @param {number} [indexStart=1] - positive numbers from left, negative numbers from right
 * @param {number} [indexEnd=val.length] - positive numbers from left, negative numbers from right
 * @param {boolean} [clamp=false] - fix index to between 1 and val.length
 * @returns {string}
 */
StrSlice := ObjBindMethod(Strings, "slice")



/**
 * Wraps a string in the specified characters
 *
 * @function Strings.wrap | StrWrap
 * @param {(string|number)} val
 * @param {number} [mode=null]
 * @param {(string|number)} [strStart=""]
 * @param {(string|number)} [strEnd=strStart]
 * @returns {string}
 *
 * modes: 1 = parentheses, 2 = square-brackets, 3 = braces,
 * 4 = angle-brackets, 5 = double-quotes, 6 = single-quotes,
 * 7 = backticks
 */
StrWrap := ObjBindMethod(Strings, "wrap")
