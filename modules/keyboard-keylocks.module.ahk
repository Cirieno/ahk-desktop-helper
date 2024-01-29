class module__KeyboardKeylocks {
	__Init() {
		this.moduleName := "KeyboardKeylocks"
		this.enabled := getIniVal(this.moduleName, "enabled", false)
		this.settings := {
			moduleName: this.moduleName,
			enabled: this.enabled,
			activateOnLoad: getIniVal(this.moduleName, "on", []),
			deactivateOnLoad: getIniVal(this.moduleName, "off", []),
			states: {
				caps: null,
				num: null,
				scroll: null
			},
			menuLabels: {
				rootMenu: "Keyboard",
				subMenu: "Key Locks",
				caps: "Caps Lock",
				num: "Num Lock",
				scroll: "Scroll Lock"
			},
		}
	}


	__New() {
		if (!this.enabled) {
			return
		}

		this.settings.states.capsEnabled := this.getButtonState("caps")
		this.settings.states.numEnabled := this.getButtonState("num")
		this.settings.states.scrollEnabled := this.getButtonState("scroll")

		for each, key in ["caps", "num", "scroll"] {
			if isInArray(this.settings.activateOnLoad, key)
				this.setButtonState(key, true)
			else if isInArray(this.settings.deactivateOnLoad, key)
				this.setButtonState(key, false)
		}

		this.drawMenu()

		SetTimer(ObjBindMethod(this, "setObservers"), 2000)
	}


	drawMenu() {
		menuLabels := this.settings.menuLabels
		_ST := _Settings.app.tray
		_SM := _Settings.app.tray.menuHandles
		local doMenuItem := ObjBindMethod(this, "doMenuItem")

		this.moduleMenu := moduleMenu := Menu()
		moduleMenu.add(this.settings.menuLabels.caps, doMenuItem)
		moduleMenu.add(this.settings.menuLabels.num, doMenuItem)
		moduleMenu.add(this.settings.menuLabels.scroll, doMenuItem)

		if (_SM.has(this.settings.menuLabels.rootMenu) == true) {
			this.rootMenu := rootMenu := _SM[this.settings.menuLabels.rootMenu]
		} else {
			this.rootMenu := rootMenu := Menu()
			_SM.set(this.settings.menuLabels.rootMenu, rootMenu)
			A_TrayMenu.add(this.settings.menuLabels.rootMenu, rootMenu)
			if (_ST.includeSubmenuIcons) {
				A_TrayMenu.setIcon(this.settings.menuLabels.rootMenu, "icons\" . StrLower(this.settings.menuLabels.rootMenu) . ".ico", -0)
			}
		}
		rootMenu.add(menuLabels.subMenu, moduleMenu)

		this.tickMenuItems()
	}


	tickMenuItems() {
		try {
			capsEnabled := this.settings.states.capsEnabled
			numEnabled := this.settings.states.numEnabled
			scrollEnabled := this.settings.states.scrollEnabled
			menuLabels := this.settings.menuLabels
			moduleMenu := this.moduleMenu

			(capsEnabled == true ? moduleMenu.check(menuLabels.caps) : moduleMenu.uncheck(menuLabels.caps))
			(numEnabled == true ? moduleMenu.check(menuLabels.num) : moduleMenu.uncheck(menuLabels.num))
			(scrollEnabled == true ? moduleMenu.check(menuLabels.scroll) : moduleMenu.uncheck(menuLabels.scroll))
		}
	}


	doMenuItem(name, position, menu) {
		capsEnabled := this.settings.states.capsEnabled
		numEnabled := this.settings.states.numEnabled
		scrollEnabled := this.settings.states.scrollEnabled
		menuLabels := this.settings.menuLabels

		switch (name) {
			case menuLabels.caps: this.setButtonState("caps", !capsEnabled)
			case menuLabels.num: this.setButtonState("num", !numEnabled)
			case menuLabels.scroll: this.setButtonState("scroll", !scrollEnabled)
		}
	}


	getButtonState(key) {
		switch (key) {
			case "caps": return GetKeyState("CapsLock", "T")
			case "num": return GetKeyState("NumLock", "T")
			case "scroll": return GetKeyState("ScrollLock", "T")
		}
	}


	setButtonState(key, state) {
		switch (key) {
			case "caps":
				SetCapsLockState(state)
				this.settings.states.capsEnabled := state
			case "num":
				SetNumLockState(state)
				this.settings.states.numEnabled := state
			case "scroll":
				SetScrollLockState(state)
				this.settings.states.scrollEnabled := state
		}

		this.tickMenuItems()
	}


	setObservers() {
		stateThen := this.settings.states.capsEnabled
		stateNow := this.getButtonState("caps")
		if (stateNow !== stateThen) {
			this.settings.states.capsEnabled := stateNow
			this.tickMenuItems()
		}

		stateThen := this.settings.states.numEnabled
		stateNow := this.getButtonState("num")
		if (stateNow !== stateThen) {
			this.settings.states.numEnabled := stateNow
			this.tickMenuItems()
		}

		stateThen := this.settings.states.scrollEnabled
		stateNow := this.getButtonState("scroll")
		if (stateNow !== stateThen) {
			this.settings.states.scrollEnabled := stateNow
			this.tickMenuItems()
		}
	}
}
