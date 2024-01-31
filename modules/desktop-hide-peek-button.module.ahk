class module__DesktopHidePeekButton {
	__Init() {
		this.moduleName := "DesktopHidePeekButton"
		this.enabled := getIniVal(this.moduleName, "enabled", true)
		this.settings := {
			moduleName: this.moduleName,
			enabled: this.enabled,
			activateOnLoad: getIniVal(this.moduleName, "on", false),
			states: {
				buttonFound: null,
				buttonHidden: null,
				onInit: null
			},
			menuLabels: {
				rootMenu: "Desktop",
				btns: "Hide Peek button"
			}
		}

		this.doSettingsFileCheck()
	}



	__New() {
		if (!this.enabled) {
			return
		}

		this.settings.hWnd := hWnd := this.getPeekButtonHwnd()
		this.settings.states.buttonFound := buttonFound := (hWnd !== null)
		this.settings.states.onInit := this.getPeekButtonState()
		activateOnLoad := this.settings.activateOnLoad

		if (buttonFound) {
			this.settings.states.buttonHidden := buttonHidden := this.getPeekButtonState()

			if (activateOnLoad && !buttonHidden) {
				this.setPeekButtonState(false)
			} else if (!activateOnLoad && buttonHidden) {
				this.setPeekButtonState(true)
			}
		}

		this.drawMenu()
	}



	__Delete() {
		this.setPeekButtonState(this.settings.states.onInit)
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
			buttonHidden := this.settings.states.buttonHidden
			menuLabels := this.settings.menuLabels
			rootMenu := this.rootMenu

			(buttonHidden == true ? rootMenu.check(menuLabels.btns) : rootMenu.uncheck(menuLabels.btns))
		} catch Error as e {
			; do nothing
		}
	}



	doMenuItem(name, position, menu) {
		buttonHidden := this.settings.states.buttonHidden
		menuLabels := this.settings.menuLabels

		switch (name) {
			case menuLabels.btns: this.setPeekButtonState(!!buttonHidden)
		}
	}



	getPeekButtonState() {
		return (ControlGetVisible(this.settings.hWnd) ? false : true)
	}



	setPeekButtonState(state) {
		hWnd := this.settings.hWnd

		if (state) {
			ControlShow("TrayShowDesktopButtonWClass1", "ahk_class Shell_TrayWnd")
			this.settings.states.buttonHidden := false
		} else {
			ControlHide("TrayShowDesktopButtonWClass1", "ahk_class Shell_TrayWnd")
			this.settings.states.buttonHidden := true
		}

		this.tickMenuItems()
	}



	getPeekButtonHwnd() {
		hWnd := ControlGetHwnd("TrayShowDesktopButtonWClass1", "ahk_class Shell_TrayWnd")
		return (hWnd !== null ? hWnd : null)
	}



	doSettingsFileCheck() {
		try {
			IniRead("user_settings.ini", this.moduleName)
		} catch Error as e {
			section := join([
				"[" . this.moduleName . "]",
				"enabled = " . (this.settings.enabled ? "true" : "false"),
				"on = " . (this.settings.activateOnLoad ? "true" : "false"),
			], "`n")
			FileAppend("`n" . section . "`n", "user_settings.ini")
		}
	}
}
