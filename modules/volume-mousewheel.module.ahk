/************************************************************************
 * @description VolumeMouseWheel
 * @author Rob McInnes
 * @file volume-mousewheel.module.ahk
 ***********************************************************************/



class module__VolumeMouseWheel {
	__Init() {
		this.moduleName := "VolumeMouseWheel"
		this.enabled := getIniVal(this.moduleName, "enabled", true)
		this.settings := {
			activateOnLoad: getIniVal(this.moduleName, "active", true),
			step: getIniVal(this.moduleName, "step", 3)
		}
		this.states := {
			active: this.settings.activateOnLoad
		}
		this.settings.menu := {
			path: "TRAY\Volume",
			items: [{
				type: "item",
				label: "Wheel over Systray"
			}]
		}
	}



	/** */
	__New() {
		if (!this.enabled) {
			return
		}

		thisMenu := this.drawMenu()
		setMenuItemProps(this.settings.menu.items[1].label, thisMenu, { checked: this.states.active, enabled: isTruthy(SysGet(SM_MOUSEWHEELPRESENT)) })

		this.setWheelState(this.states.active)
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
				setMenuItemProps(name, menu, { checked: this.states.active, clickCount: +1, enabled: isTruthy(SysGet(SM_MOUSEWHEELPRESENT)) })
				this.setWheelState(!this.states.active)
		}
	}



	/** */
	setWheelState(state) {
		local doWheelChange := ObjBindMethod(this, "doWheelChange")

		Hotkey("~WheelUp", doWheelChange, (state ? "on" : "off"))
		Hotkey("~WheelDown", doWheelChange, (state ? "on" : "off"))
	}



	/** */
	doWheelChange(name) {
		trayControls := ["Button2", "ToolbarWindow323", "TrayButton1", "TrayClockWClass1", "TrayNotifyWnd1", "TrayShowDesktopButtonWClass1"]
		MouseGetPos(&X, &Y, &winUID, &winControl)

		if (isInArray(trayControls, winControl)) {
			vol := SoundGetVolume()
			switch (name) {
				case "~WheelUp": newVol := Min((vol + this.settings.step), 100)
				case "~WheelDown": newVol := Max((vol - this.settings.step), 0)
			}
			SoundSetVolume(newVol)
		}
	}



	/** */
	updateSettingsFile() {
		_SAE := _Settings.app.environment
		try {
			IniWrite((this.enabled ? "true" : "false"), _SAE.settingsFilename, this.moduleName, "enabled")
			IniWrite((this.states.active ? "true" : "false"), _SAE.settingsFilename, this.moduleName, "active")
			IniWrite(this.settings.step, _SAE.settingsFilename, this.moduleName, "step")
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
