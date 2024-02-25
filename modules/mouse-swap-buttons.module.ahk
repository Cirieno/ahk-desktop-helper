/************************************************************************
 * @description MouseSwapButtons
 * @author Rob McInnes
 * @file mouse-swap-buttons.module.ahk
 ***********************************************************************/
; Handy for if you're left-handed, or maybe just having an RSI day
; Checks for external changes every 5 seconds



class module__MouseSwapButtons {
	__Init() {
		this.moduleName := "MouseSwapButtons"
		this.enabled := getIniVal(this.moduleName, "enabled", true)
		this.settings := {
			activateOnLoad: getIniVal(this.moduleName, "active", false),
			overrideExternalChanges: getIniVal(this.moduleName, "overrideExternalChanges", false),
			resetOnExit: getIniVal(this.moduleName, "resetOnExit", false)
		}
		this.states := {
			active: this.settings.activateOnLoad,
			buttonsSwapped: null,
			buttonsSwappedOnInit: null
		}
		this.settings.menu := {
			path: "TRAY\Mouse",
			items: [{
				type: "item",
				label: "Swap mouse buttons"
			}]
		}
	}



	/** */
	__New() {
		if (!this.enabled) {
			return
		}

		this.states.buttonsSwapped := this.states.buttonsSwappedOnInit := this.getButtonsState()

		if (this.states.active && !this.states.buttonsSwapped) {
			this.setButtonsState(true)
		} else if (!this.states.active && this.states.buttonsSwapped) {
			this.setButtonsState(false)
		}

		thisMenu := this.drawMenu()
		setMenuItemProps(this.settings.menu.items[1].label, thisMenu, { checked: this.states.active, enabled: isTruthy(SysGet(SM_MOUSEPRESENT)) })

		this.runObserver(true)
		SetTimer(ObjBindMethod(this, "runObserver"), 5 * U_msSecond)
	}



	/** */
	__Delete() {
		if (this.settings.resetOnExit) {
			this.setButtonsState(this.states.buttonsSwappedOnInit)
		}
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
				setMenuItemProps(name, menu, { checked: this.states.active, clickCount: +1, enabled: isTruthy(SysGet(SM_MOUSEPRESENT)) })
				this.setButtonsState(this.states.active)
		}
	}



	/** */
	getButtonsState() {
		try {
			return isTruthy(RegRead("HKEY_CURRENT_USER\Control Panel\Mouse", "SwapMouseButtons", 0))
		} catch Error as e {
			throw Error("Error reading registry key")
		}
	}



	/** */
	setButtonsState(state) {
		try {
			RegWrite((state == true ? 1 : 0), "REG_SZ", "HKEY_CURRENT_USER\Control Panel\Mouse", "SwapMouseButtons")
			DllCall("SwapMouseButton", "int", (state == true ? 1 : 0))
			this.states.buttonsSwapped := state
		} catch Error as e {
			throw Error("Error writing registry key")
		}
	}



	/** */
	runObserver(forced := false) {
		stateThen := this.states.buttonsSwapped
		stateNow := this.getButtonsState()
		if (stateNow !== stateThen) {
			this.states.buttonsSwapped := stateNow
			this.states.active := !this.states.active
			setMenuItemProps(this.settings.menu.items[1].label, this.settings.menu.path, { checked: this.states.active, enabled: SysGet(SM_MOUSEPRESENT) })
		}
	}



	/** */
	updateSettingsFile() {
		_SAE := _Settings.app.environment
		try {
			IniWrite((this.enabled ? "true" : "false"), _SAE.settingsFilename, this.moduleName, "enabled")
			IniWrite((this.states.active ? "true" : "false"), _SAE.settingsFilename, this.moduleName, "active")
			IniWrite((this.settings.overrideExternalChanges ? "true" : "false"), _SAE.settingsFilename, this.moduleName, "overrideExternalChanges")
			IniWrite((this.settings.resetOnExit ? "true" : "false"), _SAE.settingsFilename, this.moduleName, "resetOnExit")
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
