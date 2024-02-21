isArray(val) {
	return (Type(val) == "Array")
}



/**
 * @notes AHK internally uses 1 for true and 0 for false instead of a Boolean type
 */
isBoolean(val) {
	return ((Type(val) == "Integer") && (val == 1 || val == 0))
}



/**
 * @notes There is Null type in AHK so we use -1 as an equivalent, however AHK uses an empty string for null
 */
isNull(val) {
	return (val == U_null || val == "")
}



isString(val) {
	return (Type(val) == "String")
}



isMap(val) {
	return (Type(val) == "Map")
}



isMenu(val) {
	return (Type(val) == "Menu")
}



isFunction(val) {
	return (Type(val) == "Func" || Type(val) == "BoundFunc")
}



isTruthy(val) {
	val := StrUpper(val)
	return (val == 1 || val == "1" || val == "T" || val == "TRUE" || val == "ENABLED" || val == "ACTIVE" || val == "ON")
}



isFalsy(val) {
	val := StrUpper(val)
	return (val == 0 || val == "0" || val == -1 || val == "-1" || val == "" || val == "F" || val == "FALSE" || val == "DISABLED" || val == "DEACTIVE" || val == "INACTIVE" || val == "OFF")
}



toBoolean(val) {
	return (isTruthy(val))
}



/**
 * @param {string} val - a comma-delimited string whose content is enclosed in square brackets, else a string that will be split into an array of characters
 * @returns {(array|null)}
 */
toArray(val) {
	if (isString(val)) {
		if ((SubStr(val, 1, 1) == "[") && (SubStr(val, -1) == "]")) {
			val := SubStr(val, 2, -1)
		}
		arr := StrSplit(val, ",")
		loop arr.Length {
			arr[A_Index] := Trim(arr[A_Index])
		}
		return arr
	} else if (isArray(val)) {
		return val
	} else {
		return null
	}
}



/**
 * @param {array} val
 * @param {(string|number)} needle
 * @param {boolean} [caseSensitive:=false]
 * @returns {boolean}
 */
isInArray(val, needle, caseSensitive := false) {
	if (isArray(val)) {
		for ii, item in val {
			if (!caseSensitive) {
				item := StrUpper(item)
				needle := StrUpper(needle)
			}
			if (item == needle) {
				return true
			}
		}
		return false
	} else {
		return false
	}
}



/**
 * @param {array} val
 * @param {string} separator
 * @returns {string}
 */
join(val, separator := ",") {
	if (isArray(val) && (val.Length > 0)) {
		str := ""
		for ii, item in val {
			str .= (item . separator)
		}
		return SubStr(str, 1, -StrLen(separator))
	} else {
		return ""
	}
}



/**
 * @param {array} val
 * @param {number} [startPos:=1]
 * @param {number} [endPos:=-1]
 * @returns {array}
 * @notes pops n items off the array and returns the array
 */
slice(val, startPos := 1, endPos := -1) {
	if (isArray(val)) {
		(startPos < 0 ? startPos := 1 : startPos := startPos)
		(endPos < 0 ? endPos := (val.Length + endPos) : endPos := endPos)
		tempArr := []
		loop val.Length {
			if ((A_Index >= startPos) && (A_Index <= endPos)) {
				tempArr.Push(val[A_Index])
			}
		}
		return tempArr
	} else if (isString(val)) {
		(startPos < 0 ? startPos := 1 : startPos := startPos)
		(endPos < 0 ? endPos := (val.Length + endPos) : endPos := endPos)
		return SubStr(val, startPos, endPos)
	}
	return val
}
