/**********************************************************
 * @name KeyboardExplorerDialogSlashes
 * @author RM
 * @file keyboard-explorer-dialog-slashes.module.ahk
 *********************************************************/
; Replaces forward-slashes with back-slashes in Explorer-based windows
;     and File dialogs, useful when working with LAMP paths in VSCode



class module__KeyboardExplorerDialogSlashes {
	__Init() {
		this.moduleName := moduleName := "KeyboardExplorerDialogSlashes"
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
				label: "Replace fwd slashes in File Explorer"
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
		doPaste := ObjBindMethod(this, "doPaste")

		HotIf(this.checkCtrl)
		Hotstring(":*:/", "\", (state ? "on" : "off"))
		Hotkey("^v", doPaste, (state ? "on" : "off"))
		; OnMessage(0x0302, doPaste)    ; 0x0302 is WM_PASTE
		; TODO: capture mouse paste events to exisiting windows?
		HotIf()
	}



	checkCtrl() {
		try {
			controls := ["Edit1", "Edit2"]
			control := ControlGetClassNN(ControlGetFocus("A"))
			return (WinActive("ahk_group explorerWindows") && controls.includes(control))
		} catch Error as e {
			return false
		}
	}



	doPaste(*) {
		try {
			clipboardSaved := RegExReplace(A_Clipboard, "S)[\\/]+", "\")
			EditPaste(clipboardSaved, ControlGetFocus("A"))
		} catch Error as e {
			throw Error("Couldn't paste content to control")
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
