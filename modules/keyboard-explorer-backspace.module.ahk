/**********************************************************
 * @name KeyboardExplorerBackspace
 * @author RM
 * @file keyboard-explorer-backspace.module.ahk
 *********************************************************/
;
; TODO: triple click to select all in any file open edit control (e.g. notepad, wordpad, etc.)



class module__KeyboardExplorerBackspace {
	__Init() {
		this.moduleName := moduleName := "KeyboardExplorerBackspace"
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
				label: "Enable backspace in File Explorer"
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
		doBackspace := ObjBindMethod(this, "doBackspace")

		HotIfWinActive("ahk_group explorerWindows")
		Hotkey("BackSpace", doBackspace, (state ? "on" : "off"))
		HotIfWinActive()
	}



	doBackspace(*) {
		renaming := false

		for (i, classNN in WinGetControls("A")) {
			if (classNN == "Edit1") {
				renaming := true
				break
			}
		}

		if (renaming) {
			ControlSend("{Backspace}", "Edit1", "A")
		} else {
			Send("!{Up}")
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
