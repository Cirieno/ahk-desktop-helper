/************************************************************************
 * @description DesktopFileDialogSlashes
 * @author Rob McInnes
 * @file desktop-file-dialog-slashes.module.ahk
 ***********************************************************************/
; Replaces forward-slashes with back-slashes in Explorer-based windows
; and File dialogs, useful when working with LAMP paths in VSCode



class module__DesktopFileDialogSlashes {
	__Init() {
		this.moduleName := "DesktopFileDialogSlashes"
		this.enabled := getIniVal(this.moduleName, "enabled", true)
		this.settings := {
			activateOnLoad: getIniVal(this.moduleName, "active", false)
		}
		this.states := {
			active: this.settings.activateOnLoad
		}
		this.settings.menu := {
			path: "TRAY\Desktop",
			items: [{
				type: "item",
				label: "Replace fwd slashes in File dialogs"
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
		for ii, item in this.settings.menu.items {
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
		local doPaste := ObjBindMethod(this, "doPaste")

		HotIfWinActive("ahk_group explorerWindows")    ;// defined in constants.utils.ahk
		Hotstring(":*:/", "\", state)
		Hotkey("^v", doPaste, state)
		HotIfWinActive()
	}



	/** */
	doPaste(*) {
		try {
			clipboardSaved := StrReplace(A_Clipboard, "/", "\")
			EditPaste(clipboardSaved, ControlGetFocus("A"))
		} catch Error as e {
			throw Error("Couldn't paste content to control")
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
