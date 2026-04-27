/**********************************************************
 * @type {AHKModule}
 * @name Keyboard Media Keys
 * @author Rob McInnes (Cirieno)
 * @file keyboard-media-keys.ahk
 *********************************************************/
;
; A set of hotkeys to control media playback (next, previous)


class module__KeyboardMediaKeys {
	/**
	 * @returns {void}
	 */
	__Init() {
		this.moduleName := moduleName := "KeyboardMediaKeys"
		this.settings := {
			isEnabled: IniUtils.getVal(moduleName, "enabled", true),
			activateOnLoad: IniUtils.getVal(moduleName, "activateOnLoad", true),
			defaultHotkeys: {
				mediaPrev: "^!Left",
				mediaNext: "^!Right"
			},
			hotkeySettingKeys: {},
			hotkeys: {}
		}
		for (bindingName, defaultHotkey in this.settings.defaultHotkeys.OwnProps()) {
			settingKey := "hotkey" . StrUpper(SubStr(bindingName, 1, 1)) . SubStr(bindingName, 2)
			this.settings.hotkeySettingKeys.%bindingName% := settingKey
			this.settings.hotkeys.%bindingName% := IniUtils.getVal(moduleName, settingKey, defaultHotkey)
		}
		this.state := {
			isActive: null,
			onMediaKeyChangeCallback: null,
			hotkeys: Map()
		}
		this.ui := {
			menu: {
				parentPath: "TRAY\Keyboard-2",
				entries: [{
					type: "item",
					label: "Media key shortcuts"
				}]
			}
		}
	}


	/**
	 * @returns {void}
	 */
	__New() {
		if (!this.settings.isEnabled) {
			return
		}

		this.state.isActive := this.settings.activateOnLoad
		this.state.onMediaKeyChangeCallback := ObjBindMethod(this, "onMediaKeyChange")
		this.state.hotkeys := this.getResolvedHotkeys()

		thisMenu := this.drawMenu()
		this.syncMenuItem(thisMenu)

		this.setHotkeysEnabled(this.state.isActive)
	}


	/**
	 * @returns {void}
	 */
	__Delete() {
		if (IsObject(this.state.onMediaKeyChangeCallback)) {
			this.setHotkeysEnabled(false)
			this.state.onMediaKeyChangeCallback := null
		}

		this.state.hotkeys := Map()
	}


	/**
	 * @returns {Menu|null}
	 */
	drawMenu() {
		thisMenu := ensureNativeMenuPath(this.ui.menu.parentPath)
		local onMenuItemClick := ObjBindMethod(this, "onMenuItemClick")
		this.drawMenuEntries(thisMenu, this.ui.menu.entries, onMenuItemClick)

		return (isMenu(thisMenu) ? thisMenu : null)
	}


	/**
	 * @param {Menu} thisMenu
	 * @param {Array} entries
	 * @param {Func|BoundFunc} onMenuItemClick
	 * @returns {void}
	 */
	drawMenuEntries(thisMenu, entries, onMenuItemClick) {
		for (i, entry in entries) {
			switch (entry.type) {
				case "item":
					thisMenu.Add(entry.label, onMenuItemClick)
				case "submenu":
					childMenu := Menu()
					this.drawMenuEntries(childMenu, entry.entries, onMenuItemClick)
					thisMenu.Add(entry.label, childMenu)
				case "separator", "---":
					thisMenu.Add()
			}
		}
	}


	/**
	 * @param {string} name
	 * @param {integer} position
	 * @param {Menu} menu
	 * @returns {void}
	 */
	onMenuItemClick(name, position, menu) {
		switch (name) {
			case this.ui.menu.entries[1].label:
				this.state.isActive := !this.state.isActive
				this.syncMenuItem(menu)
				this.setHotkeysEnabled(this.state.isActive)
				this.updateSettingsFile()
		}
	}


	/**
	 * @param {Menu} menu
	 * @returns {void}
	 */
	syncMenuItem(menu) {
		label := this.ui.menu.entries[1].label
		(this.state.isActive ? menu.Check(label) : menu.Uncheck(label))
		menu.Enable(label)
	}


	/**
	 * @param {boolean} state
	 * @returns {void}
	 */
	setHotkeysEnabled(state) {
		for (bindingName, hotkeyName in this.state.hotkeys) {
			Hotkey(hotkeyName, this.state.onMediaKeyChangeCallback, (state ? "on" : "off"))
		}
	}


	/**
	 * @param {string} name
	 * @returns {void}
	 */
	onMediaKeyChange(name) {
		switch (name) {
			case this.state.hotkeys["mediaPrev"]:
				Send("{Media_Prev}")
			case this.state.hotkeys["mediaNext"]:
				Send("{Media_Next}")
		}
	}


	/**
	 * @returns {Map}
	 */
	getResolvedHotkeys() {
		resolvedHotkeys := Map()

		for (bindingName, defaultHotkey in this.settings.defaultHotkeys.OwnProps()) {
			configuredHotkey := HotkeyUtils.normaliseHotkey(this.settings.hotkeys.%bindingName%)
			resolvedHotkeys[bindingName] := HotkeyUtils.validateHotkey(configuredHotkey, defaultHotkey, this.state.onMediaKeyChangeCallback)
			this.settings.hotkeys.%bindingName% := resolvedHotkeys[bindingName]
		}

		return resolvedHotkeys
	}


	/**
	 * @returns {void}
	 */
	updateSettingsFile() {
		_S := __Settings.settingsFilePath

		try {
			IniWrite(toString(this.settings.isEnabled), _S, this.moduleName, "enabled")
			IniWrite(toString(this.state.isActive), _S, this.moduleName, "activateOnLoad")
			for (bindingName, hotkeyName in this.settings.hotkeys.OwnProps()) {
				IniWrite(hotkeyName, _S, this.moduleName, this.settings.hotkeySettingKeys.%bindingName%)
			}
		} catch Error as e {
			throw Error("Error updating settings file: " . e.Message)
		}
	}
}
