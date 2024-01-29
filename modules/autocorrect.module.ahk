class module__AutoCorrect {
	__Init() {
		this.moduleName := "AutoCorrect"
		this.enabled := getIniVal(this.moduleName, "enabled", false)
		this.settings := {
			moduleName: this.moduleName,
			enabled: this.enabled,
			activateOnLoad: getIniVal(this.moduleName, "on", ["default", "user"]),
			states: {
				defaultListEnabled: null,
				defaultListLoaded: null,
				userListEnabled: null,
				userListLoaded: null
			},
			menuLabels: {
				rootMenu: "AutoCorrect",
				defaultList: "Default",
				userList: "User",
				editDefaultList: "Edit Default" . ellipsis,
				editUserList: "Edit User" . ellipsis
			},
			hotstrings: []
		}
	}


	__New() {
		if (!this.enabled) {
			return
		}

		if isInArray(this.settings.activateOnLoad, "default") {
			this.settings.states.defaultListEnabled := true
			SetTimer(ObjBindMethod(this, "readHotstrings", "default", true), -3000)
		}
		if isInArray(this.settings.activateOnLoad, "user") {
			this.settings.states.userListEnabled := true
			SetTimer(ObjBindMethod(this, "readHotstrings", "user", true), -1000)
		}
		; this.setState("en-gb", isInArray(this.settings.activateOnLoad, "en-gb"))
		; this.setState("en-us", isInArray(this.settings.activateOnLoad, "en-us"))

		this.drawMenu()
	}


	drawMenu() {
		menuLabels := this.settings.menuLabels
		_ST := _Settings.app.tray
		_SM := _Settings.app.tray.menuHandles
		local doMenuItem := ObjBindMethod(this, "doMenuItem")

		if (_SM.has(menuLabels.rootMenu)) {
			this.rootMenu := rootMenu := _SM[menuLabels.rootMenu]
		} else {
			this.rootMenu := rootMenu := Menu()
			_SM.set(menuLabels.rootMenu, rootMenu)
			A_TrayMenu.add(menuLabels.rootMenu, rootMenu)
			if (_ST.includeSubmenuIcons) {
				A_TrayMenu.setIcon(menuLabels.rootMenu, "icons\" . StrLower(menuLabels.rootMenu) . ".ico", -0)
			}
		}
		rootMenu.add(menuLabels.defaultList, doMenuItem)
		rootMenu.add(menuLabels.userList, doMenuItem)
		rootMenu.add()
		rootMenu.add(menuLabels.editDefaultList, doMenuItem)
		rootMenu.add(menuLabels.editUserList, doMenuItem)
		rootMenu.add()
		rootMenu.add("Show counts", doMenuItem)

		this.tickMenuItems()
	}


	tickMenuItems() {
		try {
			defaultListEnabled := this.settings.states.defaultListEnabled
			userListEnabled := this.settings.states.userListEnabled
			menuLabels := this.settings.menuLabels
			rootMenu := this.rootMenu

			(defaultListEnabled == true ? rootMenu.check(menuLabels.defaultList) : rootMenu.uncheck(menuLabels.defaultList))
			(userListEnabled == true ? rootMenu.check(menuLabels.userList) : rootMenu.uncheck(menuLabels.userList))
		}
	}


	doMenuItem(name, position, menu) {
		defaultListEnabled := this.settings.states.defaultListEnabled
		userListEnabled := this.settings.states.userListEnabled
		menuLabels := this.settings.menuLabels

		switch (name) {
			case menuLabels.defaultList: this.setListState("default", !defaultListEnabled)
			case menuLabels.userList: this.setListState("user", !userListEnabled)
			case menuLabels.editDefaultList: this.editFile("default")
			case menuLabels.editUserList: this.editFile("user")
			case "Show counts": this.showHotstringsInfo()
		}
	}


	setListState(key, state) {
		switch (key) {
			case "default": this.settings.states.defaultListEnabled := state
			case "user": this.settings.states.userListEnabled := state
		}

		this.readHotstrings(key, state)

		this.tickMenuItems()
	}


	readHotstrings(key, state) {
		filename := key . "_autocorrect.txt"
		if FileExist(filename) {
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
		if ((len := StrLen(str)) = 1) {
			return [str]
		}
		result := []
		loop len {
			Split1 := SubStr(str, 1, A_Index - 1)      ; before pos
			Split2 := SubStr(str, A_Index, 1)          ; at pos
			Split3 := SubStr(str, A_Index + 1)         ; after pos
			for each, Perm in this.getCharCombos(Split1 Split3) {
				result.push(Split2 Perm)
			}
		}
		return result
	}


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


	showHotstringsInfo() {
		defaultCount := 0
		userCount := 0

		for index, subArray in this.settings.hotstrings {
			switch (subArray[4]) {
				case "default": defaultCount++
				case "user": userCount++
			}
		}

		MsgBox("ACTIVE HOTSTRINGS"
			. "`n"
			. "`nDefault count: " . defaultCount
			. "`nUser count: " . userCount
			, _Settings.app.name, 4160)
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
