class Module__SetVolume {
	__New() {
		this.moduleName := "SetVolume"
		this.settings := {0:0
			, moduleName: this.moduleName
			, enabled: getIniVal(this.moduleName . "\enabled", false)
			, notify: getIniVal(this.moduleName . "\notify", false)
			, menuLabel: "Set volume" }
		_S := this.settings

		this.enabled := _S.enabled

		this.Module__SetVolumeWithMouseWheel := new Module__SetVolumeWithMouseWheel
		; TODO: remove this class into a separate module and call to see if it exists
	}


	drawMenuItems() {
		_S := this.settings
		_MW := this.Module__SetVolumeWithMouseWheel
		if (!_S.enabled && !_MW.enabled) {
			return
		}

		if (_S.enabled){
			setVolume := ObjBindMethod(this, "setVolume")
			menu volumeSubmenu, add, % "MUTE", % setVolume
			menu volumeSubmenu, add
			menu volumeSubmenu, add, % "0", % setVolume
			menu volumeSubmenu, add, % "20", % setVolume
			menu volumeSubmenu, add, % "40", % setVolume
			menu volumeSubmenu, add, % "60", % setVolume
			menu volumeSubmenu, add, % "80", % setVolume
			menu volumeSubmenu, add, % "100", % setVolume
			menu volumeSubmenu, add
			menu volumeSubmenu, add, % "25", % setVolume
			menu volumeSubmenu, add, % "33", % setVolume
			menu volumeSubmenu, add, % "50", % setVolume
			menu volumeSubmenu, add, % "66", % setVolume
			menu volumeSubmenu, add, % "75", % setVolume
			; menu volumeSubmenu, add
			; menu volumeSubmenu, add, % "+5%", % setVolume
			; menu volumeSubmenu, add, % "-5%", % setVolume
		}
		if (_MW.enabled){
			if (_S.enabled){
				menu volumeSubmenu, add
			}
			_MW.drawMenuItems()
		}
		menu tray, add, % _S.menuLabel, :volumeSubmenu
	}


	setVolume(vol := "20") {
		_S := this.settings
		if (!_S.enabled) {
			return
		}

		if (vol == "MUTE") {
			soundSet 1, MASTER, MUTE
		} else {
			soundSet vol, MASTER, VOLUME
			soundSet 0, MASTER, MUTE
		}
	}


	getVolume() {
		soundGet vol, MASTER, VOLUME
		return % round(vol)
	}
}
