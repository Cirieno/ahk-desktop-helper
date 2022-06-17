class Module__SetVolumeWithMouseWheel {
	__New() {
		this.moduleName := "SetVolume_WithMouseWheel"
		this.settings := {0:0
			, moduleName: this.moduleName
			, enabled: getIniVal(this.moduleName . "\enabled", false)
			, activeFirstRun: getIniVal(this.moduleName . "\active", false)
			, active: false
			, notify: getIniVal(this.moduleName . "\notify", false)
			, menuLabel: "Wheel over systray"
			, checkInterval: 200
			, step: getIniVal(this.moduleName . "\step", 5)
			, isOverTray: false }
		_S := this.settings

		_S.enabled := (_S.activeFirstRun ? true : _S.enabled)
		this.enabled := _S.enabled

		this.setActive(((_S.enabled && _S.activeFirstRun) || _S.active),  false)
	}


	toggleActive() {
		_S := this.settings
		if (!_S.enabled) {
			return
		}

		this.setActive(!_S.active, _S.notify)
	}


	setActive(action := false, notify := false) {
		_S := this.settings
		if (!_S.enabled) {
			return
		}

		_S.active := action

		checkActivity := ObjBindMethod(this, "checkActivity")
		hotkey ~WheelUp, % checkActivity, % (action ? on : off)
		hotkey ~WheelDown, % checkActivity, % (action ? on : off)

		__tickMenuItem("volumeSubmenu", (_S.active ? "check" : "uncheck"), _S.menuLabel)
		__notify(_S.moduleName, notify, _S.active)
	}


	checkActivity(){
		_S := this.settings
		if (!_S.enabled) {
			return
		}

		grpSysTrayControlNames := ["Button2", "ToolbarWindow323", "TrayButton1", "TrayClockWClass1", "TrayNotifyWnd1", "TrayShowDesktopButtonWClass1"]
		MouseGetPos x , y, winUID, winControl
		if isInArray(grpSysTrayControlNames, winControl){
			this.setVolume((Instr(A_ThisHotkey, "Up") ? "+" : "-") . _S.step)
			; tooltip % (Instr(A_ThisHotkey, "Up") ? "+" : "-") . _S.step . " --> " . this.getVolume()
			tooltipMsg("Volume: " . this.getVolume(), , 1000)
		}
	}


	setVolume(vol) {
		_S := this.settings
		if (!_S.enabled) {
			return
		}

		soundSet vol, MASTER, VOLUME
		soundSet 0, MASTER, MUTE
	}
	getVolume() {
		soundGet vol, MASTER, VOLUME
		return % round(vol)
	}


	drawMenuItems() {
		_S := this.settings
		if (!_S.enabled) {
			return
		}

		toggleActive := ObjBindMethod(this, "toggleActive")
		menu volumeSubmenu, add, % _S.menuLabel, % toggleActive
		__tickMenuItem("volumeSubmenu", (_S.active ? "check" : "uncheck"), _S.menuLabel)
	}
}
