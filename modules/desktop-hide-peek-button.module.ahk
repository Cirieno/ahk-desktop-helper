/**********************************************************
 * @name DesktopHidePeekButton
 * @author RM
 * @file desktop-hide-peek-button.module.ahk
 *********************************************************/
; Removes the annoying little button at the end of the taskbar
; Checks for external changes every 5 seconds
; Can be forced to override external changes



class module__DesktopHidePeekButton {
	__Init() {
		this.moduleName := moduleName := "DesktopHidePeekButton"
		this.enabled := getIniVal(moduleName, "enabled", true)
		this.settings := {
			activateOnLoad: getIniVal(moduleName, "active", ignore),
			resetOnExit: getIniVal(moduleName, "resetOnExit", true),
			allowExternalChange: getIniVal(moduleName, "allowExternalChange", true),
			hWnd: null
		}
		this.states := {
			active: null,
			buttonFound: null,
			buttonVisible: null,
			buttonVisibleOnLoad: null
		}
		this.settings.menu := {
			path: "TRAY\Desktop",
			items: [{
				type: "item",
				label: "Hide Peek button"
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
			this.setButtonState(this.settings.hWnd, this.states.buttonVisibleOnLoad)
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
				setMenuItemProps(name, menu, { checked: this.states.active, clickCount: +1 })
				this.runObserver(this.states.active, true)
		}
	}



	getButtonHwnd() {
		try {
			return ControlGetHwnd("TrayShowDesktopButtonWClass1", "ahk_class Shell_TrayWnd")
		} catch Error as e {
			; throw Error("Couldn't get button handle")
			; NOTE: for some reason an error is thrown when the Start menu is open, so return the old value instead
			return this.settings.hWnd
		}
	}



	getButtonState(hWnd) {
		if (isEmpty(hWnd)) {
			return null
		}

		try {
			return (ControlGetVisible(hWnd) !== 0)
		} catch Error as e {
			throw Error("Couldn't get button state")
		}
	}



	setButtonState(hWnd, state) {
		if (isEmpty(hWnd)) {
			return null
		}

		try {
			if (state) {
				ControlShow(hWnd)
			} else {
				ControlHide(hWnd)
			}
			this.states.buttonVisible := this.getButtonState(hWnd)
		} catch Error as e {
			throw Error("Couldn't set button state")
		}
	}



	runObserver(state := this.states.active, forced := false) {
		hWndThen := this.settings.hWnd
		hWndNow := this.settings.hWnd := this.getButtonHwnd()

		foundThen := this.states.buttonFound
		foundNow := this.states.buttonFound := !isNull(hWndNow)

		visibleThen := this.states.buttonVisible
		visibleNow := this.states.buttonVisible := this.getButtonState(hWndNow)

		activeThen := this.states.active
		activeNow := this.states.active := !visibleNow

		if (isNull(foundThen) && isNull(visibleThen)) {
			this.states.buttonVisibleOnLoad := visibleNow
		}

		if (isIgnore(state)) {
			setMenuItemProps(this.settings.menu.items[1].label, this.settings.menu.path, { checked: this.states.active })
		} else {
			if ((state !== activeNow) || (hWndNow !== hWndThen) || (foundNow !== foundThen) || (visibleNow !== visibleThen)) {
				if (forced || !this.settings.allowExternalChange) {
					this.states.active := state
					this.setButtonState(hWndNow, !state)
				} else {
					this.states.active := activeNow
				}
				setMenuItemProps(this.settings.menu.items[1].label, this.settings.menu.path, { checked: this.states.active })
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
