/**********************************************************
 * @name KeyboardMediaKeys
 * @author RM
 * @file keyboard-media-keys.module.ahk
 *********************************************************/
; A set of hotkeys to control media playback (next, previous)


class module__KeyboardMediaKeys {
	__Init() {
		this.moduleName := moduleName := "KeyboardMediaKeys"
		this.enabled := getIniVal(moduleName, "enabled", true)
		this.settings := {
			activateOnLoad: getIniVal(moduleName, "active", true)
		}
		this.states := {
			active: null
		}
		this.settings.menu := {
			path: "TRAY\Keyboard",
			items: [{
				type: "item",
				label: "Enable media key shortcuts"
			}]
		}
	}


	__New() {
		if (!this.enabled) {
			return
		}

		this.states.active := this.settings.activateOnLoad

		thisMenu := this.drawMenu()
		setMenuItemProps(this.settings.menu.items[1].label, thisMenu, { checked: this.states.active })

		this.setHotkeys(this.states.active)
	}


	__Delete() {
	}


	drawMenu() {
		thisMenu := getMenu(this.settings.menu.path)
		if (!isMenu(thisMenu)) {
			parentMenu := getMenu("TRAY")
			if (!isMenu(parentMenu)) {
				throw Error("ParentMenu not found")
			}
			thisMenu := setMenu(this.settings.menu.path, parentMenu)
			arrMenuPath := StrSplit(this.settings.menu.path, "\")
			setMenuItem(arrMenuPath.pop(), parentMenu, thisMenu)
		}
		local doMenuItem := ObjBindMethod(this, "doMenuItem")
		for (i, item in this.settings.menu.items) {
			switch (item.type) {
				case "item":
					menuItemKey := setMenuItem(item.label, thisMenu, doMenuItem)
				case "separator", "---":
					setMenuItem("---", thisMenu)
			}
		}

		return (isMenu(thisMenu) ? thisMenu : null)
	}


	doMenuItem(name, position, menu) {
		switch (name) {
			case this.settings.menu.items[1].label:
				this.states.active := !this.states.active
				setMenuItemProps(name, menu, { checked: this.states.active, clickCount: +1 })
				this.setHotkeys(this.states.active)
		}
	}


	setHotkeys(state) {
		doMediaPrev := ObjBindMethod(this, "doMediaPrev")
		doMediaNext := ObjBindMethod(this, "doMediaNext")

		Hotkey("^!Left", doMediaPrev, (state ? "on" : "off"))
		Hotkey("^!Right", doMediaNext, (state ? "on" : "off"))
	}


	doMediaPrev(*) {
		Send("{Media_Prev}")
	}


	doMediaNext(*) {
		Send("{Media_Next}")
	}


	updateSettingsFile() {
		SFP := __Settings.settingsFilePath

		try {
			IniWrite(toString(this.enabled), SFP, this.moduleName, "enabled")
			IniWrite(toString(this.states.active), SFP, this.moduleName, "active")
		} catch Error as e {
			throw Error("Error updating settings file: " . e.Message)
		}
	}
}
