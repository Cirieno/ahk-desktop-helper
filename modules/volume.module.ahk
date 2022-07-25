class Module__Volume {
	__New(){
		moduleName := "Volume"
		_S := this._Settings := {0:0
			, moduleName: moduleName
			, enabled: getIniVal(moduleName . "\enabled", false)
			, activateOnLoad: getIniVal(moduleName . "\active", false)
			, notifyUser: getIniVal(moduleName . "\notify", false)
			, parentMenuLabel: "Volume"
			, useTens: isTruthy(getIniVal(moduleName . "\includeTens", false))
			, useQuarters: isTruthy(getIniVal(moduleName . "\includeQuarters", false))
			, useThirds: isTruthy(getIniVal(moduleName . "\includeThirds", false)) }
		_S.enabled := (_S.activateOnLoad ? true : _S.enabled)
		_S.active := (_S.enabled && _S.activateOnLoad)

		if (!_S.enabled){
			return
		}

		this.drawMenuItems()
	}



	drawMenuItems(){
		_S := this._Settings

		setVolume := ObjBindMethod(this, "setVolume")

		menu volumeMenu, add, % "MUTE", % setVolume
		menu volumeMenu, add
		if (_S.useTens){
			menu volumeMenu, add, % "10", % setVolume
			menu volumeMenu, add, % "20", % setVolume
			menu volumeMenu, add, % "30", % setVolume
			menu volumeMenu, add, % "40", % setVolume
			menu volumeMenu, add, % "50", % setVolume
			menu volumeMenu, add, % "60", % setVolume
			menu volumeMenu, add, % "70", % setVolume
			menu volumeMenu, add, % "80", % setVolume
			menu volumeMenu, add, % "90", % setVolume
		}
		if (_S.useQuarters or _S.useThirds){
			if (_S.useTens){
				menu volumeMenu, add
			}
			if (_S.useQuarters){
				menu volumeMenu, add, % "25", % setVolume
			}
			if (_S.useThirds){
				menu volumeMenu, add, % "33", % setVolume
			}
			if (_S.useQuarters){
				menu volumeMenu, add, % "50", % setVolume
			}
			if (_S.useThirds){
				menu volumeMenu, add, % "66", % setVolume
			}
			if (_S.useQuarters){
				menu volumeMenu, add, % "75", % setVolume
			}
		}
		; if (_S.useThirds){
		; 	if (_S.useQuarters or _S.useTens){
		; 		menu volumeMenu, add
		; 	}
		; 	menu volumeMenu, add, % "33", % setVolume
		; 	menu volumeMenu, add, % "66", % setVolume
		; }
		menu volumeMenu, add
		menu volumeMenu, add, % "100", % setVolume
		menu volumeMenu, add
		menu tray, add, % _S.parentMenuLabel, :volumeMenu
	}



	setVolume(vol){
		if (vol == "MUTE"){
			soundSet 1, MASTER, MUTE
		} else {
			soundSet vol, MASTER, VOLUME
			soundSet 0, MASTER, MUTE
		}
	}



	getVolume(){
		soundGet vol, MASTER, VOLUME
		return % round(vol)
	}
}
