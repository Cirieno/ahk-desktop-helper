/**********************************************************
 * @type {AHKLibrary}
 * @name Ini Utils
 * @author Rob McInnes (Cirieno)
 * @file ini_utils.lib.ahk
 *********************************************************/


class IniUtils {
	/**
	 * @param {string} section
	 * @returns {boolean}
	 */
	static sectionExists(section) {
		funcName := "IniUtils.sectionExists"

		if (!isString(section)) {
			throw Error(StrWrap(funcName, 2) . " — Param <section> is not a String")
		}

		_S := __Settings.settingsFilePath

		try {
			IniRead(_S, section, "")
		} catch Error {
			return false
		}

		return true
	}


	/**
	 * @param {string} section
	 * @param {string} key
	 * @param {any} [defaultVal]
	 * @returns {any}
	 */
	static getVal(section, key, defaultVal?) {
		funcName := "IniUtils.getVal"

		if (!isString(section)) {
			throw Error(StrWrap(funcName, 2) . " — Param <section> is not a String")
		}
		if (!isString(key)) {
			throw Error(StrWrap(funcName, 2) . " — Param <key> is not a String")
		}
		if (!IsSet(defaultVal)) {
			throw Error(StrWrap(funcName, 2) . " — Param <defaultVal> does not have a value")
		}

		_S := __Settings.settingsFilePath

		try {
			val := IniRead(_S, section, key)
		} catch Error {
			return defaultVal
		}

		bool := toBoolean(val)
		if (isBoolean(bool)) {
			return bool
		}

		if (isIgnore(val)) {
			return (val == "ignore" ? "ignore" : ignore)
		}

		arr := ArrFrom(val)
		if (isArray(arr)) {
			return arr
		}

		if (isEmpty(val)) {
			return defaultVal
		}

		if (IsFloat(val)) {
			return Float(val)
		}

		if (IsInteger(val)) {
			return Integer(val)
		}

		return String(val)
	}
}
