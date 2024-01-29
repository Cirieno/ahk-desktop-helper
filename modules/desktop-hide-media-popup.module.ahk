class module__DesktopHideMediaPopup {
	__Init() {
		this.moduleName := "DesktopHideMediaPopup"
		this.enabled := getIniVal(this.moduleName, "enabled", false)
		this.settings := {
			moduleName: this.moduleName,
			enabled: this.enabled,
			activateOnLoad: getIniVal(this.moduleName, "on", false),
			states: {
				popupFound: null,
				popupHidden: null
			},
			menuLabels: {
				rootMenu: "Desktop",
				btns: "Hide Volume popup"
			}
		}
	}


	__New() {
		if (!this.enabled) {
			return
		}

		this.settings.hWnd := hWnd := this.getPopupHwnd()
		this.settings.states.popupFound := popupFound := (hWnd !== null)
		activateOnLoad := this.settings.activateOnLoad

		if (popupFound) {
			this.settings.states.popupHidden := popupHidden := !this.getPopupState()

			if (activateOnLoad && !popupHidden) {
				this.setPopupState(false)
			} else if (!activateOnLoad && popupHidden) {
				this.setPopupState(true)
			}
		}

		this.drawMenu()

		SetTimer(ObjBindMethod(this, "setObservers"), 2000)
	}


	drawMenu() {
		menuLabels := this.settings.menuLabels
		_ST := _Settings.app.tray
		_SM := _Settings.app.tray.menuHandles
		local doMenuItem := ObjBindMethod(this, "doMenuItem")

		if (_SM.has(menuLabels.rootMenu)) {
			this.rootMenu := rootMenu := _SM[menuLabels.rootMenu]
		} else {
			this.rootMenu := rootMenu := Menu()
			_SM.set(menuLabels.rootMenu, rootMenu)
			A_TrayMenu.add(menuLabels.rootMenu, rootMenu)
			if (_ST.includeSubmenuIcons) {
				A_TrayMenu.setIcon(menuLabels.rootMenu, "icons\" . StrLower(menuLabels.rootMenu) . ".ico", -0)
			}
		}
		rootMenu.add(menuLabels.btns, doMenuItem)

		this.tickMenuItems()
	}


	tickMenuItems() {
		try {
			popupHidden := this.settings.states.popupHidden
			menuLabels := this.settings.menuLabels
			rootMenu := this.rootMenu

			(popupHidden == true ? rootMenu.check(menuLabels.btns) : rootMenu.uncheck(menuLabels.btns))
		}
	}


	doMenuItem(name, position, menu) {
		popupHidden := this.settings.states.popupHidden
		menuLabels := this.settings.menuLabels

		switch (name) {
			case menuLabels.btns: this.setPopupState(!!popupHidden)
		}
	}


	getPopupState() {
		return (WinGetStyle(this.settings.hWnd) & WS_MINIMIZE ? false : true)
	}


	setPopupState(state) {
		hWnd := this.settings.hWnd

		if (state) {
			WinRestore(hWnd)
			this.settings.states.popupHidden := false
		} else {
			WinMinimize(hWnd)
			this.settings.states.popupHidden := true
		}

		this.tickMenuItems()
	}


	getPopupHwnd() {
		; loop through all windows with a class of "NativeHWNDHost"and child "DirectUIHWND"
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


	setObservers() {
		stateThen := this.settings.states.popupHidden
		stateNow := !this.getPopupState()

		if (stateNow !== stateThen) {
			this.settings.states.popupHidden := stateNow
			this.tickMenuItems()
		}
	}
}








; -----------------------------------------------------------------
; checkMediaPopup() {
; 	_MS := this.settings

; 	hWnd := DllCall("User32\FindWindow", "Str","NativeHWNDHost", "Ptr",0)
; 	isPopupVisible := DllCall("IsWindowVisible", "Ptr",hWnd)

; 	if (this.settings.states.popup == true) {
; 		; hasChild := DllCall("User32\getPopupHwnd", "Ptr",hWnd, "UInt",0x0005)
; 		; hasChild := DllCall("User32\FindWindow", "Str","DirectUIHWND", "Ptr",0)
; 		; WinHide(hwnd)
; 		WinMinimize(hwnd)
; 	}

; 	; ToolTip(
; 	; 	"IsWindowVisible = " . DllCall("IsWindowVisible", "Ptr",hWnd)
; 	; 	. "`nhasChild = " . hasChild
; 	; 	, 0, 0, 12)

; 	; ToolTip("hWnd = " . hWnd, , , 12)
; 	; WinShow(hWnd)
; 	; PostMessage(0xC028, 0x0C, 0xA0000,, "ahk_id" hWnd)
; 	; sleep(100)
; 	; MsgBox( (DllCall("IsWindowVisible", "Ptr",hWnd) ? "Yes" : "No"), "OSD visible?", 0x40 )
; 	; }
; }

; SetTimer(ObjBindMethod(this, "getPopupHwnd"), 1000)
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
