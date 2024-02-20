/************************************************************************
 * @description KeyboardKeylocks
 * @author Rob McInnes
 * @date 2024-01
 * @file keyboard-keylocks.module.ahk
 ***********************************************************************/
; Just a handy-dandy way to keep track of the state of the keyboard keylocks
; and to be able to toggle them from the tray menu
;
; Checks for external changes every 5 seconds



class module__KeyboardKeylocks {
	__Init() {
		this.moduleName := "KeyboardKeylocks"
		this.enabled := getIniVal(this.moduleName, "enabled", true)
		this.settings := {
			activateOnLoad: getIniVal(this.moduleName, "active", "[num]"),
			overrideExternalChanges: getIniVal(this.moduleName, "overrideExternalChanges", false),
			resetOnExit: getIniVal(this.moduleName, "resetOnExit", false),
			fileName: _Settings.app.environment.settingsFile,
			menu: {
				path: "TRAY\Keyboard",
				items: [{
					type: "item",
					label: "Caps Lock"
				}, {
					type: "item",
					label: "Num Lock"
				}, {
					type: "item",
					label: "Scroll Lock"
				}]
			}
		}
		this.states := {
			capsActive: isInArray(this.settings.activateOnLoad, "caps"),
			capsEnabled: null,
			capsEnabledOnInit: null,
			numActive: isInArray(this.settings.activateOnLoad, "num"),
			numEnabled: null,
			numEnabledOnInit: null,
			scrollActive: isInArray(this.settings.activateOnLoad, "scroll"),
			scrollEnabled: null,
			scrollEnabledOnInit: null
		}

		this.checkSettingsFile()
	}



	/** */
	__New() {
		if (!this.enabled) {
			return
		}

		this.states.capsEnabled := this.states.capsEnabledOnInit := this.getButtonState("caps")
		this.states.numEnabled := this.states.numEnabledOnInit := this.getButtonState("num")
		this.states.scrollEnabled := this.states.scrollEnabledOnInit := this.getButtonState("scroll")

		if (this.states.capsActive && !this.states.capsEnabled) {
			this.setButtonState("caps", true)
		} else if (!this.states.capsActive && this.states.capsEnabled) {
			this.setButtonState("caps", false)
		}

		if (this.states.numActive && !this.states.numEnabled) {
			this.setButtonState("num", true)
		} else if (!this.states.numActive && this.states.numEnabled) {
			this.setButtonState("num", false)
		}

		if (this.states.scrollActive && !this.states.scrollEnabled) {
			this.setButtonState("scroll", true)
		} else if (!this.states.scrollActive && this.states.scrollEnabled) {
			this.setButtonState("scroll", false)
		}


		thisMenu := this.drawMenu()
		setMenuItemProps(this.settings.menu.items[1].label, thisMenu, { checked: this.states.capsActive })
		setMenuItemProps(this.settings.menu.items[2].label, thisMenu, { checked: this.states.numActive })
		setMenuItemProps(this.settings.menu.items[3].label, thisMenu, { checked: this.states.scrollActive })

		; SetTimer(ObjBindMethod(this, "showDebugTooltip"), U_msSecond)

		this.runObserver(true)
		SetTimer(ObjBindMethod(this, "runObserver"), 5 * U_msSecond)
	}



	/** */
	__Delete() {
		if (this.settings.resetOnExit) {
			this.setButtonState("caps", this.states.capsEnabledOnInit)
			this.setButtonState("num", this.states.numEnabledOnInit)
			this.setButtonState("scroll", this.states.scrollEnabledOnInit)
		}
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
		for ii, item in this.settings.menu.items {
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
				this.states.capsEnabled := !this.states.capsEnabled
				setMenuItemProps(name, menu, { checked: this.states.capsEnabled, clickCount: +1 })
				this.setButtonState("caps", this.states.capsEnabled)
			case this.settings.menu.items[2].label:
				this.states.numEnabled := !this.states.numEnabled
				setMenuItemProps(name, menu, { checked: this.states.numEnabled, clickCount: +1 })
				this.setButtonState("num", this.states.numEnabled)
			case this.settings.menu.items[3].label:
				this.states.scrollEnabled := !this.states.scrollEnabled
				setMenuItemProps(name, menu, { checked: this.states.scrollEnabled, clickCount: +1 })
				this.setButtonState("scroll", this.states.scrollEnabled)
		}
	}



	/** */
	getButtonState(key) {
		switch (key) {
			case "caps":
				return GetKeyState("CapsLock", "T")
			case "num":
				return GetKeyState("NumLock", "T")
			case "scroll":
				return GetKeyState("ScrollLock", "T")
		}
	}



	/** */
	setButtonState(key, state) {
		switch (key) {
			case "caps":
				SetCapsLockState(state)
				this.states.capsEnabled := state
			case "num":
				SetNumLockState(state)
				this.states.numEnabled := state
			case "scroll":
				SetScrollLockState(state)
				this.states.scrollEnabled := state
		}
	}



	/** */
	runObserver(forced := false) {
		stateThen := this.states.capsEnabled
		stateNow := this.getButtonState("caps")
		if (stateNow !== stateThen) {
			this.states.capsEnabled := stateNow
			setMenuItemProps(this.settings.menu.items[1].label, this.settings.menu.path, { checked: this.states.capsEnabled })
		}

		stateThen := this.states.numEnabled
		stateNow := this.getButtonState("num")
		if (stateNow !== stateThen) {
			this.states.numEnabled := stateNow
			setMenuItemProps(this.settings.menu.items[2].label, this.settings.menu.path, { checked: this.states.numEnabled })
		}

		stateThen := this.states.scrollEnabled
		stateNow := this.getButtonState("scroll")
		if (stateNow !== stateThen) {
			this.states.scrollEnabled := stateNow
			setMenuItemProps(this.settings.menu.items[3].label, this.settings.menu.path, { checked: this.states.scrollEnabled })
		}
	}



	/** */
	updateSettingsFile() {
		try {
			state := join([
				(this.states.capsEnabled ? "caps" : ""),
				(this.states.numEnabled ? "num" : ""),
				(this.states.scrollEnabled ? "scroll" : "")
			], ",")
			state := RegExReplace(state, ",+", ",")
			state := RegExReplace(state, ",$", "")
			state := RegExReplace(state, "^,", "")

			IniWrite((this.enabled ? "true" : "false"), this.settings.fileName, this.moduleName, "enabled")
			IniWrite("[" . state . "]", this.settings.fileName, this.moduleName, "active")
			IniWrite((this.settings.overrideExternalChanges ? "true" : "false"), this.settings.fileName, this.moduleName, "overrideExternalChanges")
			IniWrite((this.settings.resetOnExit ? "true" : "false"), this.settings.fileName, this.moduleName, "resetOnExit")
		} catch Error as e {
			throw ("Error updating settings file: " . e.Message)
		}
	}



	/** */
	checkSettingsFile() {
		try {
			IniRead(this.settings.fileName, this.moduleName)
		} catch Error as e {
			section := join([
				"[" . this.moduleName . "]",
				"enabled=true",
				"active=[num]",
				"overrideExternalChanges=false"
				"resetOnExit=false"
			], "`n")
			FileAppend("`n" . section . "`n", this.settings.fileName)
		}
	}



	/** */
	showDebugTooltip() {
		debugMsg(join([
			"MODULE = " . this.moduleName . "`n",
			"states.capsActive = " . this.states.capsActive,
			"states.numActive = " . this.states.numActive,
			"states.scrollActive = " . this.states.scrollActive,
			"states.capsEnabled = " . this.states.capsEnabled . " (init: " . this.states.capsEnabledOnInit . ")",
			"states.numEnabled = " . this.states.numEnabled . " (init: " . this.states.numEnabledOnInit . ")",
			"states.scrollEnabled = " . this.states.scrollEnabled . " (init: " . this.states.scrollEnabledOnInit . ")",
			"settings.resetOnExit = " . this.settings.resetOnExit
			"settings.activateOnLoad = [" . join(this.settings.activateOnLoad, ",") . "]",
		], "`n"), 1, 1)
	}
}
