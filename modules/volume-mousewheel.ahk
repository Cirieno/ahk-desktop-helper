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
; Tooltip is configurable


class module__VolumeMouseWheel {
	/**
	 * @returns {void}
	 */
	__Init() {
		this.moduleName := moduleName := "VolumeMouseWheel"
		this.settings := {
			isEnabled: IniUtils.getVal(moduleName, "enabled", true),
			activateOnLoad: IniUtils.getVal(moduleName, "activateOnLoad", false),
			showTooltip: IniUtils.getVal(moduleName, "showTooltip", true),
			step: IniUtils.getVal(moduleName, "step", 3)
		}
		this.state := {
			isActive: null,
			hasWheel: null,
			onWheelChangeCallback: null,
			hideTooltipCallback: null,
			trayControls: []
		}
		this.ui := {
			menu: {
				parentPath: "TRAY\Volume-2",
				entries: [{
					type: "item",
					label: "Wheel over Systray"
				}]
			}
		}
	}


	/**
	 * @returns {void}
	 */
	__New() {
		if (!this.settings.isEnabled) {
			return
		}

		this.settings.step := this.normaliseStep(this.settings.step)
		this.state.isActive := this.settings.activateOnLoad
		this.state.hasWheel := toBoolean(SysGet(SM_MOUSEPRESENT) && SysGet(SM_MOUSEWHEELPRESENT))
		this.state.onWheelChangeCallback := ObjBindMethod(this, "onWheelChange")
		this.state.hideTooltipCallback := ObjBindMethod(this, "hideTooltip")

		; Broader taskbar notification-area coverage for Win10/Win11.
		; Includes visible tray icons, clock, show-desktop button, chevron/overflow-adjacent containers,
		; and secondary-taskbar variants where present. Exact ClassNN ordinals can vary by Windows build.
		this.state.trayControls := [
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

		thisMenu := this.drawMenu()
		this.syncMenuItem(thisMenu)

		this.setHotkeysEnabled(this.state.isActive)
	}


	/**
	 * @returns {void}
	 */
	__Delete() {
		if (IsObject(this.state.onWheelChangeCallback)) {
			this.setHotkeysEnabled(false)
			this.state.onWheelChangeCallback := null
		}
		if (IsObject(this.state.hideTooltipCallback)) {
			this.hideTooltip()
			this.state.hideTooltipCallback := null
		}

		this.state.trayControls := []
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
		MouseGetPos(, , , &control)

		if (this.state.trayControls.includes(control)) {
			try {
				vol := SoundGetVolume()
				switch (name) {
					case "~WheelUp":
						newVol := Min((vol + this.settings.step), 100)
					case "~WheelDown":
						newVol := Max((vol - this.settings.step), 0)
				}
				SoundSetVolume(newVol)
				if (this.settings.showTooltip) {
					this.showVolumeTooltip(newVol)
				}
			} catch Error {
				return
			}
		}
	}


	/**
	 * @param {number} volume
	 * @returns {void}
	 */
	showVolumeTooltip(volume) {
		deviceName := this.getOutputDeviceName()
		tooltipText := Round(volume) . "%"
		if (!isEmpty(deviceName)) {
			tooltipText := deviceName . ": " . tooltipText
		}

		ToolTip(tooltipText, , , 1)
		SetTimer(this.state.hideTooltipCallback, 0)
		SetTimer(this.state.hideTooltipCallback, -1000)
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
	 * @param {...any} args
	 * @returns {void}
	 */
	hideTooltip(args*) {
		ToolTip(, , , 1)
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
			IniWrite(toString(this.settings.isEnabled), _S, this.moduleName, "enabled")
			IniWrite(toString(this.state.isActive), _S, this.moduleName, "activateOnLoad")
			IniWrite(toString(this.settings.showTooltip), _S, this.moduleName, "showTooltip")
			IniWrite(this.settings.step, _S, this.moduleName, "step")
		} catch Error as e {
			throw Error("Error updating settings file: " . e.Message)
		}
	}
}
