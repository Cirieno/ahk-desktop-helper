/************************************************************************
 * @description DesktopHidePeekButton
 * @author Rob McInnes
 * @date 2024-01
 * @file desktop-hide-peek-button.module.ahk
 ***********************************************************************/
; Removes the annoying little button at the end of the taskbar
; Checks for external changes every second
; Can be forced to override external changes



class module__DesktopHidePeekButton {
	__Init() {
		this.moduleName := "DesktopHidePeekButton"
		this.enabled := getIniVal(this.moduleName, "enabled", true)
		this.settings := {
			activateOnLoad: getIniVal(this.moduleName, "active", false),
			overrideExternalChanges: getIniVal(this.moduleName, "overrideExternalChanges", true),
			resetOnExit: getIniVal(this.moduleName, "resetOnExit", false),
			fileName: _Settings.app.environment.settingsFile,
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

		this.checkSettingsFile()
	}



	/** */
	__New() {
		if (!this.enabled) {
			return
		}

		thisMenu := this.drawMenu()

		this.runObserver(true)
		SetTimer(ObjBindMethod(this, "runObserver"), 5 * U_msSecond)

		; SetTimer(ObjBindMethod(this, "showDebugTooltip"), U_msSecond)
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
				this.setButtonState(!this.states.active)
		}
	}



	/** */
	getButtonState() {
		if (!isNull(this.settings.hWnd)) {
			try {
				return (ControlGetVisible(this.settings.hWnd) > 0)
			} catch Error as e {
				throw ("Couldn't get button state")
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
				throw ("Couldn't set button state")
			}
		}
	}



	/** */
	getButtonHwnd() {
		try {
			hWnd := ControlGetHwnd("TrayShowDesktopButtonWClass1", "ahk_class Shell_TrayWnd")
			return hWnd
		} catch Error as e {
			; throw ("Couldn't get button hWnd")
			; NOTE: for some reason an error is thrown when the Start menu is open, so return null instead
			return null
		}
	}



	/** */
	runObserver(forced := false) {
		handleThen := this.settings.hWnd
		handleNow := this.getButtonHwnd()
		foundThen := this.states.buttonFound
		foundNow := !isNull(handleNow)
		enabledThen := this.states.buttonEnabled
		enabledNow := this.getButtonState()

		if ((handleNow != handleThen) || (foundNow != foundThen) || (enabledNow != enabledThen)) {
			this.settings.hWnd := handleNow
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
		try {
			IniWrite((this.enabled ? "true" : "false"), this.settings.fileName, this.moduleName, "enabled")
			IniWrite((this.states.active ? "true" : "false"), this.settings.fileName, this.moduleName, "active")
			IniWrite((this.settings.overrideExternalChanges ? "true" : "false"), this.settings.fileName, this.moduleName, "overrideExternalChanges")
			IniWrite((this.settings.resetOnExit ? "true" : "false"), this.settings.fileName, this.moduleName, "resetOnExit")
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
				"overrideExternalChanges=true",
				"resetOnExit=false"
			], "`n")
			FileAppend("`n" . section . "`n", this.settings.fileName)
		}
	}



	/** */
	showDebugTooltip() {
		debugMsg(join([
			"MODULE = " . this.moduleName . "`n",
			"states.active = " . this.states.active,
			"states.buttonFound = " . this.states.buttonFound . " (hWnd: " . Format("{:#x}", this.settings.hWnd) . ")",
			"states.buttonEnabled = " . this.states.buttonEnabled . " (init: " . this.states.buttonEnabledOnInit . ")",
			"settings.overrideExternalChanges = " . this.settings.overrideExternalChanges,
			"settings.resetOnExit = " . this.settings.resetOnExit
		], "`n"), 1, 1)
	}
}
