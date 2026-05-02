/**********************************************************
 * @type {AHKModule}
 * @name Desktop Find Lost Windows
 * @author Rob McInnes (Cirieno)
 * @file desktop-find-lost-windows.ahk
 *********************************************************/
;
; Presents a GUI listing top-level windows that are not fully within the primary screen.
; Checked windows can be brought back to the primary screen.
; Resizable windows are resized to a centred quarter-screen footprint.
; Obvious immovable shell/system windows are filtered out of the picker.


class module__DesktopFindLostWindows {
	__Init() {
		this.moduleName := moduleName := "DesktopFindLostWindows"
		this.settings := {
			useModule: IniUtils.getVal(moduleName, "useModule", true),
			listMinRows: 8,
			listMaxRows: 14
		}
		this.state := {
			gui: null,
			listView: null,
			bringButton: null,
			refreshButton: null,
			layout: null,
			rowsByHandle: Map()
		}
		this.ui := {
			bringButtonLabel: "Bring to Main Screen",
			menu: {
				parentPath: "TRAY\Desktop-2",
				entries: [{
					type: "item",
					label: "Find lost windows..."
				}]
			}
		}
	}


	__New() {
		if (!this.settings.useModule) {
			return
		}

		this.drawMenu()
	}


	__Delete() {
		if (IsObject(this.state.gui)) {
			try {
				this.state.gui.Destroy()
			}
		}
		this.state.gui := null
		this.state.listView := null
		this.state.bringButton := null
		this.state.refreshButton := null
		this.state.layout := null
		this.state.rowsByHandle := Map()
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
				this.showWindowPicker()
		}
	}


	/**
	 * @returns {void}
	 */
	showWindowPicker() {
		this.destroyWindowPicker()
		initialWindows := this.getWindowCandidates()
		initialListRows := this.getInitialListRowCount(initialWindows.Length)

		guiObj := Gui("+Resize", __Settings.app.name . ": Find Lost Windows")
		guiObj.SetFont("s9", "Segoe UI")
		guiObj.MarginX := 10
		guiObj.MarginY := 10

		guiObj.AddText("xm", "Tick one or more windows to bring back to the primary screen.")
		listView := guiObj.AddListView("xm w980 r" . initialListRows . " Checked Grid", ["Window", "Process", "State", "Position", "Size"])
		listView.ModifyCol(1, 360)
		listView.ModifyCol(2, 140)
		listView.ModifyCol(3, 80)
		listView.ModifyCol(4, 110)
		listView.ModifyCol(5, 90)

		bringButton := guiObj.AddButton("xm w180 Default Disabled", this.ui.bringButtonLabel)
		refreshButton := guiObj.AddButton("x+10 w100", "Refresh")

		listView.OnEvent("ItemCheck", ObjBindMethod(this, "onListViewItemCheck"))
		bringButton.OnEvent("Click", ObjBindMethod(this, "onBringSelectedClick"))
		refreshButton.OnEvent("Click", ObjBindMethod(this, "onRefreshClick"))
		guiObj.OnEvent("Close", (*) => this.destroyWindowPicker())
		guiObj.OnEvent("Escape", (*) => this.destroyWindowPicker())
		guiObj.OnEvent("Size", ObjBindMethod(this, "onWindowPickerSize"))

		this.state.gui := guiObj
		this.state.listView := listView
		this.state.bringButton := bringButton
		this.state.refreshButton := refreshButton
		this.captureWindowPickerLayout()
		this.applyWindowPickerMinSize()
		this.populateWindowList(initialWindows)
		guiObj.Show()
	}


	/**
	 * @returns {void}
	 */
	destroyWindowPicker() {
		if (IsObject(this.state.gui)) {
			try {
				this.state.gui.Destroy()
			}
		}
		this.state.gui := null
		this.state.listView := null
		this.state.bringButton := null
		this.state.refreshButton := null
		this.state.layout := null
		this.state.rowsByHandle := Map()
	}


	/**
	 * @returns {void}
	 */
	captureWindowPickerLayout() {
		if (!IsObject(this.state.listView) || !IsObject(this.state.bringButton) || !IsObject(this.state.refreshButton)) {
			return
		}

		this.state.listView.GetPos(&listX, &listY, &listWidth, &listHeight)
		this.state.bringButton.GetPos(&bringX, &bringY, &bringWidth, &bringHeight)
		this.state.refreshButton.GetPos(&refreshX, , &refreshWidth, &refreshHeight)

		this.state.layout := {
			listX: listX,
			listY: listY,
			listMinWidth: listWidth,
			listMinHeight: listHeight,
			listBottomGap: (bringY - (listY + listHeight)),
			buttonX: bringX,
			buttonGap: (refreshX - (bringX + bringWidth)),
			buttonWidth: bringWidth,
			buttonHeight: bringHeight,
			refreshButtonWidth: refreshWidth,
			refreshButtonHeight: refreshHeight
		}
	}


	/**
	 * @returns {void}
	 */
	applyWindowPickerMinSize() {
		if (!IsObject(this.state.layout) || !IsObject(this.state.gui)) {
			return
		}

		layout := this.state.layout
		marginX := this.state.gui.MarginX
		marginY := this.state.gui.MarginY
		minWidth := Max(
			(layout.listX + layout.listMinWidth + marginX),
			(layout.buttonX + layout.buttonWidth + layout.buttonGap + layout.refreshButtonWidth + marginX)
		)
		minHeight := (layout.listY + layout.listMinHeight + layout.listBottomGap + layout.buttonHeight + marginY)

		this.state.gui.Opt("+MinSize" . minWidth . "x" . minHeight)
	}


	/**
	 * @param {Gui} guiObj
	 * @param {integer} minMax
	 * @param {integer} width
	 * @param {integer} height
	 * @returns {void}
	 */
	onWindowPickerSize(guiObj, minMax, width, height) {
		if (minMax == -1) {
			return
		}

		this.updateWindowPickerLayout(width, height)
	}


	/**
	 * @param {integer} width
	 * @param {integer} height
	 * @returns {void}
	 */
	updateWindowPickerLayout(width, height) {
		if (!IsObject(this.state.layout) || !IsObject(this.state.listView) || !IsObject(this.state.bringButton) || !IsObject(this.state.refreshButton)) {
			return
		}

		layout := this.state.layout
		marginX := this.state.gui.MarginX
		marginY := this.state.gui.MarginY
		buttonY := Max(layout.listY + layout.listMinHeight + layout.listBottomGap, height - marginY - layout.buttonHeight)
		listWidth := Max(layout.listMinWidth, width - layout.listX - marginX)
		listHeight := Max(layout.listMinHeight, buttonY - layout.listY - layout.listBottomGap)

		this.state.listView.Move(, , listWidth, listHeight)
		this.state.bringButton.Move(layout.buttonX, buttonY, layout.buttonWidth, layout.buttonHeight)
		this.state.refreshButton.Move(layout.buttonX + layout.buttonWidth + layout.buttonGap, buttonY, layout.refreshButtonWidth, layout.refreshButtonHeight)
		this.resizeWindowPickerColumns(listWidth)
	}


	/**
	 * @param {integer} listWidth
	 * @returns {void}
	 */
	resizeWindowPickerColumns(listWidth) {
		if (!IsObject(this.state.listView)) {
			return
		}

		fixedWidth := (140 + 80 + 110 + 90)
		windowWidth := Max(240, listWidth - fixedWidth - 24)
		this.state.listView.ModifyCol(1, windowWidth)
	}


	/**
	 * @param {integer} candidateCount
	 * @returns {integer}
	 */
	getInitialListRowCount(candidateCount) {
		return Max(this.settings.listMinRows, Min(candidateCount, this.settings.listMaxRows))
	}

	/**
	 * @param {Array} windows
	 * @returns {void}
	 */
	populateWindowList(windows := unset) {
		if (!IsObject(this.state.listView)) {
			return
		}
		if !IsSet(windows) {
			windows := this.getWindowCandidates()
		}

		this.state.listView.Delete()
		this.state.rowsByHandle := Map()

		for (i, win in windows) {
			row := this.state.listView.Add(
				"Check0",
				win.displayTitle,
				win.process,
				win.stateLabel,
				win.posX . ", " . win.posY,
				win.width . " x " . win.height
			)
			this.state.rowsByHandle[row] := win.handle
		}

		this.updateBringButtonState()
	}


	/**
	 * @returns {boolean}
	 */
	hasCheckedRows() {
		if (!IsObject(this.state.listView)) {
			return false
		}

		return (this.state.listView.GetNext(0, "Checked") > 0)
	}


	/**
	 * @returns {void}
	 */
	updateBringButtonState() {
		if (!IsObject(this.state.bringButton)) {
			return
		}

		this.state.bringButton.Enabled := this.hasCheckedRows()
	}


	/**
	 * @returns {Array}
	 */
	getWindowCandidates() {
		windows := []
		monitorBounds := this.getPrimaryMonitorBounds()

		DetectHiddenWindows(false)
		handles := WinGetList()
		DetectHiddenWindows(true)

		for (i, hWnd in handles) {
			try {
				WinGetPos(&X, &Y, &W, &H, hWnd)
				win := {
					handle: hWnd,
					posX: X,
					posY: Y,
					width: W,
					height: H,
					title: WinGetTitle(hWnd),
					class: WinGetClass(hWnd),
					state: WinGetMinMax(hWnd),
					process: WinGetProcessName(hWnd),
					style: WinGetStyle(hWnd)
				}
				win.displayTitle := (isEmpty(win.title) ? "<Untitled>" : win.title)
				win.stateLabel := this.getWindowStateLabel(win.state)
				if (this.shouldIncludeWindow(win, monitorBounds)) {
					windows.Push(win)
				}
			} catch Error {
				continue
			}
		}

		this.sortWindowCandidates(windows)

		return windows
	}


	/**
	 * @param {Array} windows
	 * @returns {void}
	 */
	sortWindowCandidates(windows) {
		loop windows.Length {
			indexA := A_Index
			loop (windows.Length - indexA) {
				indexB := (indexA + A_Index)
				if (this.compareWindowTitles(windows[indexA], windows[indexB]) > 0) {
					temp := windows[indexA]
					windows[indexA] := windows[indexB]
					windows[indexB] := temp
				}
			}
		}
	}


	/**
	 * @param {Object} winA
	 * @param {Object} winB
	 * @returns {integer}
	 */
	compareWindowTitles(winA, winB) {
		titleA := winA.displayTitle
		titleB := winB.displayTitle
		categoryA := this.getTitleSortCategory(titleA)
		categoryB := this.getTitleSortCategory(titleB)

		if (categoryA != categoryB) {
			return (categoryA - categoryB)
		}

		return StrCompare(titleA, titleB, false)
	}


	/**
	 * @param {string} title
	 * @returns {integer}
	 */
	getTitleSortCategory(title) {
		firstChar := SubStr(title, 1, 1)

		if RegExMatch(firstChar, "^[0-9]$") {
			return 2
		}
		if RegExMatch(firstChar, "^[A-Za-z]$") {
			return 3
		}

		return 1
	}


	/**
	 * @param {Object} win
	 * @param {Object} monitorBounds
	 * @returns {boolean}
	 */
	shouldIncludeWindow(win, monitorBounds) {
		ignoreClasses := [
			"Progman",
			"WorkerW",
			"Shell_TrayWnd",
			"Shell_SecondaryTrayWnd",
			"NotifyIconOverflowWindow",
			"TopLevelWindowForOverflowXamlIsland",
			"TaskListThumbnailWnd"
		]
		ignoreTitles := [
			"Program Manager",
			"Start"
		]

		if ((win.width <= 0) || (win.height <= 0)) {
			return false
		}
		if (win.state == -1) {
			return false
		}
		if (!this.isWindowCandidateByVisibility(win, monitorBounds)) {
			return false
		}
		if (IsObject(this.state.gui) && (win.handle == this.state.gui.Hwnd)) {
			return false
		}
		if (ignoreClasses.includes(win.class) || ignoreTitles.includes(win.title)) {
			return false
		}
		if (win.style & WS_CHILD) {
			return false
		}

		return true
	}


	/**
	 * @param {Object} win
	 * @param {Object} monitorBounds
	 * @returns {boolean}
	 */
	isWindowCandidateByVisibility(win, monitorBounds) {
		visibleRect := this.getVisibleWindowRect(win.handle)

		if (IsObject(visibleRect)) {
			return !this.isRectFullyVisibleOnPrimaryScreen(visibleRect, monitorBounds)
		}

		return !this.isRectFullyVisibleOnPrimaryScreen(win, monitorBounds)
	}


	/**
	 * @param {integer} hWnd
	 * @returns {Object|null}
	 */
	getVisibleWindowRect(hWnd) {
		DWMWA_EXTENDED_FRAME_BOUNDS := 9
		rect := Buffer(16, 0)

		try {
			hResult := DllCall(
				"dwmapi\DwmGetWindowAttribute",
				"ptr", hWnd,
				"uint", DWMWA_EXTENDED_FRAME_BOUNDS,
				"ptr", rect,
				"uint", rect.Size,
				"int"
			)
			if (hResult != 0) {
				return null
			}

			left := NumGet(rect, 0, "int")
			top := NumGet(rect, 4, "int")
			right := NumGet(rect, 8, "int")
			bottom := NumGet(rect, 12, "int")
			width := (right - left)
			height := (bottom - top)

			if ((width <= 0) || (height <= 0)) {
				return null
			}

			return {
				posX: left,
				posY: top,
				width: width,
				height: height
			}
		} catch Error {
			return null
		}
	}


	/**
	 * @param {Object} win
	 * @param {Object} workArea
	 * @returns {boolean}
	 */
	isRectFullyVisibleOnPrimaryScreen(win, workArea) {
		return (
			(win.posX >= workArea.left)
			&& (win.posY >= workArea.top)
			&& ((win.posX + win.width) <= workArea.right)
			&& ((win.posY + win.height) <= workArea.bottom)
		)
	}


	/**
	 * @param {integer} state
	 * @returns {string}
	 */
	getWindowStateLabel(state) {
		switch (state) {
			case -1:
				return "Min"
			case 0:
				return "Normal"
			case 1:
				return "Max"
			default:
				return "Unknown"
		}
	}


	/**
	 * @returns {Object}
	 */
	getPrimaryWorkArea() {
		monitorId := MonitorGetPrimary()
		MonitorGetWorkArea(monitorId, &left, &top, &right, &bottom)

		workArea := {
			id: monitorId,
			left: left,
			top: top,
			right: right,
			bottom: bottom
		}
		workArea.width := (workArea.right - workArea.left)
		workArea.height := (workArea.bottom - workArea.top)

		return workArea
	}


	/**
	 * @returns {Object}
	 */
	getPrimaryMonitorBounds() {
		monitorId := MonitorGetPrimary()
		MonitorGet(monitorId, &left, &top, &right, &bottom)

		monitorBounds := {
			id: monitorId,
			left: left,
			top: top,
			right: right,
			bottom: bottom
		}
		monitorBounds.width := (monitorBounds.right - monitorBounds.left)
		monitorBounds.height := (monitorBounds.bottom - monitorBounds.top)

		return monitorBounds
	}


	/**
	 * @param {GuiCtrlObj} ctrl
	 * @param {integer} item
	 * @param {boolean} isChecked
	 * @returns {void}
	 */
	onListViewItemCheck(ctrl, item, isChecked) {
		this.updateBringButtonState()
	}


	/**
	 * @param {GuiCtrlObj} ctrl
	 * @param {Info} info
	 * @returns {void}
	 */
	onBringSelectedClick(ctrl, info) {
		if (!IsObject(this.state.listView)) {
			return
		}

		checkedRows := []
		row := 0
		while (row := this.state.listView.GetNext(row, "Checked")) {
			checkedRows.Push(row)
		}

		if (isEmpty(checkedRows)) {
			MsgBox("No windows selected.", __Settings.app.name . ": Find Lost Windows", "0x40")
			return
		}

		for (i, checkedRow in checkedRows) {
			if (this.state.rowsByHandle.Has(checkedRow)) {
				this.bringWindowToMainScreen(this.state.rowsByHandle[checkedRow])
			}
		}

		this.populateWindowList()
	}


	/**
	 * @param {GuiCtrlObj} ctrl
	 * @param {Info} info
	 * @returns {void}
	 */
	onRefreshClick(ctrl, info) {
		this.populateWindowList()
	}


	/**
	 * @param {integer} hWnd
	 * @returns {void}
	 */
	bringWindowToMainScreen(hWnd) {
		workArea := this.getPrimaryWorkArea()
		try {
			style := WinGetStyle(hWnd)
			state := WinGetMinMax(hWnd)

			if (state !== 0) {
				WinRestore(hWnd)
			}

			if (this.isResizableWindow(style)) {
				newWidth := Floor(workArea.width / 2)
				newHeight := Floor(workArea.height / 2)
				newPosX := workArea.left + Floor((workArea.width - newWidth) / 2)
				newPosY := workArea.top + Floor((workArea.height - newHeight) / 2)
				WinMove(newPosX, newPosY, newWidth, newHeight, hWnd)
			} else {
				WinGetPos(, , &winWidth, &winHeight, hWnd)
				newPosX := workArea.left + Floor((workArea.width - winWidth) / 2)
				newPosY := workArea.top + Floor((workArea.height - winHeight) / 2)
				WinMove(newPosX, newPosY, , , hWnd)
			}

			WinActivate(hWnd)
		} catch Error as e {
			MsgBox("Could not move the selected window.`n`n" . e.Message, __Settings.app.name . ": Find Lost Windows", "0x10")
		}
	}


	/**
	 * @param {integer} style
	 * @returns {boolean}
	 */
	isResizableWindow(style) {
		return ((style & WS_SIZEBOX) || (style & WS_THICKFRAME))
	}


	/**
	 * @returns {void}
	 */
	updateSettingsFile() {
		_S := __Settings.settingsFilePath

		try {
			IniWrite(toString(this.settings.useModule), _S, this.moduleName, "useModule")
		} catch Error as e {
			throw Error("Error updating settings file: " . e.Message)
		}
	}
}
