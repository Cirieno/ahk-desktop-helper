class module__VolumeMouseWheel {
	__Init() {
		this.moduleName := "VolumeMouseWheel"
		this.enabled := getIniVal(this.moduleName, "enabled", false)
		this.settings := {
			moduleName: this.moduleName,
			enabled: this.enabled,
			activateOnLoad: getIniVal(this.moduleName, "on", true),
			states: {
				wheelEnabled: null
			},
			menuLabels: {
				rootMenu: "Volume",
				btns: "Wheel over Systray"
			},
			step: getIniVal(this.moduleName, "step", 3)
		}
	}


	__New() {
		if (!this.enabled) {
			return
		}

		this.settings.states.wheelEnabled := this.settings.activateOnLoad
		this.setWheelState(this.settings.activateOnLoad)

		this.drawMenu()
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
			wheelEnabled := this.settings.states.wheelEnabled
			menuLabels := this.settings.menuLabels
			rootMenu := this.rootMenu

			(wheelEnabled == true ? rootMenu.check(menuLabels.btns) : rootMenu.uncheck(menuLabels.btns))
		}
	}


	doMenuItem(name, position, menu) {
		wheelEnabled := this.settings.states.wheelEnabled
		menuLabels := this.settings.menuLabels

		switch (name) {
			case menuLabels.btns: this.setWheelState(!wheelEnabled)
		}
	}


	setWheelState(state) {
		this.settings.states.wheelEnabled := state
		local doWheelChange := ObjBindMethod(this, "doWheelChange")

		Hotkey("~WheelUp", doWheelChange, state)
		Hotkey("~WheelDown", doWheelChange, state)

		this.tickMenuItems()
	}


	doWheelChange(name) {
		trayControls := ["Button2", "ToolbarWindow323", "TrayButton1", "TrayClockWClass1", "TrayNotifyWnd1", "TrayShowDesktopButtonWClass1"]
		MouseGetPos(&x, &y, &winUID, &winControl)

		if isInArray(trayControls, winControl) {
			vol := SoundGetVolume()
			switch (name) {
				case "~WheelUp": newVol := Min((vol + this.settings.step), 100)
				case "~WheelDown": newVol := Max((vol - this.settings.step), 0)
			}
			SoundSetVolume(newVol)
		}
	}
}
