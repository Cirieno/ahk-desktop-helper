class module__VolumeSteps {
	__Init() {
		this.moduleName := "VolumeSteps"
		this.enabled := getIniVal(this.moduleName, "enabled", true)
		this.settings := {
			moduleName: this.moduleName,
			enabled: this.enabled,
			states: {
				volsteps: null
			},
			menuLabels: {
				rootMenu: "Volume",
				subMenu: "Steps"
			},
			steps: getIniVal(this.moduleName, "steps", [10, 20, 25, 30, 33, 40, 50, 60, 66, 70, 75, 80, 90, 100])
		}

		this.doSettingsFileCheck()
	}



	__New() {
		if (!this.enabled) {
			return
		}

		this.drawMenu()

		SetTimer(ObjBindMethod(this, "setObservers"), 2000)
	}



	__Delete() {
	}



	drawMenu() {
		menuLabels := this.settings.menuLabels
		_ST := _Settings.app.tray
		_SM := _Settings.app.tray.menuHandles
		local doMenuItem := ObjBindMethod(this, "doMenuItem")

		this.moduleMenu := moduleMenu := Menu()
		; rootMenu.add("MUTE", doMenuItem)
		moduleMenu.add()
		for index, val in this.settings.steps {
			moduleMenu.add(val, doMenuItem)
		}

		if (_SM.has(menuLabels.rootMenu) == true) {
			this.rootMenu := rootMenu := _SM[menuLabels.rootMenu]
		} else {
			this.rootMenu := rootMenu := Menu()
			_SM.set(menuLabels.rootMenu, rootMenu)
			A_TrayMenu.add(menuLabels.rootMenu, rootMenu)
			if (_ST.includeSubmenuIcons) {
				A_TrayMenu.setIcon(menuLabels.rootMenu, "icons\" . StrLower(menuLabels.rootMenu) . ".ico", -0)
			}
		}
		rootMenu.add("MUTE", doMenuItem)
		rootMenu.add(menuLabels.subMenu, moduleMenu)

		this.tickMenuItems()
	}



	tickMenuItems() {
		try {
			rootMenu := this.rootMenu
			moduleMenu := this.moduleMenu

			mute := isTruthy(SoundGetMute())
			vol := Round(SoundGetVolume())

			if (mute == true) {
				rootMenu.check("MUTE")
			} else {
				rootMenu.uncheck("MUTE")
				for ii, val in this.settings.steps {
					if (vol == val) {
						moduleMenu.check(val)
					} else {
						moduleMenu.uncheck(val)
					}
				}
			}
		} catch Error as e {
			; do nothing
		}
	}



	doMenuItem(name, position, menu) {
		this.setVolume(name)
	}



	setObservers() {
		this.tickMenuItems()
	}



	setVolume(vol) {
		if (vol == "MUTE") {
			SoundSetMute(!SoundGetMute())
		} else {
			SoundSetVolume(vol)
			SoundSetMute(false)
		}
	}



	doSettingsFileCheck() {
		try {
			IniRead("user_settings.ini", this.moduleName)
		} catch Error as e {
			section := join([
				"[" . this.moduleName . "]",
				"enabled = " . (this.settings.enabled ? "true" : "false"),
				"steps = [" . join(this.settings.steps, ",") . "]",
			], "`n")
			FileAppend("`n" . section . "`n", "user_settings.ini")
		}
	}
}
