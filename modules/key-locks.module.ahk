class Module__KeyLocks {
	__New(){
		moduleName := "KeyLocks"
		_S := this._Settings := {0:0
			, moduleName: moduleName
			, enabled: getIniVal(moduleName . "\enabled", false)
			, notifyUser: getIniVal(moduleName . "\notify", false)
			, parentMenuLabel: "Keyboard"
			, menuLabel: "Key Locks"
			, capsOnLoad: getIniVal(moduleName . "\capsOnLoad", false)
			, numOnLoad: getIniVal(moduleName . "\numOnLoad", true)
			, scrollOnLoad: getIniVal(moduleName . "\scrollOnLoad", true) }
		if (!_S.enabled){
			return
		}
		this.getKeyStates()
		this.drawMenu()
		this.setHotkeys("on", false)
	}
	drawMenu(){
		_S := this._Settings
		setKeyLock := ObjBindMethod(this, "setKeyLock")
		menu keylockMenu, add, % "Caps Lock", % setKeyLock
		menu keylockMenu, add, % "Num Lock", % setKeyLock
		menu keylockMenu, add, % "Scroll Lock", % setKeyLock
		menu tray, add, % _S.parentMenuLabel, :keylockMenu
		this.tickMenuItems()
	}
	tickMenuItems(){
		_S := this._Settings
		menu, keylockMenu, % (_S.capsActive ? "check" : "uncheck"), % "Caps Lock"
		menu, keylockMenu, % (_S.numActive ? "check" : "uncheck"), % "Num Lock"
		menu, keylockMenu, % (_S.scrollActive ? "check" : "uncheck"), % "Scroll Lock"
	}
	getKeyStates(){
		_S := this._Settings
		_S.capsActive := isTruthy(GetKeyState("CapsLock", "T"))
		_S.numActive := isTruthy(GetKeyState("NumLock", "T"))
		_S.scrollActive := isTruthy(GetKeyState("ScrollLock", "T"))
	}
	setHotkeys(state, notify := false){
		_S := this._Settings
		state := isTruthy(state)
		setKeyLock := ObjBindMethod(this, "setKeyLock")
		Hotkey, ~CapsLock, % setKeyLock, % (state ? "on" : "off")
		Hotkey, ~NumLock, % setKeyLock, % (state ? "on" : "off")
		Hotkey, ~ScrollLock, % setKeyLock, % (state ? "on" : "off")
	}
	setKeyLock(key := ""){
		_S := this._Settings
		key := StrReplace((StrLen(key) > 0 ? key : A_ThisHotkey), " ", "")
		switch key {
		case "CapsLock":
			SetCapsLockState % !GetKeyState("CapsLock", "T")
		case "NumLock":
			SetNumLockState % !GetKeyState("NumLock", "T")
		case "ScrollLock":
			SetScrollLockState % !GetKeyState("ScrollLock", "T")
		}
		this.getKeyStates()
		this.tickMenuItems()
	}
}
