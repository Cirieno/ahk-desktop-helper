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



;------------------------------------------------
; Constants
;------------------------------------------------
U_ellipsis := "…"
ignore := U_ignore := -1    ; a trinary counterpart to true(1) and false(0)



U_msSecond := 1000
U_msMinute := 60000
U_msHour := 3600000
U_msDay := 86400000



; in the style of VBScript constants
; https://ss64.com/vb/syntax-constants.html
U_null := null := Chr(0)
U_empty := ""
U_integer := 2
U_long := 3
U_single := 4
U_double := 5
U_date := 7
U_string := 8
U_object := 9
U_error := 10
U_boolean := 11
U_decimal := 14
U_byte := 17
U_hex := 18
U_array := 8192



GroupAdd("explorerWindows", "ahk_exe explorer.exe")
GroupAdd("explorerWindows", "ahk_class CabinetWClass")
GroupAdd("explorerWindows", "ahk_class ExploreWClass")
GroupAdd("explorerWindows", "ahk_class Progman")
GroupAdd("explorerWindows", "ahk_class WorkerW")
GroupAdd("explorerWindows", "ahk_class #32770")



; windows decoration styles
WS_BORDER := 0x00800000
WS_CAPTION := 0x00C00000
WS_CHILD := 0x40000000
WS_CHILDWINDOW := 0x40000000
WS_CLIPCHILDREN := 0x02000000
WS_CLIPSIBLINGS := 0x04000000
WS_DISABLED := 0x08000000
WS_DLGFRAME := 0x00400000
WS_GROUP := 0x00020000
WS_HSCROLL := 0x00100000
WS_ICONIC := 0x20000000
WS_MAXIMIZE := 0x01000000
WS_MAXIMIZEBOX := 0x00010000
WS_MINIMIZE := 0x20000000
WS_MINIMIZEBOX := 0x00020000
WS_OVERLAPPED := 0x00000000
WS_POPUP := 0x80000000
WS_SIZEBOX := 0x00040000
WS_SYSMENU := 0x00080000
WS_TABSTOP := 0x00010000
WS_THICKFRAME := 0x00040000
WS_TILED := 0x00000000
WS_VISIBLE := 0x10000000
WS_VSCROLL := 0x00200000
WS_EX_ACCEPTFILES := 0x00000010
WS_EX_APPWINDOW := 0x00040000
WS_EX_CLIENTEDGE := 0x00000200
WS_EX_COMPOSITED := 0x02000000
WS_EX_CONTEXTHELP := 0x00000400
WS_EX_CONTROLPARENT := 0x00010000
WS_EX_DLGMODALFRAME := 0x00000001
WS_EX_LAYERED := 0x00080000
WS_EX_LAYOUTRTL := 0x00400000
WS_EX_LEFT := 0x00000000
WS_EX_LEFTSCROLLBAR := 0x00004000
WS_EX_LTRREADING := 0x00000000
WS_EX_MDICHILD := 0x00000040
WS_EX_NOACTIVATE := 0x08000000
WS_EX_NOINHERITLAYOUT := 0x00100000
WS_EX_NOPARENTNOTIFY := 0x00000004
WS_EX_NOREDIRECTIONBITMAP := 0x00200000
WS_EX_RIGHT := 0x00001000
WS_EX_RIGHTSCROLLBAR := 0x00000000
WS_EX_RTLREADING := 0x00002000
WS_EX_STATICEDGE := 0x00020000
WS_EX_TOOLWINDOW := 0x00000080
WS_EX_TOPMOST := 0x00000008
WS_EX_TRANSPARENT := 0x00000020
WS_EX_WINDOWEDGE := 0x00000100



SM_CXSCREEN := 0
SM_CYSCREEN := 1
SM_CYCAPTION := 4
SM_CXFULLSCREEN := 16
SM_CYFULLSCREEN := 17
SM_MOUSEPRESENT := 19
SM_SWAPBUTTON := 23
SM_CXSIZEFRAME := 32
SM_CXMAXIMIZED := 61
SM_CYMAXIMIZED := 62
SM_NETWORK := 63
SM_MOUSEWHEELPRESENT := 75



GA_PARENT := 1



; Strings.wrap modes
SW_PARENTHESES := 1
SW_SQUARE_BRACKETS := 2
SW_BRACES := 3
SW_ANGLE_BRACKETS := 4
SW_DOUBLE_QUOTES := 5
SW_SINGLE_QUOTES := 6
SW_BACKTICKS := 7


; Boolean.toString modes
BTS_TRUE_FALSE := 2
BTS_ON_OFF := 3
BTS_YES_NO := 4
BTS_ENABLED_DISABLED := 5
BTS_ACTIVE_DEACTIVE := 6
BTS_OPEN_CLOSED := 7
BTS_UP_DOWN := 8
BTS_IN_OUT := 9
BTS_HIGH_LOW := 10
BTS_POSITIVE_NEGATIVE := 11
BTS_SUCCESS_FAILURE := 12
BTS_PASS_FAIL := 13
BTS_START_STOP := 14
BTS_GOOD_BAD := 15
