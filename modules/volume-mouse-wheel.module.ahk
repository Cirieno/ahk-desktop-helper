class Module__VolumeMouseWheel {
	__New(){
		moduleName := "VolumeMouseWheel"
		_S := this._Settings := {0:0
			, moduleName: moduleName
			, enabled: getIniVal(moduleName . "\enabled", false)
			, activateOnLoad: getIniVal(moduleName . "\active", false)
			, notifyUser: getIniVal(moduleName . "\notify", false)
			, menuLabelParent: "Volume"
			, menuLabel: "Wheel over Systray"
			, step: getIniVal(moduleName . "\step", 3)
			, tooltipLabel: "Volume: " }
		_S.active := false
		if (!_S.enabled){
			return
		}
		this.drawMenu()
		this.CML := ObjBindMethod(this, "checkMouseLocation")
		this.setHotkeys(_S.activateOnLoad, false)
	}
	drawMenu(){
		_S := this._Settings
		toggleActive := ObjBindMethod(this, "toggleActive")
		menu, tray, UseErrorLevel
		menu tray, rename, % _S.menuLabelParent, % _S.menuLabelParent
		if (ErrorLevel){
			menu volumeMenu, add, % _S.menuLabel, % toggleActive
			menu tray, add, % _S.menuLabelParent, :volumeMenu
		}
		else {
			menu volumeMenu, add
			menu volumeMenu, add, % _S.menuLabel, % toggleActive
		}
		menu, tray, UseErrorLevel, "off"
		this.tickMenuItems()
	}
	tickMenuItems(){
		_S := this._Settings
		menu volumeMenu, % (_S.active ? "check" : "uncheck"), % _S.menuLabel
	}
	toggleActive(){
		_S := this._Settings
		this.setHotkeys(!_S.active, true)
	}
	setHotkeys(action, notify := false){
		_S := this._Settings
		_S.active := action
		CML := this.CML
		hotkey ~WheelUp, % CML, % (action ? "on" : "off")
		hotkey ~WheelDown, % CML, % (action ? "on" : "off")
		this.tickMenuItems()
	}
	checkMouseLocation(){
		_S := this._Settings
		grpSysTrayControlNames := ["Button2", "ToolbarWindow323", "TrayButton1", "TrayClockWClass1", "TrayNotifyWnd1", "TrayShowDesktopButtonWClass1"]
		MouseGetPos x, y, winUID, winControl
		if isInArray(grpSysTrayControlNames, winControl){
			this.setVolume((Instr(A_ThisHotkey, "Up") ? "+" : "-") . _S.step)
			tooltipMsg(_S.tooltipLabel . this.getVolume(),, 1000)
		}
	}
	setVolume(vol){
		soundSet vol, MASTER, VOLUME
		soundSet 0, MASTER, MUTE
	}
	getVolume(){
		soundGet vol, MASTER, VOLUME
		return % round(vol)
	}
}
