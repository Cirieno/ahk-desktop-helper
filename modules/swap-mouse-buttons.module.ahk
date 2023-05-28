class Module__SwapMouseButtons {
	__Init() {
		this.moduleName := moduleName := "SwapMouseButtons"

		_Settings.modules[moduleName] := this.M_Settings := {
			moduleName: moduleName,
			enabled: getIniVal(moduleName . "\enabled", false),
			; notifyUser: getIniVal(moduleName . "\notify", false),
			parentMenuLabel: "Mouse",
			menuLabel: "Swap mouse buttons",
			swapOnLoad: getIniVal(moduleName . "\active", false),
			swapState: this.getMouseButtonState()
		}
	}


	__New() {
		if (this.M_Settings.enabled == false) {
			return
		}

		local tickMenuItems := ObjBindMethod(this, "tickMenuItems")
		SetTimer(tickMenuItems, 1000)

		this.drawMenu()
	}


	drawMenu() {
		local _MS := this.M_Settings
		local doMenuItem := ObjBindMethod(this, "doMenuItem")

		this.moduleMenu := moduleMenu := Menu()
		moduleMenu.add(_MS.menuLabel, doMenuItem)

		local trayMenu := A_TrayMenu
		trayMenu.add(_MS.parentMenuLabel, moduleMenu)

		this.tickMenuItems()
	}


	tickMenuItems() {
		local _MS := this.M_Settings
		local moduleMenu := this.moduleMenu

		(this.getMouseButtonState() ? moduleMenu.Check(_MS.menuLabel) : moduleMenu.Uncheck(_MS.menuLabel))
	}


	doMenuItem(name, position, menu) {
		this.setMouseButtonState(!this.getMouseButtonState(), true)
		this.tickMenuItems()
	}


	getMouseButtonState() {
		local val := regRead("HKEY_CURRENT_USER\Control Panel\Mouse", "SwapMouseButtons")
		return isTruthy(val)
	}


	setMouseButtonState(state, notify := false) {
		regwrite((state ? 1 : 0), "REG_SZ", "HKEY_CURRENT_USER\Control Panel\Mouse", "SwapMouseButtons")
		dllCall("SwapMouseButton", "int", (state ? 1 : 0))
	}
}
