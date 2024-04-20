/**********************************************************
 * @name VolumeMouseWheel
 * @author RM
 * @file volume-mousewheel.module.ahk
 *********************************************************/



class module__VolumeMouseWheel {
	__Init() {
		this.moduleName := moduleName := "VolumeMouseWheel"
		this.enabled := getIniVal(moduleName, "enabled", true)
		this.settings := {
			activateOnLoad: getIniVal(moduleName, "active", false),
			step: getIniVal(moduleName, "step", 3)
		}
		this.states := {
			active: null,
			wheelFound: null
		}
		this.settings.menu := {
			path: "TRAY\Volume",
			items: [{
				type: "item",
				label: "Wheel over Systray"
			}]
		}
	}



	__New() {
		if (!this.enabled) {
			return
		}

		this.states.active := this.settings.activateOnLoad
		this.states.wheelFound := toBoolean(SysGet(SM_MOUSEPRESENT) && SysGet(SM_MOUSEWHEELPRESENT))

		thisMenu := this.drawMenu()
		setMenuItemProps(this.settings.menu.items[1].label, thisMenu, {
			checked: this.states.active,
			enabled: this.states.wheelFound
		})

		this.setWheelState(this.states.active)
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
				this.states.active := !this.states.active
				setMenuItemProps(name, menu, {
					checked: this.states.active,
					clickCount: +1,
					enabled: this.states.wheelFound
				})
				this.setWheelState(this.states.active)
		}
	}



	setWheelState(state) {
		doWheelChange := ObjBindMethod(this, "doWheelChange")

		Hotkey("~WheelUp", doWheelChange, (state ? "on" : "off"))
		Hotkey("~WheelDown", doWheelChange, (state ? "on" : "off"))
	}



	doWheelChange(name) {
		trayControls := ["Button2", "ToolbarWindow323", "TrayButton1", "TrayClockWClass1", "TrayNotifyWnd1", "TrayShowDesktopButtonWClass1"]
		MouseGetPos(, , , &control)

		if (trayControls.includes(control)) {
			vol := SoundGetVolume()
			switch (name) {
				case "~WheelUp":
					newVol := Min((vol + this.settings.step), 100)
				case "~WheelDown":
					newVol := Max((vol - this.settings.step), 0)
			}
			SoundSetVolume(newVol)
		}
	}



	updateSettingsFile() {
		SFP := __Settings.settingsFilePath

		try {
			IniWrite(toString(this.enabled), SFP, this.moduleName, "enabled")
			IniWrite(toString(this.states.active), SFP, this.moduleName, "active")
			IniWrite(this.settings.step, SFP, this.moduleName, "step")
		} catch Error as e {
			throw Error("Error updating settings file: " . e.Message)
		}
	}
}
