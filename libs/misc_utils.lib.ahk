/**
 * @param {string} section
 * @returns {boolean}
 */
iniSectionExists(section) {
	funcName := "iniSectionExists"

	if (!isString(section)) {
		throw Error(StrWrap(funcName, 2) . " — Param <section> is not a String")
	}

	SFP := __Settings.settingsFilePath

	try {
		IniRead(SFP, section, "")
	} catch Error as e {
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
getIniVal(section, key, defaultVal?) {
	funcName := "getIniVal"

	if (!isString(section)) {
		throw Error(StrWrap(funcName, 2) . " — Param <section> is not a String")
	}
	if (!isString(key)) {
		throw Error(StrWrap(funcName, 2) . " — Param <key> is not a String")
	}
	if (!IsSet(defaultVal)) {
		throw Error(StrWrap(funcName, 2) . " — Param <defaultVal> does not have a value")
	}

	SFP := __Settings.settingsFilePath

	try {
		val := IniRead(SFP, section, key)
	} catch Error as e {
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


MsgboxJoin(msg) {
	if (isArray(msg)) {
		return msg.join("`n")
	}
	return msg
}


checkMemoryUsage() {
	pid := DllCall("GetCurrentProcessId")
	h := DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
	DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
	DllCall("CloseHandle", "Int", h)
	return
}


; reload this script/app on save
#HotIf WinActive("`.ahk",)
~^s:: {
	title := WinGetTitle("A")
	if (InStr(title, A_ScriptName)) {
		Sleep(500)
		Reload()
	}
}
#HotIf
