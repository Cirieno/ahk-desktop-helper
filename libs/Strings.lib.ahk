global Strings := prototype__Strings()
class prototype__Strings {
	charAt(_string, index := 1, clamp := false) {
		funcName := "Strings.charAt"

		if !(isString(_string) || isNumber(_string)) {
			throw Error(StrWrap(funcName, 2) . " — Param <_string> is not a String or Number")
		}
		if (!isNumber(index)) {
			throw Error(StrWrap(funcName, 2) . " — Param <index> is not a Number")
		}
		if (!isBoolean(clamp)) {
			throw Error(StrWrap(funcName, 2) . " — Param <clamp> is not a Boolean")
		}
		if (isEmpty(_string)) {
			return null
		}

		_string := StrSplit(String(_string))

		index := (index < 0 ? (_string.length + index + 1) : index)
		index := (clamp ? NumClamp(index, 1, _string.length) : index)

		if (index < 1) {
			throw Error(StrWrap(funcName, 2) . " — Target index cannot be less than 1")
		}
		if (index > _string.length) {
			throw Error(StrWrap(funcName, 2) . " — Target index exceeds the length of the string")
		}

		return _string[index]
	}



	getCharFirst(_string) {
		funcName := "Strings.getCharFirst"

		if !(isString(_string) || isNumber(_string)) {
			throw Error(StrWrap(funcName, 2) . " — Param <_string> is not a String or Number")
		}
		if (isEmpty(_string)) {
			return null
		}

		return SubStr(_string, 1, 1)
	}



	getCharLast(_string) {
		funcName := "Strings.getCharLast"

		if !(isString(_string) || isNumber(_string)) {
			throw Error(StrWrap(funcName, 2) . " — Param <_string> is not a String or Number")
		}
		if (isEmpty(_string)) {
			return null
		}

		return SubStr(_string, -1, 1)
	}



	includes(_string, needle, caseSense := false, indexStart := 1, clamp := false) {
		funcName := "Strings.includes"

		if !(isString(_string) || isNumber(_string)) {
			throw Error(StrWrap(funcName, 2) . " — Param <_string> is not a String or Number")
		}
		if !(isString(needle) || isNumber(needle)) {
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
		if (isEmpty(_string) || isEmpty(needle)) {
			return false
		}

		indexStart := (indexStart < 0 ? (StrLen(_string) + indexStart + 1) : indexStart)
		indexStart := (clamp ? NumClamp(indexStart, 1, StrLen(_string)) : indexStart)

		if (indexStart < 1) {
			throw Error(StrWrap(funcName, 2) . " — Target index cannot be less than 1")
		}
		if (indexStart > StrLen(_string)) {
			throw Error(StrWrap(funcName, 2) . " — Target index exceeds the length of the string")
		}

		return (InStr(_string, needle, caseSense, indexStart) > 0)
	}



	padLeft(_string, length := 1, strStart := " ") {
		funcName := "Strings.padLeft"

		if !(isString(_string) || isNumber(_string)) {
			throw Error(StrWrap(funcName, 2) . " — Param <_string> is not a String or Number")
		}
		if (!isNumber(length)) {
			throw Error(StrWrap(funcName, 2) . " — Param <length> is not a Number")
		}
		if !(isString(strStart) || isNumber(strStart)) {
			throw Error(StrWrap(funcName, 2) . " — Param <strStart> is not a String or Number")
		}
		if (length <= StrLen(_string)) {
			return _string
		}

		_string := String(_string)
		strStart := String(strStart)

		pad := SubStr(StrRepeat(strStart, length), 1, length - StrLen(_string))

		return pad . _string
	}



	padRight(_string, length := 1, strEnd := " ") {
		funcName := "Strings.padRight"

		if !(isString(_string) || isNumber(_string)) {
			throw Error(StrWrap(funcName, 2) . " — Param <_string> is not a String or Number")
		}
		if (!isNumber(length)) {
			throw Error(StrWrap(funcName, 2) . " — Param <length> is not a Number")
		}
		if !(isString(strEnd) || isNumber(strEnd)) {
			throw Error(StrWrap(funcName, 2) . " — Param <strEnd> is not a String or Number")
		}
		if (length <= StrLen(_string)) {
			return String(_string)
		}

		_string := String(_string)
		strEnd := String(strEnd)

		pad := SubStr(StrRepeat(strEnd, length), 1, length - StrLen(_string))

		return _string . pad
	}



	repeat(_string, count := 1) {
		funcName := "Strings.repeat"

		if !(isString(_string) || isNumber(_string)) {
			throw Error(StrWrap(funcName, 2) . " — Param <_string> is not a String or Number")
		}
		if (!isNumber(count)) {
			throw Error(StrWrap(funcName, 2) . " — Param <count> is not a Number")
		}

		_string := String(_string)

		str := ""
		loop count {
			str .= _string
		}

		return str
	}



	slice(_string, indexStart := 1, indexEnd?, clamp := false) {
		funcName := "Strings.slice"

		indexEnd := (indexEnd ?? StrLen(_string))

		if !(isString(_string) || isNumber(_string)) {
			throw Error(StrWrap(funcName, 2) . " — Param <_string> is not a String or Number")
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

		_string := StrSplit(String(_string))

		indexStart := (indexStart < 0 ? (_string.length + indexStart + 1) : indexStart)
		indexStart := (clamp ? NumClamp(indexStart, 1, _string.length) : indexStart)

		indexEnd := (indexEnd < 0 ? (_string.length + indexEnd) : indexEnd)
		indexEnd := (clamp ? NumClamp(indexEnd, 1, _string.length) : indexEnd)

		if (indexStart < 1) {
			throw Error(StrWrap(funcName, 2) . " — Target index <start> cannot be less than 1")
		}
		if (indexStart > _string.length) {
			throw Error(StrWrap(funcName, 2) . " — Target index <start> exceeds the length of the array")
		}
		if (indexEnd < 1) {
			throw Error(StrWrap(funcName, 2) . " — Target index <end> cannot be less than 1")
		}
		if (indexEnd > _string.length) {
			throw Error(StrWrap(funcName, 2) . " — Target index <end> exceeds the length of the array")
		}
		if (indexStart > indexEnd) {
			throw Error(StrWrap(funcName, 2) . " — Target index <start> cannot be greater than target index <end>")
		}

		arr := [], i := indexStart
		while (i <= indexEnd) {
			if (_string.has(i)) {
				arr.push(_string.get(i))
			}
			i++
		}

		return ArrJoin(arr)
	}



	; unwrap(val, strStart := "", strEnd?) {
	; 	funcName := "Strings.unwrap"

	; 	if !(isString(val) || isNumber(val)) {
	; 		throw Error(StrWrap(funcName, 2) . " — Param <val> is not a String or Number")
	; 	}
	; 	; if !(isString(val) || isNumber(val)) {
	; 	; 	throw Error(StrWrap(funcName, 2) . " — Param <strStart> is not a String or Number")
	; 	; }
	; 	; if (IsSet(strEnd) && !(isString(val) || isNumber(val))) {
	; 	; 	throw Error(StrWrap(funcName, 2) . " — Param <strEnd> is not a String or Number")
	; 	; }
	; 	; strStart := (isNull(strStart) ? "" : strStart)
	; 	; strEnd := (strEnd ?? strStart)
	; 	; strEnd := (isNull(strEnd) ? "" : strEnd)

	; 	; return StrSlice(val, StrLen(strStart) + 1, -StrLen(strEnd))
	; }
	;// TODO



	wrap(_string, mode := 0, strStart := "", strEnd?) {
		funcName := "Strings.wrap"

		if !(isString(_string) || isNumber(_string)) {
			throw Error("[" . funcName . "] — Param <_string> is not a String or Number")
		}
		if (!isNumber(mode)) {
			throw Error("[" . funcName . "] — Param <mode> is not a Number")
		}
		if (!NumBetween(mode, 0, 9)) {
			throw Error("[" . funcName . "] — Param <mode> is not in range 0-9")
		}
		if !(isString(_string) || isNumber(_string)) {
			throw Error("[" . funcName . "] — Param <strStart> is not a String or Number")
		}
		if (IsSet(strEnd) && !(isString(_string) || isNumber(_string))) {
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
					strStart := Chr(34), strEnd := Chr(34)
				case 6:
					strStart := Chr(39), strEnd := Chr(39)
				case 7:
					strStart := Chr(96), strEnd := Chr(96)
				case 8:
					strStart := Chr(8216), strEnd := Chr(8217)
				case 9:
					strStart := Chr(8220), strEnd := Chr(8221)
			}
		}

		return strStart . String(_string) . strEnd
	}
}



/**
 * Returns the character at the specified position in a string
 *
 * @function Strings.charAt | StrCharAt
 * @param {(string|number)} _string
 * @param {number} [index=1] - positive numbers from left, negative numbers from right
 * @param {boolean} [clamp=false] - fix index to between 1 and _string.length
 * @returns {(string|null)}
 */
StrCharAt := ObjBindMethod(Strings, "charAt")



/**
 * Returns the first character in a string
 *
 * @function Strings.getCharFirst | StrCharFirst
 * @param {(string|number)} _string
 * @returns {(string|null)}
 */
StrCharFirst := ObjBindMethod(Strings, "getCharFirst")



/**
 * Returns the last character in a string
 *
 * @function Strings.getCharLast | StrCharLast
 * @param {(string|number)} _string
 * @returns {(string|null)}
 */
StrCharLast := ObjBindMethod(Strings, "getCharLast")



/**
 * Checks if a string contains a given value
 *
 * @function Strings.includes | StrIncludes
 * @param {(string|number)} _string
 * @param {(string|number)} needle
 * @param {boolean} [caseSense=false]
 * @param {number} [indexStart=1] - positive numbers from left, negative numbers from right
 * @param {boolean} [clamp=false] - fix index to between 1 and _string.length
 * @returns {boolean}
 */
StrIncludes := ObjBindMethod(Strings, "includes")



/**
 * Pads a string on the left side with the specified character(s)
 *
 * @function Strings.padLeft | StrPadLeft
 * @param {(string|number)} _string
 * @param {number} [length=1]
 * @param {(string|number)} [strStart=" "]
 * @returns {string}
 */
StrPadLeft := ObjBindMethod(Strings, "padLeft")



/**
 * Pads a string on the right side with the specified character(s)
 *
 * @function Strings.padRight | StrPadRight
 * @param {(string|number)} _string
 * @param {number} [length=1]
 * @param {(string|number)} [strStart=" "]
 * @returns {string}
 */
StrPadRight := ObjBindMethod(Strings, "padRight")



/**
 * Repeats a string a specified number of times
 *
 * @function Strings.repeat | StrRepeat
 * @param {(string|number)} _string
 * @param {number} [count=1]
 * @returns {string}
 */
StrRepeat := ObjBindMethod(Strings, "repeat")



/**
 * Returns a section of a string
 *
 * @function Strings.slice | StrSlice
 * @param {(string|number)} _string
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
 * @param {(string|number)} _string
 * @param {number} [mode=null]
 * @param {(string|number)} [strStart=""]
 * @param {(string|number)} [strEnd=strStart]
 * @returns {string}
 *
 * modes: 1 = parentheses, 2 = square-brackets, 3 = braces,
 * 4 = angle-brackets, 5 = double-quotes, 6 = single-quotes,
 * 7 = backticks, 8 = single-curly-quotes, 9 = double-curly-quotes
 */
StrWrap := ObjBindMethod(Strings, "wrap")
