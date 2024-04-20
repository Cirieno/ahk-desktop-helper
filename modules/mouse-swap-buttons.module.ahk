/**********************************************************
 * @name MouseSwapButtons
 * @author RM
 * @file mouse-swap-buttons.module.ahk
 *********************************************************/
; Handy for if you're left-handed, or maybe just having an RSI day
; Checks for external changes every 5 seconds



class module__MouseSwapButtons {
	__Init() {
		this.moduleName := moduleName := "MouseSwapButtons"
		this.enabled := getIniVal(moduleName, "enabled", true)
		this.settings := {
			activateOnLoad: getIniVal(moduleName, "active", ignore),
			resetOnExit: getIniVal(moduleName, "resetOnExit", true),
			allowExternalChange: getIniVal(moduleName, "allowExternalChange", true)
		}
		this.states := {
			active: null,
			mouseFound: null,
			buttonsSwapped: null,
			buttonsSwappedOnLoad: null
		}
		this.settings.menu := {
			path: "TRAY\Mouse",
			items: [{
				type: "item",
				label: "Swap mouse buttons"
			}]
		}
	}



	__New() {
		if (!this.enabled) {
			return
		}

		this.drawMenu()

		this.runObserver(this.settings.activateOnLoad, true)
		SetTimer(ObjBindMethod(this, "runObserver"), 10 * U_msSecond)
	}



	__Delete() {
		if (this.settings.resetOnExit) {
			; this.setButtonsState(this.states.buttonsSwappedOnLoad)
		}
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
				setMenuItemProps(name, menu, {
					checked: this.states.active,
					clickCount: +1,
					enabled: this.states.mouseFound
				})
				this.runObserver(this.states.active, true)
		}
	}



	getButtonsState() {
		try {
			return toBoolean(RegRead("HKEY_CURRENT_USER\Control Panel\Mouse", "SwapMouseButtons", 0))
		} catch Error as e {
			throw Error("Error reading registry key")
		}
	}



	setButtonsState(state) {
		try {
			RegWrite((state ? 1 : 0), "REG_SZ", "HKEY_CURRENT_USER\Control Panel\Mouse", "SwapMouseButtons")
			DllCall("SwapMouseButton", "int", (state ? 1 : 0))
			this.states.buttonsSwapped := this.getButtonsState()
		} catch Error as e {
			throw Error("Error writing registry key")
		}
	}



	runObserver(state := this.states.active, forced := false) {
		foundThen := this.states.mouseFound
		foundNow := this.states.mouseFound := toBoolean(SysGet(SM_MOUSEPRESENT))

		swappedThen := this.states.buttonsSwapped
		swappedNow := this.states.buttonsSwapped := this.getButtonsState()

		activeThen := this.states.active
		activeNow := this.states.active := swappedNow

		if (isNull(foundThen) && isNull(swappedThen)) {
			this.states.buttonsSwappedOnLoad := swappedNow
		}

		if (isIgnore(state)) {
			setMenuItemProps(this.settings.menu.items[1].label, this.settings.menu.path, { checked: this.states.active })
		} else {
			if ((state !== activeNow) || (foundNow !== foundThen) || (swappedNow !== swappedThen)) {
				if (forced || !this.settings.allowExternalChange) {
					this.states.active := state
					this.setButtonsState(state)
				} else {
					this.states.active := activeNow
				}
				setMenuItemProps(this.settings.menu.items[1].label, this.settings.menu.path, {
					checked: this.states.active,
					enabled: this.states.mouseFound
				 })
			}
		}
	}



	updateSettingsFile() {
		SFP := __Settings.settingsFilePath

		try {
			IniWrite(toString(this.enabled), SFP, this.moduleName, "enabled")
			IniWrite(toString(this.states.active), SFP, this.moduleName, "active")
			IniWrite(toString(this.settings.allowExternalChange), SFP, this.moduleName, "allowExternalChange")
			IniWrite(toString(this.settings.resetOnExit), SFP, this.moduleName, "resetOnExit")
		} catch Error as e {
			throw Error("Error updating settings file: " . e.Message)
		}
	}
}
