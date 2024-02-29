/************************************************************************
 * @description DesktopHideMediaPopup
 * @author Rob McInnes
 * @file desktop-hide-media-popup.module.ahk
 ***********************************************************************/
; Checks for external changes every 5 seconds
; Can be forced to override external changes
; TODO: this also hides the brightness popup...



class module__DesktopHideMediaPopup {
	__Init() {
		this.moduleName := "DesktopHideMediaPopup"
		this.enabled := getIniVal(this.moduleName, "enabled", true)
		this.settings := {
			activateOnLoad: getIniVal(this.moduleName, "active", false),
			overrideExternalChanges: getIniVal(this.moduleName, "overrideExternalChanges", true),
			resetOnExit: getIniVal(this.moduleName, "resetOnExit", false),
			hWnd: null
		}
		this.states := {
			active: this.settings.activateOnLoad,
			popupFound: null,
			popupEnabled: null,
			popupEnabledOnInit: null
		}
		this.settings.menu := {
			path: "TRAY\Desktop",
			items: [{
				type: "item",
				label: "Hide Volume / Brightness popup"
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
			this.setPopupState(this.states.popupEnabledOnInit)
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
				this.setPopupState(!this.states.active)
		}
	}



	/** */
	getPopupState() {
		if (!isNull(this.settings.hWnd)) {
			try {
				return (WinGetStyle(this.settings.hWnd) & WS_MINIMIZE ? false : true)
			} catch Error as e {
				throw Error("Couldn't get popup state")
			}
		}
		return null
	}



	/** */
	setPopupState(state) {
		if (!isNull(this.settings.hWnd)) {
			try {
				if (state) {
					WinRestore(this.settings.hWnd)
				} else {
					WinMinimize(this.settings.hWnd)
				}
				this.states.popupEnabled := state
			} catch Error as e {
				throw Error("Couldn't set popup state")
			}
		}
	}



	/** */
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



	/** */
	runObserver(forced := false) {
		hWndThen := this.settings.hWnd
		hWndNow := this.getPopupHwnd()
		foundThen := this.states.popupFound
		foundNow := !isNull(hWndNow)
		enabledThen := this.states.popupEnabled
		enabledNow := this.getPopupState()

		if ((hWndNow != hWndThen) || (foundNow != foundThen) || (enabledNow != enabledThen)) {
			this.settings.hWnd := hWndNow
			this.states.popupFound := foundNow
			this.states.popupEnabled := enabledNow
			this.states.popupEnabledOnInit := (isNull(this.states.popupEnabledOnInit) ? enabledNow : null)

			if (forced || this.settings.overrideExternalChanges) {
				if (this.states.active && enabledNow) {
					this.setPopupState(false)
				} else if (!(this.states.active && enabledNow)) {
					this.setPopupState(true)
				}
			} else {
				this.states.active := !enabledNow
			}

			_TSM := this.settings.menu
			setMenuItemProps(_TSM.items[1].label, getMenu(_TSM.path), {
				checked: this.states.active,
				enabled: this.states.popupFound
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



;
;
;
;
;
;
;
;
;
;
;
;
;
;
; checkMediaPopup() {
; 	_MS := this.settings

; 	hWnd := DllCall("User32\FindWindow", "Str","NativeHWNDHost", "Ptr",0)
; 	isPopupVisible := DllCall("IsWindowVisible", "Ptr",hWnd)

; 	if (this.states.popup == true) {
; 		; hasChild := DllCall("User32\getPopupHwnd", "Ptr",hWnd, "UInt",0x0005)
; 		; hasChild := DllCall("User32\FindWindow", "Str","DirectUIHWND", "Ptr",0)
; 		; WinHide(hwnd)
; 		WinMinimize(hwnd)
; 	}

; 	; ToolTip(
; 	; 	"IsWindowVisible = " . DllCall("IsWindowVisible", "Ptr",hWnd)
; 	; 	. "`nhasChild = " . hasChild
; 	; 	, 0, 0, 12)

; 	; WinShow(hWnd)
; 	; PostMessage(0xC028, 0x0C, 0xA0000,, "ahk_id" hWnd)
; 	; sleep(100)
; 	; MsgBox( (DllCall("IsWindowVisible", "Ptr",hWnd) ? "Yes" : "No"), "OSD visible?", 0x40 )
; 	; }
; }

; this.settings.hWnd := DllCall("User32\FindWindow", "Str", "NativeHWNDHost", "Ptr", 0)

; MsgBox(""
; . "hWnd = " . Format("{:#x}", hWnd) . " (" . hWnd . ")"
; . "`nhWndChild = " . Format("{:#x}", hWndChild) . " (" . hWndChild . ")"
; . "`nStyle = " . Format("{:#x}", wsStyles) . " (" . wsStyles . ")"
; . "`nExStyle = " . Format("{:#x}", wsExStyles) . " (" . wsExStyles . ")"
; 	. "`nis WS_VISIBLE = " . (wsStyles & WS_VISIBLE ? "Yes" : "No")
; 	. "`nhas WS_EX_LAYERED = " . (wsExStyles & WS_EX_LAYERED ? "Yes" : "No")
; 	. "`nhas WS_EX_NOACTIVATE = " . (wsExStyles & WS_EX_NOACTIVATE ? "Yes" : "No")
; 	. "`nhas WS_EX_TOPMOST = " . (wsExStyles & WS_EX_TOPMOST ? "Yes" : "No")
; )
;
;
;
;
;
;
;
;
;
; https://github.com/malensek/3RVX/blob/master/3RVX/HideWin10VolumeOSD.cpp
; https://www.reddit.com/r/AutoHotkey/comments/sgglqo/trying_to_find_a_script_that_closes_the_on_screen/
; https://gist.github.com/krrr/3c3f1747480189dbb71f
; https://superuser.com/questions/1500468/media-control-panel-in-windows-10
; https://www.reddit.com/r/AutoHotkey/comments/owgn3j/volume_brightness_with_osd_aka_flyout/

; WinShow(hWnd)
; use postMessage to show window
; PostMessage(0x0018, 0x0C, 0xA0000, , "ahk_id" hWnd)
; postMessage(0xC028, 0x0C, 0xA0000,, "ahk_id" hWnd)
; sendMessage(0xC028, 0x0C, 0xA0000,, "ahk_id" hWndChild)
; sendMessage(0x0018, 0x0C, 0xA0000,, "ahk_id" hWndChild)
; sleep(100)
; get caption from this windw
; msgbox(WinGetTitle(hWndChild))

; use postMessage to increase volume
; PostMessage(0x319, 0x0C, 0xA0000,, "ahk_id" hWnd)
; send a test postmessage to check e have the right window

; return hWnd
