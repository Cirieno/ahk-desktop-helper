/**********************************************************
 * @type {AHKLibrary}
 * @name VarTypes Utils
 * @author Rob McInnes (Cirieno)
 * @file vartypes.lib.ahk
 *********************************************************/


#Include ".\constants.lib.ahk"
#Include ".\Arrays.lib.ahk"
#Include ".\Booleans.lib.ahk"
#Include ".\Numbers.lib.ahk"
#Include ".\Strings.lib.ahk"


/**
 * @param {any} val
 * @returns {boolean}
 */
isArray(val) {
	return (IsSet(val) && (Type(val) == "Array"))
}


/**
 * @param {any} val
 * @returns {boolean}
 *
 * AHK uses Integer[1|0] instead of having a native Boolean type;
 * it also coerces strings to numbers internally, which we need to avoid
 */
isBoolean(val) {
	return (IsSet(val) && (val is Number) && (val == 0 || val == 1))
}


/**
 * @param {any} val
 * @returns {boolean}
 *
 * includes checking for null
 */
isEmpty(val) {
	if (!IsSet(val)) {
		return true
	}
	if (isArray(val)) {
		return (val.length == 0)
	}
	if (isBoolean(val)) {
		return false
	}
	if (isFunction(val)) {
		return false
	}
	if (isMap(val)) {
		return (val.count == 0)
	}
	if (isMenu(val)) {
		; TODO: count number of items (ownprop array added by dev)?
		return false
	}
	if (isNull(val)) {
		return true
	}
	if (isNumber(val)) {
		return false
	}
	if (IsObject(val)) {
		return (ObjOwnPropCount(val) == 0)
	}
	if (isString(val)) {
		return (val == "")
	}
	return true
}


/**
 * @param {any} val
 * @returns {boolean}
 */
isFunction(val) {
	if (Type(val) == "Func" || Type(val) == "BoundFunc" || Type(val) == "Closure" || Type(val) == "Enumerator") {
		return true
	}
	return false
}


/**
 * @param {any} val
 * @returns {boolean}
 */
isIgnore(val) {
	return (IsSet(val) && ((val == ignore) || val == "ignore"))
}


/**
 * @param {any} val
 * @returns {boolean}
 */
isMap(val) {
	return (IsSet(val) && (Type(val) == "Map"))
}


/**
 * @param {any} val
 * @returns {boolean}
 */
isMenu(val) {
	return (IsSet(val) && (Type(val) == "Menu"))
}


/**
 * @param {any} val
 * @returns {boolean}
 *
 * There is no Null type in AHK so we use Chr(0) as a substitute
 */
isNull(val) {
	return (IsSet(val) && (Type(val) == "String") && (val == Chr(0)))
}


/**
 * @param {any} val
 * @returns {boolean}
 *
 * This function overrides the built-in isNumber() which is not reliable due to AHK's string-to-number type coercion
 */
isNumber(val) {
	return (IsSet(val) && (val is Number))
}


/**
 * @param {any} val
 * @returns {boolean}
 *
 * We use Chr(0), which is a string, as a substitute for Null in AHK so we need to check for that
 */
isString(val) {
	return (IsSet(val) && (Type(val) == "String") && !isNull(val))
}


/**
 * @param {any} val
 * @returns {boolean}
 */
isStringable(val) {
	return (IsSet(val) && (val is String || val is Number) && !isNull(val))
}


/**
 * @param {any} val
 * @param {boolean} [force=false] - return null instead of throwing an error
 * @returns {(boolean|null)}
 */
toBoolean(val, force := false) {
	funcName := "toBoolean"

	if (!isBoolean(force)) {
		throw Error(StrWrap(funcName, 2) . " param <force> is not a Boolean")
	}
	if !(isString(val) || isNumber(val)) {
		throw Error(StrWrap(funcName, 2) . " param <val> is not coerceable to a Boolean")
	}

	if (isBoolean(val)) {
		return val
	}

	if (isEmpty(val)) {
		return false
	}

	T := Booleans.trueValues
	F := Booleans.falseValues

	if (T.includes(val)) {
		return true
	} else if (F.includes(val)) {
		return false
	}

	return (!force ? null : false)
}


/**
 * @param {any} val
 * @param {boolean} [debug=false] - tokenize non-stringable elements
 * @returns {string}
 */
toString(val, debug := false) {
	funcName := "toString"

	if (!isBoolean(debug)) {
		throw Error(StrWrap(funcName, 2) . " param <debug> is not a Boolean")
	}

	if (!IsSet(val)) {
		return (!debug ? "" : "<Unset>")
	}
	if (isArray(val)) {
		return ArrJoin(val, ",", debug)
	}
	if (isBoolean(val)) {
		return Booleans.toString(val)
	}
	if (isFunction(val) || isMap(val) || isMenu(val) || IsObject(val)) {
		return (!debug ? "" : "<" . Type(val) . ">")
	}
	if (isNull(val)) {
		return (!debug ? "" : "<Null>")
	}
	if (isNumber(val)) {
		return String(val)
	}
	if (isString(val)) {
		return val
	}

	return ""
}


/**
 * @param {any} val1
 * @param {any} val2
 * @param {boolean} [caseSense=false]
 * @returns {(boolean)}
 */
typeCompare(val1, val2, caseSense := false) {
	if !(IsSet(val1) && IsSet(val2)) {
		return false
	}
	if (isArray(val1) && isArray(val2)) {
		return true
	}
	if (isBoolean(val1) && isBoolean(val2)) {
		return true
	}
	if (isFunction(val1) && isFunction(val2)) {
		return true
	}
	if (isMap(val1) && isMap(val2)) {
		return true
	}
	if (isMenu(val1) && isMenu(val2)) {
		return true
	}
	if (isNull(val1) && isNull(val2)) {
		return true
	}
	if (isNumber(val1) && isNumber(val2)) {
		return true
	}
	if (IsObject(val1) && IsObject(val2)) {
		return true
	}
	if (isString(val1) && isString(val2)) {
		return (!caseSense ? val1 = val2 : val1 == val2)
	}
}
