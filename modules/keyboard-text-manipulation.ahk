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
	__Init() {
		this.moduleName := moduleName := "KeyboardTextManipulation"
		this.settings := {
			useModule: IniUtils.getVal(moduleName, "useModule", true),
			enableKeyboardShortcutsOnLoad: IniUtils.getVal(moduleName, "enableKeyboardShortcutsOnLoad", false),
			enableTextMenuOnLoad: IniUtils.getVal(moduleName, "enableTextMenuOnLoad", false),
			sarcasmCase: IniUtils.getVal(moduleName, "sarcasmCase", "random"),
			defaultHotkeys: {
				textManipulationMenu: "$^!M",
				upperCase: "$^!U",
				lowerCase: "$^!L",
				l33tSpeak: "$^!3",
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
			isPopupMenuHotkeyActive: null,
			onTextManipulationChangeCallback: null,
			hotkeys: Map(),
			popupMenu: null
		}
		this.ui := {
			menu: {
				parentPath: "TRAY\Keyboard-2\Text Manipulation",
				entries: [{
					type: "item",
					label: "Enable keyboard shortcuts"
				}, {
					type: "item",
					labelBase: "Enable popup menu",
					label: "Enable popup menu"
				}]
			},
			popupMenuItems: [{
				type: "header",
				label: "Text Manipulation"
			}, {
				type: "separator"
			}, {
				type: "submenu",
				label: "Formatting",
				entries: [{
					bindingName: "upperCase",
					label: "UPPER CASE"
				}, {
					bindingName: "lowerCase",
					label: "lower case"
				}, {
					bindingName: "l33tSpeak",
					label: "L33tSpeak"
				}, {
					bindingName: "titleCase",
					label: "Title Case"
				}, {
					bindingName: "camelCase",
					label: "camelCase"
				}, {
					bindingName: "pascalCase",
					label: "PascalCase"
				}, {
					bindingName: "kebabCase",
					label: "kebab-case"
				}, {
					bindingName: "snakeCase",
					label: "snake_case"
				}, {
					bindingName: "sarcasmCase",
					label: "SaRcAsM cAsE"
				}, {
					bindingName: "joinLines",
					label: "Join Lines"
				}]
			}, {
				type: "submenu",
				label: "Wrapping",
				entries: [{
					bindingName: "singleQuotes",
					label: "Single Quotes"
				}, {
					bindingName: "doubleQuotes",
					label: "Double Quotes"
				}, {
					bindingName: "singleCurlyQuotes",
					label: "Single Curly Quotes"
				}, {
					bindingName: "doubleCurlyQuotes",
					label: "Double Curly Quotes"
				}, {
					bindingName: "backticks",
					label: "Backticks"
				}, {
					bindingName: "parenthesesOpen",
					label: "Parentheses"
				}, {
					bindingName: "squareBracketsOpen",
					label: "Square Brackets"
				}, {
					bindingName: "curlyBracesOpen",
					label: "Curly Braces"
				}, {
					bindingName: "angleBracketsOpen",
					label: "Angle Brackets"
				}]
			}]
		}
	}


	__New() {
		if (!this.settings.useModule) {
			return
		}

		this.state.isActive := this.settings.enableKeyboardShortcutsOnLoad
		this.state.isPopupMenuHotkeyActive := this.settings.enableTextMenuOnLoad
		this.state.onTextManipulationChangeCallback := ObjBindMethod(this, "onTextManipulationChange")
		this.state.hotkeys := this.getResolvedHotkeys()
		this.ui.menu.entries[2].label := this.getPopupLauncherMenuLabel()
		this.state.popupMenu := this.buildPopupMenu()

		thisMenu := this.drawMenu()
		this.syncMenuItem(thisMenu)

		this.setTextManipulationHotkeysEnabled(this.state.isActive)
		this.setPopupMenuHotkeyEnabled(this.state.isPopupMenuHotkeyActive)
	}


	__Delete() {
		if (IsObject(this.state.onTextManipulationChangeCallback)) {
			this.setTextManipulationHotkeysEnabled(false)
			this.setPopupMenuHotkeyEnabled(false)
			this.state.onTextManipulationChangeCallback := null
		}

		this.state.hotkeys := Map()
		this.state.popupMenu := null
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
				this.setTextManipulationHotkeysEnabled(this.state.isActive)
				this.refreshPopupMenu()
				this.updateSettingsFile()
			case this.ui.menu.entries[2].label:
				this.state.isPopupMenuHotkeyActive := !this.state.isPopupMenuHotkeyActive
				this.syncMenuItem(menu)
				this.setPopupMenuHotkeyEnabled(this.state.isPopupMenuHotkeyActive)
				this.updateSettingsFile()
		}
	}


	/**
	 * @param {Menu} menu
	 * @returns {void}
	 */
	syncMenuItem(menu) {
		toggleLabel := this.ui.menu.entries[1].label
		popupLabel := this.ui.menu.entries[2].label
		(this.state.isActive ? menu.Check(toggleLabel) : menu.Uncheck(toggleLabel))
		(this.state.isPopupMenuHotkeyActive ? menu.Check(popupLabel) : menu.Uncheck(popupLabel))
		menu.Enable(toggleLabel)
		menu.Enable(popupLabel)
	}


	/**
	 * @param {boolean} state
	 * @returns {void}
	 */
	setTextManipulationHotkeysEnabled(state) {
		for (bindingName, hotkeyName in this.state.hotkeys) {
			if (bindingName == "textManipulationMenu") {
				continue
			}

			Hotkey(hotkeyName, this.state.onTextManipulationChangeCallback, (state ? "on" : "off"))
		}
	}


	/**
	 * @param {boolean} state
	 * @returns {void}
	 */
	setPopupMenuHotkeyEnabled(state) {
		hotkeyName := this.state.hotkeys["textManipulationMenu"]
		if (isEmpty(hotkeyName)) {
			return
		}

		Hotkey(hotkeyName, this.state.onTextManipulationChangeCallback, (state ? "on" : "off"))
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

		if (bindingName == "textManipulationMenu") {
			this.showPopupMenu()
			return
		}

		this.runBindingAction(bindingName)
	}


	/**
	 * @param {string} bindingName
	 * @returns {void}
	 */
	runBindingAction(bindingName) {

		switch (bindingName) {
			case "upperCase":
				this.doPaste("upper-case")
			case "lowerCase":
				this.doPaste("lower-case")
			case "l33tSpeak":
				this.doPaste("l33t-speak")
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
	 * @returns {Menu}
	 */
	buildPopupMenu() {
		popupMenu := Menu()
		this.addPopupMenuEntries(popupMenu, this.ui.popupMenuItems)

		return popupMenu
	}


	/**
	 * @returns {void}
	 */
	refreshPopupMenu() {
		this.state.popupMenu := this.buildPopupMenu()
	}


	/**
	 * @param {Menu} menuObj
	 * @param {Array} entries
	 * @returns {void}
	 */
	addPopupMenuEntries(menuObj, entries) {
		headerHandler := ObjBindMethod(this, "onPopupMenuHeadingClick")

		for (i, item in entries) {
			if (item.HasOwnProp("type") && ((item.type == "separator") || (item.type == "---"))) {
				menuObj.Add()
				continue
			}

			if (item.HasOwnProp("type") && (item.type == "header")) {
				menuObj.Add(item.label, headerHandler)
				menuObj.Default := item.label
				continue
			}

			if (item.HasOwnProp("type") && (item.type == "submenu")) {
				childMenu := Menu()
				this.addPopupMenuEntries(childMenu, item.entries)
				menuObj.Add(item.label, childMenu)
				continue
			}

			label := this.formatPopupMenuLabel(item.label, item.bindingName)
			menuObj.Add(label, ObjBindMethod(this, "onPopupMenuItemClick", item.bindingName))
		}
	}


	/**
	 * @returns {void}
	 */
	showPopupMenu() {
		if (!isMenu(this.state.popupMenu)) {
			return
		}

		this.state.popupMenu.Show()
	}


	/**
	 * @param {string} bindingName
	 * @returns {void}
	 */
	onPopupMenuItemClick(bindingName, *) {
		this.runBindingAction(bindingName)
	}


	/**
	 * @returns {void}
	 */
	onPopupMenuHeadingClick(*) {
	}


	/**
	 * @param {string} englishLabel
	 * @param {string} bindingName
	 * @returns {string}
	 */
	formatPopupMenuLabel(englishLabel, bindingName) {
		if (!this.state.isActive) {
			return englishLabel
		}

		return englishLabel . " (" . HotkeyUtils.formatHotkeyForDisplay(this.state.hotkeys[bindingName]) . ")"
	}


	/**
	 * @returns {string}
	 */
	getPopupLauncherMenuLabel() {
		return this.ui.menu.entries[2].labelBase . " (" . HotkeyUtils.formatHotkeyForDisplay(this.state.hotkeys["textManipulationMenu"]) . ")"
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
			case "l33t-speak":
				copied := this.toL33tSpeak(copied)
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
					bias := (StrFirstChar(copied) == StrUpper(StrFirstChar(copied)) ? 1 : 0)
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
	 * @param {string} text
	 * @returns {string}
	 */
	toL33tSpeak(text) {
		static replacements := Map(
			"a", "4",
			"b", "8",
			"e", "3",
			"g", "6",
			"i", "1",
			"o", "0",
			"s", "5",
			"t", "7",
			"z", "2"
		)

		characters := StrSplit(text)
		for (index, character in characters) {
			lookup := StrLower(character)
			if (replacements.Has(lookup)) {
				characters[index] := replacements[lookup]
			}
		}

		return ArrJoin(characters)
	}


	/**
	 * @returns {void}
	 */
	updateSettingsFile() {
		_S := __Settings.settingsFilePath

		try {
			IniWrite(toString(this.settings.useModule), _S, this.moduleName, "useModule")
			IniWrite(toString(this.state.isActive), _S, this.moduleName, "enableKeyboardShortcutsOnLoad")
			IniWrite(toString(this.state.isPopupMenuHotkeyActive), _S, this.moduleName, "enableTextMenuOnLoad")
			IniWrite(toString(this.settings.sarcasmCase), _S, this.moduleName, "sarcasmCase")
			for (bindingName, hotkeyName in this.settings.hotkeys.OwnProps()) {
				IniWrite(hotkeyName, _S, this.moduleName, this.settings.hotkeySettingKeys.%bindingName%)
			}
		} catch Error as e {
			throw Error("Error updating settings file: " . e.Message)
		}
	}
}
