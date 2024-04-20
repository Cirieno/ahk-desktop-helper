/**********************************************************
 * @name DesktopGatherWindows
 * @author RM
 * @file desktop-gather-windows.module.ahk
 *********************************************************/
; Because sometimes windows get stuck offscreen and you can't get them back,
;     or the window size goes a bit wonky
; This script will bring windows back to the main monitor
; It also resizes them if they are resizable
; It ignores minimized windows and certain processes and titles
;
; TODO: this module struggles with browser windows that are F11'd



class module__DesktopGatherWindows {
	__Init() {
		this.moduleName := moduleName := "DesktopGatherWindows"
		this.enabled := getIniVal(moduleName, "enabled", true)
		this.settings := {
			resizeOnMove: getIniVal(moduleName, "resizeOnMove", true)
		}
		this.states := {}
		this.settings.menu := {
			path: "TRAY\Desktop",
			items: [{
				type: "item",
				label: "Bring windows to main monitor"
			}]
		}
	}



	__New() {
		if (!this.enabled) {
			return
		}

		this.drawMenu()

		toBoolean("no")
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
				setMenuItemProps(name, menu, { clickCount: +1 })
				this.doGatherWindows()
		}
	}



	doGatherWindows(doResize := this.settings.resizeOnMove) {
		if (primaryWorkArea := {}) {
			pid := MonitorGetWorkArea(MonitorGetPrimary(), &L, &T, &R, &B)
			pwa := { id: pid, left: L, top: T, right: R, bottom: B }
			pwa.width := (pwa.right - pwa.left)
			pwa.height := (pwa.bottom - pwa.top)
			primaryWorkArea := pwa
		}

		msgboxTimeout := "T5"    ; 5 seconds
		countMoves := 0
		canMove := null
		windowOffsetX := windowOffsetY := (SysGet(SM_CYCAPTION) + SysGet(SM_CXSIZEFRAME))

		ignoreProcesses := []
		ignoreTitles := ["Program Manager"]
		ignoreMinimized := false

		DetectHiddenWindows(false)
		handles := WinGetList()
		DetectHiddenWindows(true)

		for (i, hWnd in handles) {
			if (win := {}) {
				WinGetPos(&X, &Y, &win, &H, hWnd)
				win := { posX: X, posY: Y, width: win, height: H }
				win.handle := hWnd
				win.title := WinGetTitle(hWnd)
				win.class := WinGetClass(hWnd)
				win.state := WinGetMinMax(hWnd)
				win.process := WinGetProcessName(hWnd)
				win.path := WinGetProcessPath(hWnd)
				win.style := WinGetStyle(hWnd)
			}

			; ignore if the window is minimized, or has no size
			if ((ignoreMinimized && win.state == -1) || (win.width == 0 && win.height == 0)) {
				continue
			}

			; don't bother with windows we have elected to ignore
			if ((ignoreProcesses.includes(win.process) || ignoreTitles.includes(win.title)) || (win.process == "explorer.exe" && win.title == "")) {
				continue
			}

			; to count as being "offscreen" the whole window must be entirely off the primary monitor, not just the top left corner
			; this is made harder by windows having a shadow offset that extends beyond the window's actual dimensions (which we assume is 20 pixels)
			; so if the window is 20 pixels or more into the primary monitor we can consider the actual content to be offscreen
			; TODO: all of this ^^^

			title := __Settings.app.name . " — " . this.settings.menu.items[1].label . U_ellipsis
			msg := MsgboxJoin([win.title, "",
				"Window class: " . win.class,
				"Process: " . win.process,
				"State: " . (win.state == -1 ? "minimized" : (win.state == 0 ? "normal" : (win.state == 1 ? "maximized" : "unknown"))),
				"Position: " . win.posX . " x " . win.posY,
				"Size: " . win.width . " x " . win.height
			])
			mbox := MsgBox(msg, title, (3 + 512 + 64) . " " . msgboxTimeout)

			switch (mbox) {
				case "Yes":
					canMove := false
					try {
						WinMove(, , , , hWnd)
						canMove := true
					}

					if (!canMove) {
						title := __Settings.app.name . " — " . this.settings.menu.items[1].label . U_ellipsis
						msg := MsgboxJoin(["Error trying to move window " . StrWrap(win.title, 5), "",
							"Running this script with administrator priviledges might fix this issue."
						])
						MsgBox(msg, title, (0 + 64))
						continue
					}

					try {
						WinSetTransparent(0, hWnd)
					}

					if (win.state !== 0) {
						WinRestore(hWnd)
						WinRestore(hWnd)
					}

					newPosX := (primaryWorkArea.left + (windowOffsetX * (countMoves * 1.3)))
					newPosY := (primaryWorkArea.top + (windowOffsetY * (countMoves * 1.3)))
					newPosW := (primaryWorkArea.width * 0.75)
					newPosH := (primaryWorkArea.height * 0.75)

					try {
						if (doResize && ((win.style & WS_SIZEBOX) || (win.style & WS_THICKFRAME))) {
							WinMove(newPosX, newPosY, newPosW, newPosH, hWnd)
						} else {
							WinMove(newPosX, newPosY, , , hWnd)
						}
					} catch Error as e {
						title := __Settings.app.name . " — " . this.settings.menu.items[1].label . U_ellipsis
						msg := MsgboxJoin(["Error trying to move window " . StrWrap(win.title, 5), "",
							"Running this script with administrator priviledges might fix this issue."
						])
						MsgBox(msg, title, (0 + 64))
					}

					try {
						WinSetTransparent(255, hWnd)
					}

					WinActivate(hWnd)

					countMoves++
				case "No":
					continue
				case "Cancel", "Timeout":
					break
			}
		}
	}



	updateSettingsFile() {
		SFP := __Settings.settingsFilePath

		try {
			IniWrite(toString(this.enabled), SFP, this.moduleName, "enabled")
			IniWrite(toString(this.settings.resizeOnMove), SFP, this.moduleName, "resizeOnMove")
		} catch Error as e {
			throw Error("Error updating settings file: " . e.Message)
		}
	}
}
