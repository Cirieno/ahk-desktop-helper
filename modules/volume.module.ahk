class Module__Volume {
	__New(){
		moduleName := "Volume"
		_S := this._Settings := {0:0
			, moduleName: moduleName
			, enabledOnInit: getIniVal(moduleName . "\enabled", false)
			, activeOnInit: getIniVal(moduleName . "\active", false)
			, notifyUser: getIniVal(moduleName . "\notify", false)
			, parentMenuLabel: "Volume"
			, useTens: isTruthy(getIniVal(moduleName . "\includeTens", false))
			, useQuarters: isTruthy(getIniVal(moduleName . "\includeQuarters", false))
			, useThirds: isTruthy(getIniVal(moduleName . "\includeThirds", false)) }
		_S.enabled := (_S.activeOnInit ? true : _S.enabledOnInit)
		_S.active := (_S.enabled && _S.activeOnInit)

		if (!_S.enabled){
			return
		}

		this.drawMenuItems()
	}



	drawMenuItems(){
		_S := this._Settings

		setVolume := ObjBindMethod(this, "setVolume")

		menu volumeSub, add, % "MUTE", % setVolume
		menu volumeSub, add
		if (_S.useTens){
			menu volumeSub, add, % "10", % setVolume
			menu volumeSub, add, % "20", % setVolume
			menu volumeSub, add, % "30", % setVolume
			menu volumeSub, add, % "40", % setVolume
			menu volumeSub, add, % "50", % setVolume
			menu volumeSub, add, % "60", % setVolume
			menu volumeSub, add, % "70", % setVolume
			menu volumeSub, add, % "80", % setVolume
			menu volumeSub, add, % "90", % setVolume
		}
		if (_S.useQuarters or _S.useThirds){
			if (_S.useTens){
				menu volumeSub, add
			}
			if (_S.useQuarters){
				menu volumeSub, add, % "25", % setVolume
			}
			if (_S.useThirds){
				menu volumeSub, add, % "33", % setVolume
			}
			if (_S.useQuarters){
				menu volumeSub, add, % "50", % setVolume
			}
			if (_S.useThirds){
				menu volumeSub, add, % "66", % setVolume
			}
			if (_S.useQuarters){
				menu volumeSub, add, % "75", % setVolume
			}
		}
		; if (_S.useThirds){
		; 	if (_S.useQuarters or _S.useTens){
		; 		menu volumeSub, add
		; 	}
		; 	menu volumeSub, add, % "33", % setVolume
		; 	menu volumeSub, add, % "66", % setVolume
		; }
		menu volumeSub, add
		menu volumeSub, add, % "100", % setVolume
		menu volumeSub, add
		menu tray, add, % _S.parentMenuLabel, :volumeSub
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
