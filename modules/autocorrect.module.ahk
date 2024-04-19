/**********************************************************
 * @name AutoCorrect
 * @author RM
 * @file autocorrect.module.ahk
 *********************************************************/



class module__AutoCorrect {
	__Init() {
		this.moduleName := moduleName := "AutoCorrect"
		this.enabled := getIniVal(moduleName, "enabled", true)
		this.settings := {
			activateOnLoad: getIniVal(moduleName, "active", ["user"]),
			hotstrings: Map()
		}
		this.states := {
			active: []
		}
		this.settings.menu := {
			path: "TRAY\AutoCorrect",
			items: [{
				type: "item",
				label: "Default list"
			}, {
				type: "item",
				label: "User list"
			}, {
				type: "separator"
			}, {
				type: "item",
				label: "Edit User list" . U_ellipsis
			}, {
				type: "---"
			}, {
				type: "item",
				label: "Show counts"
			}]
		}

		this.checkUserAutocorrectFile()
	}



	__New() {
		if (!this.enabled) {
			return
		}

		thisMenu := this.drawMenu()

		lists := ["default", "user"]
		for ii, listName in lists {
			listIsActive := this.settings.activateOnLoad.includes(listName)
			(listIsActive ? this.states.active.push(listName) : this.states.active.remove(listName))

			switch (listName) {
				case "default":
					setMenuItemProps(this.settings.menu.items[1].label, thisMenu, { checked: listIsActive })
				case "user":
					setMenuItemProps(this.settings.menu.items[2].label, thisMenu, { checked: listIsActive })
			}

			; the default list is big, so load any lists a few seconds after the app has loaded
			readHotstrings := ObjBindMethod(this, "readHotstrings", listName, listIsActive)
			SetTimer(readHotstrings, -2000)
		}
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
		for ii, item in this.settings.menu.items {
			switch (item.type) {
				case "item":
					setMenuItem(item.label, thisMenu, doMenuItem)
				case "separator", "---":
					setMenuItem("---", thisMenu)
			}
		}
		if __DEBUGGING {
			setMenuItem("---", thisMenu)
			setMenuItem("Build Default list", thisMenu, doMenuItem)
		}

		return (isMenu(thisMenu) ? thisMenu : null)
	}



	doMenuItem(name, position, menu) {
		switch (name) {
			case this.settings.menu.items[1].label:
				do("default")
			case this.settings.menu.items[2].label:
				do("user")
			case this.settings.menu.items[4].label:
				this.editFile("user")
			case this.settings.menu.items[6].label:
				this.showHotstringsInfo()
			case "Build Default list":
				this.buildDefaultList()
		}

		do(listName) {
			listIsActive := this.states.active.includes(listName)
			(listIsActive ? this.states.active.remove(listName) : this.states.active.push(listName))
			listIsActive := !listIsActive

			setMenuItemProps(name, menu, { checked: listIsActive, clickCount: +1 })

			this.setHotstrings(listName, listIsActive)
		}
	}



	setHotstrings(listName, state) {
		; key = trigger, val = [replacement, modifiers, listName, state]
		for key, val in this.settings.hotstrings {
			trigger := key
			replacement := val[1]
			modifiers := val[2]

			if (val[3] == listName) {
				try {
					val[4] := state
					Hotstring(":" . modifiers . ":" . key, replacement, (state ? "on" : "off"))
				} catch Error as e {
					; throw Error("Error setting hotstring: " . e.Message)
				}
			}
		}
	}



	readHotstrings(listName, state) {
		filePath := A_WorkingDir . "\" . listName . ".autocorrect.txt"
		fileContent := (FileExist(filePath) ? FileRead(filePath) : "")

		loop parse fileContent, "`n", "`r" {
			line := Trim(A_LoopField)

			if (isEmpty(line) || [";", "#"].includes(StrCharAt(line, 1))) {
				continue
			}

			replacement := "", trigger := "", modifiers := ""
			arr := StrSplit(line, "|")
			if (isEmpty(arr) || (arr.length < 2)) {
				continue
			}
			trigger := arr[2]
			replacement := arr[1]
			modifiers := ((arr.length >= 3) ? arr[3] : "")

			triggers := this.makeTriggers(trigger, replacement)
			for trigger in triggers {
				if (trigger == replacement) {
					continue
				}
				this.settings.hotstrings.Set(trigger, [replacement, modifiers, listName, state])
			}
		}

		for key, val in this.settings.hotstrings {
			trigger := key
			modifiers := val[2]
			if (InStr(modifiers, "X")) {
				this.settings.hotstrings.delete(trigger)
			}
		}


		this.setHotstrings(listName, state)
	}



	makeTriggers(trigger, replacement, triggers := []) {
		pattern := "S)((?:\[(.+?)\])([\?\+\^\!\#\*]?))"
		posStart := 1
		matchFound := false

		while (RegExMatch(trigger, pattern, &match, posStart)) {
			posStart := (match.pos + 1)
			matchFound := (matchFound || true)

			; [abc]* = one or none of these characters must be present at this position
			; [abc]? = one of these characters must be present at this position
			; [abc]+ = all of these characters must be present in any order
			; [abc]! = this phrase is optional

			switch (match[3]) {
				case "*":
					do(ArrConcat(StrSplit(match[2]), [""]))
				case "?":
					do(StrSplit(match[2]))
				case "+":
					do(this.makeCharCombos(match[2]))
				case "!":
					do([match[2], ""])
			}
		}

		if (!matchFound && !triggers.includes(trigger)) {
			triggers.push(trigger)
		}

		return triggers


		do(combos) {
			for combo in combos {
				triggerNew := StrReplace(trigger, match[1], combo)
				if (triggerNew !== replacement) && !RegExMatch(triggerNew, pattern) && !triggers.includes(triggerNew) {
					triggers.push(triggerNew)
				} else {
					this.makeTriggers(triggerNew, replacement, triggers)
				}
			}
		}
	}



	makeCharCombos(str) {
		if ((len := StrLen(str)) == 1) {
			return [str]
		}
		result := []
		loop len {
			Split1 := SubStr(str, 1, A_Index - 1)    ; before pos
			Split2 := SubStr(str, A_Index, 1)    ; at pos
			Split3 := SubStr(str, A_Index + 1)    ; after pos
			for Perm in this.makeCharCombos(Split1 Split3) {
				result.push(Split2 . Perm)
			}
		}
		return result
	}



	editFile(listName) {
		filePath := A_WorkingDir . "\" . listName . ".autocorrect.txt"
		if (!FileExist(filePath)) {
			return
		}

		exitcode := RunWait(A_WinDir . "\notepad.exe " . StrWrap(filePath, 5))
		if (exitcode == 0) {
			Reload()
		}
	}



	showHotstringsInfo() {
		counts := Map()
		counts["default"] := 0
		counts["user"] := 0

		for key, val in this.settings.hotstrings {
			listName := val[3]
			counts[listName]++
		}

		title := __Settings.app.name . " — Hotstrings Info" . U_ellipsis
		msg := MsgboxJoin([
			"Default list: " . counts["default"] . " " . StrWrap(BoolToString(this.states.active.includes("default"), 2), 2),
			"User list: " . counts["user"] . " " . StrWrap(BoolToString(this.states.active.includes("user"), 2), 2),
		])
		MsgBox(msg, title, (0 + 64 + 4096))
	}



	buildDefaultList() {
		fileDir := A_WorkingDir
		if (!DirExist(fileDir)) {
			DirCreate(fileDir)
		}

		filePath := fileDir . "\default.autocorrect.txt"
		if (FileExist(filePath)) {
			FileDelete(filePath)
		}

		lines := Map()    ; because Maps avoid duplicate entries and also sort alphabetically
		lines.CaseSense := false
		hotkeys := []
		comments := []

		this.import_WikipediaCommonMisspellings(&lines)
		this.import_WikipediaCommonGrammar(&lines)
		this.import_WiktionaryDiacritics(&lines)
		this.import_CdelaHousseAutoCorrect(&lines)
		this.import_AdditionalsAndOverrides(&lines)

		for key, val in lines {
			if (StrCharAt(key, 1) == ";") {
				comments.Push(key)
			} else {
				hotkeys.Push(key)
			}
		}

		str := ArrJoin([
			";" . StrRepeat("-", 69),
			"; " . __Settings.app.name . " v" . __Settings.app.build.version,
			"; " . this.moduleName . " — Default list",
			"; " . FormatTime(A_Now, "yyyy-MM-dd HH:mm"),
			this.listBoilerplateText(),
		], "`n")
		FileAppend(str . "`n`n`n", filePath)

		FileAppend(ArrJoin([hotkeys.join("`n"), comments.join("`n")], "`n`n`n"), filePath)

		MsgBox("Default list built", (__Settings.app.name . " - AutoCorrect"), (0 + 64 + 4096) . " T3")
	}



	import_WikipediaCommonMisspellings(&lines) {
		filePath := A_WorkingDir . "\autocorrect_lists\wikipedia_list_of_common_misspellings.txt"
		fileContent := (FileExist(filePath) ? FileRead(filePath) : null)

		loop parse fileContent, "`n", "`r" {
			regex := "S)^([;#\- ]+)?(.*) - {(.*)}$"
			RegExMatch(Trim(A_LoopField), regex, &match)
			if (match && !isEmpty(match[2]) && !isEmpty(match[3])) {
				comment := match[1]
				trigger := match[3]
				replacement := match[2]

				if (trigger == replacement) {
					continue
				}

				if (StrLen(comment)) {
					str := "; " . ArrJoin([replacement, trigger], "|", true)
				} else {
					this.replaceAccents(&trigger, replacement)
					str := ArrJoin([replacement, trigger], "|", true)
				}

				lines.Set(str, null)
			}
		}
	}



	import_WikipediaCommonGrammar(&lines) {
		filePath := A_WorkingDir . "\autocorrect_lists\wikipedia_common_grammar_and_miscellaneous.txt"
		fileContent := (FileExist(filePath) ? FileRead(filePath) : null)

		loop parse fileContent, "`n", "`r" {
			regex := "S)^([;#\- ]+)?(.*) - {(.*)}$"
			RegExMatch(Trim(A_LoopField), regex, &match)
			if (match && !isEmpty(match[2]) && !isEmpty(match[3])) {
				comment := match[1]
				trigger := match[3]
				replacement := match[2]

				if (trigger == replacement) {
					continue
				}

				if (StrLen(comment)) {
					str := "; " . ArrJoin([replacement, trigger], "|", true)
				} else {
					this.replaceAccents(&trigger, replacement)
					str := ArrJoin([replacement, trigger], "|", true)
				}

				lines.Set(str, null)
			}
		}
	}



	import_WiktionaryDiacritics(&lines) {
		filePath := A_WorkingDir . "\autocorrect_lists\wiktionary_english_words_with_diacritics.txt"
		fileContent := (FileExist(filePath) ? FileRead(filePath) : null)

		loop parse fileContent, "`n", "`r" {
			regex := "S)^([;#\- ]+)?(.*)$"
			RegExMatch(Trim(A_LoopField), regex, &match)
			if (match && !isEmpty(match[2])) {
				comment := match[1]
				trigger := match[2]
				replacement := match[2]

				if (StrLen(comment)) {
					str := "; " . ArrJoin([replacement], "|", true)
				} else {
					this.replaceAccents(&trigger, replacement)
					str := ArrJoin([replacement, trigger], "|", true)
				}

				lines.Set(str, null)
			}
		}
	}



	import_CdelaHousseAutoCorrect(&lines) {
		filePath := A_WorkingDir . "\autocorrect_lists\cdelahousse_autocorrect.txt"
		fileContent := (FileExist(filePath) ? FileRead(filePath) : null)

		loop parse fileContent, "`n", "`r" {
			regex := "S)^([;# -]+)?:(.*?):(.*?)::(.*?)$"
			RegExMatch(Trim(A_LoopField), regex, &match)
			if (match && !isEmpty(match[3]) && !isEmpty(match[4])) {
				comment := match[1]
				trigger := match[3]
				replacement := match[4]
				modifiers := match[2]

				if (trigger == replacement) {
					continue
				}

				if (StrLen(comment)) {
					str := "; " . ArrJoin([replacement, trigger, modifiers], "|", true)
				} else {
					this.replaceAccents(&trigger, replacement)
					str := ArrJoin([replacement, trigger, modifiers], "|", true)
				}

				lines.Set(str, null)
			}
		}
	}



	import_AdditionalsAndOverrides(&lines) {
		filePath := A_WorkingDir . "\autocorrect_lists\additionals_and_overrides.txt"
		fileContent := (FileExist(filePath) ? FileRead(filePath) : null)

		loop parse fileContent, "`n", "`r" {
			regex := "^([;# -]+)?(.*?)\|(.*?)(?:\|(.*))?$"
			RegExMatch(Trim(A_LoopField), regex, &match)
			if (match && !isEmpty(match[2]) && !isEmpty(match[3])) {
				comment := match[1]
				trigger := match[3]
				replacement := match[2]
				modifiers := match[4]

				if (trigger == replacement) {
					continue
				}

				if (StrLen(comment)) {
					str := "; " . ArrJoin([replacement, trigger, modifiers], "|", true)
				} else {
					this.replaceAccents(&trigger, replacement)
					str := ArrJoin([replacement, trigger, modifiers], "|", true)
				}

				lines.Set(str, null)
			}
		}
	}



	replaceAccents(&trigger, replacement) {
		chars := [
			["a", "àáâãäåāăą"], ["A", "ÀÁÂÃÄÅĀĂĄ"],
			["c", "çć"], ["C", "ÇĆ"],
			["e", "èéêëēę"], ["E", "ÈÉÊËĒĘ"],
			["i", "ìíîïī"], ["I", "ÌÍÎÏĪ"],
			["l", "ł"], ["L", "Ł"],
			["n", "ñń"], ["N", "ÑŃ"],
			["o", "òóôõöøō"], ["O", "ÒÓÔÕÖØŌ"],
			["s", "śš"], ["S", "ŚŠ"],
			["u", "ùúûüū"], ["U", "ÙÚÛÜŪ"],
			["y", "ýÿȳ"], ["Y", "ÝŸȲ"],
			["Z", "ŹŻ"], ["z", "źż"],
			[" ", "-"],
			["ae", "æ"], ["AE", "Æ"],
			["dh", "ð"], ["DH", "Ð"],
			["oe", "œ"], ["OE", "Œ"],
			["ss", "ß"], ["SS", "ẞ"],
			["th", "þ"], ["TH", "Þ"],
		]

		regex := "S)[^\x00-\x7F]+\ *(?:[^\x00-\x7F]| )*"
		RegExMatch(replacement, regex, &match)
		if (match) {
			triggerNew := replacement
			for arr in chars {
				for accent in StrSplit(arr[2]) {
					if (StrLen(arr[1]) == 1) {
						triggerNew := StrReplace(triggerNew, accent, StrWrap(arr[1] . accent, 2) . "?", true)
					} else {
						triggerNew := StrReplace(triggerNew, accent, arr[1], true)
					}
				}
			}
			trigger := triggerNew
		}
	}



	updateSettingsFile() {
		SFP := __Settings.settingsFilePath

		try {
			IniWrite(toString(this.enabled), SFP, this.moduleName, "enabled")
			IniWrite(StrWrap(toString(this.states.active), 2), SFP, this.moduleName, "active")
		} catch Error as e {
			throw Error("Error updating settings file: " . e.Message)
		}
	}



	checkUserAutocorrectFile() {
		fileDir := A_WorkingDir
		filePath := fileDir . "\user.autocorrect.txt"
		if (!FileExist(filePath)) {
			str := ArrJoin([
				";" . StrRepeat("-", 69),
				"; " . __Settings.app.name . " v" . __Settings.app.build.version,
				"; " . this.moduleName . " — User list",
				this.listBoilerplateText(),
				"; EXAMPLES:",
				";    {U+02DC}\_({U+30C4})_/{U+02DC}|//shrug|*   -->   ˜\_(ツ)_/˜",
			], "`n")
			FileAppend(str . "`n`n`n", filePath)
		}
	}



	listBoilerplateText() {
		return ArrJoin([
			";" . StrRepeat("-", 69),
			"; USAGE:",
			";    replacement|trigger|modifiers",
			";",
			"; CHARACTER COMBINATIONS:",
			";    [abc]* = one of these characters can optionally be at this position",
			";    [abc]? = one of these characters must be at this position",
			";    [abc]+ = all of these characters must be present in any order",
			";    [abc]! = this combination is optional",
			";",
			"; OPTIONAL MODIFIERS:",
			";    ?  = the hotstring will trigger even when inside another word",
			";    *  = an ending character is not required to trigger",
			";    B0 = turn off backspacing",
			";    C  = trigger is case sensitive",
			";    C1 = always send the replacement as typed",
			";    O  = remove the trigger character",
			";    R  = send raw output",
			";    X  = ignore this trigger entirely",
			";" . StrRepeat("-", 69),
		], "`n")
	}
}



;--------------------------------------------------------------------
; NOTES:
; makeCharCombos() from https://www.autohotkey.com/boards/viewtopic.php?p=158444#p158444
;
; SOURCES:
;    https://en.wikipedia.org/wiki/Wikipedia:AutoWikiBrowser/Typos
;    https://en.wikipedia.org/wiki/Commonly_misspelled_English_words
