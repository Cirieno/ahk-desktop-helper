/**********************************************************
 * @name VolumeMouseWheel
 * @author Rob McInnes (Cirieno)
 * @file volume-mousewheel.module.ahk
 *********************************************************/


class module__VolumeMouseWheel {
	__Init() {
		this.moduleName := moduleName := "VolumeMouseWheel"
		this.settings := {
			isEnabled: getIniVal(moduleName, "enabled", true),
			defaultIsActive: getIniVal(moduleName, "active", false),
			step: getIniVal(moduleName, "step", 3)
		}
		this.state := {
			isActive: null,
			hasWheel: null,
			onWheelChangeCallback: null,
			trayControls: []
		}
		this.ui := {
			menu: {
				parentPath: "TRAY\Volume",
				entries: [{
					type: "item",
					label: "Wheel over Systray"
				}]
			}
		}
	}


	__New() {
		if (!this.settings.isEnabled) {
			return
		}

		this.settings.step := this.normaliseStep(this.settings.step)
		this.state.isActive := this.settings.defaultIsActive
		this.state.hasWheel := toBoolean(SysGet(SM_MOUSEPRESENT) && SysGet(SM_MOUSEWHEELPRESENT))
		this.state.onWheelChangeCallback := ObjBindMethod(this, "onWheelChange")
		; Original list
		; this.state.trayControls := Arrays.concat(
		; 	["Button2", "ToolbarWindow323", "TrayButton1", "TrayClockWClass1", "TrayNotifyWnd1", "TrayShowDesktopButtonWClass1"],
		; 	["SIBTrayButton1", "SIBTrayButton2", "SIBTrayButton3", "ToolbarWindow325", "TrayClockWClass2", "TrayShowDesktopButtonWClass2"]
		; )

		; Broader taskbar notification-area coverage for Win10/Win11.
		; Includes visible tray icons, clock, show-desktop button, chevron/overflow-adjacent containers,
		; and secondary-taskbar variants where present. Exact ClassNN ordinals can vary by Windows build.
		this.state.trayControls := [
			"Button2",
			"Button3",
			"ToolbarWindow321",
			"ToolbarWindow322",
			"ToolbarWindow323",
			"ToolbarWindow324",
			"ToolbarWindow325",
			"ToolbarWindow326",
			"TrayButton1",
			"TrayButton2",
			"TrayButton3",
			"TrayButton4",
			"SIBTrayButton1",
			"SIBTrayButton2",
			"SIBTrayButton3",
			"SIBTrayButton4",
			"SIBTrayButton5",
			"TrayClockWClass1",
			"TrayClockWClass2",
			"TrayNotifyWnd1",
			"TrayNotifyWnd2",
			"TrayShowDesktopButtonWClass1",
			"TrayShowDesktopButtonWClass2",
			"SysPager1",
			"SysPager2",
			"NotifyIconOverflowWindow1",
			"Shell_TrayWnd1",
			"Shell_SecondaryTrayWnd1"
		]

		thisMenu := this.drawMenu()
		this.syncMenuItem(thisMenu)

		this.setHotkeysEnabled(this.state.isActive)
	}


	__Delete() {
		if (IsObject(this.state.onWheelChangeCallback)) {
			this.setHotkeysEnabled(false)
			this.state.onWheelChangeCallback := null
		}

		this.state.trayControls := []
	}


	drawMenu() {
		thisMenu := ensureNativeMenuPath(this.ui.menu.parentPath)
		local onMenuItemClick := ObjBindMethod(this, "onMenuItemClick")
		this.drawMenuEntries(thisMenu, this.ui.menu.entries, onMenuItemClick)

		return (isMenu(thisMenu) ? thisMenu : null)
	}


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


	onMenuItemClick(name, position, menu) {
		switch (name) {
			case this.ui.menu.entries[1].label:
				this.state.isActive := !this.state.isActive
				this.syncMenuItem(menu)
				this.setHotkeysEnabled(this.state.isActive)
				this.updateSettingsFile()
		}
	}


	syncMenuItem(menu) {
		label := this.ui.menu.entries[1].label
		(this.state.isActive ? menu.Check(label) : menu.Uncheck(label))
		(this.state.hasWheel ? menu.Enable(label) : menu.Disable(label))
	}


	setHotkeysEnabled(state) {
		Hotkey("~WheelUp", this.state.onWheelChangeCallback, (state ? "on" : "off"))
		Hotkey("~WheelDown", this.state.onWheelChangeCallback, (state ? "on" : "off"))
	}


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
			} catch Error {
				return
			}
		}
	}


	normaliseStep(step) {
		if (!IsNumber(step)) {
			return 3
		}

		step := Round(step)
		return Max(1, Min(step, 100))
	}


	updateSettingsFile() {
		SFP := __Settings.settingsFilePath

		try {
			IniWrite(toString(this.settings.isEnabled), SFP, this.moduleName, "enabled")
			IniWrite(toString(this.state.isActive), SFP, this.moduleName, "active")
			IniWrite(this.settings.step, SFP, this.moduleName, "step")
		} catch Error as e {
			throw Error("Error updating settings file: " . e.Message)
		}
	}
}