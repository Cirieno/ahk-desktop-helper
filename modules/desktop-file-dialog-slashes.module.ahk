/************************************************************************
 * @description DesktopFileDialogSlashes
 * @author Rob McInnes
 * @date 2024-01
 * @file desktop-file-dialog-slashes.module.ahk
 ***********************************************************************/
; Replaces forward-slashes with back-slashes in Explorer-based windows
; and File dialogs, useful when working with LAMP paths in VSCode
;
; `ahk_group explorerWindows` is defined in constants.utils.ahk



class module__DesktopFileDialogSlashes {
	__Init() {
		this.moduleName := "DesktopFileDialogSlashes"
		this.enabled := getIniVal(this.moduleName, "enabled", true)
		this.settings := {
			activateOnLoad: getIniVal(this.moduleName, "active", false),
			resetOnExit: null,
			fileName: _Settings.app.environment.settingsFile,
			menu: {
				path: "TRAY\Desktop",
				items: [{
					type: "item",
					label: "Replace fwd slashes in File dialogs"
				}]
			}
		}
		this.states := {
			active: this.settings.activateOnLoad
		}

		this.checkSettingsFile()
	}



	/** */
	__New() {
		if (!this.enabled) {
			return
		}

		thisMenu := this.drawMenu()
		setMenuItemProps(this.settings.menu.items[1].label, thisMenu, { checked: this.states.active })

		; SetTimer(ObjBindMethod(this, "showDebugTooltip"), U_msSecond)
	}



	/** */
	__Delete() {
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
		; HotIfWinactive("ahk_class #32770")
		HotIfWinactive("ahk_group explorerWindows")
		Hotstring(":*:/", "\", (state ? "on" : "off"))
		Hotkey("^v", doPaste, (state ? "on" : "off"))
		HotIfWinactive()
	}



	/** */
	doPaste(*) {
		try {
			clipboardSaved := StrReplace(A_Clipboard, "/", "\")
			EditPaste(clipboardSaved, ControlGetFocus("A"))
		} catch Error as e {
			throw ("Couldn't paste content to control")
		}
	}



	/** */
	updateSettingsFile() {
		try {
			IniWrite((this.enabled ? "true" : "false"), this.settings.fileName, this.moduleName, "enabled")
			IniWrite((this.states.active ? "true" : "false"), this.settings.fileName, this.moduleName, "active")
		} catch Error as e {
			throw ("Error updating settings file: " . e.Message)
		}
	}



	/** */
	checkSettingsFile() {
		try {
			IniRead(this.settings.fileName, this.moduleName)
		} catch Error as e {
			section := join([
				"[" . this.moduleName . "]",
				"enabled=true",
				"active=false",
			], "`n")
			FileAppend("`n" . section . "`n", this.settings.fileName)
		}
	}



	/** */
	showDebugTooltip() {
		debugMsg(join([
			"MODULE = " . this.moduleName . "`n",
			"states.active = " . this.states.active,
		], "`n"), 1, 1)
	}
}
