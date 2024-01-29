class module__MouseSwapButtons {
	__Init() {
		this.moduleName := "MouseSwapButtons"
		this.enabled := getIniVal(this.moduleName, "enabled", false)
		this.settings := {
			moduleName: this.moduleName,
			enabled: this.enabled,
			activateOnLoad: getIniVal(this.moduleName, "on", false),
			states: {
				buttonsSwapped: null
			},
			menuLabels: {
				rootMenu: "Mouse",
				btns: "Swap mouse buttons"
			}
		}
	}


	__New() {
		if (!this.enabled) {
			return
		}

		this.settings.states.buttonsSwapped := buttonsSwapped := this.getButtonsState()
		activateOnLoad := this.settings.activateOnLoad

		if (activateOnLoad && !buttonsSwapped) {
			this.setButtonsState(true)
		} else if (!activateOnLoad && buttonsSwapped) {
			this.setButtonsState(false)
		}

		this.drawMenu()

		SetTimer(ObjBindMethod(this, "setObservers"), 2000)
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
			buttonsSwapped := this.settings.states.buttonsSwapped
			menuLabels := this.settings.menuLabels
			rootMenu := this.rootMenu

			(buttonsSwapped == true ? rootMenu.check(menuLabels.btns) : rootMenu.uncheck(menuLabels.btns))
		}
	}


	doMenuItem(name, position, menu) {
		buttonsSwapped := this.settings.states.buttonsSwapped
		menuLabels := this.settings.menuLabels

		switch (name) {
			case menuLabels.btns: this.setButtonsState(!buttonsSwapped)
		}
	}


	getButtonsState() {
		return isTruthy(RegRead("HKEY_CURRENT_USER\Control Panel\Mouse", "SwapMouseButtons"))
	}


	setButtonsState(state) {
		RegWrite((state == true ? 1 : 0), "REG_SZ", "HKEY_CURRENT_USER\Control Panel\Mouse", "SwapMouseButtons")
		DllCall("SwapMouseButton", "int", (state == true ? 1 : 0))

		this.settings.states.buttonsSwapped := state

		this.tickMenuItems()
	}


	setObservers() {
		stateThen := this.settings.states.buttonsSwapped
		stateNow := this.getButtonsState()

		if (stateNow !== stateThen) {
			this.settings.states.buttonsSwapped := stateNow
			this.tickMenuItems()
		}
	}
}
