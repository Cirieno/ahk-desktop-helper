class Module__PreventSleep {
	__New(){
		this.moduleName := "PreventSleep"
		this.settings := {_:_
			, moduleName: this.moduleName
			, enabled: getIniVal(this.moduleName . "\enabled", false)
			, activeOnInit: getIniVal(this.moduleName . "\active", false)
			, active: false
			, notify: getIniVal(this.moduleName . "\notify", false)
			, menuLabel: "Prevent sleep"
			, checkInterval: 1000
			, checkTimeout: (1000 * 60 * 5)     ;// every 5 minutes
			, moveCount: 0 }
		_S := this.settings

		_S.enabled := (_S.activeOnInit ? true : _S.enabled)
		this.enabled := _S.enabled

		; _S.active := this.checkIsActive()
		this.setActive(((_S.enabled && _S.activeOnInit) || _S.active),  false)
	}


	toggleActive(){
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
		_S.moveCount := 0

		if (action) {
			checkBackgroundChange := ObjBindMethod(this, "checkBackgroundChange")
			setTimer % checkBackgroundChange, % _S.checkInterval
		}

		__tickMenuItem("tray", (_S.active ? "check" : "uncheck"), _S.menuLabel)
		__notify(_S.moduleName, notify, _S.active)
	}


	checkBackgroundChange(){
		_S := this.settings
		if (!_S.enabled) {
			return
		}

		; __sendMsg(A_Now, _S.moduleName,, ahkMsgFormatTooltip)

		if (!_S.active) {
			setTimer ,, delete
		} else {
			if (A_TimeIdle >= _S.checkTimeout) {
				send {RShift}
				_S.moveCount += 1
			}
			this.sendDebugMsg("timeIdle = " . A_TimeIdle . " / " . _S.checkTimeout . "`nmoveCount = " . _S.moveCount)
		}
	}


	sendDebugMsg(text := ""){
		_S := this.settings
		if (!_S.enabled) {
			return
		}

		if (__D.enabled && __D.active){
			__sendMsg(text, _S.moduleName,, ahkMsgFormatTooltip)
		}
	}


	drawMenuItems(){
		_S := this.settings
		if (!_S.enabled) {
			return
		}

		toggleActive := ObjBindMethod(this, "toggleActive")
		menu tray, add, % _S.menuLabel, % toggleActive
		__tickMenuItem("tray", (_S.active ? "check" : "uncheck"), _S.menuLabel)
	}
}




; this.timer := ObjBindMethod(this, "checkBackgroundChange")
; timer := this.timer
; wibble := this.checkBackgroundChange.bind(this)
; wibble := ObjBindMethod(this, "checkBackgroundChange")
