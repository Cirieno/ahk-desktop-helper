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
		_S.enabled := (_S.activateOnLoad ? true : _S.enabled)

		if (!_S.enabled){
			return
		}

		this.drawMenuItems()

		this.setHotkeys()
	}



	drawMenuItems(){
		_S := this._Settings

		setKeyLock := ObjBindMethod(this, "setKeyLock")

		menu keylockMenu, add, % "Caps Lock", % setKeyLock
		menu keylockMenu, add, % "Num Lock", % setKeyLock
		menu keylockMenu, add, % "Scroll Lock", % setKeyLock
		menu tray, add, % _S.parentMenuLabel, :keylockMenu

		this.checkMenuItems()
	}



	checkMenuItems(){
		_S := this._Settings

		menu, keylockMenu, % (GetKeyState("CapsLock", "T") ? "check" : "uncheck"), % "Caps Lock"
		menu, keylockMenu, % (GetKeyState("NumLock", "T") ? "check" : "uncheck"), % "Num Lock"
		menu, keylockMenu, % (GetKeyState("ScrollLock", "T") ? "check" : "uncheck"), % "Scroll Lock"
	}



	setHotkeys(){
		_S := this._Settings

		checkMenuItems := ObjBindMethod(this, "checkMenuItems")

		Hotkey, ~CapsLock, % checkMenuItems, % "on"
		Hotkey, ~NumLock, % checkMenuItems, % "on"
		Hotkey, ~ScrollLock, % checkMenuItems, % "on"
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

		this.checkMenuItems()
	}
}
