/************************************************************************
 * @description AutoCorrect
 * @author Rob McInnes
 * @file autocorrect.module.ahk
 ***********************************************************************/



class module__AutoCorrect {
	__Init() {
		this.moduleName := "AutoCorrect"
		this.enabled := getIniVal(this.moduleName, "enabled", true)
		this.settings := {
			activateOnLoad: getIniVal(this.moduleName, "active", ["default", "user"]),
			hotstrings: []
		}
		this.states := {
			defaultListActive: isInArray(this.settings.activateOnLoad, "default"),
			userListActive: isInArray(this.settings.activateOnLoad, "user")
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

		; this.checkUserAutocorrectFile()
	}



	/** */
	__New() {
		if (!this.enabled) {
			return
		}

		thisMenu := this.drawMenu()

		setMenuItemProps(this.settings.menu.items[1].label, thisMenu, { checked: this.states.defaultListActive })
		if (this.states.defaultListActive) {
			SetTimer(ObjBindMethod(this, "readHotstrings", "default", true), -1000)
		}

		setMenuItemProps(this.settings.menu.items[2].label, thisMenu, { checked: this.states.userListActive })
		if (this.states.userListActive) {
			SetTimer(ObjBindMethod(this, "readHotstrings", "user", true), -1000)
		}
	}



	/** */
	__Delete() {
		; remove hotstrings?
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
		for ii, item in this.settings.menu.items {
			switch (item.type) {
				case "item":
					local doMenuItem := ObjBindMethod(this, "doMenuItem")
					menuItemKey := setMenuItem(item.label, thisMenu, doMenuItem)
				case "separator", "---":
					setMenuItem("---", thisMenu)
			}
		}

		return (isMenu(thisMenu) ? thisMenu : null)
	}



	/** */
	doMenuItem(name, position, menu) {
		switch (name) {
			case this.settings.menu.items[1].label:
				this.states.defaultListActive := !this.states.defaultListActive
				setMenuItemProps(name, menu, { checked: this.states.defaultListActive, clickCount: +1 })
				this.readHotstrings("default", this.states.defaultListActive)
			case this.settings.menu.items[2].label:
				this.states.userListActive := !this.states.userListActive
				setMenuItemProps(name, menu, { checked: this.states.userListActive, clickCount: +1 })
				this.readHotstrings("user", this.states.userListActive)
			case this.settings.menu.items[4].label:
				this.editFile("user")
			case this.settings.menu.items[6].label:
				this.showHotstringsInfo()
		}
	}



	/** */
	readHotstrings(key, state) {
		filename := key . "_autocorrect.txt"
		if (FileExist(filename)) {
			loop read, filename {
				readLine := Trim(A_LoopReadLine)
				if (readLine == "") {
					continue
				}

				firstChar := SubStr(readLine, 1, 1)
				if ((firstChar == ";") || (firstChar == "#") || (firstChar == " ")) {
					continue
				}

				replacement := "", trigger := "", modifiers := ""

				Loop parse, readLine, "|" {
					if (replacement == "") {
						replacement := A_LoopField
					} else if (trigger == "") {
						trigger := A_LoopField
					} else {
						modifiers := A_LoopField
					}
				}

				triggers := this.makeTriggers(trigger, replacement)
				for each, trigger in triggers {
					this.settings.hotstrings.push([trigger, replacement, modifiers, key, state])
				}
			}

			for each, trigger in this.settings.hotstrings {
				Hotstring(":" . trigger[3] . ":" . trigger[1], trigger[2], state)
			}
		}
	}



	/** */
	makeTriggers(trigger, replacement, triggers := []) {
		; loop through potentially multiple character sets
		; if the trigger has an [xyz]?+ character set then we need to loop through each character in the set and make a hotstring for each one

		pattern := "((?:\[(.+?)\])([\?\+\^]?))"
		startPos := 1

		if (RegExMatch(trigger, pattern)) {
			while (match := RegExMatch(trigger, pattern, &groups, startPos)) {
				startPos := match + StrLen(groups[1])

				if (groups[3] == "") {
					loop parse groups[2] {
						triggerNew := StrReplace(trigger, groups[1], A_LoopField)
						if (triggerNew !== replacement) && !RegExMatch(triggerNew, pattern) && !isInArray(triggers, triggerNew) {
							triggers.push(triggerNew)
						} else {
							this.makeTriggers(triggerNew, replacement, triggers)
						}
					}
				} else if (groups[3] == "?") {
					triggerNew := StrReplace(trigger, groups[1], "")
					if (triggerNew !== replacement) && !RegExMatch(triggerNew, pattern) && !isInArray(triggers, triggerNew) {
						triggers.push(triggerNew)
					} else {
						this.makeTriggers(triggerNew, replacement, triggers)
					}
					loop parse groups[2] {
						triggerNew := StrReplace(trigger, groups[1], A_LoopField)
						if (triggerNew !== replacement) && !RegExMatch(triggerNew, pattern) && !isInArray(triggers, triggerNew) {
							triggers.push(triggerNew)
						} else {
							this.makeTriggers(triggerNew, replacement, triggers)
						}
					}
				} else if (groups[3] == "+") {
					combos := this.getCharCombos(groups[2])
					for each, combo in combos {
						triggerNew := StrReplace(trigger, groups[1], combo)
						if (triggerNew !== replacement) && !RegExMatch(triggerNew, pattern) && !isInArray(triggers, triggerNew) {
							triggers.push(triggerNew)
						} else {
							this.makeTriggers(triggerNew, replacement, triggers)
						}
					}
				}
			}
		} else {
			triggers := [trigger]
		}

		return triggers
	}



	; https://www.autohotkey.com/boards/viewtopic.php?p=158444#p158444
	getCharCombos(str) {
		if ((len := StrLen(str)) == 1) {
			return [str]
		}
		result := []
		loop len {
			Split1 := SubStr(str, 1, A_Index - 1)    ; before pos
			Split2 := SubStr(str, A_Index, 1)        ; at pos
			Split3 := SubStr(str, A_Index + 1)       ; after pos
			for each, Perm in this.getCharCombos(Split1 Split3) {
				result.push(Split2 Perm)
			}
		}
		return result
	}



	/** */
	editFile(key) {
		switch (key) {
			case "default": filePath := "default_autocorrect.txt"
			case "user": filePath := "user_autocorrect.txt"
		}

		if (FileExist(filePath)) {
			local exitcode := RunWait("C:\Windows\notepad.exe `"" . filePath . "`"")
			if (exitcode == 0) {
				Reload()
			}
		}
	}



	/** */
	showHotstringsInfo() {
		defaultCount := 0
		userCount := 0

		for ii, subArray in this.settings.hotstrings {
			switch (subArray[4]) {
				case "default": defaultCount++
				case "user": userCount++
			}
		}

		MsgBox(join([
			"Default list: " . defaultCount,
			"User list: " . userCount
		], "`n"), (_Settings.app.name . " - Hotstrings Info" . U_ellipsis), (0 + 64 + 4096))
	}



	/** */
	updateSettingsFile() {
		_SAE := _Settings.app.environment
		try {
			state := join([
				(isTruthy(this.states.defaultListActive) ? "default" : ""),
				(isTruthy(this.states.userListActive) ? "user" : "")
			], ",")
			state := RegExReplace(state, ",+", ",")
			state := RegExReplace(state, "^,", "")
			state := RegExReplace(state, ",$", "")

			IniWrite((this.enabled ? "true" : "false"), _SAE.settingsFilename, this.moduleName, "enabled")
			IniWrite("[" . state . "]", _SAE.settingsFilename, this.moduleName, "active")
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



	/** */
	checkUserAutocorrectFile() {
		filename := "user_autocorrect.txt"
		if (!FileExist(filename)) {
			content := join([
				"; https://www.autohotkey.com/docs/v2/Hotstrings.htm",
				";",
				"; USAGE",
				";   replacement | trigger | modifiers",
				";",
				"; CHARACTER COMBINATIONS",
				";   [abc] = one of these characters must be present at this position",
				";   [abc]? = one (or none) of these characters must be present at this position",
				";   [abc]+ = all of these characters must be present in any order",
				";",
				"; MODIFIERS (optional 3rd parameter)",
				";   ? = The hotstring will be triggered even when it is inside another word",
				";   * = an ending character is not required to trigger",
				";   B0 = turn off backspacing",
				";   C = case sensitive",
				";   C1 = ignore the case that was typed, always use the same case for output",
				";   O = remove the trigger character",
				";   R = send raw output",
				";------------------------------------------------------------------------------",
				"`n`n`n"
			], "`n")
			FileAppend(content, filename)
		}
	}
}



; --------------------------------------------------------------
; https://en.wikipedia.org/wiki/Wikipedia:Lists_of_common_misspellings
; https://en.wikipedia.org/wiki/Wikipedia:Lists_of_common_misspellings/Grammar_and_miscellaneous
; https://en.wiktionary.org/wiki/Category:English_terms_by_their_individual_characters
; https://web.archive.org/web/20190310225422/https://en.wiktionary.org/wiki/Appendix:English_words_with_diacritics
; https://github.com/cdelahousse/Autocorrect-AutoHotKey
; https://www.dictionary.com/e/british-english-vs-american-english/
; https://www.grammarly.com/blog/common-grammar-mistakes/
