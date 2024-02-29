/************************************************************************
 * @description KeyboardExplorerBackspace
 * @author Rob McInnes
 * @file keyboard-explorer-backspace.module.ahk
 ***********************************************************************/



class module__KeyboardExplorerBackspace {
	__Init() {
		this.moduleName := "KeyboardExplorerBackspace"
		this.enabled := getIniVal(this.moduleName, "enabled", true)
		this.settings := {
			activateOnLoad: getIniVal(this.moduleName, "active", false)
		}
		this.states := {
			active: this.settings.activateOnLoad
		}
		this.settings.menu := {
			path: "TRAY\Keyboard",
			items: [{
				type: "item",
				label: "Enable backspace in File Explorer"
			}]
		}
	}



	/** */
	__New() {
		if (!this.enabled) {
			return
		}

		thisMenu := this.drawMenu()
		setMenuItemProps(this.settings.menu.items[1].label, thisMenu, { checked: this.states.active })

		this.setHotkeys(this.states.active)
	}



	/** */
	__Delete() {
		; nothing to do
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
		for item in this.settings.menu.items {
			if (item.type == "item") {
				local doMenuItem := ObjBindMethod(this, "doMenuItem")
				menuItemKey := setMenuItem(item.label, thisMenu, doMenuItem)
			}
		}

		return (isMenu(thisMenu) ? thisMenu : null)
	}



	/** */
	doMenuItem(name, position, menu) {
		switch (name) {
			case this.settings.menu.items[1].label:
				this.states.active := !this.states.active
				setMenuItemProps(name, menu, { checked: this.states.active, clickCount: +1 })
				this.setHotkeys(this.states.active)
		}
	}



	/** */
	setHotkeys(state) {
		HotIfWinActive("ahk_group explorerWindows")    ;// defined in constants.utils.ahk
		Hotkey("BackSpace", doBackspace, (state ? "on" : "off"))
		HotIfWinActive()

		doBackspace(*) {
			try {
				renaming := toBoolean(ControlGetVisible("Edit1", "A"))
			} catch Error as e {
				renaming := false
			}

			if (renaming) {
				SendInput("{Backspace}")
			} else {
				SendInput("!{Up}")
			}
		}
	}



	/** */
	updateSettingsFile() {
		_SAE := _Settings.app.environment
		try {
			IniWrite((this.enabled ? "true" : "false"), _SAE.settingsFilename, this.moduleName, "enabled")
			IniWrite((this.states.active ? "true" : "false"), _SAE.settingsFilename, this.moduleName, "active")
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
}
