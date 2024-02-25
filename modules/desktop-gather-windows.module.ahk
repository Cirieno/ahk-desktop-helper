/************************************************************************
 * @description DesktopGatherWindows
 * @author Rob McInnes
 * @file desktop-gather-windows.module.ahk
 ***********************************************************************/



class module__DesktopGatherWindows {
	__Init() {
		this.moduleName := "DesktopGatherWindows"
		this.enabled := getIniVal(this.moduleName, "enabled", true)
		this.settings := {
			resizeOnMove: getIniVal(this.moduleName, "resizeOnMove", false)
		}
		this.states := {
		}
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
			primaryId := MonitorGetWorkArea(MonitorGetPrimary(), &primaryLeft, &primaryTop, &primaryRight, &primaryBottom)
			p := { id: primaryId, left: primaryLeft, top: primaryTop, right: primaryRight, bottom: primaryBottom }
			p.width := (p.right - p.left)
			p.height := (p.bottom - p.top)
			return p
		}

		border := 100
		pwaWidthWithBorders := (primaryWorkArea.width - (border * 2))
		pwaHeightWithBorders := (primaryWorkArea.height - (border * 2))

		ignoreProcesses := []
		ignoreTitles := ["Program Manager"]

		for handle in WinGetList() {
			win := getWinVals(handle)
			getWinVals(handle) {
				WinGetPos(&winPosX, &winPosY, &winWidth, &winHeight, handle)
				w := { posX: winPosX, posY: winPosY, width: winWidth, height: winHeight }
				w.title := WinGetTitle(handle)
				w.class := WinGetClass(handle)
				w.state := WinGetMinMax(handle)
				w.process := WinGetProcessName(handle)
				w.style := WinGetStyle(handle)
				return w
			}

			;// don't bother with windows we have elected to ignore
			if ((win.process == "explorer.exe" && win.title == "") || isInArray(ignoreProcesses, win.process) || isInArray(ignoreTitles, win.title)) {
				continue
			}

			; to count as being "offscreen" the whole window must be entirely off the primary monitor, not just the top left corner
			; this is made harder by Windows having a shadow that extends beyond the window's actual dimensions (which I'm going to assume is 20 pixels)
			; so if the window is 20 pixels or more into the primary monitor we can consider the actual content to be offscreen
			; TODO: all of this ^^^

			res := MsgBox(join([
				win.title . "`n",
				; "Window class: " . win.class,
				"Process: " . win.process,
				"State: " . (win.state == -1 ? "minimized" : (win.state == 0 ? "normal" : (win.state == 1 ? "maximized" : "unknown"))),
				"Position: " . win.posX . " x " . win.posY,
				"Size: " . win.width . " x " . win.height
			], "`n"), (_Settings.app.name . " - " . this.settings.menu.items[1].label . U_ellipsis), (3 + 256 + 64))
			switch res {
				case "Yes":
					WinSetTransparent(1, handle)
					WinRestore(handle)

					countTries := 0
					while ((countTries < 3) || (win.state != 0)) {
						WinRestore(handle)
						Sleep(50)
						win.state := WinGetMinMax(handle)
						countTries++
					}

					WinMove((primaryWorkArea.left + border), (primaryWorkArea.top + border), , , handle)
					if (doResize && (win.style & WS_SIZEBOX)) {
						WinMove(, ,
							pwaWidthWithBorders,
							pwaHeightWithBorders,
							; (win.width > pwaWidthWithBorders ? pwaWidthWithBorders : win.width),
							; (win.height > pwaHeightWithBorders ? pwaHeightWithBorders : win.height),
							handle)
					}
					WinSetTransparent(255, handle)
				case "No":
					continue
				case "Cancel":
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
