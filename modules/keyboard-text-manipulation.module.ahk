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
			activateOnLoad: getIniVal(moduleName, "active", false),
			sarcasmCase: getIniVal(moduleName, "sarcasmCase", "random")    ; or "alternating"
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

		; thisGui := this.openGui()

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
		Hotkey("$^!(", whichHotkey, (state ? "on" : "off"))    ; parentheses
		Hotkey("$^!)", whichHotkey, (state ? "on" : "off"))    ; parentheses
		Hotkey("$^![", whichHotkey, (state ? "on" : "off"))    ; square-brackets
		Hotkey("$^!]", whichHotkey, (state ? "on" : "off"))    ; square-brackets
		Hotkey("$^!{", whichHotkey, (state ? "on" : "off"))    ; curly-braces
		Hotkey("$^!}", whichHotkey, (state ? "on" : "off"))    ; curly-braces
		Hotkey("$^!<", whichHotkey, (state ? "on" : "off"))    ; angle-brackets
		Hotkey("$^!>", whichHotkey, (state ? "on" : "off"))    ; angle-brackets
		Hotkey("$^!-", whichHotkey, (state ? "on" : "off"))    ; en-dash
		Hotkey("$^!_", whichHotkey, (state ? "on" : "off"))    ; em-dash
		Hotkey("$^!O", whichHotkey, (state ? "on" : "off"))    ; degree symbol
		Hotkey("$^!J", whichHotkey, (state ? "on" : "off"))    ; join lines

		Hotkey("$^!F", whichHotkey, (state ? "on" : "off"))    ; open gui

		whichHotkey(key) {
			key := RegExReplace(key, "S)[\$\#\!\^]", "")
			switch (strUpper(key)) {
				case "U":
					this.doPaste("upper-case")
				case "L":
					this.doPaste("lower-case")
				case "T":
					this.doPaste("title-case")
				; case "C":
					; this.doPaste("camel-case")
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
				case "O":
					SendText(Chr(176))
				case "J":
					this.doPaste("join", false)
				case "F":
					this.openGui()
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
				if (this.settings.sarcasmCase == "random") {
					for (i, el in arr) {
						arr[i] := (Random(1) ? StrUpper(el) : StrLower(el))
					}
				} else {
					bias := (StrCharFirst(copied) == StrUpper(StrCharFirst(copied)) ? 1 : 0)
					for (i, el in arr) {
						if (i == 1) {
							continue
						}
						arr[i] := (bias && Mod(i, 2) ? StrUpper(el) : StrLower(el))
					}
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

		; if (reselect) {
		; 	Send("+{left " . StrLen(copied) . "}")    ; this is visibly slow
		; }

		; Sleep(Max(StrLen(copied), 250))
		Sleep(200)
		A_Clipboard := clipSavedAll
	}


	openGui() {
		; DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")

		; MouseGetPos(&x, &y, &hWnd)
		hWnd := WinExist("A")
		winTitle := WinGetTitle(hWnd)
		buttonMultiplier := 1.6

		gui_ := Gui("+AlwaysOnTop +SysMenu -MaximizeBox -MinimizeBox", this.moduleName)
		; MyGui.opt("+AlwaysOnTop -Disabled +SysMenu +Owner")

		gui_.SetFont("s10")
		gui_.Add("Text", "", "Target window: " . StrWrap(WinGetTitle(hWnd), 5))

		groupbox1 := gui_.Add("GroupBox", "x10 y35 Section w150 r" . (6 * buttonMultiplier), "Formatting")
		gui_.Add("button", "xs+10 ys+25", "Upper case").OnEvent("click", whichButton)
		gui_.Add("button", "", "Lower case").OnEvent("click", whichButton)
		gui_.Add("button", "", "Title case").OnEvent("click", whichButton)
		gui_.Add("button", "", "Kebab case").OnEvent("click", whichButton)
		gui_.Add("button", "", "Snake case").OnEvent("click", whichButton)
		gui_.Add("button", "", "Sarcasm case").OnEvent("click", whichButton)

		groupbox2 := gui_.Add("GroupBox", "x180 y35 Section w150 r" . (9 * buttonMultiplier), "Encapsulating")
		gui_.Add("button", "xs+10 ys+25", "Single quotes").OnEvent("click", whichButton)
		gui_.Add("button", "", "Double quotes").OnEvent("click", whichButton)
		gui_.Add("button", "", "Single curly quotes").OnEvent("click", whichButton)
		gui_.Add("button", "", "Double curly quotes").OnEvent("click", whichButton)
		gui_.Add("button", "", "Backticks").OnEvent("click", whichButton)
		gui_.Add("button", "", "Parentheses").OnEvent("click", whichButton)
		gui_.Add("button", "", "Square brackets").OnEvent("click", whichButton)
		gui_.Add("button", "", "Curly braces").OnEvent("click", whichButton)
		gui_.Add("button", "", "Angle brackets").OnEvent("click", whichButton)

		groupbox3 := gui_.Add("GroupBox", "x350 y35 Section w150 r" . (4 * buttonMultiplier), "Inserting")
		gui_.Add("button", "xs+10 ys+25", "En-dash").OnEvent("click", whichButton)
		gui_.Add("button", "", "Em-dash").OnEvent("click", whichButton)
		gui_.Add("button", "", "Degree symbol").OnEvent("click", whichButton)
		gui_.Add("button", "", "Ellipsis").OnEvent("click", whichButton)

		groupbox4 := gui_.Add("GroupBox", "x350 y220 Section w150 r" . (1 * buttonMultiplier), "Functions")
		gui_.Add("button", "xs+10 ys+25", "Join lines").OnEvent("click", whichButton)

		; gui_.Add("Button", "default", "Close").OnEvent("click", closeGui)
		gui_.Show("NoActivate")  ; NoActivate avoids deactivating the currently active window.

		whichButton(button, *) {
			winActivate(hWnd)
			buttonText := strReplace(strLower(button.text), " ", "-")
			switch (buttonText) {
				case "upper-case",
				"lower-case",
				"title-case",
				"kebab-case",
				"snake-case",
				"sarcasm-case",
				"single-quotes",
				"double-quotes",
				"single-curly-quotes",
				"double-curly-quotes",
				"backticks",
				"parentheses",
				"square-brackets",
				"curly-braces",
				"angle-brackets":
					this.doPaste(buttonText)
				case "en-dash":
					SendText(Chr(8211))
				case "em-dash":
					SendText(Chr(8212))
				case "degree-symbol":
					SendText(Chr(176))
				case "ellipsis":
					SendText(Chr(8230))
				case "join lines":
					this.doPaste("join", false)
			}
		}

		closeGui(*) {
			gui_.hide()
		}
	}


	updateSettingsFile() {
		SFP := __Settings.settingsFilePath

		try {
			IniWrite(toString(this.enabled), SFP, this.moduleName, "enabled")
			IniWrite(toString(this.states.active), SFP, this.moduleName, "active")
			IniWrite(toString(this.settings.sarcasmCase), SFP, this.moduleName, "sarcasmCase")
		} catch Error as e {
			throw Error("Error updating settings file: " . e.Message)
		}
	}
}
