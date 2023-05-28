class Module__KeyLocks {
	__Init() {
		this.moduleName := moduleName := "KeyLocks"

		_Settings.modules[moduleName] := this.M_Settings := {
			moduleName: moduleName,
			enabled: getIniVal(moduleName . "\enabled", false),
			; notifyUser: getIniVal(moduleName . "\notify", false),
			parentMenuLabel: "Keyboard",
			menuLabel: "Key Locks",
			capsOnLoad: getIniVal(moduleName . "\capsOnLoad", false),
			numOnLoad: getIniVal(moduleName . "\numOnLoad", true),
			scrollOnLoad: getIniVal(moduleName . "\scrollOnLoad", true)
		}
	}


	__New() {
		if (this.M_Settings.enabled == false) {
			return
		}

		local _MS := this.M_Settings

		SetCapsLockState(_MS.capsOnLoad)
		SetNumLockState(_MS.numOnLoad)
		SetScrollLockState(_MS.scrollOnLoad)

		local captureKeyChange := ObjBindMethod(this, "captureKeyChange")
		Hotkey("~CapsLock", captureKeyChange, true)
		Hotkey("~NumLock", captureKeyChange, true)
		Hotkey("~ScrollLock", captureKeyChange, true)

		local tickMenuItems := ObjBindMethod(this, "tickMenuItems")
		SetTimer(tickMenuItems, 1000)

		this.drawMenu()
	}


	drawMenu() {
		local _MS := this.M_Settings
		local doMenuItem := ObjBindMethod(this, "doMenuItem")

		this.moduleMenu := moduleMenu := Menu()
		moduleMenu.add("Caps Lock", doMenuItem)
		moduleMenu.add("Num Lock", doMenuItem)
		moduleMenu.add("Scroll Lock", doMenuItem)

		local trayMenu := A_TrayMenu
		trayMenu.add(_MS.parentMenuLabel, moduleMenu)

		this.tickMenuItems()
	}


	tickMenuItems() {
		local moduleMenu := this.moduleMenu

		(GetKeyState("CapsLock", "T") ? moduleMenu.Check("Caps Lock") : moduleMenu.Uncheck("Caps Lock"))
		(GetKeyState("NumLock", "T") ? moduleMenu.Check("Num Lock") : moduleMenu.Uncheck("Num Lock"))
		(GetKeyState("ScrollLock", "T") ? moduleMenu.Check("Scroll Lock") : moduleMenu.Uncheck("Scroll Lock"))
	}


	doMenuItem(name, position, menu) {
		local key := StrReplace(name, " ", "")
		switch key {
			case "CapsLock": SetCapsLockState(!GetKeyState(key, "T"))
			case "NumLock": SetNumLockState(!GetKeyState(key, "T"))
			case "ScrollLock": SetScrollLockState(!GetKeyState(key, "T"))
		}

		this.tickMenuItems()
	}


	captureKeyChange(key) {
		this.tickMenuItems()
	}
}
