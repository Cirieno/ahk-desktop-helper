/**********************************************************
 * @type {AHKModule}
 * @name Keyboard Text Manipulation
 * @author Rob McInnes (Cirieno)
 * @file keyboard-text-manipulation.ahk
 *********************************************************/
;
; A set of hotkeys to manipulate text copied to the clipboard
; Works like VSCode's text manipulation shortcuts


class module__KeyboardTextManipulation {
	/**
	 * @returns {void}
	 */
	__Init() {
		this.moduleName := moduleName := "KeyboardTextManipulation"
		this.settings := {
			isEnabled: IniUtils.getVal(moduleName, "enabled", true),
			activateOnLoad: IniUtils.getVal(moduleName, "activateOnLoad", false),
			sarcasmCase: IniUtils.getVal(moduleName, "sarcasmCase", "random"),
			defaultHotkeys: {
				upperCase: "$^!U",
				lowerCase: "$^!L",
				titleCase: "$^!T",
				camelCase: "$^!C",
				pascalCase: "$^!P",
				kebabCase: "$^!K",
				snakeCase: "$^!S",
				sarcasmCase: "$^!&",
				singleQuotes: "$^!'",
				doubleQuotes: "$^!2",
				singleCurlyQuotes: "$^!+'",
				doubleCurlyQuotes: "$^!+2",
				backticks: "$^!``",
				parenthesesOpen: "$^!(",
				parenthesesClose: "$^!)",
				squareBracketsOpen: "$^![",
				squareBracketsClose: "$^!]",
				curlyBracesOpen: "$^!{",
				curlyBracesClose: "$^!}",
				angleBracketsOpen: "$^!<",
				angleBracketsClose: "$^!>",
				enDash: "$^!-",
				emDash: "$^!_",
				degreeSymbol: "$^!O",
				joinLines: "$^!J",
				quoteClipboardText: "$^!Q"
			},
			hotkeySettingKeys: {},
			hotkeys: {}
		}
		for (bindingName, defaultHotkey in this.settings.defaultHotkeys.OwnProps()) {
			settingKey := "hotkey" . StrUpper(SubStr(bindingName, 1, 1)) . SubStr(bindingName, 2)
			this.settings.hotkeySettingKeys.%bindingName% := settingKey
			this.settings.hotkeys.%bindingName% := IniUtils.getVal(moduleName, settingKey, defaultHotkey)
		}
		this.state := {
			isActive: null,
			onTextManipulationChangeCallback: null,
			hotkeys: Map()
		}
		this.ui := {
			menu: {
				parentPath: "TRAY\Keyboard-2",
				entries: [{
					type: "item",
					label: "Text manipulation shortcuts"
				}]
			}
		}
	}


	/**
	 * @returns {void}
	 */
	__New() {
		if (!this.settings.isEnabled) {
			return
		}

		this.state.isActive := this.settings.activateOnLoad
		this.state.onTextManipulationChangeCallback := ObjBindMethod(this, "onTextManipulationChange")
		this.state.hotkeys := this.getResolvedHotkeys()

		thisMenu := this.drawMenu()
		this.syncMenuItem(thisMenu)

		this.setHotkeysEnabled(this.state.isActive)
	}


	/**
	 * @returns {void}
	 */
	__Delete() {
		if (IsObject(this.state.onTextManipulationChangeCallback)) {
			this.setHotkeysEnabled(false)
			this.state.onTextManipulationChangeCallback := null
		}

		this.state.hotkeys := Map()
	}


	/**
	 * @returns {Menu|null}
	 */
	drawMenu() {
		thisMenu := ensureNativeMenuPath(this.ui.menu.parentPath)
		local onMenuItemClick := ObjBindMethod(this, "onMenuItemClick")
		this.drawMenuEntries(thisMenu, this.ui.menu.entries, onMenuItemClick)

		return (isMenu(thisMenu) ? thisMenu : null)
	}


	/**
	 * @param {Menu} thisMenu
	 * @param {Array} entries
	 * @param {Func|BoundFunc} onMenuItemClick
	 * @returns {void}
	 */
	drawMenuEntries(thisMenu, entries, onMenuItemClick) {
		for (i, entry in entries) {
			switch (entry.type) {
				case "item":
					thisMenu.Add(entry.label, onMenuItemClick)
				case "submenu":
					childMenu := Menu()
					this.drawMenuEntries(childMenu, entry.entries, onMenuItemClick)
					thisMenu.Add(entry.label, childMenu)
				case "separator", "---":
					thisMenu.Add()
			}
		}
	}


	/**
	 * @param {string} name
	 * @param {integer} position
	 * @param {Menu} menu
	 * @returns {void}
	 */
	onMenuItemClick(name, position, menu) {
		switch (name) {
			case this.ui.menu.entries[1].label:
				this.state.isActive := !this.state.isActive
				this.syncMenuItem(menu)
				this.setHotkeysEnabled(this.state.isActive)
				this.updateSettingsFile()
		}
	}


	/**
	 * @param {Menu} menu
	 * @returns {void}
	 */
	syncMenuItem(menu) {
		label := this.ui.menu.entries[1].label
		(this.state.isActive ? menu.Check(label) : menu.Uncheck(label))
		menu.Enable(label)
	}


	/**
	 * @param {boolean} state
	 * @returns {void}
	 */
	setHotkeysEnabled(state) {
		for (bindingName, hotkeyName in this.state.hotkeys) {
			Hotkey(hotkeyName, this.state.onTextManipulationChangeCallback, (state ? "on" : "off"))
		}
	}


	/**
	 * @param {string} name
	 * @returns {void}
	 */
	onTextManipulationChange(name) {
		bindingName := this.getBindingNameByHotkey(name)
		if (isEmpty(bindingName)) {
			return
		}

		switch (bindingName) {
			case "upperCase":
				this.doPaste("upper-case")
			case "lowerCase":
				this.doPaste("lower-case")
			case "titleCase":
				this.doPaste("title-case")
			case "camelCase":
				this.doPaste("camel-case")
			case "pascalCase":
				this.doPaste("pascal-case")
			case "kebabCase":
				this.doPaste("kebab-case")
			case "snakeCase":
				this.doPaste("snake-case")
			case "sarcasmCase":
				this.doPaste("sarcasm-case")
			case "singleQuotes":
				this.doSurrounder("single-quotes")
			case "doubleQuotes":
				this.doSurrounder("double-quotes")
			case "singleCurlyQuotes":
				this.doSurrounder("single-curly-quotes")
			case "doubleCurlyQuotes":
				this.doSurrounder("double-curly-quotes")
			case "backticks":
				this.doSurrounder("backticks")
			case "parenthesesOpen", "parenthesesClose":
				this.doSurrounder("parentheses")
			case "squareBracketsOpen", "squareBracketsClose":
				this.doSurrounder("square-brackets")
			case "curlyBracesOpen", "curlyBracesClose":
				this.doSurrounder("curly-braces")
			case "angleBracketsOpen", "angleBracketsClose":
				this.doSurrounder("angle-brackets")
			case "enDash":
				SendText(Chr(8211))
			case "emDash":
				SendText(Chr(8212))
			case "degreeSymbol":
				SendText(Chr(176))
			case "joinLines":
				this.doPaste("join")
			case "quoteClipboardText":
				this.pasteQuotedClipboard()
		}
	}


	/**
	 * @returns {Map}
	 */
	getResolvedHotkeys() {
		resolvedHotkeys := Map()

		for (bindingName, defaultHotkey in this.settings.defaultHotkeys.OwnProps()) {
			configuredHotkey := HotkeyUtils.normaliseHotkey(this.settings.hotkeys.%bindingName%)
			resolvedHotkeys[bindingName] := HotkeyUtils.validateHotkey(configuredHotkey, defaultHotkey, this.state.onTextManipulationChangeCallback)
			this.settings.hotkeys.%bindingName% := resolvedHotkeys[bindingName]
		}

		return resolvedHotkeys
	}


	/**
	 * @param {string} hotkeyName
	 * @returns {string}
	 */
	getBindingNameByHotkey(hotkeyName) {
		for (bindingName, configuredHotkey in this.state.hotkeys) {
			if (configuredHotkey == hotkeyName) {
				return bindingName
			}
		}

		return ""
	}


	/**
	 * @returns {void}
	 */
	pasteQuotedClipboard() {
		if (!A_Clipboard || !StrLen(A_Clipboard)) {
			return
		}

		quotedText := Chr(34) . A_Clipboard . Chr(34)
		this.pasteTextViaClipboard(quotedText)
	}


	/**
	 * @param {string} mode
	 * @param {boolean} [reselect=false]
	 * @returns {void}
	 */
	doPaste(mode, reselect := false) {
		copied := this.copySelectedText(2)

		if (!StrLen(copied)) {
			return
		}

		switch (mode) {
			case "upper-case":
				copied := StrUpper(copied)
			case "lower-case":
				copied := StrLower(copied)
			case "title-case":
				copied := this.toTitleCase(copied)
			case "camel-case":
				copied := this.buildCompoundCase(copied, "camel")
			case "pascal-case":
				copied := this.buildCompoundCase(copied, "pascal")
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
				copied := RegExReplace(copied, "\s*[\r\n]+\s*", " ")
				copied := Trim(copied)
		}

		this.pasteTextViaClipboard(copied, reselect)
	}


	/**
	 * @param {string} mode
	 * @returns {void}
	 */
	doSurrounder(mode) {
		surroundText := this.getSurroundText(mode)
		if (isEmpty(surroundText)) {
			return
		}

		selectedText := this.copySelectedText(0.15)
		if (!StrLen(selectedText)) {
			return
		}

		this.pasteTextViaClipboard(this.wrapWithSurrounder(selectedText, mode))
	}


	/**
	 * @param {number} timeoutSeconds
	 * @returns {string}
	 */
	copySelectedText(timeoutSeconds := 2) {
		clipSavedAll := ClipboardAll()
		A_Clipboard := ""

		try {
			Send("^c")
			if (!ClipWait(timeoutSeconds)) {
				return ""
			}

			return A_Clipboard
		} finally {
			A_Clipboard := clipSavedAll
		}
	}


	/**
	 * @param {string} text
	 * @param {boolean} [reselect=false]
	 * @returns {void}
	 */
	pasteTextViaClipboard(text, reselect := false) {
		clipSavedAll := ClipboardAll()

		try {
			A_Clipboard := text
			Send("^v")    ; in tests any Send(copied) variant is visibly slow

			if (reselect) {
				Send("+{left " . StrLen(text) . "}")    ; this is visibly slow
			} else {
				trailingLineBreakCount := this.countTrailingLineBreaks(text)
				if (trailingLineBreakCount) {
					Send("{Left " . trailingLineBreakCount . "}")
				}
			}

			Sleep(75)
		} finally {
			A_Clipboard := clipSavedAll
		}
	}


	/**
	 * @param {string} text
	 * @returns {integer}
	 */
	countTrailingLineBreaks(text) {
		count := 0
		position := StrLen(text)

		while (position > 0) {
			char := SubStr(text, position, 1)
			if ((char != "`r") && (char != "`n")) {
				break
			}

			if ((char == "`n") && (position > 1) && (SubStr(text, position - 1, 1) == "`r")) {
				position -= 2
			} else {
				position -= 1
			}

			count += 1
		}

		return count
	}


	/**
	 * @param {string} mode
	 * @returns {boolean}
	 */
	insertSurrounder(mode) {
		surroundText := this.getSurroundText(mode)
		if (isEmpty(surroundText)) {
			return false
		}

		SendText(surroundText)
		Send("{Left}")
		return true
	}


	/**
	 * @param {string} text
	 * @param {string} mode
	 * @returns {string}
	 */
	wrapWithSurrounder(text, mode) {
		surroundText := this.getSurroundText(mode)
		if (isEmpty(surroundText)) {
			return text
		}

		return SubStr(surroundText, 1, 1) . text . SubStr(surroundText, 2)
	}


	/**
	 * @param {string} mode
	 * @returns {string}
	 */
	getSurroundText(mode) {
		switch (mode) {
			case "single-quotes":
				return Chr(39) . Chr(39)
			case "double-quotes":
				return Chr(34) . Chr(34)
			case "single-curly-quotes":
				return Chr(8216) . Chr(8217)
			case "double-curly-quotes":
				return Chr(8220) . Chr(8221)
			case "backticks":
				return Chr(96) . Chr(96)
			case "parentheses":
				return "()"
			case "square-brackets":
				return "[]"
			case "curly-braces":
				return "{}"
			case "angle-brackets":
				return "<>"
		}

		return ""
	}


	/**
	 * @param {string} text
	 * @param {string} style
	 * @returns {string}
	 */
	buildCompoundCase(text, style) {
		normalisedText := RegExReplace(text, "([\p{Ll}\p{Nd}])([\p{Lu}])", "$1 $2")
		normalisedText := RegExReplace(normalisedText, "[^\p{L}\p{N}]+", " ")
		normalisedText := Trim(normalisedText)
		if (!StrLen(normalisedText)) {
			return ""
		}

		words := StrSplit(normalisedText, A_Space)
		for (index, word in words) {
			word := StrLower(word)
			if ((style == "camel") && (index == 1)) {
				words[index] := word
				continue
			}

			words[index] := StrUpper(SubStr(word, 1, 1)) . SubStr(word, 2)
		}

		return ArrJoin(words)
	}


	/**
	 * @param {string} text
	 * @returns {string}
	 */
	toTitleCase(text) {
		segments := StrSplit(text, "-")
		for (index, segment in segments) {
			segments[index] := StrTitle(segment)
		}

		return ArrJoin(segments, "-")
	}


	/**
	 * @returns {void}
	 */
	updateSettingsFile() {
		_S := __Settings.settingsFilePath

		try {
			IniWrite(toString(this.settings.isEnabled), _S, this.moduleName, "enabled")
			IniWrite(toString(this.state.isActive), _S, this.moduleName, "activateOnLoad")
			IniWrite(toString(this.settings.sarcasmCase), _S, this.moduleName, "sarcasmCase")
			for (bindingName, hotkeyName in this.settings.hotkeys.OwnProps()) {
				IniWrite(hotkeyName, _S, this.moduleName, this.settings.hotkeySettingKeys.%bindingName%)
			}
		} catch Error as e {
			throw Error("Error updating settings file: " . e.Message)
		}
	}
}
