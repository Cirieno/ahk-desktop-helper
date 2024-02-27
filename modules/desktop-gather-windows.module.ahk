/************************************************************************
 * @description DesktopGatherWindows
 * @author Rob McInnes
 * @file desktop-gather-windows.module.ahk
 ***********************************************************************/
; Because sometimes windows get stuck offscreen and you can't get them back,
;   or the window size goes a bit wonky
; This script will bring windows back to the main monitor
; It will also resize them if they are resizable
; It ignores minimized windows and certain processes and titles



class module__DesktopGatherWindows {
	__Init() {
		this.moduleName := "DesktopGatherWindows"
		this.enabled := getIniVal(this.moduleName, "enabled", true)
		this.settings := {
			resizeOnMove: getIniVal(this.moduleName, "resizeOnMove", false)
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



	/** */
	__New() {
		if (!this.enabled) {
			return
		}

		thisMenu := this.drawMenu()
	}



	/** */
	__Delete() {
		; nothing to do
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
				setMenuItemProps(name, menu, { clickCount: +1 })
				this.doGatherWindows()
		}
	}



	/** */
	doGatherWindows(doResize := this.settings.resizeOnMove) {
		primaryWorkArea := getPrimaryVals()
		getPrimaryVals() {
			primaryId := MonitorGetWorkArea(MonitorGetPrimary(), &L, &T, &R, &B)
			p := { id: primaryId, left: L, top: T, right: R, bottom: B }
			p.width := (p.right - p.left)
			p.height := (p.bottom - p.top)
			return p
		}

		msgboxTimeout := "T5"    ;// seconds
		countMoves := 0
		border := 100
		pwaWidthWithBorders := (primaryWorkArea.width - (border * 2))
		pwaHeightWithBorders := (primaryWorkArea.height - (border * 2))

		ignoreProcesses := []
		ignoreTitles := ["Program Manager"]
		ignoreMinimized := true

		for handle in WinGetList() {
			win := getWinVals(handle)
			getWinVals(handle) {
				WinGetPos(&X, &Y, &W, &H, handle)
				W := { posX: X, posY: Y, width: W, height: H }
				W.hWnd := handle
				W.title := WinGetTitle(handle)
				W.class := WinGetClass(handle)
				W.state := WinGetMinMax(handle)
				W.process := WinGetProcessName(handle)
				W.path := WinGetProcessPath(handle)
				W.style := WinGetStyle(handle)
				return W
			}

			;// ignore if the window is minimized
			if (ignoreMinimized && (win.state == -1)) {
				continue
			}

			;// don't bother with windows we have elected to ignore
			if (isInArray(ignoreProcesses, win.process) || isInArray(ignoreTitles, win.title) || (win.process == "explorer.exe" && win.title == "")) {
				continue
			}

			; to count as being "offscreen" the whole window must be entirely off the primary monitor, not just the top left corner
			; this is made harder by Windows having a shadow that extends beyond the window's actual dimensions (which I'm going to assume is 20 pixels)
			; so if the window is 20 pixels or more into the primary monitor we can consider the actual content to be offscreen
			; TODO: all of this ^^^

			mboxResult := MsgBox(join([
				win.title . "`n",
				; "Window class: " . win.class,
				"Process: " . win.process,
				"State: " . (win.state == -1 ? "minimized" : (win.state == 0 ? "normal" : (win.state == 1 ? "maximized" : "unknown"))),
				"Position: " . win.posX . " x " . win.posY,
				"Size: " . win.width . " x " . win.height
			], "`n"), (_Settings.app.name . " — " . this.settings.menu.items[1].label . U_ellipsis), (3 + 512 + 64) . " " . msgboxTimeout)

			switch mboxResult {
				case "Yes":
					countMoves++

					countTries := 0
					while ((countTries <= 3) || (win.state != 0)) {
						countTries++
						WinRestore(handle)
						Sleep(50)
						win.state := WinGetMinMax(handle)
					}

					moveLeft := (primaryWorkArea.left + (border * countMoves))
					moveTop := (primaryWorkArea.top + (border * countMoves))
					moveWidth := (pwaWidthWithBorders * 0.75)
					moveHeight := (pwaHeightWithBorders * 0.8)

					if (doResize && (win.style & WS_SIZEBOX)) {
						WinMove(moveLeft, moveTop, moveWidth, moveHeight, handle)
					} else {
						WinMove(moveLeft, moveTop, handle)
					}

					WinActivate(handle)
				case "No":
					continue
				case "Cancel", "Timeout":
					break
			}
		}
	}



	/** */
	updateSettingsFile() {
		_SAE := _Settings.app.environment
		try {
			IniWrite((this.enabled ? "true" : "false"), _SAE.settingsFilename, this.moduleName, "enabled")
			IniWrite((this.settings.resizeOnMove ? "true" : "false"), _SAE.settingsFilename, this.moduleName, "resizeOnMove")
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
