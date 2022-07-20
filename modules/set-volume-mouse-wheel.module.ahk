__Modules.loaded.SetVolumeMouseWheel := true

class Module__SetVolumeMouseWheel {
    __New(){
        moduleName := "SetVolume_MouseWheel"
        this._S := {0:0
            , moduleName: this.moduleName
            , enabledOnInit: getIniVal(moduleName . "\enabled", false)
            , activeOnInit: getIniVal(moduleName . "\active", false)
            , notifyUser: getIniVal(moduleName . "\notify", false)
            , menuLabel: "Wheel over Systray"
			, tooltipLabel: "Volume: "
			, parentMenuLabel: __Modules.SetVolume._S.menuLabel
			, checkInterval: 200
			, step: getIniVal(this.moduleName . "\step", 3) }
		this._S.enabled := (this._S.activeOnInit ? true : this._S.enabledOnInit)
		this._S.active := (this._S.enabled && this._S.activeOnInit)
		this._S.parentMenuLabel := (StrLen(this._S.parentMenuLabel) ? this._S.parentMenuLabel : "Volume")

		if (!this._S.enabled) {
			return
		}

		this.drawMenuItems()

		this.setActive(this._S.active, false)
        }


	/**
	* @function setActive
	* @param {boolean} [active]
	* @param {boolean} [notify=false] Notify the user
	*/
	setActive(active, notify := false) {
		this._S.active := active

		checkMouseLocation := ObjBindMethod(this, "checkMouseLocation")
		hotkey ~WheelUp, % checkMouseLocation, % (this._S.active ? "on" : "off")
		hotkey ~WheelDown, % checkMouseLocation, % (this._S.active ? "on" : "off")

		Menu, volumeSub, % (this._S.active ? "check" : "uncheck"), % this._S.menuLabel

		; __notify(this._S.moduleName, notify, this._S.active)
		; TODO: put __notify in a class or copy the function here
	}


	/**
	 * @function toggleActive
	 */
	toggleActive(){
		this.setActive(!this._S.active, this._S.notify)
	}


	/**
	 * @function checkMouseLocation
	 */
	checkMouseLocation(){
		grpSysTrayControlNames := ["Button2", "ToolbarWindow323", "TrayButton1", "TrayClockWClass1", "TrayNotifyWnd1", "TrayShowDesktopButtonWClass1"]
		MouseGetPos x, y, winUID, winControl
		if isInArray(grpSysTrayControlNames, winControl) {
			this.setVolume((Instr(A_ThisHotkey, "Up") ? "+" : "-") . this._S.step)
			tooltipMsg(this._S.tooltipLabel . this.getVolume(),, 1000)
		}
	}


	/**
	 * @function setVolume
	 * @param {integer|string} vol
	 */
	setVolume(vol) {
		soundSet vol, MASTER, VOLUME
		soundSet 0, MASTER, MUTE
	}


	/**
	 * @function getVolume
	*/
	getVolume(){
		soundGet vol, MASTER, VOLUME
		return % round(vol)
	}


	/**
	 * @function drawMenuItems
	 */
	drawMenuItems(){
		toggleActive := ObjBindMethod(this, "toggleActive")
		doMenuItem__null := ObjBindMethod(this, "doMenuItem__null")

		menu, tray, UseErrorLevel
		menu tray, rename, % this._S.parentMenuLabel, % this._S.parentMenuLabel
		if (ErrorLevel){
			menu volumeSub, add, % this._S.menuLabel, % toggleActive
			menu tray, add, % this._S.parentMenuLabel, :volumeSub
			}
		else {
			menu volumeSub, add
			menu volumeSub, add, % this._S.menuLabel, % toggleActive
			}
		Menu, tray, UseErrorLevel, "off"
    }


	/**
	 * @label doMenuItem__null
	 */
	doMenuItem__null(){
		return
	}
}
