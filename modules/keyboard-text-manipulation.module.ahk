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
		for (i, item in this.settings.menu.items) {
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
		Hotkey("$^!U", whichHotkey, (state ? "on" : "off"))    ; upper-case
		Hotkey("$^!L", whichHotkey, (state ? "on" : "off"))    ; lower-case
		Hotkey("$^!T", whichHotkey, (state ? "on" : "off"))    ; title-case
		; Hotkey("$#!C", whichHotkey, (state ? "on" : "off"))    ; camel-case
		Hotkey("$^!K", whichHotkey, (state ? "on" : "off"))    ; kebab-case
		Hotkey("$^!S", whichHotkey, (state ? "on" : "off"))    ; snake-case
		Hotkey("$^!&", whichHotkey, (state ? "on" : "off"))    ; sarcasm-case
		Hotkey("$^!'", whichHotkey, (state ? "on" : "off"))    ; single-quotes
		Hotkey("$^!2", whichHotkey, (state ? "on" : "off"))    ; double-quotes
		Hotkey("$^!+'", whichHotkey, (state ? "on" : "off"))    ; single-curly-quotes
		Hotkey("$^!+2", whichHotkey, (state ? "on" : "off"))    ; double-curly-quotes
		Hotkey("$^!``", whichHotkey, (state ? "on" : "off"))    ; backticks
		Hotkey("$^!(", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!)", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^![", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!]", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!{", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!}", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!<", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!>", whichHotkey, (state ? "on" : "off"))
		Hotkey("$^!-", whichHotkey, (state ? "on" : "off"))    ; en-dash
		Hotkey("$^!_", whichHotkey, (state ? "on" : "off"))    ; em-dash
		Hotkey("$^!J", whichHotkey, (state ? "on" : "off"))    ; join lines

		whichHotkey(key) {
			key := RegExReplace(key, "S)[\$\#\!\^]", "")
			; MsgBox(key)

			switch (key) {
				case "U":
					this.doPaste("upper-case")
				case "L":
					this.doPaste("lower-case")
				case "T":
					this.doPaste("title-case")
				; case "C":
				; 	this.doPaste("camel-case")
				case "K":
					this.doPaste("kebab-case")
				case "S":
					this.doPaste("snake-case")
				case "&":
					this.doPaste("sarcasm-case")
				case "'":
					this.doPaste("single-quotes")
				case "2":
					this.doPaste("double-quotes")
				case "+'":
					this.doPaste("single-curly-quotes")
				case "+2":
					this.doPaste("double-curly-quotes")
				case "``":
					this.doPaste("backticks")
				case "(", ")":
					this.doPaste("parentheses")
				case "[", "]":
					this.doPaste("square-brackets")
				case "{", "}":
					this.doPaste("curly-braces")
				case "<", ">":
					this.doPaste("angle-brackets")
				case "-":
					SendText(Chr(8211))
				case "_":
					SendText(Chr(8212))
				case "J":
					this.doPaste("join", false)
			}
		}
	}


	doPaste(mode, reselect := false) {
		clipSavedAll := ClipboardAll()
		A_Clipboard := ""

		Send("^c")

		if (!ClipWait(2)) {
			A_Clipboard := clipSavedAll
			return
		}

		copied := A_Clipboard

		if (!StrLen(copied)) {
			A_Clipboard := clipSavedAll
			return
		}

		switch (mode) {
			case "upper-case":
				copied := StrUpper(copied)
			case "lower-case":
				copied := StrLower(copied)
			case "title-case":
				copied := StrTitle(copied)
				; TODO: should titlecase regard hyphens as spaces?
			; case "camel-case":
			; 	regex := "S)[\s\-]+([^A-Z])"
			; 	copied := RegExReplace(copied, regex, "$U1")
			case "kebab-case":
				copied := RegExReplace(copied, "[ _]", "-")
			case "snake-case":
				copied := RegExReplace(copied, "[ -]", "_")
			case "sarcasm-case":
				arr := StrSplit(copied)
				for (i, el in arr) {
					arr[i] := (Random(1) ? StrUpper(el) : StrLower(el))
				}
				copied := ArrJoin(arr)
			case "single-quotes":
				copied := Chr(39) . copied . Chr(39)
			case "double-quotes":
				copied := Chr(34) . copied . Chr(34)
			case "single-curly-quotes":
				copied := Chr(8216) . copied . Chr(8217)
			case "double-curly-quotes":
				copied := Chr(8220) . copied . Chr(8221)
			case "backticks":
				copied := Chr(96) . copied . Chr(96)
			case "parentheses":
				copied := "(" . copied . ")"
			case "square-brackets":
				copied := "[" . copied . "]"
			case "curly-braces":
				copied := "{" . copied . "}"
			case "angle-brackets":
				copied := "<" . copied . ">"
			case "join":
				copied := RegExReplace(copied, "[\r\n]", " ")
		}

		A_Clipboard := copied
		Send("^v")    ; in tests any Send(copied) variant is visibly slow

		if (reselect) {
			Send("+{left " . StrLen(copied) . "}")    ; this is visibly slow
		}

		; Sleep(Max(StrLen(copied), 250))
		Sleep(200)
		A_Clipboard := clipSavedAll
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
