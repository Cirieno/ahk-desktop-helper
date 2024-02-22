; Compile-time settings for "File Properties > Details" panel
;@Ahk2Exe-Let PName = AHK Desktop Helper, PVersion = 2.2.0.0, PAuthor = Rob McInnes, PCompany = Cirieno Ltd
;@ Ahk2Exe-ExeName C:\Program Files (portable)\%U_PName%\%U_PName%.exe
;@Ahk2Exe-ExeName %A_ScriptDir%\compiled\%U_PName%.exe
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
; DetectHiddenText(true)
; DetectHiddenWindows(true)
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
		build: { version: "2.2.0.0", date: "2024-02", repo: "github.com/cirieno/ahk-desktop-helper" }
	}

	_S.app.tray := {
		title: _S.app.name,
		traytip: "" . _S.app.name . " - " . _S.app.build.version . "",
		icon: { location: (A_IsCompiled == true ? A_ScriptName : "icons\app-icon-debugging.ico"), index: -0 },
		includeSubmenuIcons: false
	}

	_S.app.environment := {
		company: getIniVal("Environment", "company", ""),
		user: getIniVal("Environment", "user", A_UserName),
		computerName: A_ComputerName,
		domain: EnvGet("USERDOMAIN"),
		architecture: (A_Is64bitOS ? "x64" : "x86"),
		settingsFile: "user_settings.ini"
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
#Include "*i .\modules\mouse-swap-buttons.module.ahk"
; #Include "*i .\modules\volume-mousewheel.module.ahk"



/** */
checkSettingsFileExists()
checkStartWithWindows()
drawMenu("init")
loadModules()
drawMenu("exit")
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
		_ShadowMenu.menus.set("" . menuVals.path, menuVals)
		A_TrayMenu.vals := _ShadowMenu.menus[menuVals.path]
	}

	switch (section) {
		case "init":
			A_IconTip := _SAT.traytip
			TraySetIcon(_SAT.icon.location)
			A_TrayMenu.delete()
			A_TrayMenu.add(_SAT.title, doMenuItem)
			; A_TrayMenu.setIcon(_ST.title, _ST.icon.location)
			A_TrayMenu.default := _SAT.title
			A_TrayMenu.add()
		case "exit":
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
		}
		return thisMenu
	}
}



/** */
doMenuItem(name, position, menu) {
	_SA := _Settings.app

	switch (name) {
		case _Settings.app.tray.title:
			if (!A_IsCompiled) {
				; TODO: this is for debugging
				Reload()
			}
		case "About" . U_ellipsis:
			MsgBox(join([
				_SA.name, "v" . _SA.build.version . " (" . _SA.build.date . ")", "",
				"Repo @ " . _SA.build.repo,
				"AutoHotkey v2 @ autohotkey.com",
				; "AutoCorrect @ github.com/cdelahousse",
				; "Icons @ flaticon.com/authors/xnimrodx"
			], "`n"), (_Settings.app.name . " - About" . U_ellipsis), (0 + 64 + 4096))
		case "Edit config" . U_ellipsis:
			local exitcode := RunWait(_Settings.apps.Notepad.location . " " . _SA.environment.settingsFile)
			if (exitcode == 0) {
				Reload()
			}
		case "Save current config":
			doSettingsFileUpdate()
		case "Show menu paths":
			alertMenuPaths()
		case "Exit":
			ExitApp()
	}
}



/** */
loadModules() {
	; try {
	_Modules["AutoCorrect"] := module__AutoCorrect()
	_Modules["DesktopFileDialogSlashes"] := module__DesktopFileDialogSlashes()
	_Modules["DesktopHideMediaPopup"] := module__DesktopHideMediaPopup()
	_Modules["DesktopHidePeekButton"] := module__DesktopHidePeekButton()
	setMenuItem("---", "TRAY\Desktop")
	_Modules["DesktopGatherWindows"] := module__DesktopGatherWindows()
	_Modules["KeyboardKeylocks"] := module__KeyboardKeylocks()
	_Modules["MouseSwapButtons"] := module__MouseSwapButtons()
	; _Modules["VolumeMouseWheel"] := module__VolumeMouseWheel()
	; } catch Error as e {
	; do nothing
	; }
}



/** */
doExit(reason, code) {
	if (IsSet(_Modules) && isMap(_Modules)) {
		for key, module in _Modules {
			module.__Delete()
			module := null
		}
	}
}



/** */
checkSettingsFileExists() {
	sectionExists := IniRead(_Settings.app.environment.settingsFile, "Environment", , false)
	if (!sectionExists) {
		section := join([
			"[Environment]",
			"startWithWindows=false",
			"enableExtendedRightMouseClick=false",
			"enableTextManipulationHotkeys=true"
		], "`n")
		FileAppend("`n" . section . "`n", _Settings.app.environment.settingsFile)
	}
	sectionExists := IniRead(_Settings.app.environment.settingsFile, "CloseAppsWithCtrlW", , false)
	if (!sectionExists) {
		section := join([
			"[CloseAppsWithCtrlW]",
			"enabled=true",
			"apps=[`"notepad.exe`",`"vlc.exe`"]"
		], "`n")
		FileAppend("`n" . section . "`n", _Settings.app.environment.settingsFile)
	}
}



/** */
doSettingsFileUpdate() {
	try {
		for key, module in _Modules {
			module.updateSettingsFile()
		}
	} catch Error as e {
		throw ("Error updating settings file: " . e.Message)
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
doTextManipulation(what, reselect := true) {
	clipSaved := ClipboardAll()
	A_Clipboard := ""
	; Sleep(50)
	Send("^x")
	ClipWait()
	len := StrLen(A_Clipboard)
	if (len !== 0) {
		switch (what) {
			case "lower": A_Clipboard := StrLower(A_Clipboard)
			case "upper": A_Clipboard := StrUpper(A_Clipboard)
			case "title": A_Clipboard := StrTitle(A_Clipboard)
			case "singlequote": A_Clipboard := "'" . A_Clipboard . "'"
			case "doublequote": A_Clipboard := "`"" . A_Clipboard . "`""
			case "parentheses": A_Clipboard := "(" . A_Clipboard . ")"
			case "brackets": A_Clipboard := "[" . A_Clipboard . "]"
			case "curlies": A_Clipboard := "{" . A_Clipboard . "}"
		}
		Send("^v")
		if (reselect) {
			Send("+{left " . (len + 2) . "}")
		}
	}
	; Sleep(50)
	A_Clipboard := clipSaved
	clipSaved := ""
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



/** */
enableTextManipulationHotkeys := getIniVal("Environment", "enableTextManipulationHotkeys", true)
#HotIf enableTextManipulationHotkeys
$^!U:: doTextManipulation("upper")
$^!L:: doTextManipulation("lower")
$^!T:: doTextManipulation("title")
$^!':: doTextManipulation("singlequote")
$^!2:: doTextManipulation("doublequote")
$^!9:: doTextManipulation("parentheses")
$^!0:: doTextManipulation("parentheses")
$^![:: doTextManipulation("brackets")
$^!]:: doTextManipulation("brackets")
$^!+{:: doTextManipulation("curlies")
$^!+}:: doTextManipulation("curlies")
#HotIf
