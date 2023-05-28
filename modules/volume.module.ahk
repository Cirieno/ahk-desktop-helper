class Module__Volume {
	__Init() {
		this.moduleName := moduleName := "Volume"

		_Settings.modules[moduleName] := this.M_Settings := {
			moduleName: moduleName,
			enabled: getIniVal(moduleName . "\enabled", false),
			; notifyUser: getIniVal(moduleName . "\notify", false)
			parentMenuLabel: "[root]",
			menuLabel: "Volume",
			useTens: getIniVal(moduleName . "\includeTens", false),
			useQuarters: getIniVal(moduleName . "\includeQuarters", false),
			useThirds: getIniVal(moduleName . "\includeThirds", false)
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
		moduleMenu.Add("MUTE", doMenuItem)
		moduleMenu.Add()
		if (_MS.useTens) {
			moduleMenu.Add("10", doMenuItem)
			moduleMenu.Add("20", doMenuItem)
			moduleMenu.Add("30", doMenuItem)
			moduleMenu.Add("40", doMenuItem)
			moduleMenu.Add("50", doMenuItem)
			moduleMenu.Add("60", doMenuItem)
			moduleMenu.Add("70", doMenuItem)
			moduleMenu.Add("80", doMenuItem)
			moduleMenu.Add("90", doMenuItem)
		}
		if (_MS.useQuarters) {
			; moduleMenu.Add(" ", doMenuItem, "+Break +BarBreak")
			moduleMenu.Add()
			moduleMenu.Add("25", doMenuItem)
			moduleMenu.Add("50", doMenuItem)
			moduleMenu.Add("75", doMenuItem)
		}
		if (_MS.useThirds) {
			; moduleMenu.Add(" ", doMenuItem, "+Break +BarBreak")
			moduleMenu.Add()
			moduleMenu.Add("33", doMenuItem)
			moduleMenu.Add("66", doMenuItem)
		}
		moduleMenu.Add("100", doMenuItem)

		local trayMenu := A_TrayMenu
		trayMenu.Add(_MS.menuLabel, moduleMenu)

		this.tickMenuItems()
	}


	tickMenuItems() {
		local moduleMenu := this.moduleMenu

		mute := isTruthy(SoundGetMute())
		vol := integer(SoundGetVolume())

		if (mute == true) {
			moduleMenu.Check("MUTE")
		} else {
			moduleMenu.Uncheck("MUTE")
			(vol == 10 ? moduleMenu.Check("10") : moduleMenu.Uncheck("10"))
			(vol == 20 ? moduleMenu.Check("20") : moduleMenu.Uncheck("20"))
			(vol == 25 ? moduleMenu.Check("25") : moduleMenu.Uncheck("25"))
			(vol == 30 ? moduleMenu.Check("30") : moduleMenu.Uncheck("30"))
			(vol == 33 ? moduleMenu.Check("33") : moduleMenu.Uncheck("33"))
			(vol == 40 ? moduleMenu.Check("40") : moduleMenu.Uncheck("40"))
			(vol == 50 ? moduleMenu.Check("50") : moduleMenu.Uncheck("50"))
			(vol == 60 ? moduleMenu.Check("60") : moduleMenu.Uncheck("60"))
			(vol == 66 ? moduleMenu.Check("66") : moduleMenu.Uncheck("66"))
			(vol == 70 ? moduleMenu.Check("70") : moduleMenu.Uncheck("70"))
			(vol == 75 ? moduleMenu.Check("75") : moduleMenu.Uncheck("75"))
			(vol == 80 ? moduleMenu.Check("80") : moduleMenu.Uncheck("80"))
			(vol == 90 ? moduleMenu.Check("90") : moduleMenu.Uncheck("90"))
			(vol == 100 ? moduleMenu.Check("100") : moduleMenu.Uncheck("100"))
		}
	}


	doMenuItem(name, position, menu) {
		this.setVolume(name)
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
}
