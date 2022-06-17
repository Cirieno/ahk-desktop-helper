class Module__DisableProxy {
	__New() {
		this.moduleName := "DisableProxy"
		this.settings := {0:0
			, moduleName: this.moduleName
			, enabled: getIniVal(this.moduleName . "\enabled", false)
			, activeFirstRun: getIniVal(this.moduleName . "\active", false)
			, active: false
			, notify: getIniVal(this.moduleName . "\notify", false)
			, menuLabel: "Disable proxy"
			, checkInterval: 1000
			, keyName: "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings"
			, valueName: "ProxyEnable"
			, valueType: "REG_DWORD" }
		_S := this.settings

		_S.enabled := (_S.activeFirstRun ? true : _S.enabled)
		this.enabled := _S.enabled

		_S.active := this.checkIsActive()
		this.setActive(((_S.enabled && _S.activeFirstRun) || _S.active),  false)
	}


	checkIsActive() {
		_S := this.settings
		if (!_S.enabled) {
			return
		}

		regRead regVal, % _S.keyName, % _S.valueName
		return (regVal == "0")
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
		regWrite % _S.valueType, % _S.keyName, % _S.valueName, % (_S.active ? 0 : 1)

		if (action){
			checkBackgroundChange := ObjBindMethod(this, "checkBackgroundChange")
			setTimer % checkBackgroundChange, % _S.checkInterval
		}

		__tickMenuItem("tray", (_S.active ? "check" : "uncheck"), _S.menuLabel)
		__notify(_S.moduleName, notify, _S.active)
	}


	checkBackgroundChange() {
		_S := this.settings
		if (!_S.enabled) {
			return
		}

		; __sendMsg(A_Now, _S.moduleName, , ahkMsgFormatTooltip)

		if (!_S.active) {
			setTimer , , delete
		} else {
			if (!this.checkIsActive()) {
				this.setActive(true, false)
				this.sendDebugMsg("status changed to in the background")
			}
		}
	}


	sendDebugMsg(text := ""){
		_S := this.settings
		if (!_S.enabled) {
			return
		}

		if (__D.enabled && __D.active){
			__sendMsg(text, _S.moduleName, , ahkMsgFormatMsgbox)
		}
	}


	drawMenuItems() {
		_S := this.settings
		if (!_S.enabled) {
			return
		}

		toggleActive := ObjBindMethod(this, "toggleActive")
		menu tray, add, % _S.menuLabel, % toggleActive
		__tickMenuItem("tray", (_S.active ? "check" : "uncheck"), _S.menuLabel)
	}
}