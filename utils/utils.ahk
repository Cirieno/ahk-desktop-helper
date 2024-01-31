isArray(val) {
	return (Type(val) == "Array")
}



isBoolean(val) {
	return ((Type(val) == "Integer") && (val == 1 || val == 0))
}



isNull(val) {
	return (val == "" || val == -1)
}



isString(val) {
	return (Type(val) == "String")
}



isTruthy(val) {
	val := StrUpper(val)
	return (val == 1 || val == "1" || val == "T" || val == "TRUE" || val == "ENABLED" || val == "ACTIVE" || val == "ON")
}



isFalsy(val) {
	val := StrUpper(val)
	return (val == 0 || val == "0" || val == -1 || val == "-1" || val = "" || val == "F" || val == "FALSE" || val == "DISABLED" || val == "DEACTIVE" || val == "INACTIVE" || val == "OFF")
}



toBoolean(val) {
	return (isTruthy(val))
}



toArray(val) {
	if isString(val) && (SubStr(val, 1, 1) == "[" && SubStr(val, -1) == "]") {
		str := Trim(SubStr(val, 2, -1))
		arr := []
		loop parse str, "CSV", "`" " {
			arr.Push(A_LoopField)
		}
		return arr
	} else {
		return [val]
	}
}



isInArray(haystack, needle, caseSensitive := false) {
	if (isArray(haystack)) {
		for each, item in haystack {
			if (!caseSensitive) {
				item := StrUpper(item)
				needle := StrUpper(needle)
			}
			if (item == needle) {
				return true
			}
		}
	} else {
		return false
	}
}



join(val, separator := ",") {
	if (isArray(val) && (val.Length > 0)) {
		str := ""
		for item in val {
			str .= (item . separator)
		}
		return SubStr(str, 1, -StrLen(separator))
	} else {
		return ""
	}
}



/**
 * @param {string} section
 * @param {string} key
 * @param {any} [defaultVal:""]
 * @returns {any}
 */
getIniVal(section, key, defaultVal := "") {
	try {
		keyVal := IniRead("user_settings.ini", section, key)
	} catch Error as e {
		return defaultVal
	}

	if (keyVal == "") {
		return defaultVal
	}

	if (SubStr(keyVal, 1, 1) == "[" && SubStr(keyVal, -1) == "]") {
		return toArray(keyVal)
	}

	if isTruthy(keyVal) {
		return true
	}

	if isFalsy(keyVal) {
		return false
	}
}



checkMemoryUsage() {
	pid := DllCall("GetCurrentProcessId")
	h := DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
	DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
	DllCall("CloseHandle", "Int", h)
	return
}



; used for debugging menu stuff
; addTestMenuItem(menux, label) {
; 	local m := Menu()
; 	m.add("Test1", doMenuItem)
; 	m.add("Test2", doMenuItem)
; 	menux.add(label, m)
; 	_Settings.app.tray.menuHandles.set(label, m)
; }



; reload this script/app on save
#HotIf WinActive("`.ahk",)
~^s:: {
	title := WinGetTitle("A")
	; if InStr(title, A_ScriptName) {
	Sleep(500)
	Reload()
	; }
}
#HotIf
