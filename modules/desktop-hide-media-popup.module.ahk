/**********************************************************
 * @name DesktopHideMediaPopup
 * @author RM
 * @file desktop-hide-media-popup.module.ahk
 *********************************************************/
; Checks for external changes every 5 seconds
; Can be forced to override external changes
; NOTE: this also hides the brightness popup...



class module__DesktopHideMediaPopup {
	__Init() {
		this.moduleName := moduleName := "DesktopHideMediaPopup"
		this.enabled := getIniVal(moduleName, "enabled", true)
		this.settings := {
			activateOnLoad: getIniVal(moduleName, "active", ignore),
			resetOnExit: getIniVal(moduleName, "resetOnExit", true),
			allowExternalChange: getIniVal(moduleName, "allowExternalChange", true),
			hWnd: null
		}
		this.states := {
			active: null,
			popupFound: null,
			popupVisible: null,
			popupVisibleOnLoad: null
		}
		this.settings.menu := {
			path: "TRAY\Desktop",
			items: [{
				type: "item",
				label: "Hide Volume / Brightness popup"
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
			this.setPopupState(this.settings.hWnd, this.states.popupVisibleOnLoad)
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
		for item in this.settings.menu.items {
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



	getPopupHwnd() {
		hWnd := DllCall("FindWindowEx", "Ptr", 0, "Ptr", 0, "Str", "NativeHWNDHost", "Ptr", 0)
		while (hWnd) {
			hWndChild := DllCall("FindWindowEx", "Ptr", hWnd, "Ptr", 0, "Str", "DirectUIHWND", "Ptr", 0)
			if (hWndChild) {
				wsStyles := WinGetStyle(hWnd)
				wsExStyles := WinGetExStyle(hWnd)
				hasWasExStyles := ((wsExStyles & WS_EX_LAYERED) && (wsExStyles & WS_EX_NOACTIVATE) && (wsExStyles & WS_EX_TOPMOST) ? true : false)
				if (hasWasExStyles) {
					return hWnd
				}
			}
		}
		return null
	}



	getPopupState(hWnd) {
		if (isEmpty(hWnd)) {
			return null
		}

		try {
			return (WinGetStyle(hWnd) & WS_MINIMIZE ? false : true)
		} catch Error as e {
			throw Error("Couldn't get popup state")
		}
	}



	setPopupState(hWnd, state) {
		if (isEmpty(hWnd)) {
			return null
		}

		try {
			if (state) {
				WinSetTransparent(0, hWnd)
				WinActivate(hWnd)
				WinHide(hWnd)
				WinSetTransparent(255, hWnd)
			} else {
				WinMinimize(hWnd)
			}
			this.states.popupVisible := this.getPopupState(hWnd)
		} catch Error as e {
			throw Error("Couldn't set popup state")
		}
	}



	runObserver(state := this.states.active, forced := false) {
		hWndThen := this.settings.hWnd
		hWndNow := this.settings.hWnd := this.getPopupHwnd()

		foundThen := this.states.popupFound
		foundNow := this.states.popupFound := !isNull(hWndNow)

		visibleThen := this.states.popupVisible
		visibleNow := this.states.popupVisible := this.getPopupState(hWndNow)

		activeThen := this.states.active
		activeNow := this.states.active := !visibleNow

		if (isNull(foundThen) && isNull(visibleThen)) {
			this.states.popupVisibleOnLoad := visibleNow
		}

		if (isIgnore(state)) {
			setMenuItemProps(this.settings.menu.items[1].label, this.settings.menu.path, { checked: this.states.active })
		} else {
			if ((state !== activeNow) || (hWndNow !== hWndThen) || (foundNow !== foundThen) || (visibleNow !== visibleThen)) {
				if (forced || !this.settings.allowExternalChange){
					this.states.active := state
					this.setPopupState(hWndNow, !state)
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
