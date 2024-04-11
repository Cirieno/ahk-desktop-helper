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
			SetTimer(readHotstrings, -5000)
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
			if (val[3] == listName) {
				try {
					val[4] := state
					Hotstring(":" . val[2] . ":" . key, val[1], (state ? "on" : "off"))
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
				if (trigger !== replacement) {
					this.settings.hotstrings.Set(trigger, [replacement, modifiers, listName, state])
				}
			}
		}

		this.setHotstrings(listName, state)
	}



	makeTriggers(trigger, replacement, triggers := []) {
		pattern := "S)((?:\[(.+?)\])([\?\+\^\!\#]?))"
		posStart := 1
		matchFound := false

		while (RegExMatch(trigger, pattern, &match, posStart)) {
			posStart := (match.pos + 1)
			matchFound := (matchFound || true)

			switch (match[3]) {
				case "!":
					do(ArrConcat([""], StrSplit(match[2])))
				case "+":
					do(this.getCharCombos(match[2]))
				case "?":
					do([match[2], ""])
				default:
					do(StrSplit(match[2]))
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



	; https://www.autohotkey.com/boards/viewtopic.php?p=158444#p158444
	getCharCombos(str) {
		if ((len := StrLen(str)) == 1) {
			return [str]
		}
		result := []
		loop len {
			Split1 := SubStr(str, 1, A_Index - 1)    ; before pos
			Split2 := SubStr(str, A_Index, 1)    ; at pos
			Split3 := SubStr(str, A_Index + 1)    ; after pos
			for Perm in this.getCharCombos(Split1 Split3) {
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
		outputFileDir := A_WorkingDir . "\releases\" . __Settings.app.build.version
		outputFilePath := outputFileDir . "\default.autocorrect.txt"
		if (!DirExist(outputFileDir)) {
			DirCreate(outputFileDir)
		}
		if (FileExist(outputFilePath)) {
			FileDelete(outputFilePath)
		}

		lines := Map()    ; Maps don't allow duplicate entries and also sort alphabetically
		hotkeys := []
		comments := []

		this.importWikipediaCommonMisspellings(&lines)
		this.importWikipediaCommonGrammar(&lines)
		this.importWiktionaryDiacritics(&lines)
		this.importCdelaHousseAutoCorrect(&lines)
		this.importAdditionals(&lines)

		for key, val in lines {
			if (StrCharAt(key, 1) == ";") {
				comments.Push(key)
			} else {
				hotkeys.Push(key)
			}
		}

		FileAppend(ArrJoin(hotkeys, "`n") . "`n`n", outputFilePath)
		FileAppend(ArrJoin(comments, "`n") . "`n`n", outputFilePath)

		MsgBox("Default list built", (__Settings.app.name . " - AutoCorrect"), (0 + 64 + 4096) . " T5")
	}



	importWikipediaCommonMisspellings(&lines) {
		filePath := A_WorkingDir . "\autocorrect_lists\wikipedia_common_misspellings.txt"
		fileContent := (FileExist(filePath) ? FileRead(filePath) : null)

		fileContent := RegExReplace(fileContent, "S)\s?insource:(\/.*\/)?", "")    ; remove the insource: term
		fileContent := RegExReplace(fileContent, "S)\[+wikt:(.*?)\|.*?\]+", "$1")    ; remove the wikt: term
		fileContent := RegExReplace(fileContent, "S)[\[\]]{2}", "")    ; remove double brackets from around words
		fileContent := RegExReplace(fileContent, "S)\s+\[(.*?)\]", "")    ; remove words in single square brackets

		loop parse fileContent, "`n", "`r" {
			line := Trim(A_LoopField)

			regex := "S){{search link\|`"?(.*?)(?:`"?\s*\|.*?)?(?:(?:\|+ns\d+)*)?}} \((.*?)\)(?: \(.*\))?"
			RegExMatch(line, regex, &match)
			if (match && match.pos && !isEmpty(match[1]) && !isEmpty(match[2])) {
				trigger := Trim(match[1])
				replacement := Trim(match[2])

				str := ArrJoin([replacement, trigger], "|", , true)

				found := false
				chars := StrSplit("\|,<.>/?;:@[{]}#~``¦!`"£$%^&*()_=+")
				for ii, needle in chars {
					if (StrIncludes(replacement, needle)) {
						found := true
						break
					}
				}
				if (trigger == replacement) {
					continue
				}
				if (StrCharAt(line, 1) == ";") {
					found := true
				}
				if (StrIncludes(match[1], " -")) {
					found := true
				}
				if (StrIncludes(match[2], "variant of")) {
					found := true
				}

				if (!found) {
					lines.Set(str, null)
					this.replaceAccents(&trigger, replacement)
					str := ArrJoin([replacement, trigger], "|", , true)
					lines.Set(str, null)
				} else {
					str := StrReplace("; " . str, "`; `;", ";")
					lines.Set(str, null)
				}
			}
		}
	}



	importWikipediaCommonGrammar(&lines) {
		filePath := A_WorkingDir . "\autocorrect_lists\wikipedia_common_grammar.txt"
		fileContent := (FileExist(filePath) ? FileRead(filePath) : null)

		fileContent := RegExReplace(fileContent, "S)\s?insource:(\/.*\/)?", "")    ; remove the insource: term
		fileContent := RegExReplace(fileContent, "S)\[+wikt:(.*?)\|.*?\]+", "$1")    ; remove the wikt: term
		fileContent := RegExReplace(fileContent, "S)[\[\]]{2}", "")    ; remove double brackets from around any words
		fileContent := RegExReplace(fileContent, "S)\s+\[(.*?)\]", "")    ; remove words in single square brackets

		loop parse fileContent, "`n", "`r" {
			line := Trim(A_LoopField)
			found := false

			regex := "S){{search link\|`"?(.*?)(?:`"?\s*\|.*?)?(?:(?:\|+ns\d+)*)?}} \((.*?)\)(?: \(.*\))?"
			RegExMatch(line, regex, &match)
			if (match && match.pos && !isEmpty(match[1]) && !isEmpty(match[2])) {
				trigger := Trim(match[1])
				replacement := Trim(match[2])

				str := ArrJoin([replacement, trigger], "|", , true)

				chars := StrSplit("\|,<.>/?;:@[{]}#~``¦!`"£$%^&*()_=+")
				for ii, needle in chars {
					if (StrIncludes(replacement, needle)) {
						found := true
						break
					}
				}
				if (trigger == replacement) {
					continue
				}
				if (StrCharAt(line, 1) == ";") {
					found := true
				}
				if (StrIncludes(match[1], " -")) {
					found := true
				}
				if (StrIncludes(match[2], "variant of")) {
					found := true
				}

				if (!found) {
					lines.Set(str, null)
					this.replaceAccents(&trigger, replacement)
					str := ArrJoin([replacement, trigger], "|", , true)
					lines.Set(str, null)
				} else {
					str := StrReplace("; " . str, "`; `;", ";")
					lines.Set(str, null)
				}
			}
		}
	}



	importWiktionaryDiacritics(&lines) {
		filePath := A_WorkingDir . "\autocorrect_lists\wiktionary_english_diacritics.txt"
		fileContent := (FileExist(filePath) ? FileRead(filePath) : null)

		loop parse fileContent, "`n", "`r" {
			line := Trim(A_LoopField)
			found := false

			regex := "^(.*?)\|(.*?)(?:\|(.*))?$"
			RegExMatch(line, regex, &match)
			if (match && match.pos && !isEmpty(match[1]) && !isEmpty(match[2])) {
				trigger := Trim(match[2])
				replacement := Trim(match[1])
				modifiers := Trim(match[3])

				str := ArrJoin([replacement, trigger, modifiers], "|", , true)

				if (trigger == replacement) {
					continue
				}
				if (StrCharAt(line, 1) == ";") {
					found := true
				}

				if (!found) {
					lines.Set(str, null)
					this.replaceAccents(&trigger, replacement)
					str := ArrJoin([replacement, trigger, modifiers], "|", , true)
					lines.Set(str, null)
				} else {
					str := StrReplace("; " . str, "`; `;", ";")
					lines.Set(str, null)
				}
			}
		}
	}



	importCdelaHousseAutoCorrect(&lines) {
		filePath := A_WorkingDir . "\autocorrect_lists\cdelahousse_autocorrect.txt"
		fileContent := (FileExist(filePath) ? FileRead(filePath) : null)

		loop parse fileContent, "`n", "`r" {
			line := Trim(A_LoopField)
			found := false

			regex := "S)::(.*)::(.*)"
			RegExMatch(line, regex, &match)
			if (match && match.pos && !isEmpty(match[1]) && !isEmpty(match[2])) {
				trigger := Trim(match[1])
				replacement := Trim(match[2])

				str := ArrJoin([replacement, trigger], "|", , true)

				if (trigger == replacement) {
					continue
				}
				if (StrCharAt(line, 1) == ";") {
					found := true
				}

				if (!found) {
					lines.Set(str, null)
					this.replaceAccents(&trigger, replacement)
					str := ArrJoin([replacement, trigger], "|", , true)
					lines.Set(str, null)
				} else {
					str := StrReplace("; " . str, "`; `;", ";")
					lines.Set(str, null)
				}
			}
		}
	}



	importAdditionals(&lines) {
		filePath := A_WorkingDir . "\autocorrect_lists\additionals.txt"
		fileContent := (FileExist(filePath) ? FileRead(filePath) : null)

		loop parse fileContent, "`n", "`r" {
			line := Trim(A_LoopField)
			found := false

			regex := "^(.*?)\|(.*?)(?:\|(.*))?$"
			RegExMatch(line, regex, &match)
			if (match && match.pos && !isEmpty(match[1]) && !isEmpty(match[2])) {
				trigger := Trim(match[2])
				replacement := Trim(match[1])
				modifiers := Trim(match[3])

				str := ArrJoin([replacement, trigger, modifiers], "|", , true)

				if (trigger == replacement) {
					continue
				}
				if (StrCharAt(line, 1) == ";") {
					found := true
				}

				if (!found) {
					lines.Set(str, null)
					this.replaceAccents(&trigger, replacement)
					str := ArrJoin([replacement, trigger, modifiers], "|", , true)
					lines.Set(str, null)
				} else {
					str := StrReplace("; " . str, "`; `;", ";")
					lines.Set(str, null)
				}
			}
		}
	}



	replaceAccents(&trigger, replacement) {
		chars := [
			["a", "àáâãäå"],
			["c", "ç"],
			["e", "èéêë"],
			["i", "ìíîï"],
			["n", "ñ"],
			["o", "òóôõöø"],
			["u", "ùúûüū"],
			["y", "ýÿ"],
			["A", "ÀÁÂÃÄÅ"],
			["C", "Ç"],
			["E", "ÈÉÊË"],
			["I", "ÌÍÎÏ"],
			["N", "Ñ"],
			["O", "ÒÓÔÕÖØ"],
			["U", "ÙÚÛÜŪ"],
			["Y", "ÝŸ"]
		]

		regex := "S)[^\w\s\!\`"\£\$\%\^\&\*\(\)\_\+\-\=\|\\\<\>\,\.\?\/\{\}\[\]\#\:\;\@\'\``]"
		RegExMatch(replacement, regex, &match)
		if (match) {
			triggerNew := replacement
			for ii, arr in chars {
				for jj, accent in StrSplit(arr[2]) {
					triggerNew := StrReplace(triggerNew, accent, StrWrap(arr[1] . accent, 2), true)
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
		filePath := A_WorkingDir . "\user.autocorrect.txt"
		if (!FileExist(filePath)) {
			str := ArrJoin([
				";" . StrRepeat("-", 69),
				"; https://www.autohotkey.com/docs/v2/Hotstrings.htm",
				";",
				"; USAGE:",
				";    replacement | trigger | modifiers",
				";",
				"; CHARACTER COMBINATIONS:",
				";    [abc] = one of these characters must be present at this position",
				";    [abc]! = one (or none) of these characters must be present at this position",
				";    [abc]+ = all of these characters must be present in any order",
				";    [abc]? = this phrase is optional",
				";",
				"; MODIFIERS: (optional 3rd parameter)",
				";    * = an ending character is not required to trigger",
				";    ? = the hotstring will be triggered even when it is inside another word",
				";    C = case sensitive",
				";    C1 = ignore the trigger case and return the replacement as typed",
				";    B0 = turn off backspacing",
				";    O = remove the trigger character",
				";    R = send raw output",
				";" . StrRepeat("-", 69),
				"; examples:",
				";    {U+02DC}\_({U+30C4})_/{U+02DC}|//shrug|*   -->   ˜\_(ツ)_/˜",
				"`n`n"
			], "`n")
			FileAppend(str, filePath)
		}
	}
}
