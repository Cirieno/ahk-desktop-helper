class module__DesktopFileDialogs {
	__Init() {
		this.moduleName := "DesktopFileDialogs"
		this.settings := {
			moduleName: this.moduleName,
			enabled: getIniVal(this.moduleName, "enabled", false),
			activateOnLoad: getIniVal(this.moduleName, "on", false),
			activeStates: { slashes: null },
			menuLabels: {
				rootMenu: "Desktop",
				btns: "Replace fwd slashes in File dialogs"
			},
		}
	}


	__New() {
		if (!this.settings.enabled) {
			return
		}

		this.setState("slashes", this.settings.activateOnLoad)

		this.drawMenu()
	}


	drawMenu() {
		_ST := _Settings.app.tray
		_SM := _Settings.app.tray.menuHandles
		local doMenuItem := ObjBindMethod(this, "doMenuItem")

		if (_SM.has(this.settings.menuLabels.rootMenu)) {
			this.rootMenu := rootMenu := _SM[this.settings.menuLabels.rootMenu]
		} else {
			this.rootMenu := rootMenu := Menu()
			_SM.set(this.settings.menuLabels.rootMenu, rootMenu)
			A_TrayMenu.add(this.settings.menuLabels.rootMenu, rootMenu)
			if (_ST.includeSubmenuIcons) {
				A_TrayMenu.setIcon(this.settings.menuLabels.rootMenu, "icons\" . StrLower(this.settings.menuLabels.rootMenu) . ".ico", -0)
			}
		}
		rootMenu.add(this.settings.menuLabels.btns, doMenuItem)

		this.tickMenuItems()
	}


	tickMenuItems() {
		try {
			rootMenu := this.rootMenu

			(this.settings.activeStates.slashes == true ? rootMenu.check(this.settings.menuLabels.btns) : rootMenu.uncheck(this.settings.menuLabels.btns))
		}
	}


	doMenuItem(name, position, menu) {
		switch (name) {
			case this.settings.menuLabels.btns: this.setState("slashes", !this.settings.activeStates.slashes)
		}
	}


	setState(key, state) {
		switch (key) {
			case "slashes": this.settings.activeStates.slashes := state
		}

		this.setHotkeys(state)

		this.tickMenuItems()
	}


	setHotkeys(state) {
		local doPaste := ObjBindMethod(this, "doPaste")

		HotIfWinactive("ahk_class #32770")
		Hotstring(":*:/", "\", state)
		Hotkey("^v", doPaste, state)
		HotIfWinactive()
	}


	doPaste(text) {
		clipboardSaved := StrReplace(A_Clipboard, "/", "\")
		EditPaste(clipboardSaved, ControlGetFocus("A"))
	}
}
