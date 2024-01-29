ellipsis := "…"
null := ""



/**
 * @param {string} section
 * @param {string} key
 * @param {any} [defaultVal:""]
 * @returns {any}
 */
getIniVal(section, key, defaultVal := "") {
	try {
		keyVal := IniRead("user_settings.ini", section, key)
	} catch {
		return defaultVal
	}

	if (keyVal == "ERROR" || keyVal == "") {
		return defaultVal
	}

	if (keyVal == "true" || keyVal == "false") {
		return (keyVal == "true" ? true : false)
	}

	if (SubStr(keyVal, 1, 1) == "[" && SubStr(keyVal, -1) == "]") {
		keyVal := Trim(SubStr(keyVal, 2, -1))
		keyVal := RegExReplace(keyVal, "\s*,(?=(?:[^\`"]*\`"[^\`"]*\`")*(?![^\`"]*\`"))\s*", "|")
		keyArr := StrSplit(keyVal, "|")
		for ii, val in keyArr {
			if (SubStr(val, 1, 1) == "`"" && SubStr(val, -1) == "`"") {
				val := SubStr(val, 2, -1)
			}
			keyArr[ii] := val
			if (Trim(keyArr[ii]) == "true" || Trim(keyArr[ii]) == "false") {
				keyArr[ii] := (Trim(keyArr[ii]) == "true" ? true : false)
			}
		}
		return keyArr
	}

	return keyVal
}


isBoolean(val) {
	return (val == 1 || val == 0)
}


isTruthy(val) {
	val := StrUpper(val)
	return (val == 1 || val == "1" || val == "T" || val == "TRUE" || val == "ENABLED" || val == "ACTIVE" || val == "ON")
}


isFalsy(val) {
	val := StrUpper(val)
	return (val == 0 || val == "0" || val == -1 || val == "-1" || val = "" || val == "F" || val == "FALSE" || val == "DISABLED" || val == "DEACTIVE" || val == "INACTIVE" || val == "OFF")
}


isInArray(haystack, needle, caseSensitive := false) {
	try {
		for ii, val in haystack {
			if (!caseSensitive) {
				val := StrUpper(val)
				needle := StrUpper(needle)
			}
			if (val == needle) {
				return true
			}
		}
	} catch {
		MsgBox("Error in isInArray()")
	}
}


isNull(val) {
	return (val == "" || val == -1)
}


toBoolean(val) {
	return (isTruthy(val) ? 1 : 0)
}


join(params, separator) {
	try {
		for ii, param in params {
			str .= param . separator
		}
		return SubStr(str, 1, -StrLen(separator))
	} catch {
		MsgBox("Error in join()")
	}
}


checkMemoryUsage() {
	pid := DllCall("GetCurrentProcessId")
	h := DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
	DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
	DllCall("CloseHandle", "Int", h)
	return
}


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
