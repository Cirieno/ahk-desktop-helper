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



#Requires AutoHotkey v2+
#ClipboardTimeout 2000
#SingleInstance force
#WinActivateForce
A_HotkeyInterval := 2000
A_MaxHotkeysPerInterval := 2000
DetectHiddenText(true)
DetectHiddenWindows(true)
FileEncoding("UTF-8-RAW")
InstallKeybdHook(true)
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



; #Include "*i .\modules\autocorrect.module.ahk"
#Include "*i .\modules\desktop-file-dialog-slashes.module.ahk"
#Include "*i .\modules\desktop-hide-media-popup.module.ahk"
#Include "*i .\modules\desktop-hide-peek-button.module.ahk"
#Include "*i .\modules\keyboard-keylocks.module.ahk"
#Include "*i .\modules\mouse-swap-buttons.module.ahk"
; #Include "*i .\modules\volume-mousewheel.module.ahk"
; #Include "*i .\modules\volume-steps.module.ahk"



/** */
checkSettingsFileExists()
checkStartWithWindows()
drawMenu("init")
loadModules()
drawMenu("exit")
SetTimer(checkMemoryUsage, (30 * U_msMinute))
OnExit(doExit)



/** */
drawMenu(section) {
	_SA := _Settings.app
	_ST := _Settings.app.tray

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
			A_IconTip := _ST.traytip
			TraySetIcon(_ST.icon.location)
			A_TrayMenu.delete()
			A_TrayMenu.add(_ST.title, doMenuItem)
			; A_TrayMenu.setIcon(_ST.title, _ST.icon.location)
			A_TrayMenu.default := _ST.title
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
	_ST := _Settings.app.tray
	_S := _Settings.apps

	switch (name) {
		case _ST.title:
			if (!A_IsCompiled) {
				; TODO: this is for debugging
				Reload()
			}
		case "About" . U_ellipsis:
			msg := join([
				_SA.name, "v" . _SA.build.version . " (" . _SA.build.date . ")", "",
				"Repo @ " . _SA.build.repo,
				"AutoHotkey v2 @ autohotkey.com",
				"AutoCorrect @ github.com/cdelahousse",
				"Icons @ flaticon.com/authors/xnimrodx"
			], "`n")
			MsgBox(msg, _ST.title, 4160)
		case "Edit config" . U_ellipsis:
			local exitcode := RunWait(_S.Notepad.location . " " . _SA.environment.settingsFile)
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
	; _Modules["AutoCorrect"] := module__AutoCorrect()
	_Modules["DesktopFileDialogSlashes"] := module__DesktopFileDialogSlashes()
	_Modules["DesktopHideMediaPopup"] := module__DesktopHideMediaPopup()
	_Modules["DesktopHidePeekButton"] := module__DesktopHidePeekButton()
	_Modules["KeyboardKeylocks"] := module__KeyboardKeylocks()
	_Modules["MouseSwapButtons"] := module__MouseSwapButtons()
	; _Modules["VolumeSteps"] := module__VolumeSteps()
	; _Modules["VolumeMouseWheel"] := module__VolumeMouseWheel()
	; } catch Error as e {
	; do nothing
	; }
}



/** */
doExit(reason, code) {
	if (isSet(_Modules) && isMap(_Modules)) {
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
			"enableTextManipulationHotkeys=false",
			"enableExtendedRightMouseClick=false"
		], "`n")
		FileAppend("" . section . "`n", _Settings.app.environment.settingsFile)
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
	clipboardSaved := ClipboardAll()
	A_Clipboard := ""
	Send("^c")
	ClipWait()
	len := StrLen(A_Clipboard)
	switch (what) {
		case "lower": SendText(StrLower(A_Clipboard))
		case "upper": SendText(StrUpper(A_Clipboard))
		case "title": SendText(StrTitle(A_Clipboard))
		case "singlequote": SendText("'" . A_Clipboard . "'")
		case "doublequote": SendText("`"" . A_Clipboard . "`"")
		case "parentheses": SendText("(" . A_Clipboard . ")")
		case "brackets": SendText("[" . A_Clipboard . "]")
		case "curlies": SendText("{" . A_Clipboard . "}")
	}
	if (reselect) {
		Send("+{left " . (len + 2) . "}")
	}
	A_Clipboard := clipboardSaved
	clipboardSaved := ""
}



/** */
enableTextManipulationHotkeys := getIniVal("Environment", "enableTextManipulationHotkeys", false)
#HotIf enableTextManipulationHotkeys
$^!L:: doTextManipulation("lower")
$^!U:: doTextManipulation("upper")
$^!T:: doTextManipulation("title")
$^!':: doTextManipulation("singlequote")
$^!2:: doTextManipulation("doublequote")
$^!9:: doTextManipulation("parentheses")
$^!0:: doTextManipulation("parentheses")
$^![:: doTextManipulation("brackets")
$^!]:: doTextManipulation("brackets")
$+^!{:: doTextManipulation("curlies")
$+^!}:: doTextManipulation("curlies")
#HotIf



/** */
GroupAdd("closeWindows", "ahk_exe notepad.exe")
GroupAdd("closeWindows", "ahk_exe vlc.exe")
#HotIf WinActive("ahk_group closeWindows")
$^w:: WinClose("A")
#HotIf



/** */
enableExtendedRightMouseClick := getIniVal("Environment", "enableExtendedRightMouseClick", false)
#HotIf WinActive("ahk_group explorerWindows") && enableExtendedRightMouseClick
$RButton:: SendInput("+{RButton}")
#HotIf
