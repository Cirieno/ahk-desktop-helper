/**********************************************************
 * @type {AHKModule}
 * @name Volume Mouse Wheel
 * @author Rob McInnes (Cirieno)
 * @file volume-mousewheel.ahk
 *********************************************************/
;
; Use mouse wheel to change volume when over any systray controls (including the clock and show desktop button).
; Win11 has some native support for this but only when hovering over the volume icon itself.
; Step size is configurable.
; Display style is configurable.


class module__VolumeMouseWheel {
	__Init() {
		this.moduleName := moduleName := "VolumeMouseWheel"
		this.settings := {
			useModule: IniUtils.getVal(moduleName, "useModule", true),
			enabledOnLoad: IniUtils.getVal(moduleName, "enabledOnLoad", false),
			displayStyle: IniUtils.getVal(moduleName, "displayStyle", "tooltip"),
			flyoutSize: IniUtils.getVal(moduleName, "flyoutSize", "large"),
			step: IniUtils.getVal(moduleName, "step", 3)
		}
		this.state := {
			isActive: null,
			hasWheel: null,
			onWheelChangeCallback: null,
			hideIndicatorCallback: null,
			flyoutGui: null,
			flyoutDeviceLabel: null,
			flyoutPercentLabel: null,
			flyoutProgress: null,
			trayControls: Map()
		}
		this.ui := {
			flyout: {
				width: 312,
				height: 86,
				marginX: 16,
				marginY: 14,
				cornerRadius: 18,
				backgroundColor: "1F1F1F",
				deviceTextColor: "CFCFCF",
				percentTextColor: "F5F5F5",
				barColor: "6CA9FF",
				barBackgroundColor: "3A3A3A",
				transparency: 242,
				edgeGap: 18,
				safeMargin: 12
			},
			menu: {
				parentPath: "TRAY\Volume-2",
				entries: [{
					type: "item",
					label: "MouseWheel over Systray"
				}]
			}
		}
	}


	__New() {
		if (!this.settings.useModule) {
			return
		}

		this.settings.displayStyle := this.normaliseDisplayStyle(this.settings.displayStyle)
		this.settings.flyoutSize := this.normaliseFlyoutSize(this.settings.flyoutSize)
		this.settings.step := this.normaliseStep(this.settings.step)
		this.applyFlyoutSizePreset(this.settings.flyoutSize)
		this.state.isActive := this.settings.enabledOnLoad
		this.state.hasWheel := toBoolean(SysGet(SM_MOUSEPRESENT) && SysGet(SM_MOUSEWHEELPRESENT))
		this.state.onWheelChangeCallback := ObjBindMethod(this, "onWheelChange")
		this.state.hideIndicatorCallback := ObjBindMethod(this, "hideVolumeIndicator")

		; Broader taskbar notification-area coverage for Win10/Win11.
		; Includes visible tray icons, clock, show-desktop button, chevron/overflow-adjacent containers,
		; and secondary-taskbar variants where present. Exact ClassNN ordinals can vary by Windows build.
		trayControls := [
			"Button2", "Button3",
			"ToolbarWindow321", "ToolbarWindow322", "ToolbarWindow323", "ToolbarWindow324", "ToolbarWindow325", "ToolbarWindow326",
			"TrayButton1", "TrayButton2", "TrayButton3", "TrayButton4",
			"SIBTrayButton1", "SIBTrayButton2", "SIBTrayButton3", "SIBTrayButton4", "SIBTrayButton5",
			"TrayClockWClass1", "TrayClockWClass2",
			"TrayNotifyWnd1", "TrayNotifyWnd2",
			"TrayShowDesktopButtonWClass1", "TrayShowDesktopButtonWClass2",
			"SysPager1", "SysPager2",
			"NotifyIconOverflowWindow1",
			"Shell_TrayWnd1",
			"Shell_SecondaryTrayWnd1"
		]
		for (i, controlName in trayControls) {
			this.state.trayControls[controlName] := true
		}

		thisMenu := this.drawMenu()
		this.syncMenuItem(thisMenu)

		this.setHotkeysEnabled(this.state.isActive)
	}


	__Delete() {
		if (IsObject(this.state.onWheelChangeCallback)) {
			this.setHotkeysEnabled(false)
			this.state.onWheelChangeCallback := null
		}
		if (IsObject(this.state.hideIndicatorCallback)) {
			this.hideVolumeIndicator()
			this.state.hideIndicatorCallback := null
		}
		if (IsObject(this.state.flyoutGui)) {
			try {
				this.state.flyoutGui.Destroy()
			}
		}

		this.state.flyoutGui := null
		this.state.flyoutDeviceLabel := null
		this.state.flyoutPercentLabel := null
		this.state.flyoutProgress := null
		this.state.trayControls := Map()
	}


	/**
	 * @returns {Menu|null}
	 */
	drawMenu() {
		thisMenu := ensureNativeMenuPath(this.ui.menu.parentPath)
		local onMenuItemClick := ObjBindMethod(this, "onMenuItemClick")
		this.drawMenuEntries(thisMenu, this.ui.menu.entries, onMenuItemClick)

		return (isMenu(thisMenu) ? thisMenu : null)
	}


	/**
	 * @param {Menu} thisMenu
	 * @param {Array} entries
	 * @param {Func|BoundFunc} onMenuItemClick
	 * @returns {void}
	 */
	drawMenuEntries(thisMenu, entries, onMenuItemClick) {
		for (i, entry in entries) {
			switch (entry.type) {
				case "item":
					thisMenu.Add(entry.label, onMenuItemClick)
				case "submenu":
					childMenu := Menu()
					this.drawMenuEntries(childMenu, entry.entries, onMenuItemClick)
					thisMenu.Add(entry.label, childMenu)
				case "separator", "---":
					thisMenu.Add()
			}
		}
	}


	/**
	 * @param {string} name
	 * @param {integer} position
	 * @param {Menu} menu
	 * @returns {void}
	 */
	onMenuItemClick(name, position, menu) {
		switch (name) {
			case this.ui.menu.entries[1].label:
				this.state.isActive := !this.state.isActive
				this.syncMenuItem(menu)
				this.setHotkeysEnabled(this.state.isActive)
				this.updateSettingsFile()
		}
	}


	/**
	 * @param {Menu} menu
	 * @returns {void}
	 */
	syncMenuItem(menu) {
		label := this.ui.menu.entries[1].label
		(this.state.isActive ? menu.Check(label) : menu.Uncheck(label))
		(this.state.hasWheel ? menu.Enable(label) : menu.Disable(label))
	}


	/**
	 * @param {boolean} state
	 * @returns {void}
	 */
	setHotkeysEnabled(state) {
		Hotkey("~WheelUp", this.state.onWheelChangeCallback, (state ? "on" : "off"))
		Hotkey("~WheelDown", this.state.onWheelChangeCallback, (state ? "on" : "off"))
	}


	/**
	 * @param {string} name
	 * @returns {void}
	 */
	onWheelChange(name) {
		CoordMode("Mouse", "Screen")
		MouseGetPos(&mouseX, &mouseY, , &control)

		if (this.state.trayControls.Has(control)) {
			try {
				vol := SoundGetVolume()
				switch (name) {
					case "~WheelUp":
						newVol := Min((vol + this.settings.step), 100)
					case "~WheelDown":
						newVol := Max((vol - this.settings.step), 0)
				}
				SoundSetVolume(newVol)
				this.showVolumeIndicator(newVol, mouseX, mouseY)
			} catch Error {
				return
			}
		}
	}


	/**
	 * @param {number} volume
	 * @param {integer} anchorX
	 * @param {integer} anchorY
	 * @returns {void}
	 */
	showVolumeIndicator(volume, anchorX, anchorY) {
		switch (this.settings.displayStyle) {
			case "tooltip":
				this.showVolumeTooltip(volume)
			case "flyout":
				this.showVolumeFlyout(volume, anchorX, anchorY)
		}
	}


	/**
	 * @param {number} volume
	 * @returns {void}
	 */
	showVolumeTooltip(volume) {
		ToolTip(this.getVolumeIndicatorText(volume), , , 1)
		SetTimer(this.state.hideIndicatorCallback, 0)
		SetTimer(this.state.hideIndicatorCallback, -1000)
	}


	/**
	 * @param {number} volume
	 * @param {integer} anchorX
	 * @param {integer} anchorY
	 * @returns {void}
	 */
	showVolumeFlyout(volume, anchorX, anchorY) {
		this.ensureVolumeFlyout()

		deviceName := this.getOutputDeviceName()
		this.state.flyoutDeviceLabel.Text := (isEmpty(deviceName) ? "Volume" : deviceName)
		this.state.flyoutPercentLabel.Text := Round(volume) . "%"
		this.state.flyoutProgress.Value := Round(volume)

		position := this.getVolumeFlyoutPosition(anchorX, anchorY, volume)
		this.state.flyoutGui.Show("x" . position.x . " y" . position.y . " NA")
		SetTimer(this.state.hideIndicatorCallback, 0)
		SetTimer(this.state.hideIndicatorCallback, -1200)
	}


	/**
	 * @returns {void}
	 */
	ensureVolumeFlyout() {
		if (IsObject(this.state.flyoutGui)) {
			return
		}

		flyout := this.ui.flyout
		guiObj := Gui("-Caption +AlwaysOnTop +ToolWindow")
		guiObj.BackColor := flyout.backgroundColor
		guiObj.MarginX := flyout.marginX
		guiObj.MarginY := flyout.marginY

		guiObj.SetFont("s" . flyout.deviceFontSize . " c" . flyout.deviceTextColor, "Segoe UI")
		deviceLabel := guiObj.AddText("xm ym w" . flyout.deviceLabelWidth . " h" . flyout.deviceLabelHeight . " BackgroundTrans", "Volume")
		guiObj.SetFont("s" . flyout.percentFontSize . " c" . flyout.percentTextColor, "Segoe UI Semibold")
		percentLabel := guiObj.AddText("x+" . flyout.percentOffsetX . " yp" . flyout.percentOffsetY . " w" . flyout.percentLabelWidth . " h" . flyout.percentLabelHeight . " Right BackgroundTrans", "0%")
		progress := guiObj.AddProgress("xm y+" . flyout.progressOffsetY . " w" . flyout.progressWidth . " h" . flyout.progressHeight . " Range0-100 c" . flyout.barColor . " Background" . flyout.barBackgroundColor, 0)

		guiObj.Show("Hide w" . flyout.width . " h" . flyout.height)
		WinSetTransparent(flyout.transparency, "ahk_id " . guiObj.Hwnd)
		this.applyRoundedWindowRegion(guiObj.Hwnd, flyout.cornerRadius)
		guiObj.Hide()

		this.state.flyoutGui := guiObj
		this.state.flyoutDeviceLabel := deviceLabel
		this.state.flyoutPercentLabel := percentLabel
		this.state.flyoutProgress := progress
	}


	/**
	 * @param {integer} anchorX
	 * @param {integer} anchorY
	 * @param {number} volume
	 * @returns {Object}
	 */
	getVolumeFlyoutPosition(anchorX, anchorY, volume) {
		layout := this.getMonitorLayoutForPoint(anchorX, anchorY)
		monitorRect := layout.monitorRect
		workArea := layout.workArea
		taskbarRect := layout.taskbarRect
		flyoutSize := this.getFlyoutWindowSize()
		flyoutWidth := flyoutSize.width
		flyoutHeight := flyoutSize.height
		x := (monitorRect.right - flyoutWidth)
		y := (monitorRect.bottom - flyoutHeight)
		edge := layout.taskbarEdge

		switch (edge) {
			case "top":
				x := this.clampFlyoutX((monitorRect.right - flyoutWidth), workArea, flyoutWidth)
				y := taskbarRect.bottom
			case "left":
				x := taskbarRect.right
				y := this.clampFlyoutY((monitorRect.bottom - flyoutHeight), workArea, flyoutHeight)
			case "right":
				x := (taskbarRect.left - flyoutWidth)
				y := this.clampFlyoutY((monitorRect.bottom - flyoutHeight), workArea, flyoutHeight)
			case "bottom":
				x := this.clampFlyoutX((monitorRect.right - flyoutWidth), workArea, flyoutWidth)
				y := (taskbarRect.top - flyoutHeight)
		}

		return { x: x, y: y }
	}


	/**
	 * @param {integer} x
	 * @param {Object} workArea
	 * @param {integer} flyoutWidth
	 * @returns {integer}
	 */
	clampFlyoutX(x, workArea, flyoutWidth) {
		maxX := (workArea.right - flyoutWidth)
		return Min(Max(x, workArea.left), maxX)
	}


	/**
	 * @param {integer} y
	 * @param {Object} workArea
	 * @param {integer} flyoutHeight
	 * @returns {integer}
	 */
	clampFlyoutY(y, workArea, flyoutHeight) {
		maxY := (workArea.bottom - flyoutHeight)
		return Min(Max(y, workArea.top), maxY)
	}


	/**
	 * @returns {Object}
	 */
	getFlyoutWindowSize() {
		if (IsObject(this.state.flyoutGui)) {
			try {
				WinGetPos(, , &width, &height, this.state.flyoutGui.Hwnd)
				if ((width > 0) && (height > 0)) {
					return {
						width: width,
						height: height
					}
				}
			}
		}

		return {
			width: this.ui.flyout.width,
			height: this.ui.flyout.height
		}
	}


	/**
	 * @param {integer} x
	 * @param {integer} y
	 * @returns {Object}
	 */
	getMonitorLayoutForPoint(x, y) {
		monitorCount := MonitorGetCount()
		loop monitorCount {
			monitorIndex := A_Index
			MonitorGet(monitorIndex, &left, &top, &right, &bottom)
			if ((x >= left) && (x < right) && (y >= top) && (y < bottom)) {
				return this.getMonitorLayout(monitorIndex)
			}
		}

		monitorIndex := MonitorGetPrimary()
		return this.getMonitorLayout(monitorIndex)
	}


	/**
	 * @param {integer} monitorIndex
	 * @returns {Object}
	 */
	getMonitorLayout(monitorIndex) {
		MonitorGet(monitorIndex, &left, &top, &right, &bottom)
		monitorRect := {
			left: left,
			top: top,
			right: right,
			bottom: bottom
		}
		MonitorGetWorkArea(monitorIndex, &workLeft, &workTop, &workRight, &workBottom)
		workArea := {
			left: workLeft,
			top: workTop,
			right: workRight,
			bottom: workBottom
		}
		taskbarEdge := "bottom"
		taskbarRect := {
			left: workLeft,
			top: workBottom,
			right: workRight,
			bottom: bottom
		}

		if (workLeft > monitorRect.left) {
			taskbarEdge := "left"
			taskbarRect := {
				left: monitorRect.left,
				top: monitorRect.top,
				right: workLeft,
				bottom: monitorRect.bottom
			}
		}
		else if (workRight < monitorRect.right) {
			taskbarEdge := "right"
			taskbarRect := {
				left: workRight,
				top: monitorRect.top,
				right: monitorRect.right,
				bottom: monitorRect.bottom
			}
		}
		else if (workTop > monitorRect.top) {
			taskbarEdge := "top"
			taskbarRect := {
				left: monitorRect.left,
				top: monitorRect.top,
				right: monitorRect.right,
				bottom: workTop
			}
		}
		else if (workBottom < monitorRect.bottom) {
			taskbarEdge := "bottom"
			taskbarRect := {
				left: monitorRect.left,
				top: workBottom,
				right: monitorRect.right,
				bottom: monitorRect.bottom
			}
		}

		return {
			monitorRect: monitorRect,
			workArea: workArea,
			taskbarEdge: taskbarEdge,
			taskbarRect: taskbarRect
		}
	}


	/**
	 * @returns {string}
	 */
	getOutputDeviceName() {
		try {
			deviceName := SoundGetName()
			return RegExReplace(deviceName, "\s+\([^()]+\)$", "")
		} catch Error {
			return ""
		}
	}


	/**
	 * @param {number} volume
	 * @returns {string}
	 */
	getVolumeIndicatorText(volume) {
		deviceName := this.getOutputDeviceName()
		indicatorText := Round(volume) . "%"
		if (!isEmpty(deviceName)) {
			indicatorText := deviceName . ": " . indicatorText
		}

		return indicatorText
	}

	/**
	 * @param {...any} args
	 * @returns {void}
	 */
	hideVolumeIndicator(args*) {
		ToolTip(, , , 1)
		if (IsObject(this.state.flyoutGui)) {
			try {
				this.state.flyoutGui.Hide()
			}
		}
	}


	/**
	 * @param {integer} hWnd
	 * @param {integer} radius
	 * @returns {void}
	 */
	applyRoundedWindowRegion(hWnd, radius) {
		try {
			WinGetPos(, , &width, &height, hWnd)
			hRegion := DllCall("CreateRoundRectRgn", "int", 0, "int", 0, "int", (width + 1), "int", (height + 1), "int", radius, "int", radius, "ptr")
			if (hRegion) {
				DllCall("SetWindowRgn", "ptr", hWnd, "ptr", hRegion, "int", true)
			}
		} catch Error {
			return
		}
	}


	/**
	 * @param {string} displayStyle
	 * @returns {string}
	 */
	normaliseDisplayStyle(displayStyle) {
		if (!isString(displayStyle)) {
			return "tooltip"
		}

		displayStyle := StrLower(Trim(displayStyle))
		switch (displayStyle) {
			case "tooltip", "flyout":
				return displayStyle
			default:
				return "tooltip"
		}
	}


	/**
	 * @param {string} flyoutSize
	 * @returns {string}
	 */
	normaliseFlyoutSize(flyoutSize) {
		if (!isString(flyoutSize)) {
			return "large"
		}

		flyoutSize := StrLower(Trim(flyoutSize))
		switch (flyoutSize) {
			case "small", "medium", "large":
				return flyoutSize
			default:
				return "large"
		}
	}


	/**
	 * @param {string} flyoutSize
	 * @returns {void}
	 */
	applyFlyoutSizePreset(flyoutSize) {
		switch (flyoutSize) {
			case "small":
				this.setFlyoutSizePreset(236, 64, 10, 9, 14, 8, 136, 16, 14, 56, 24, 6, -1, 216, 6, 10)
			case "medium":
				this.setFlyoutSizePreset(274, 74, 13, 11, 16, 9, 162, 18, 16, 66, 26, 7, -3, 248, 7, 13)
			case "large":
				this.setFlyoutSizePreset(312, 86, 16, 14, 18, 9, 190, 18, 18, 82, 28, 8, -4, 280, 8, 16)
			default:
				this.setFlyoutSizePreset(312, 86, 16, 14, 18, 9, 190, 18, 18, 82, 28, 8, -4, 280, 8, 16)
		}
	}


	/**
	 * @param {integer} width
	 * @param {integer} height
	 * @param {integer} marginX
	 * @param {integer} marginY
	 * @param {integer} cornerRadius
	 * @param {integer} deviceFontSize
	 * @param {integer} deviceLabelWidth
	 * @param {integer} deviceLabelHeight
	 * @param {integer} percentFontSize
	 * @param {integer} percentLabelWidth
	 * @param {integer} percentLabelHeight
	 * @param {integer} percentOffsetX
	 * @param {integer} percentOffsetY
	 * @param {integer} progressWidth
	 * @param {integer} progressHeight
	 * @param {integer} progressOffsetY
	 * @returns {void}
	 */
	setFlyoutSizePreset(width, height, marginX, marginY, cornerRadius, deviceFontSize, deviceLabelWidth, deviceLabelHeight, percentFontSize, percentLabelWidth, percentLabelHeight, percentOffsetX, percentOffsetY, progressWidth, progressHeight, progressOffsetY) {
		this.ui.flyout.width := width
		this.ui.flyout.height := height
		this.ui.flyout.marginX := marginX
		this.ui.flyout.marginY := marginY
		this.ui.flyout.cornerRadius := cornerRadius
		this.ui.flyout.deviceFontSize := deviceFontSize
		this.ui.flyout.deviceLabelWidth := deviceLabelWidth
		this.ui.flyout.deviceLabelHeight := deviceLabelHeight
		this.ui.flyout.percentFontSize := percentFontSize
		this.ui.flyout.percentLabelWidth := percentLabelWidth
		this.ui.flyout.percentLabelHeight := percentLabelHeight
		this.ui.flyout.percentOffsetX := percentOffsetX
		this.ui.flyout.percentOffsetY := percentOffsetY
		this.ui.flyout.progressWidth := progressWidth
		this.ui.flyout.progressHeight := progressHeight
		this.ui.flyout.progressOffsetY := progressOffsetY
	}


	/**
	 * @param {number} step
	 * @returns {integer}
	 */
	normaliseStep(step) {
		if (!IsNumber(step)) {
			return 3
		}

		step := Round(step)
		return Max(1, Min(step, 100))
	}


	/**
	 * @returns {void}
	 */
	updateSettingsFile() {
		_S := __Settings.settingsFilePath

		try {
			IniWrite(toString(this.settings.useModule), _S, this.moduleName, "useModule")
			IniWrite(toString(this.state.isActive), _S, this.moduleName, "enabledOnLoad")
			IniWrite(this.settings.displayStyle, _S, this.moduleName, "displayStyle")
			IniWrite(this.settings.flyoutSize, _S, this.moduleName, "flyoutSize")
			IniWrite(this.settings.step, _S, this.moduleName, "step")
		} catch Error as e {
			throw Error("Error updating settings file: " . e.Message)
		}
	}
}
