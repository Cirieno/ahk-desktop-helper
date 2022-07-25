class Module__VolumeMouseWheel {
	__New(){
		moduleName := "VolumeMouseWheel"
		_S := this._Settings := {0:0
			, moduleName: moduleName
			, enabledOnInit: getIniVal(moduleName . "\enabled", false)
			, activeOnInit: getIniVal(moduleName . "\active", false)
			, notifyUser: getIniVal(moduleName . "\notify", false)
			, parentMenuLabel: "Volume"
			, menuLabel: "Wheel over Systray"
			, checkInterval: 200
			, step: getIniVal(moduleName . "\step", 3)
			, tooltipLabel: "Volume: " }
		_S.enabled := (_S.activeOnInit ? true : _S.enabledOnInit)
		_S.active := (_S.enabled && _S.activeOnInit)

		if (!_S.enabled){
			return
		}

		this.drawMenuItems()

		if (_S.active){
			this.setHotkeys(_S.active, false)
		}
	}



	drawMenuItems(){
		_S := this._Settings

		toggleActive := ObjBindMethod(this, "toggleActive")

		menu, tray, UseErrorLevel
		menu tray, rename, % _S.parentMenuLabel, % _S.parentMenuLabel
		if (ErrorLevel){
			menu volumeMenu, add, % _S.menuLabel, % toggleActive
			menu tray, add, % _S.parentMenuLabel, :volumeMenu
			}
		else {
			menu volumeMenu, add, % _S.menuLabel, % toggleActive
			}
		menu, tray, UseErrorLevel, "off"

		this.checkMenuItems()
	}



	checkMenuItems(){
		_S := this._Settings

		menu volumeMenu, % (_S.active ? "check" : "uncheck"), % _S.menuLabel
	}



	toggleActive(){
		_S := this._Settings

		_S.active := !_S.active

		this.setHotkeys(_S.active)

		this.checkMenuItems()
	}



	setHotkeys(state, notify := false){
		_S := this._Settings

		checkMouseLocation := ObjBindMethod(this, "checkMouseLocation")

		hotkey ~WheelUp, % checkMouseLocation, % (isTruthy(state) ? "on" : "off")
		hotkey ~WheelDown, % checkMouseLocation, % (isTruthy(state) ? "on" : "off")
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
