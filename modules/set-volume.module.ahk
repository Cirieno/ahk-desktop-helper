__Modules.loaded.SetVolume := true

class Module__SetVolume {
    __New(){
        moduleName := "SetVolume"
        this._S := {0:0
            , moduleName: moduleName
            , enabledOnInit: getIniVal(moduleName . "\enabled", false)
            , activeOnInit: getIniVal(moduleName . "\active", false)
            , notifyUser: getIniVal(moduleName . "\notify", false)
            , menuLabel: "Volume" }
		this._S.enabled := (this._S.activeOnInit ? true : this._S.enabledOnInit)

		if (!this._S.enabled) {
			return
		}

		this.drawMenuItems()
        }


	/**
	 * @function setVolume
	 * @param {integer|string} vol
	*/
	setVolume(vol) {
        if (vol == "MUTE") {
            soundSet 1, MASTER, MUTE
        } else {
            soundSet vol, MASTER, VOLUME
            soundSet 0, MASTER, MUTE
        }
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
		useTens := isTruthy(getIniVal(this._S.moduleName . "\includeTens", false))
		useQuarters := isTruthy(getIniVal(this._S.moduleName . "\includeQuarters", false))
		useThirds = isTruthy(getIniVal(this._S.moduleName . "\includeThirds", false))
		setVolume := ObjBindMethod(this, "setVolume")

        menu volumeSub, add, % "MUTE", % setVolume
        menu volumeSub, add
		if (useTens){
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
		if (useQuarters or useThirds){
			if (useTens){
        		menu volumeSub, add
			}
			if (useQuarters){
				menu volumeSub, add, % "25", % setVolume
			}
			if (useThirds){
				menu volumeSub, add, % "33", % setVolume
			}
			if (useQuarters){
				menu volumeSub, add, % "50", % setVolume
			}
			if (useThirds){
				menu volumeSub, add, % "66", % setVolume
			}
			if (useQuarters){
				menu volumeSub, add, % "75", % setVolume
			}
		}
		; if (useThirds){
		; 	if (useQuarters or useTens){
        ; 		menu volumeSub, add
		; 	}
		; 	menu volumeSub, add, % "33", % setVolume
		; 	menu volumeSub, add, % "66", % setVolume
		; }
        menu volumeSub, add
		menu volumeSub, add, % "100", % setVolume
        menu tray, add, % this._S.menuLabel, :volumeSub
    }
}
