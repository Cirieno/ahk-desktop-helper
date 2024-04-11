/**********************************************************
 * @name KeyboardTextManipulation
 * @author RM
 * @file keyboard-text-manipulation.module.ahk
 *********************************************************/
; A set of hotkeys to manipulate text copied to the clipboard
; Works like VSCode's text manipulation shortcuts



class module__KeyboardTextManipulation {
	__Init() {
		this.moduleName := moduleName := "KeyboardTextManipulation"
		this.enabled := getIniVal(moduleName, "enabled", true)
		this.settings := {
			activateOnLoad: getIniVal(moduleName, "active", false)
		}
		this.states := {
			active: null
		}
		this.settings.menu := {
			path: "TRAY\Keyboard",
			items: [{
				type: "item",
				label: "Enable text manipulation shortcuts"
			}]
		}
	}



	__New() {
		if (!this.enabled) {
			return
		}

		this.states.active := this.settings.activateOnLoad

		thisMenu := this.drawMenu()
		setMenuItemProps(this.settings.menu.items[1].label, thisMenu, { checked: this.states.active })

		this.setHotkeys(this.states.active)
	}



	__Delete() {
	}



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
		local doMenuItem := ObjBindMethod(this, "doMenuItem")
		for item in this.settings.menu.items {
			switch (item.type) {
				case "item":
					menuItemKey := setMenuItem(item.label, thisMenu, doMenuItem)
				case "separator", "---":
					setMenuItem("---", thisMenu)
			}
		}

		return (isMenu(thisMenu) ? thisMenu : null)
	}



	doMenuItem(name, position, menu) {
		switch (name) {
			case this.settings.menu.items[1].label:
				this.states.active := !this.states.active
				setMenuItemProps(name, menu, { checked: this.states.active, clickCount: +1 })
				this.setHotkeys(this.states.active)
		}
	}



	setHotkeys(state) {
		Hotkey("$^!U", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!L", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!T", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!S", whichHotkey, (state ? "on" : "off"))

		Hotkey("$^!'", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!2", whichHotkey, (state ? "on" : "off"))
		Hotkey("~$^!``", whichHotkey, (state ? "on" : "off"))

		Hotkey("$^!9", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!0", whichHotkey, (state ? "on" : "off"))

		Hotkey("$^![", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!]", whichHotkey, (state ? "on" : "off"))

		Hotkey("$^!+{", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!+}", whichHotkey, (state ? "on" : "off"))

		Hotkey("$^!,", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!.", whichHotkey, (state ? "on" : "off"))

		Hotkey("$^!J", whichHotkey, (state ? "on" : "off"))

		Hotkey("$^!-", whichHotkey, (state ? "on" : "off"))

		whichHotkey(*) {
			if (SubStr(A_ThisHotkey, -1, 1) = "U") {
				this.doPaste("upper")
			}
			if (SubStr(A_ThisHotkey, -1, 1) = "L") {
				this.doPaste("lower")
			}
			if (SubStr(A_ThisHotkey, -1, 1) = "T") {
				this.doPaste("title")
			}
			if (SubStr(A_ThisHotkey, -1, 1) = "S") {
				this.doPaste("sarcasm")
			}
			if (SubStr(A_ThisHotkey, -1, 1) = "'") {
				this.doPaste("single-quotes")
			}
			if (SubStr(A_ThisHotkey, -1, 1) = "2") {
				this.doPaste("double-quotes")
			}
			if (SubStr(A_ThisHotkey, -1, 1) = "``") {
				this.doPaste("backticks")
			}
			if (SubStr(A_ThisHotkey, -1, 1) = "9" || SubStr(A_ThisHotkey, -1, 1) = "0") {
				this.doPaste("parentheses")
			}
			if (SubStr(A_ThisHotkey, -1, 1) = "[" || SubStr(A_ThisHotkey, -1, 1) = "]") {
				this.doPaste("square-brackets")
			}
			if (SubStr(A_ThisHotkey, -1, 1) = "{" || SubStr(A_ThisHotkey, -1, 1) = "}") {
				this.doPaste("braces")
			}
			if (SubStr(A_ThisHotkey, -1, 1) = "," || SubStr(A_ThisHotkey, -1, 1) = ".") {
				this.doPaste("angle-brackets")
			}
			if (SubStr(A_ThisHotkey, -1, 1) = "J") {
				this.doPaste("join", false)
			}
			if (SubStr(A_ThisHotkey, -1, 1) = "-") {
				SendText("—")
			}
		}
	}



	doPaste(mode, reselect := true) {
		clipSavedAll := ClipboardAll()
		A_Clipboard := ""
		Send("^c")
		if (!ClipWait(2)) {
			return
		}
		copied := A_Clipboard

		; remove final CR or NL from copied text (we put it back on later)
		linebreak := ""
		if ((SubStr(copied, -1) == "`r") || (SubStr(copied, -1) == "`n")) {
			linebreak := SubStr(copied, -1)
			copied := SubStr(copied, 1, -2)
		}

		if (!StrLen(copied)) {
			return
		}

		switch (mode) {
			case "upper":
				copied := StrUpper(copied)
			case "lower":
				copied := StrLower(copied)
			case "title":
				copied := StrTitle(copied)
			case "sarcasm":
				arr := StrSplit(copied)
				for ii, el in arr {
					arr[ii] := (Random(1) ? StrUpper(el) : StrLower(el))
				}
				copied := ArrJoin(arr, "")
			case "single-quotes":
				copied := StrWrap(copied, 6)
			case "double-quotes":
				copied := StrWrap(copied, 5)
			case "backticks":
				copied := StrWrap(copied, 7)
			case "parentheses":
				copied := StrWrap(copied, 1)
			case "square-brackets":
				copied := StrWrap(copied, 2)
			case "braces":
				copied := StrWrap(copied, 3)
			case "angle-brackets":
				copied := StrWrap(copied, 4)
			case "join":
				copied := RegExReplace(copied, "\s*[\r\n]\s*", "")
		}

		A_Clipboard := copied := (copied . linebreak)
		Send("^v")
		; Sleep(Max(StrLen(copied), 250))
		Sleep(200)
		A_Clipboard := clipSavedAll

		if (reselect) {
			Send("+{left " . StrLen(copied) . "}")
		}
	}



	updateSettingsFile() {
		SFP := __Settings.settingsFilePath

		try {
			IniWrite(toString(this.enabled), SFP, this.moduleName, "enabled")
			IniWrite(toString(this.states.active), SFP, this.moduleName, "active")
		} catch Error as e {
			throw Error("Error updating settings file: " . e.Message)
		}
	}
}
