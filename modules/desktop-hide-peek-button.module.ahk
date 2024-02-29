/************************************************************************
 * @description DesktopHidePeekButton
 * @author Rob McInnes
 * @file desktop-hide-peek-button.module.ahk
 ***********************************************************************/
; Removes the annoying little button at the end of the taskbar
; Checks for external changes every 5 seconds
; Can be forced to override external changes



class module__DesktopHidePeekButton {
	__Init() {
		this.moduleName := "DesktopHidePeekButton"
		this.enabled := getIniVal(this.moduleName, "enabled", true)
		this.settings := {
			activateOnLoad: getIniVal(this.moduleName, "active", false),
			overrideExternalChanges: getIniVal(this.moduleName, "overrideExternalChanges", true),
			resetOnExit: getIniVal(this.moduleName, "resetOnExit", false),
			hWnd: null
		}
		this.states := {
			active: this.settings.activateOnLoad,
			buttonFound: null,
			buttonEnabled: null,
			buttonEnabledOnInit: null
		}
		this.settings.menu := {
			path: "TRAY\Desktop",
			items: [{
				type: "item",
				label: "Hide Peek button"
			}]
		}
	}



	/** */
	__New() {
		if (!this.enabled) {
			return
		}

		thisMenu := this.drawMenu()

		this.runObserver(true)
		SetTimer(ObjBindMethod(this, "runObserver"), 5 * U_msSecond)
	}



	/** */
	__Delete() {
		if (this.settings.resetOnExit) {
			this.setButtonState(this.states.buttonEnabledOnInit)
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
				this.setButtonState(!this.states.active)
		}
	}



	/** */
	getButtonState() {
		if (!isNull(this.settings.hWnd)) {
			try {
				return (ControlGetVisible(this.settings.hWnd) > 0)
			} catch Error as e {
				throw Error("Couldn't get button state")
			}
		}
		return null
	}



	/** */
	setButtonState(state) {
		if (!isNull(this.settings.hWnd)) {
			try {
				if (state) {
					ControlShow("TrayShowDesktopButtonWClass1", "ahk_class Shell_TrayWnd")
				} else {
					ControlHide("TrayShowDesktopButtonWClass1", "ahk_class Shell_TrayWnd")
				}
				this.states.buttonEnabled := state
			} catch Error as e {
				throw Error("Couldn't set button state")
			}
		}
	}



	/** */
	getButtonHwnd() {
		try {
			return ControlGetHwnd("TrayShowDesktopButtonWClass1", "ahk_class Shell_TrayWnd")
		} catch Error as e {
			; throw Error("Couldn't get button handle")
			; NOTE: for some reason an error is thrown when the Start menu is open, so return null instead
			return null
		}
	}



	/** */
	runObserver(forced := false) {
		hWndThen := this.settings.hWnd
		hWndNow := this.getButtonHwnd()
		foundThen := this.states.buttonFound
		foundNow := !isNull(hWndNow)
		enabledThen := this.states.buttonEnabled
		enabledNow := this.getButtonState()

		if ((hWndNow != hWndThen) || (foundNow != foundThen) || (enabledNow != enabledThen)) {
			this.settings.hWnd := hWndNow
			this.states.buttonFound := foundNow
			this.states.buttonEnabled := enabledNow
			this.states.buttonEnabledOnInit := (isNull(this.states.buttonEnabledOnInit) ? enabledNow : null)

			if (forced || this.settings.overrideExternalChanges) {
				if (this.states.active && enabledNow) {
					this.setButtonState(false)
				} else if (!(this.states.active && enabledNow)) {
					this.setButtonState(true)
				}
			} else {
				this.states.active := !enabledNow
			}

			_TSM := this.settings.menu
			setMenuItemProps(_TSM.items[1].label, getMenu(_TSM.path), {
				checked: this.states.active,
				enabled: this.states.buttonFound
			})
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
