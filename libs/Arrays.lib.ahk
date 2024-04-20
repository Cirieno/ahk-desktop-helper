global Arrays := prototype__Arrays()
class prototype__Arrays extends Array {
	at(val?, index?, clamp?) {
		funcName := "Arrays.at"

		if (isArray(this) && IsSet(val) && isArray(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is redundant when called on an instance")
		}

		params := [[&val, &this], [&index, 1], [&clamp, false]]
		Arrays.__fixParams(&params)

		if (!isArray(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is not an Array")
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

		index := (index < 0 ? (val.length + index + 1) : index)
		(clamp ? index := NumClamp(index, 1, val.length) : ignore)

		if (index < 1) {
			throw Error(StrWrap(funcName, 2) . " — Target index cannot be less than 1")
		}
		if (index > val.length) {
			throw Error(StrWrap(funcName, 2) . " — Target index exceeds the length of the array")
		}

		return val.get(index, null)
	}



	concat(vals*) {
		funcName := "Arrays.concat"

		params := [[&val, &this], [&vals, vals]]
		Arrays.__fixParams(&params)

		arr := (isArray(this) ? this : [])

		for (i, val in vals) {
			if (!isArray(val)) {
				throw Error(StrWrap(funcName, 2) . " — Param <vals[" . i . "]> is not an Array")
			}
			arr.push(val*)
		}

		return arr
	}



	from(val?, mode?) {
		funcName := "Arrays.from"

		if (isArray(this) && IsSet(val) && isArray(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is redundant when called on an instance")
		}

		params := [[&val, &this], [&mode, 3]]
		Arrays.__fixParams(&params)

		if !(isString(val) || isNumber(val) || isMap(val) || IsObject(val) || isArray(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is not a String, Number, Map, Object, or Array")
		}
		if (!isNumber(mode)) {
			throw Error(StrWrap(funcName, 2) . " — Param <mode> is not a Number")
		}
		if (!NumBetween(mode, 1, 3)) {
			throw Error(StrWrap(funcName, 2) . " — Param <mode> is not in range 1-3")
		}
		if (isEmpty(val)) {
			return []
		}

		switch (mode) {
			case 1:
				mode := "values"
			case 2:
				mode := "keys"
			case 3:
				mode := "both"
		}

		arr := []
		switch (Type(val)) {
			case "Map", "Object":
				(Type(val) == "Map" ? scanVal(val) : scanVal(val.OwnProps()))
				scanVal(props) {
					for (key, val in props) {
						try {
							switch (mode) {
								case "values":
									arr.push(val)
								case "keys":
									arr.push(key)
								case "both":
									arr.push([key, val])
							}
						} catch Error as e {
							arr.push(null)
						}
					}
				}
				return arr
			case "String", "Integer", "Float":
				val := String(val)
				if (SubStr(val, 1, 1) == "[" && SubStr(val, -1, 1) == "]") {
					arr := StrSplit(SubStr(val, 2, -1), ",")
					for (i, el in arr) {
						arr[i] := Trim(el)
					}
					return arr
				}
			case "Array":
				return val
		}
	}



	includes(val?, needle?, caseSense?, indexStart?, clamp?) {
		funcName := "Arrays.includes"

		if (isArray(this) && IsSet(val) && isArray(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is redundant when called on an instance")
		}

		params := [[&val, &this], [&needle, null], [&caseSense, false], [&indexStart, 1], [&clamp, false]]
		Arrays.__fixParams(&params)

		if (!isArray(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is not an Array")
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
		if (isEmpty(val)) {
			return false
		}
		if (isEmpty(needle)) {
			; throw Error(StrWrap(funcName, 2) . " — Param <needle> cannot be empty")
			return false
		}

		indexStart := (indexStart < 0 ? (val.length + indexStart + 1) : indexStart)
		indexStart := (clamp ? NumClamp(indexStart, 1, val.length) : indexStart)

		if (indexStart < 1) {
			throw Error(StrWrap(funcName, 2) . " — Target index cannot be less than 1")
		}
		if (indexStart > val.length) {
			throw Error(StrWrap(funcName, 2) . " — Target index exceeds the length of the array")
		}

		i := indexStart
		while (i <= val.length) {
			if (val.has(i) && typeCompare(val.get(i, null), needle, caseSense)) {
				return true
			}
			i++
		}

		return false
	}
	; TODO: add support for any type of value



	indexOf(val?, needle?, caseSense?, indexStart?, clamp?) {
		funcName := "Arrays.indexOf"

		if (isArray(this) && IsSet(val) && isArray(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is redundant when called on an instance")
		}

		params := [[&val, &this], [&needle, null], [&caseSense, false], [&indexStart, 1], [&clamp, false]]
		Arrays.__fixParams(&params)

		if (!isArray(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is not an Array")
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
		if (isEmpty(val)) {
			return null
		}
		if (isEmpty(needle)) {
			; throw Error(StrWrap(funcName, 2) . " — Param <needle> cannot be empty")
			return null
		}

		indexStart := (indexStart < 0 ? (val.length + indexStart + 1) : indexStart)
		indexStart := (clamp ? NumClamp(indexStart, 1, val.length) : indexStart)

		if (indexStart < 1) {
			throw Error(StrWrap(funcName, 2) . " — Target index cannot be less than 1")
		}
		if (indexStart > val.length) {
			throw Error(StrWrap(funcName, 2) . " — Target index exceeds the length of the array")
		}

		i := indexStart
		while (i <= val.length) {
			if (val.has(i) && typeCompare(val.get(i, null), needle, caseSense)) {
				return i
			}
			i++
		}

		return null
	}
	; TODO: add support for any type of value



	join(val?, separator?, clean?, debugMode?) {
		funcName := "Arrays.join"

		if (isArray(this) && IsSet(val) && isArray(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is redundant when called on an instance")
		}

		params := [[&val, &this], [&separator, ""], [&clean, false], [&debugMode, 0]]
		Arrays.__fixParams(&params)

		if (!isArray(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is not an Array")
		}
		if (!isString(separator)) {
			throw Error(StrWrap(funcName, 2) . " — Param <separator> is not a String")
		}
		if (!isBoolean(clean)) {
			throw Error(StrWrap(funcName, 2) . " — Param <clean> is not a Boolean")
		}
		if (!isNumber(debugMode)) {
			throw Error(StrWrap(funcName, 2) . " — Param <debugMode> is not a Number")
		}
		if (!NumBetween(debugMode, 0, 2)) {
			throw Error(StrWrap(funcName, 2) . " — Param <debugMode> is not in range 0-2")
		}
		if (isEmpty(val)) {
			return ""
		}

		debug := (debugMode > 0)
		forceBools := (debugMode == 2)

		arr := []
		for (i, el in val) {
			if (!IsSet(el)) {
				arr.push(debug ? "<Unset>" : "")
				continue
			}
			if (isNull(el)) {
				arr.push(debug ? "<Null>" : "")
				continue
			}
			if (isString(el) || isNumber(el) || isBoolean(el)) {
				if (el == "") {
					arr.push(debug ? "<Empty>" : "")
					continue
				}
				if (forceBools && (Integer(el) == 1 || Integer(el) == 0 || Integer(el) == -1)) {
					arr.push(debug ? (el == 1 ? "<True>" : (el == 0 ? "<False>" : "<Ignore>")) : "")
					continue
				} else {
					arr.push(String(el))
					continue
				}
			}
			arr.push(debug ? "<" . Type(el) . ">" : "")
		}

		str := ""
		for (i, el in arr) {
			if (clean && !debug && isEmpty(el)) {
				continue
			}
			str .= el
			if (i < arr.length) {
				str .= separator
			}
		}

		; remove trailing separator
		if (clean && !debug && (SubStr(str, -StrLen(separator), StrLen(separator)) == separator)) {
			str := SubStr(str, 1, -StrLen(separator))
		}

		return str
	}
	; TODO: add optional start and end indexes?



	remove(val?, needle?, caseSense?, indexStart?, clamp?) {
		funcName := "Arrays.remove"

		if (isArray(this) && IsSet(val) && isArray(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is redundant when called on an instance")
		}

		params := [[&val, &this], [&needle, null], [&caseSense, false], [&indexStart, 1], [&clamp, false]]
		Arrays.__fixParams(&params)

		if (!isArray(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is not an Array")
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
		if (isEmpty(val)) {
			return val
		}
		if (isEmpty(needle)) {
			throw Error(StrWrap(funcName, 2) . " — Param <needle> cannot be empty")
		}

		indexStart := (indexStart < 0 ? (val.length + indexStart + 1) : indexStart)
		indexStart := (clamp ? NumClamp(indexStart, 1, val.length) : indexStart)

		if (indexStart < 1) {
			throw Error(StrWrap(funcName, 2) . " — Target index cannot be less than 1")
		}
		if (indexStart > val.length) {
			throw Error(StrWrap(funcName, 2) . " — Target index exceeds the length of the array")
		}

		i := indexStart
		while (i <= val.length) {
			if (val.has(i) && typeCompare(val.get(i, null), needle, caseSense)) {
				val.removeAt(i)
				i--
			}
			i++
		}

		if (isArray(this)) {
			this := val
		}

		return val
	}
	; TODO: add Count parameter to limit occurrences?
	; TODO: add support for any type of value



	reverse(val?) {
		funcName := "Arrays.reverse"

		if (isArray(this) && IsSet(val) && isArray(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is redundant when called on an instance")
		}

		params := [[&val, &this]]
		Arrays.__fixParams(&params)

		if (!isArray(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is not an Array")
		}

		arr := []
		while (val.length > 0) {
			arr.push(val.pop())
		}

		if (isArray(this)) {
			this := arr
		}

		return arr
	}



	shift(val?) {
		funcName := "Arrays.shift"

		if (isArray(this) && IsSet(val) && isArray(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is redundant when called on an instance")
		}

		params := [[&val, &this]]
		Arrays.__fixParams(&params)

		if (!isArray(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is not an Array")
		}

		el := val.removeAt(1)

		if (isArray(this)) {
			this := val
		}

		return el
	}



	slice(val?, indexStart?, indexEnd?, clamp?) {
		funcName := "Arrays.slice"

		if (isArray(this) && IsSet(val) && isArray(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is redundant when called on an instance")
		}

		params := [[&val, &this], [&indexStart, 1], [&indexEnd, null], [&clamp, false]]
		Arrays.__fixParams(&params)

		indexEnd := (isNull(indexEnd) ? val.length : indexEnd)

		if (!isArray(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is not an Array")
		}
		if (!isNumber(indexStart)) {
			throw Error(StrWrap(funcName, 2) . " — Param <indexStart> is not a Number")
		}
		if (IsSet(indexEnd) && (!isNumber(indexEnd))) {
			throw Error(StrWrap(funcName, 2) . " — Param <indexEnd> is not a Number")
		}
		if (!isBoolean(clamp)) {
			throw Error(StrWrap(funcName, 2) . " — Param <clamp> is not a Boolean")
		}

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

		arr := [], i := indexStart
		while (i <= indexEnd) {
			if (val.has(i)) {
				arr.push(val.get(i))
			}
			i++
		}

		return arr
	}



	toMap(val?) {
		funcName := "Arrays.toMap"

		if (isArray(this) && IsSet(val) && isArray(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is redundant when called on an instance")
		}

		params := [[&val, &this]]
		Arrays.__fixParams(&params)

		if (!isArray(val)) {
			throw Error(StrWrap(funcName, 2) . " — Param <val> is not an Array")
		}

		local map_ := Map()
		for (i, el in val) {
			if (!IsSet(el) || isEmpty(el)) {
				continue
			}

			if (isStringable(el)) {
				map_.set(String(el), null)
				continue
			}

			if (isArray(el) && (el.length > 0)) {
				if (isStringable(el[1])) {
					if (el.length == 1) {
						map_.set(String(el[1]), null)
					} else {
						map_.set(String(el[1]), el[2])
					}
				}
			}
		}

		return map_
	}
	; TODO: add optional start and end indexes?



	unique(arr?) {
		funcName := "Arrays.unique"

		if (isArray(this) && IsSet(arr) && isArray(arr)) {
			throw Error(StrWrap(funcName, 2) . " — Param <arr> is redundant when called on an instance")
		}

		params := [[&arr, &this]]
		Arrays.__fixParams(&params)

		if (!isArray(arr)) {
			throw Error(StrWrap(funcName, 2) . " — Param <arr> is not an Array")
		}

		obj := Object()
		for (i, val in arr) {
			if (arr.has(i) && isStringable(val)) {
				obj[String(val)] := null
			}
		}
		arrCleaned := []
		for (key, val in obj) {
			arrCleaned.Push(key)
		}

		return arrCleaned
	}



	/**
	 * internal function to shift parameters for parity between <Array> instance and function calls
	 * and set default values where necessary
	 */
	__fixParams(&params) {
		this_ := %params[1][2]%
		params.insertAt(1, [&this_, null])
		i := params.length
		while (i > 1) {
			defaultVal := params[i][2]
			%params[i][1]% := (isArray(this_) ? (%params[i - 1][1]% ?? defaultVal) : (%params[i][1]% ?? defaultVal))
			i--
		}
		params := null
	}
}



/**
 * Returns the item at the specified index
 *
 * @function Arrays.at | ArrAt
 * @param {array} val - (not required if called on an instance)
 * @param {number} [index=1] - positive numbers from left, negative numbers from right
 * @param {boolean} [clamp=false] - fix index to between 1 and val.length
 * @returns {(any|null)}
 */
ArrAt := ObjBindMethod(Arrays, "at")
Array.Prototype.DefineProp("at", { Call: Arrays.at })



/**
 * Merges (n) arrays and returns a new array
 * @function Arrays.concat | ArrConcat
 * @param {...array} vals
 * @returns {array}
 */
ArrConcat := ObjBindMethod(Arrays, "concat")
Array.Prototype.DefineProp("concat", { Call: Arrays.concat })



/**
 * creates a new array from an iterable or array-like object
 * @function Arrays.from | ArrFrom
 * @param {any} val
 * @param {string} [mode=3] - 1 = values, 2 = keys, 3 = both
 * @returns {string}
 * @note param <mode>=both returns an array of [key, value] items from a Map or Object
 * @note param <mode> has no effect on Strings or Arrays
 */
ArrFrom := ObjBindMethod(Arrays, "from")



/**
 * Checks if an array contains a given value
 *
 * @function Arrays.includes | ArrIncludes
 * @param {array} val - (not required if called on an instance)
 * @param {(string|number)} needle
 * @param {boolean} [caseSense=false]
 * @param {number} [indexStart=1] - positive numbers from left, negative numbers from right
 * @param {boolean} [clamp=false] - fix index to between 1 and val.length
 * @returns {boolean}
 *
 * This function is type-sensitive
 */
ArrIncludes := ObjBindMethod(Arrays, "includes")
Array.Prototype.DefineProp("includes", { Call: Arrays.includes })



/**
 * Returns the index of the first occurrence of a given value in an array
 *
 * @function Arrays.indexOf | ArrIndexOf
 * @param {array} val - (not required if called on an instance)
 * @param {(string|number)} needle
 * @param {boolean} [caseSense=false]
 * @param {number} [indexStart=1] - positive numbers from left, negative numbers from right
 * @param {boolean} [clamp=false] - fix index to between 1 and val.length
 * @returns {(integer|null)}
 *
 * This function is type-sensitive
 */
ArrIndexOf := ObjBindMethod(Arrays, "indexOf")
Array.Prototype.DefineProp("indexOf", { Call: Arrays.indexOf })



/**
 * Concatenates all elements of an array into a string
 *
 * @function Arrays.join | ArrJoin
 * @param {array} val - (not required if called on an instance)
 * @param {string} [separator=""]
 * @param {boolean} [clean=false] - remove empty elements from the output (ignored if debugMode > 0)
 * @param {number} [debugMode=0] - 0 = off, 1 = tokenize non-stringable elements, 2 = also force values [1 | 0 | -1] to be represented by "<True>" | "<False>" | "<Ignore>"
 * @returns {string}
 */
ArrJoin := ObjBindMethod(Arrays, "join")
Array.Prototype.DefineProp("join", { Call: Arrays.join })



/**
 * Removes occurrences of a specified value from an array
 *
 * @function Arrays.remove | ArrRemove
 * @param {array} val
 * @param {(string|number)} needle
 * @param {boolean} [caseSense=false]
 * @param {number} [indexStart=1] - positive numbers from left, negative numbers from right
 * @param {boolean} [clamp=false] - fix index to between 1 and val.length
 */
ArrRemove := ObjBindMethod(Arrays, "remove")
Array.Prototype.DefineProp("remove", { Call: Arrays.remove })



/**
 * Reverses the order of the elements in an array
 *
 * @function Arrays.reverse | ArrReverse
 * @param {array} val
 */
ArrReverse := ObjBindMethod(Arrays, "reverse")
Array.Prototype.DefineProp("reverse", { Call: Arrays.reverse })



/**
 * removes the first element from an array and returns the element
 * @function Arrays.shift | ArrShift
 * @param {array} val
 * @returns {any} - original first element
 */
ArrShift := ObjBindMethod(Arrays, "shift")
Array.Prototype.DefineProp("shift", { Call: Arrays.shift })



/**
 * returns a shallow copy of a portion of an array into a new array
 * @function Arrays.slice | ArrSlice
 * @param {number} [indexStart=1] - positive numbers from left, negative numbers from right
 * @param {number} [indexEnd=val.length] - positive numbers from left, negative numbers from right
 * @param {boolean} [clamp=false] - fix index to between 1 and val.length
 * @returns {array}
 */
ArrSlice := ObjBindMethod(Arrays, "slice")
Array.Prototype.DefineProp("slice", { Call: Arrays.slice })



/**
 * turns an array into a map object using el as key;
 * unless el contains an array, in which case we use key and value from el[1,2]
 * @function Arrays.toMap | ArrToMap
 * @returns {map}
 */
ArrToMap := ObjBindMethod(Arrays, "toMap")
Array.Prototype.DefineProp("toMap", { Call: Arrays.toMap })



/**
 * Returns an array of unique values from the input array
 * @function Arrays.unique | ArrUnique
 * @param {array} arr
 * @returns {array}
 */
ArrUnique := ObjBindMethod(Arrays, "unique")
Array.Prototype.DefineProp("unique", { Call: Arrays.unique })
