class Module__UserHotkeys {
	__New(){
		moduleName := "UserHotkeys"
		_S := this._Settings := {0:0
			, moduleName: moduleName
			, enabled: getIniVal(moduleName . "\enabled", false)
			, activateOnLoad: getIniVal(moduleName . "\active", false)
			, notifyUser: getIniVal(moduleName . "\notify", false)
			, parentMenuLabel: "Hotkeys"
			, menuLabel: "User hotkeys" }
		_S.enabled := (_S.activateOnLoad ? true : _S.enabled)
		_S.active := (_S.enabled && _S.activateOnLoad)

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
		editHotkeys := ObjBindMethod(this, "editHotkeys")

		menu hotkeyMenu, add, % _S.menuLabel, % toggleActive
		menu hotkeyMenu, add
		menu hotkeyMenu, add, % "Edit " . _S.menuLabel . "...", % editHotkeys
		menu tray, add, % _S.parentMenuLabel, :hotkeyMenu

		this.checkMenuItems()
	}



	checkMenuItems(){
		_S := this._Settings

		menu hotkeyMenu, % (_S.active ? "check" : "uncheck"), % _S.menuLabel
	}



	toggleActive(){
		_S := this._Settings

		_S.active := !_S.active

		this.setHotkeys(_S.active)

		this.checkMenuItems()
	}



	setHotkeys(state, notify := false){
		_S := this._Settings

		Loop, read, .\user_hotkeys.txt
		{
			pos := RegExMatch(A_LoopReadLine, "^(?:\s*;)?(.*)::(.*)$", matches)
			if (pos > 0){
				try {
					hotstring(matches1, matches2, (isTruthy(state) ? "on" : "off"))
				} catch e {
				}
			}
		}
	}



	editHotkeys(){
		_S := this._Settings

		runwait % __Settings.apps["Notepad"].location . " user_hotkeys.txt"
		if (errorLevel == 0){
			reload
		}
	}
}
