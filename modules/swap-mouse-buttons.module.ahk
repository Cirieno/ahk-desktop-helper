__Modules.loaded.SwapMouseButtons := true

class Module__SwapMouseButtons {
	__New(){
		moduleName := "SwapMouseButtons"
		this._S := {0:0
			, moduleName: moduleName
            , enabledOnInit: getIniVal(moduleName . "\enabled", false)
            , activeOnInit: getIniVal(moduleName . "\active", false)
            , notifyUser: getIniVal(moduleName . "\notify", false)
			, menuLabel: "Swap mouse buttons"
			, checkInterval: 1000 }
		this._S.enabled := (this._S.activeOnInit ? true : this._S.enabledOnInit)
		this._S.active := (this._S.enabled && this._S.activeOnInit)

		if (!this._S.enabled) {
			return
		}

		; _S.active := this.checkIsActive()
		; this.setActive(((_S.enabled && _S.activeOnInit) || _S.active),  false)
	}


	checkIsActive(){
		; _S := this._Settings

		; if (!_S.enabled) {
		; 	return
		; }

		; regKey := "HKEY_CURRENT_USER\Control Panel\Mouse"
		; regValue := "SwapMouseButtons"
		; regType := "REG_SZ"

		; regRead val, % regKey, % regValue
		; return (val == "1")
	}


	toggleActive(){
		; _S := this._Settings

		; this.setActive(!_S.active, _S.notify)
	}


	setActive(action := false, notify := false) {
		; _S := this._Settings

		; _S.active := action
		; regKey := "HKEY_CURRENT_USER\Control Panel\Mouse"
		; regValue := "SwapMouseButtons"
		; regType := "REG_SZ"

		; regWrite % regType, % regKey, % regValue, % (_S.active ? 1 : 0)
		; dllCall("SwapMouseButton", int, (_S.active ? 1 : 0))

		; if (action){
		; 	checkBackgroundChange := ObjBindMethod(this, "checkBackgroundChange")
		; 	setTimer % checkBackgroundChange, % _S.checkInterval
		; }

		; __tickMenuItem("tray", (_S.active ? "check" : "uncheck"), _S.menuLabel)
		; __notify(_S.moduleName, notify, _S.active)
		; ; sendMsg("SwapMouseButtons is now " . (_S.active ? "ON" : "OFF") . "`n" . "PRIMARY => " . (_S.active ? "RIGHT" : "LEFT"), "", _objSettings.app.tray.msgTimeout)
	}


	checkBackgroundChange(){
		; _S := this._Settings

		; ; __sendMsg(A_Now, _S.moduleName,, ahkMsgFormatTooltip)

		; if (!_S.active) {
		; 	setTimer ,, delete
		; } else {
		; 	if (!this.checkIsActive()) {
		; 		this.setActive(true, false)
		; 		; this.sendDebugMsg("buttons changed in the background")
		; 	}
		; }
	}


	; sendDebugMsg(text := ""){
	; 	_S := this.settings
	; 	if (!_S.enabled) {
	; 		return
	; 	}

	; 	if (__D.enabled && __D.active){
	; 		__sendMsg(text, _S.moduleName,, ahkMsgFormatMsgbox)
	; 	}
	; }


	drawMenuItems(){
		_S := this._Settings

		; toggleActive := ObjBindMethod(this, "toggleActive")
		; menu tray, add, % _S.menuLabel, % toggleActive
		; __tickMenuItem("tray", (_S.active ? "check" : "uncheck"), _S.menuLabel)
	}
}
