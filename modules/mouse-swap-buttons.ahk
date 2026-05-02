/**********************************************************
 * @type {AHKModule}
 * @name Mouse Swap Buttons
 * @author Rob McInnes (Cirieno)
 * @file mouse-swap-buttons.ahk
 *********************************************************/
;
; Handy for if you're left-handed, or maybe just having an RSI day
; Watches for external changes via WM_SETTINGCHANGE


class module__MouseSwapButtons {
	__Init() {
		this.moduleName := moduleName := "MouseSwapButtons"
		this.settings := {
			useModule: IniUtils.getVal(moduleName, "useModule", true),
			enabledOnLoad: IniUtils.getVal(moduleName, "enabledOnLoad", "inherit")
		}
		this.state := {
			hasMouse: null,
			areButtonsSwapped: null,
			onSettingsChangeCallback: null
		}
		this.ui := {
			menu: {
				parentPath: "TRAY\Mouse-2",
				entries: [{
					type: "item",
					label: "Swap mouse buttons"
				}]
			}
		}
	}


	__New() {
		if (!this.settings.useModule) {
			return
		}
		this.settings.enabledOnLoad := this.normaliseEnabledOnLoad(this.settings.enabledOnLoad)

		this.refreshState()
		this.state.onSettingsChangeCallback := ObjBindMethod(this, "onSettingsChange")

		thisMenu := this.drawMenu()
		this.syncMenuItem(thisMenu)

		this.reconcileState(this.settings.enabledOnLoad, true)
		this.setObserverEnabled(true)
	}


	__Delete() {
		if (IsObject(this.state.onSettingsChangeCallback)) {
			this.setObserverEnabled(false)
			this.state.onSettingsChangeCallback := null
		}
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
				desiredButtonsSwapped := !this.state.areButtonsSwapped
				this.reconcileState(desiredButtonsSwapped, true)
				this.syncMenuItem(menu)
				this.updateSettingsFile()
		}
	}


	/**
	 * @param {Menu} menu
	 * @returns {void}
	 */
	syncMenuItem(menu) {
		label := this.ui.menu.entries[1].label
		(this.state.areButtonsSwapped ? menu.Check(label) : menu.Uncheck(label))
		(this.state.hasMouse ? menu.Enable(label) : menu.Disable(label))
	}


	/**
	 * @param {boolean} state
	 * @returns {void}
	 */
	setObserverEnabled(state) {
		if (!IsObject(this.state.onSettingsChangeCallback)) {
			return
		}

		OnMessage(0x001A, this.state.onSettingsChangeCallback, (state ? 1 : 0))
	}


	/**
	 * @returns {void}
	 */
	refreshState() {
		this.state.hasMouse := toBoolean(SysGet(SM_MOUSEPRESENT))
		this.state.areButtonsSwapped := this.getButtonsState()
	}


	/**
	 * @param {boolean} state
	 * @returns {void}
	 */
	applyButtonsSwappedState(state) {
		this.setButtonsState(state)
	}


	/**
	 * @param {boolean|string} desiredButtonsSwapped
	 * @param {boolean} [forced=false]
	 * @returns {void}
	 */
	reconcileState(desiredButtonsSwapped, forced := false) {
		hadMouse := this.state.hasMouse
		hadButtonsSwapped := this.state.areButtonsSwapped

		this.refreshState()

		if (isIgnore(desiredButtonsSwapped)) {
			this.syncMenuItem(ensureNativeMenuPath(this.ui.menu.parentPath))
			return
		}

		if ((desiredButtonsSwapped !== this.state.areButtonsSwapped) || (this.state.hasMouse !== hadMouse) || (this.state.areButtonsSwapped !== hadButtonsSwapped)) {
			externalChangeDetected := (!forced && (this.state.areButtonsSwapped !== hadButtonsSwapped))
			if (forced) {
				this.applyButtonsSwappedState(desiredButtonsSwapped)
			}
			if (externalChangeDetected) {
				this.showDebugAlert(hadButtonsSwapped, this.state.areButtonsSwapped)
			}
			this.syncMenuItem(ensureNativeMenuPath(this.ui.menu.parentPath))
		}
	}


	/**
	 * @returns {boolean}
	 */
	getButtonsState() {
		try {
			return toBoolean(SysGet(SM_SWAPBUTTON))
		} catch Error {
			try {
				return toBoolean(RegRead("HKEY_CURRENT_USER\Control Panel\Mouse", "SwapMouseButtons", 0))
			} catch Error as e {
				throw Error("Error reading mouse button state")
			}
		}
	}


	/**
	 * @param {boolean} state
	 * @returns {void}
	 */
	setButtonsState(state) {
		try {
			RegWrite((state ? 1 : 0), "REG_SZ", "HKEY_CURRENT_USER\Control Panel\Mouse", "SwapMouseButtons")
			DllCall("SwapMouseButton", "int", (state ? 1 : 0))
			this.state.areButtonsSwapped := this.getButtonsState()
		} catch Error as e {
			throw Error("Error writing registry key")
		}
	}


	/**
	 * @param {integer} wParam
	 * @param {integer} lParam
	 * @param {integer} msg
	 * @param {integer} hWnd
	 * @returns {integer|void}
	 */
	onSettingsChange(wParam, lParam, msg, hWnd) {
		if wParam {
			if (wParam != 0x0021) {
				return
			}
		}

		this.reconcileState(this.state.areButtonsSwapped)
		return 0
	}


	/**
	 * @returns {void}
	 */
	updateSettingsFile() {
		_S := __Settings.settingsFilePath

		try {
			IniWrite(toString(this.settings.useModule), _S, this.moduleName, "useModule")
			IniWrite(toString(this.state.areButtonsSwapped), _S, this.moduleName, "enabledOnLoad")
		} catch Error as e {
			throw Error("Error updating settings file: " . e.Message)
		}
	}


	/**
	 * @param {boolean} previousState
	 * @param {boolean} currentState
	 * @returns {void}
	 */
	showDebugAlert(previousState, currentState) {
		if (!__Settings.app.environment.debugging) {
			return
		}

		title := __Settings.app.name . " - " . this.moduleName
		msg := MsgboxJoin([
			"External mouse button swap change detected.",
			"Was swapped: " . toString(previousState),
			"Now swapped: " . toString(currentState),
			"Module state updated to match Windows."
		])
		MsgBox(msg, title, (0 + 64 + 4096) . " T5")
	}


	/**
	 * @param {boolean|string} enabledOnLoad
	 * @returns {boolean|string}
	 */
	normaliseEnabledOnLoad(enabledOnLoad) {
		if (isString(enabledOnLoad)) {
			enabledOnLoad := StrLower(Trim(enabledOnLoad))
			if ((enabledOnLoad = "inherit") || (enabledOnLoad = "ignore")) {
				return ignore
			}
		}

		return enabledOnLoad
	}
}
