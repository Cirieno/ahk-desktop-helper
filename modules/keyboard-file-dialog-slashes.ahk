/**********************************************************
 * @type {AHKModule}
 * @name Keyboard File Dialog Slashes
 * @author Rob McInnes (Cirieno)
 * @file keyboard-file-dialog-slashes.ahk
 *********************************************************/
;
; Replaces forward-slashes with back-slashes in Explorer-based windows and File dialogs, useful when working with LAMP paths in VSCode
; Win11 Explorer can already handle forward slashes, but this can be helpful for older Windows versions and some other app file dialogs


class module__KeyboardFileDialogSlashes {
	__Init() {
		this.moduleName := moduleName := "KeyboardFileDialogSlashes"
		this.settings := {
			useModule: IniUtils.getVal(moduleName, "useModule", true),
			enabledOnLoad: IniUtils.getVal(moduleName, "enabledOnLoad", false)
		}
		this.state := {
			isActive: null,
			onPasteCallback: null,
			onContextCheckCallback: null
		}
		this.ui := {
			menu: {
				parentPath: "TRAY\Keyboard-2",
				entries: [{
					type: "item",
					label: "Replace fwd slashes in File dialogs"
				}]
			}
		}
	}


	__New() {
		if (!this.settings.useModule) {
			return
		}

		this.state.isActive := this.settings.enabledOnLoad
		this.state.onPasteCallback := ObjBindMethod(this, "onPaste")
		this.state.onContextCheckCallback := ObjBindMethod(this, "isTargetControlActive")

		thisMenu := this.drawMenu()
		this.syncMenuItem(thisMenu)

		this.setHotkeysEnabled(this.state.isActive)
	}


	__Delete() {
		if (IsObject(this.state.onPasteCallback)) {
			this.setHotkeysEnabled(false)
			this.state.onPasteCallback := null
		}

		this.state.onContextCheckCallback := null
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
		HotIf(this.state.onContextCheckCallback)
		Hotstring(":*?:/", "\", (state ? "on" : "off"))
		Hotkey("^v", this.state.onPasteCallback, (state ? "on" : "off"))
		; OnMessage(0x0302, doPaste)    ; 0x0302 is WM_PASTE
		; TODO: capture mouse paste events to exisiting windows?
		HotIf()
	}


	/**
	 * @param {...any} args
	 * @returns {boolean}
	 */
	isTargetControlActive(args*) {
		try {
			controls := ["Edit1", "Edit2"]
			control := ControlGetClassNN(ControlGetFocus("A"))
			return (WinActive("ahk_group explorerWindows") && controls.includes(control))
		} catch Error as e {
			return false
		}
	}


	/**
	 * @param {...any} args
	 * @returns {void}
	 */
	onPaste(args*) {
		try {
			clipboardSaved := RegExReplace(A_Clipboard, "S)[\\/]+", "\")
			EditPaste(clipboardSaved, ControlGetFocus("A"))
		} catch Error as e {
			throw Error("Couldn't paste content to control")
		}
	}


	/**
	 * @returns {void}
	 */
	updateSettingsFile() {
		_S := __Settings.settingsFilePath

		try {
			IniWrite(toString(this.settings.useModule), _S, this.moduleName, "useModule")
			IniWrite(toString(this.state.isActive), _S, this.moduleName, "enabledOnLoad")
		} catch Error as e {
			throw Error("Error updating settings file: " . e.Message)
		}
	}
}
