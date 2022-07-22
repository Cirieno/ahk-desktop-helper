class Module__SetKeyLocks {
	__New(){
		moduleName := "SetKeyLocks"
		this._S := {0:0
			, moduleName: moduleName
			, enabledOnInit: getIniVal(moduleName . "\enabled", false)
			, activeOnInit: getIniVal(moduleName . "\active", false)
			, notifyUser: getIniVal(moduleName . "\notify", false)
			, capsOnLoad: getIniVal(moduleName . "\capsOnLoad", false)
			, numOnLoad: getIniVal(moduleName . "\numOnLoad", true)
			, scrollOnLoad: getIniVal(moduleName . "\scrollOnLoad", true)
			, menuLabel: "Key Locks" }
		this._S.enabled := (this._S.activeOnInit ? true : this._S.enabledOnInit)
		this._S.active := (this._S.enabled && this._S.activeOnInit)

		if (!this._S.enabled){
			return
		}

		this.drawMenuItems()

		menuTickKeys := ObjBindMethod(this, "menuTickKeys")
		Hotkey, ~CapsLock, % menuTickKeys, On
		Hotkey, ~NumLock, % menuTickKeys, On
		Hotkey, ~ScrollLock, % menuTickKeys, On

		; TODO: notifications
	}



	drawMenuItems(){
		setKeyLock := ObjBindMethod(this, "setKeyLock")

		menu keylocksSub, add, % "Caps Lock", % setKeyLock
		menu keylocksSub, add, % "Num Lock", % setKeyLock
		menu keylocksSub, add, % "Scroll Lock", % setKeyLock
		menu tray, add, % this._S.menuLabel, :keylocksSub

		this.menuTickKeys()
	}



	menuTickKeys(){
		menu, keylocksSub, % (GetKeyState("CapsLock", "T") ? "check" : "uncheck"), % "Caps Lock"
		menu, keylocksSub, % (GetKeyState("NumLock", "T") ? "check" : "uncheck"), % "Num Lock"
		menu, keylocksSub, % (GetKeyState("ScrollLock", "T") ? "check" : "uncheck"), % "Scroll Lock"
	}



	setKeyLock(key := ""){
		key := StrReplace((StrLen(key) > 0 ? key : A_ThisHotkey), " ", "")

		switch key {
			case "CapsLock":
				SetCapsLockState % !GetKeyState("CapsLock", "T")
			case "NumLock":
				SetNumLockState % !GetKeyState("NumLock", "T")
			case "ScrollLock":
				SetScrollLockState % !GetKeyState("ScrollLock", "T")
		}

		this.menuTickKeys()
	}
}
