class Module__SwapMouseButtons {
	__New(){
		moduleName := "SwapMouseButtons"
		_S := this._Settings := {0:0
			, moduleName: moduleName
			, enabled: getIniVal(moduleName . "\enabled", false)
			, activateOnLoad: getIniVal(moduleName . "\active", false)
			, notifyUser: getIniVal(moduleName . "\notify", false)
			, parentMenuLabel: "Mouse"
			, menuLabel: "Swap mouse buttons"
			, checkInterval: 10000 }
		_S.active := this.getMouseButtonState()

		if (!_S.enabled){
			return
		}

		this.drawMenu()

		; TODO: run checkBackgroundChange timer

		if (_S.activateOnLoad){
			_S.active := true
			this.setMouseButtonState(_S.active, false)
			this.checkMenuItems()
		}
	}



	drawMenu(){
		_S := this._Settings

		toggleActive := ObjBindMethod(this, "toggleActive")

		menu mouseMenu, add, % _S.menuLabel, % toggleActive
		menu tray, add, % _S.parentMenuLabel, :mouseMenu

		this.checkMenuItems()
	}



	checkMenuItems(){
		_S := this._Settings

		menu mouseMenu, % (_S.active ? "check" : "uncheck"), % _S.menuLabel
	}



	toggleActive(){
		_S := this._Settings

		_S.active := !_S.active
		this.setMouseButtonState(_S.active, false)
		this.checkMenuItems()
	}



	getMouseButtonState(){
		regKey := "HKEY_CURRENT_USER\Control Panel\Mouse"
		regValue := "SwapMouseButtons"
		regType := "REG_SZ"

		regRead val, % regKey, % regValue
		return isTruthy(val)
	}



	setMouseButtonState(state, notify := false){
		_S := this._Settings
		state := isTruthy(state)
		notify := isTruthy(notify)

		regKey := "HKEY_CURRENT_USER\Control Panel\Mouse"
		regValue := "SwapMouseButtons"
		regType := "REG_SZ"

		regWrite % regType, % regKey, % regValue, % (state ? 1 : 0)
		dllCall("SwapMouseButton", int, (state ? 1 : 0))

		; if (state){
		; 	checkBackgroundChange := ObjBindMethod(this, "checkBackgroundChange")
		; 	setTimer % checkBackgroundChange, % _S.checkInterval
		; }

		; ; sendMsg("SwapMouseButtons is now " . (_S.active ? "ON" : "OFF") . "`n" . "PRIMARY => " . (_S.active ? "RIGHT" : "LEFT"), "", _objSettings.app.tray.msgTimeout)
	}



	; checkBackgroundChange(){
	; 	_S := this._Settings

	; 	if (!_S.active){
	; 		setTimer ,, delete
	; 	} else {
	; 		if (!this.getMouseButtonState()){
	; 			this.setMouseButtonState(true, false)
	; 			; this.sendDebugMsg("buttons changed in the background")
	; 		}
	; 	}
	; }
}
