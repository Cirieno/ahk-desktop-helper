/************************************************************************
 * @description KeyboardTextManipulation
 * @author Rob McInnes
 * @file keyboard-text-manipulation.module.ahk
 ***********************************************************************/
; a set of hotkeys to manipulate text copied to the clipboard
; works much like VSCode's text manipulation shortcuts



class module__KeyboardTextManipulation {
	__Init() {
		this.moduleName := "KeyboardTextManipulation"
		this.enabled := getIniVal(this.moduleName, "enabled", true)
		this.settings := {
			activateOnLoad: getIniVal(this.moduleName, "active", false)
		}
		this.states := {
			active: this.settings.activateOnLoad
		}
		this.settings.menu := {
			path: "TRAY\Keyboard",
			items: [{
				type: "item",
				label: "Enable text manipulation shortcuts"
			}]
		}
	}



	/** */
	__New() {
		if (!this.enabled) {
			return
		}

		thisMenu := this.drawMenu()
		setMenuItemProps(this.settings.menu.items[1].label, thisMenu, { checked: this.states.active })

		this.setHotkeys(this.states.active)
	}



	/** */
	__Delete() {
		; nothing to do
	}



	/** */
	drawMenu() {
		thisMenu := getMenu(this.settings.menu.path)
		if (!isMenu(thisMenu)) {
			parentMenu := getMenu("TRAY")
			if (!isMenu(parentMenu)) {
				throw Error("ParentMenu not found")
			}
			thisMenu := setMenu(this.settings.menu.path, parentMenu)
			arrMenuPath := StrSplit(this.settings.menu.path, "\")
			setMenuItem(arrMenuPath.pop(), parentMenu, thisMenu)
		}
		for item in this.settings.menu.items {
			if (item.type == "item") {
				local doMenuItem := ObjBindMethod(this, "doMenuItem")
				menuItemKey := setMenuItem(item.label, thisMenu, doMenuItem)
			}
		}

		return (isMenu(thisMenu) ? thisMenu : null)
	}



	/** */
	doMenuItem(name, position, menu) {
		switch (name) {
			case this.settings.menu.items[1].label:
				this.states.active := !this.states.active
				setMenuItemProps(name, menu, { checked: this.states.active, clickCount: +1 })
				this.setHotkeys(this.states.active)
		}
	}



	/** */
	setHotkeys(state) {
		Hotkey("$^!U", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!L", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!T", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!'", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!2", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!9", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!0", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^![", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!]", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!+{", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!+}", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!``", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!-", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!J", whichHotkey, (state ? "on" : "off"))

		whichHotkey(*) {
			prefix := "i)\$?\^\!"

			if (RegExMatch(A_ThisHotkey, prefix . "U")) {
				this.doPaste("upper")
			}
			if (RegExMatch(A_ThisHotkey, prefix . "L")) {
				this.doPaste("lower")
			}
			if (RegExMatch(A_ThisHotkey, prefix . "T")) {
				this.doPaste("title")
			}
			if (RegExMatch(A_ThisHotkey, prefix . "'")) {
				this.doPaste("singlequotes")
			}
			if (RegExMatch(A_ThisHotkey, prefix . "2")) {
				this.doPaste("doublequotes")
			}
			if (RegExMatch(A_ThisHotkey, prefix . "9") || RegExMatch(A_ThisHotkey, prefix . "0")) {
				this.doPaste("parentheses")
			}
			if (RegExMatch(A_ThisHotkey, prefix . "\[") || RegExMatch(A_ThisHotkey, prefix . "\]")) {
				this.doPaste("brackets")
			}
			if (RegExMatch(A_ThisHotkey, prefix . "\+\{") || RegExMatch(A_ThisHotkey, prefix . "\+\}")) {
				this.doPaste("braces")
			}
			if (RegExMatch(A_ThisHotkey, prefix . "``")) {
				this.doPaste("backticks")
			}
			if (RegExMatch(A_ThisHotkey, prefix . "J")) {
				this.doPaste("join", false)
			}
			if (RegExMatch(A_ThisHotkey, prefix . "-")) {
				SendText(" — ")
			}
		}
	}



	/** */
	doPaste(mode, reselect := true) {
		clipSavedAll := ClipboardAll()
		A_Clipboard := ""
		Send("^c")
		if (!ClipWait(3)) {
			return
		}
		copied := A_Clipboard

		; remove final CR or NL from copied text (we put it back on later)
		linebreak := ""
		if ((SubStr(copied, -1) == "`r") || (SubStr(copied, -1) == "`n")) {
			linebreak := SubStr(copied, -1)
			copied := SubStr(copied, 1, -2)
		}

		if !(StrLen(copied)) {
			return
		}

		switch (mode) {
			case "upper":
				copied := StrUpper(copied)
			case "lower":
				copied := StrLower(copied)
			case "title":
				copied := StrTitle(copied)
			case "singlequotes":
				copied := "'" . copied . "'"
			case "doublequotes":
				copied := "`"" . copied . "`""
			case "parentheses":
				copied := "(" . copied . ")"
			case "brackets":
				copied := "[" . copied . "]"
			case "braces":
				copied := "{" . copied . "}"
			case "backticks":
				copied := "``" . copied . "``"
			case "join":
				copied := RegExReplace(copied, "\s*[\r\n]\s*", " ")
		}

		A_Clipboard := copied := (copied . linebreak)
		Send("^v")
		Sleep(StrLen(copied) * 0.75)
		A_Clipboard := clipSavedAll

		if (reselect) {
			Send("+{left " . StrLen(copied) . "}")
		}
	}



	/** */
	updateSettingsFile() {
		_SAE := _Settings.app.environment
		try {
			IniWrite((this.enabled ? "true" : "false"), _SAE.settingsFilename, this.moduleName, "enabled")
			IniWrite((this.states.active ? "true" : "false"), _SAE.settingsFilename, this.moduleName, "active")
		} catch Error as e {
			throw Error("Error updating settings file: " . e.Message)
		}
	}



	/** */
	checkSettingsFile() {
		_SAE := _Settings.app.environment
		try {
			IniRead(_SAE.settingsFilename, this.moduleName)
		} catch Error as e {
			FileAppend("`n", _SAE.settingsFilename)
			this.updateSettingsFile()
		}
	}
}
