class Module__PreventSleep {
	__New(){
		moduleName := "PreventSleep"
		_S := this._Settings := {0:0
			, moduleName: moduleName
			, enabled: getIniVal(moduleName . "\enabled", false)
			, activateOnLoad: getIniVal(moduleName . "\active", false)
			, notifyUser: getIniVal(moduleName . "\notify", false)
			, menuLabelParent: "Timers"
			, menuLabel: "Prevent Sleep"
			, checkInterval: 1000
			, moveTimeout: getIniVal(moduleName . "\timeoutMins", 5) * 60000
			, moveCounter: 0 }
		_S.active := false
		if (!_S.enabled){
			return
		}
		this.drawMenu()
		this.SPST := ObjBindMethod(this, "setPreventSleep__timer")
		this.setPreventSleep(_S.activateOnLoad, false)
	}
	drawMenu(){
		_S := this._Settings
		toggleActive := ObjBindMethod(this, "toggleActive")
		menu, tray, UseErrorLevel
		menu tray, rename, % _S.menuLabelParent, % _S.menuLabelParent
		if (ErrorLevel){
			menu timersMenu, add, % _S.menuLabel, % toggleActive
			menu tray, add, % _S.menuLabelParent, :timersMenu
		}
		else {
			menu timersMenu, add
			menu timersMenu, add, % _S.menuLabel, % toggleActive
		}
		menu, tray, UseErrorLevel, "off"
		this.tickMenuItems()
	}
	tickMenuItems(){
		_S := this._Settings
		menu timersMenu, % (_S.active ? "check" : "uncheck"), % _S.menuLabel
	}
	toggleActive(){
		_S := this._Settings
		this.setPreventSleep(!_S.active, false)
	}
	setPreventSleep(action := false, notify := false) {
		_S := this._Settings
		_S.active := action
		_S.moveCounter := 0
		if (_S.active){
			this.SPST()
		}
		SPST := this.SPST
		setTimer % SPST, % (_S.active ? _S.checkInterval : "delete")
		this.tickMenuItems()
	}
	setPreventSleep__timer() {
		_S := this._Settings
		if (A_TimeIdle >= _S.moveTimeout) {
			send {PrintScreen}
			_S.moveCounter += 1
		}
	}
}
