;// Compile-time settings for "File Properties > Details" panel
;@Ahk2Exe-Let PName = AHK Desktop Helper, PVersion = 2.2.0.1, PAuthor = Rob McInnes, PCompany = Cirieno Ltd
;@Ahk2Exe-ExeName C:\Program Files (portable)\%U_PName%\%U_PName%.exe
;@ Ahk2Exe-ExeName %A_ScriptDir%\compiled\%U_PName%.exe
;@Ahk2Exe-SetCompanyName %U_PCompany%
;@Ahk2Exe-SetCopyright %U_PCompany%
;@Ahk2Exe-SetDescription %U_PName%
;@Ahk2Exe-SetFileVersion %U_PVersion%
;@Ahk2Exe-SetLanguage 0x0809
;@Ahk2Exe-SetMainIcon icons\app-icon-compiled.ico
;@Ahk2Exe-SetName %U_PName%
;@Ahk2Exe-SetOrigFilename ahk-desktop-helper.ahk
;@Ahk2Exe-SetProductName %U_PName%
;@Ahk2Exe-SetVersion %U_PVersion%
;@Ahk2Exe-PostExec "MPRESS.exe" "%A_WorkFileName%" -q -x, 0,, 1



/** */
#ClipboardTimeout 2000
#Requires AutoHotkey v2+
#SingleInstance force
#WinActivateForce
A_HotkeyInterval := 2000
A_MaxHotkeysPerInterval := 2000
DetectHiddenText(false)
DetectHiddenWindows(false)
FileEncoding("UTF-8-RAW")
InstallKeybdHook(true)
OnExit(doExit)
Persistent(true)
SetTitleMatchMode("slow")
SetWorkingDir(A_ScriptDir)



/** */
#Include ".\utils\constants.utils.ahk"
#Include ".\utils\misc.utils.ahk"
#Include ".\utils\shadowmenu.utils.ahk"
#Include ".\utils\vartypes.utils.ahk"



/** */
global _Modules := Map()
global _ShadowMenu := { menus: Map(), items: Map() }
global _Settings := populateGlobalVars()
populateGlobalVars() {
	_S := {}

	_S.app := {
		name: "AHK Desktop Helper",
		author: { name: "Rob McInnes", email: "rob.mcinnes@cirieno.co.uk", company: "Cirieno Ltd" },
		build: { version: "2.2.0.1", date: "2024-02", repo: "github.com/cirieno/ahk-desktop-helper" }
	}

	_S.app.tray := {
		title: _S.app.name,
		traytip: _S.app.name . " — " . _S.app.build.version,
		icon: { location: (A_IsCompiled == true ? A_ScriptName : "icons\app-icon-debugging.ico"), index: -0 },
		includeSubmenuIcons: false
	}

	_S.app.environment := {
		company: getIniVal("Environment", "company", ""),
		user: getIniVal("Environment", "user", A_UserName),
		computerName: A_ComputerName,
		domain: EnvGet("USERDOMAIN"),
		architecture: (A_Is64bitOS ? "x64" : "x86"),
		settingsFilename: "user_settings.ini"
	}

	_S.apps := {
		Notepad: { location: A_WinDir . "\notepad.exe" }
	}

	return _S
}



/** */
#Include "*i .\modules\autocorrect.module.ahk"
#Include "*i .\modules\desktop-file-dialog-slashes.module.ahk"
#Include "*i .\modules\desktop-gather-windows.module.ahk"
#Include "*i .\modules\desktop-hide-media-popup.module.ahk"
#Include "*i .\modules\desktop-hide-peek-button.module.ahk"
#Include "*i .\modules\keyboard-keylocks.module.ahk"
#Include "*i .\modules\keyboard-text-manipulation.module.ahk"
#Include "*i .\modules\mouse-swap-buttons.module.ahk"
#Include "*i .\modules\volume-mousewheel.module.ahk"



/** */
checkSettingsFileExists()
checkStartWithWindows()
drawMenu("before")
loadModules()
drawMenu("after")
checkMemoryUsage()
SetTimer(checkMemoryUsage, (30 * U_msMinute))



/** */
drawMenu(section) {
	_SAT := _Settings.app.tray

	if (!_ShadowMenu.menus.has("TRAY")) {
		menuVals := {
			type: "menu",
			path: "TRAY",
			handle: A_TrayMenu.handle,
			parentHandle: null,
			items: []
		}
		_ShadowMenu.menus.set(menuVals.path, menuVals)
		A_TrayMenu.vals := _ShadowMenu.menus[menuVals.path]
	}

	switch (section) {
		case "before":
			A_IconTip := _SAT.traytip
			TraySetIcon(_SAT.icon.location)
			A_TrayMenu.delete()
			A_TrayMenu.add(_SAT.title, doMenuItem)
			; A_TrayMenu.setIcon(_ST.title, _ST.icon.location)
			A_TrayMenu.default := _SAT.title
			A_TrayMenu.add()
		case "after":
			A_TrayMenu.add()
			setMenuItem("Settings" . U_ellipsis, A_TrayMenu, setSubMenu("TRAY\Settings"))
			setMenuItem("About" . U_ellipsis, A_TrayMenu, doMenuItem)
			setMenuItem("Exit", A_TrayMenu, doMenuItem)
			if (A_IsCompiled == false) {
				A_TrayMenu.add()
				setMenuItem("Debugging" . U_ellipsis, A_TrayMenu, setSubMenu("TRAY\Debugging"))
				A_TrayMenu.add()
				A_TrayMenu.addStandard()
			}
	}

	setSubMenu(section) {
		thisMenu := setMenu(section, A_TrayMenu)
		switch (section) {
			case "TRAY\Settings":
				setMenuItem("Save current config", thisMenu, doMenuItem)
				setMenuItem("Edit config" . U_ellipsis, thisMenu, doMenuItem)
			case "TRAY\Debugging":
				setMenuItem("Show menu paths", thisMenu, doMenuItem)
				setMenuItem("Reload app" . U_ellipsis, thisMenu, doMenuItem)
		}
		return thisMenu
	}
}



/** */
doMenuItem(name, position, menu) {
	_SA := _Settings.app
	_SAP := _Settings.apps

	switch (name) {
		case _SA.tray.title, "About" . U_ellipsis:
			msg := join([
				_SA.name, "v" . _SA.build.version . " (" . _SA.build.date . ")",
				"",
				"Repo @ " . _SA.build.repo,
				"AutoHotkey v2 @ autohotkey.com",
				; "AutoCorrect @ github.com/cdelahousse",
				; "Icons @ flaticon.com/authors/xnimrodx"
			], "`n")
			title := _Settings.app.name . " — About" . U_ellipsis
			MsgBox(msg, title, (0 + 64 + 4096))
		case "Edit config" . U_ellipsis:
			local exitcode := RunWait(_SAP.Notepad.location . " " . _SA.environment.settingsFilename)
			if (exitcode == 0) {
				; save config first?
				Reload()
			}
		case "Save current config":
			doSettingsFileUpdate()
		case "Show menu paths":
			alertMenuPaths()
		case "Reload app" . U_ellipsis:
			Reload()
		case "Exit":
			ExitApp()
	}
}



/** */
loadModules() {
	try {
		_Modules["AutoCorrect"] := module__AutoCorrect()
		_Modules["DesktopFileDialogSlashes"] := module__DesktopFileDialogSlashes()
		_Modules["DesktopHideMediaPopup"] := module__DesktopHideMediaPopup()
		_Modules["DesktopHidePeekButton"] := module__DesktopHidePeekButton()
		_Modules["KeyboardKeylocks"] := module__KeyboardKeylocks()
		_Modules["MouseSwapButtons"] := module__MouseSwapButtons()
		_Modules["VolumeMouseWheel"] := module__VolumeMouseWheel()
		setMenuItem("---", "TRAY\Desktop")
		_Modules["DesktopGatherWindows"] := module__DesktopGatherWindows()
		setMenuItem("---", "TRAY\Keyboard")
		_Modules["KeyboardTextManipulation"] := module__KeyboardTextManipulation()

		for key, module in _Modules {
			if (module.hasMethod("checkSettingsFile")) {
				module.checkSettingsFile()
			}
		}
	} catch Error as e {
		throw Error("Error loading modules: " . e.Message)
	}
}



/** */
doExit(reason, code) {
	if (IsSet(_Modules) && isMap(_Modules)) {
		for key, module in _Modules {
			if (module.hasMethod("__Delete")) {
				module.__Delete()
			}
			module := null
		}
	}
}



/** */
checkSettingsFileExists() {
	_SAE := _Settings.app.environment
	sectionExists := IniRead(_SAE.settingsFilename, "Environment", , false)
	if (!sectionExists) {
		section := join([
			"[Environment]",
			"startWithWindows=false",
			"enableExtendedRightMouseClick=false"
		], "`n")
		FileAppend("`n" . section . "`n", _SAE.settingsFilename)
	}

	; TODO: move to module?
	sectionExists := IniRead(_SAE.settingsFilename, "CloseAppsWithCtrlW", , false)
	if (!sectionExists) {
		section := join([
			"[CloseAppsWithCtrlW]",
			"enabled=true",
			"apps=[`"notepad.exe`",`"vlc.exe`"]"
		], "`n")
		FileAppend("`n" . section . "`n", _SAE.settingsFilename)
	}
}



/** */
doSettingsFileUpdate() {
	try {
		for key, module in _Modules {
			if (module.hasMethod("updateSettingsFile")) {
				module.updateSettingsFile()
			}
		}
	} catch Error as e {
		throw Error("Error updating settings file: " . e.Message)
	}
}



/** */
checkStartWithWindows() {
	startWithWindows := getIniVal("Environment", "startWithWindows", false)
	startupFolder := A_AppData . "\Microsoft\Windows\Start Menu\Programs\Startup"
	startupShortcut := startupFolder . "\" . _Settings.app.name . ".lnk"
	shortcutExists := (FileExist(startupShortcut) ? true : false)

	if (!startWithWindows && shortcutExists) {
		FileDelete(startupShortcut)
	} else if (startWithWindows && !shortcutExists) {
		wsh := ComObject("WScript.Shell")
		shortcut := wsh.CreateShortcut(startupShortcut)
		shortcut.TargetPath := A_ScriptFullPath
		shortcut.WorkingDirectory := A_ScriptDir
		shortcut.Description := _Settings.app.name
		; shortcut.IconLocation := A_ScriptDir . "\icons\app-icon-debugging.ico"
		shortcut.Save()
	}
}



/** */
closeAppsWithCtrlW_enabled := getIniVal("CloseAppsWithCtrlW", "enabled", true)
if (closeAppsWithCtrlW_enabled) {
	doCloseAppsWithCtrlWGroupAdd()
	doCloseAppsWithCtrlWGroupAdd() {
		appsList := getIniVal("closeAppsWithCtrlW", "apps", [])
		for key, app in appsList {
			app := StrReplace(app, "`"", "")
			app := StrReplace(app, "'", "")
			GroupAdd("closeAppsWithCtrlW", "ahk_exe " . app)
		}
	}
}
#HotIf (WinActive("ahk_group closeAppsWithCtrlW") && closeAppsWithCtrlW_enabled)
$^w:: WinClose("A")
#HotIf



/** */
enableExtendedRightMouseClick := getIniVal("Environment", "enableExtendedRightMouseClick", false)
#HotIf (WinActive("ahk_group explorerWindows") && enableExtendedRightMouseClick)
$RButton:: SendInput("+{RButton}")
#HotIf
