__Modules.loaded.UserHotkeys := true

class Module__UserHotkeys {
    __New(){
        moduleName := "UserHotkeys"
        this._S := {0:0
            , moduleName: moduleName
            , enabledOnInit: getIniVal(moduleName . "\enabled", false)
            , activeOnInit: getIniVal(moduleName . "\active", false)
            , notifyUser: getIniVal(moduleName . "\notify", false)
            , menuLabel: "Hotkeys" }
		this._S.enabled := (this._S.activeOnInit ? true : this._S.enabledOnInit)

		if (!this._S.enabled) {
			return
		}

		this.drawMenuItems()

		this.loadHotkeys()
        }


	/**
	 * @function drawMenuItems
    */
    drawMenuItems(){
		editHotkeys := ObjBindMethod(this, "editHotkeys")

		; menu hotkeysSub, add, % "Enable user hotkeys"
		menu hotkeysSub, add, % "Edit hotkeys", % editHotkeys
        menu tray, add, % this._S.menuLabel, :hotkeysSub
    }


	loadHotkeys(){
		Loop, read, .\user_hotkeys.txt
		{
			pos := RegExMatch(A_LoopReadLine, "^(?:\s*;)?(.*)::(.*)$", matches)
			if (pos > 0){
				try {
					Hotstring(matches1, matches2)
				} catch e {
				}
			}
		}
	}


	editHotkeys(){
		runwait % __Settings.apps["Notepad"].location . " user_hotkeys.txt"
		if (errorLevel == 0) {
			reload
		}
	}
}
