/**
 * @param {string} section
 * @param {string} key
 * @param {any} [defaultVal:""]
 * @returns {any}
 */
getIniVal(section, key, defaultVal := "") {
	try {
		_SAE := _Settings.app.environment
		keyVal := IniRead(_SAE.settingsFilename, section, key)
	} catch Error as e {
		return defaultVal
	}

	if (keyVal == "") {
		return defaultVal
	}

	if (SubStr(keyVal, 1, 1) == "[" && SubStr(keyVal, -1) == "]") {
		return toArray(keyVal)
	}

	if (isTruthy(keyVal)) {
		return true
	}

	if (isFalsy(keyVal)) {
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
	if (InStr(title, A_ScriptName)) {
		Sleep(500)
		Reload()
	}
}
#HotIf



/** */
debugMsg(msg := "", showMsg := false, asTooltip := false) {
	if (showMsg) {
		if (asTooltip) {
			CoordMode("Tooltip", "Screen")
			ToolTip(msg, 0, (A_ScreenHeight / 2) + Random(-100, 100))
		} else {
			MsgBox(msg, (_Settings.app.name . " - " . "Debugging" . U_ellipsis), (0 + 64 + 4096))
		}
	}
}
