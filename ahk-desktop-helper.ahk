;// Compile-time settings for "File Properties > Details" panel
;@Ahk2Exe-Let PName = AHK Desktop Helper, PVersion = 2.5.2.0, PAuthor = Rob McInnes, PCompany = Cirieno Ltd
;@ Ahk2Exe-ExeName C:\Program Files (portable)\%U_PName%\%U_PName%.exe
;@Ahk2Exe-ExeName %A_ScriptDir%\releases\%U_PVersion%\%U_PName% x64.exe
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



#Requires AutoHotkey v2.0.13 64-bit
; Run *RunAs.
#ClipboardTimeout 2000
#SingleInstance force
#Warn
#WinActivateForce
A_HotkeyInterval := 2000
A_MaxHotkeysPerInterval := 2000
DetectHiddenText(true)
DetectHiddenWindows(true)
FileEncoding("UTF-8-RAW")
InstallKeybdHook(true)
InstallMouseHook(true)
OnExit(doExit)
Persistent(true)
SetTitleMatchMode("slow")
SetWorkingDir(A_ScriptDir)



#Include ".\libs\misc_utils.lib.ahk"
#Include ".\libs\shadow_menu.lib.ahk"
#Include ".\libs\vartypes.lib.ahk"



global __DEBUGGING := (A_IsCompiled ? false : true)    ; use true to override compiled setting
global __Modules := Map()
global __ShadowMenu := { menus: Map(), items: Map() }
if (__Settings := {}) {
	__Settings.app := {
		name: "AHK Desktop Helper",
		author: { name: "Rob McInnes", email: "rob.mcinnes" . chr(64) . "cirieno.co.uk", company: "Cirieno Ltd" },
		build: { version: "2.5.2.0", date: "2024-04", repo: "github.com/cirieno/ahk-desktop-helper" }
	}
	__Settings.settingsFilePath := A_WorkingDir . "\settings.ini"
	__Settings.app.tray := {
		title: __Settings.app.name,
		traytip: __Settings.app.name,
		icon: { location: (A_IsCompiled ? A_ScriptName : "icons\app-icon-debugging.ico"), index: 0 },
		includeSubmenuIcons: false
	}
	__Settings.app.environment := {
		company: getIniVal("Environment", "company", ""),
		user: getIniVal("Environment", "user", A_UserName),
		computerName: A_ComputerName,
		domain: EnvGet("USERDOMAIN"),
		architecture: (A_Is64bitOS ? "x64" : "x86"),
		startWithWindows: getIniVal("Environment", "startWithWindows", false),
		debugging: __DEBUGGING
	}
	__Settings.apps := {
		Notepad: { location: A_WinDir . "\notepad.exe" }
	}
}



#Include "*i .\modules\autocorrect.module.ahk"
#Include "*i .\modules\desktop-gather-windows.module.ahk"
#Include "*i .\modules\desktop-hide-media-popup.module.ahk"
#Include "*i .\modules\desktop-hide-peek-button.module.ahk"
#Include "*i .\modules\keyboard-explorer-backspace.module.ahk"
#Include "*i .\modules\keyboard-explorer-dialog-slashes.module.ahk"
#Include "*i .\modules\keyboard-text-manipulation.module.ahk"
#Include "*i .\modules\mouse-swap-buttons.module.ahk"
#Include "*i .\modules\volume-mousewheel.module.ahk"



drawMenu("before")
loadModules()
drawMenu("after")
checkStartWithWindows()
checkMemoryUsage()
SetTimer(checkMemoryUsage, (30 * U_msMinute))



drawMenu(section) {
	SAT := __Settings.app.tray

	if (!__ShadowMenu.menus.has("TRAY")) {
		menuVals := {
			type: "menu",
			path: "TRAY",
			handle: A_TrayMenu.handle,
			parentHandle: null,
			items: []
		}
		__ShadowMenu.menus.set(menuVals.path, menuVals)
		A_TrayMenu.vals := __ShadowMenu.menus[menuVals.path]
	}

	switch (section) {
		case "before":
			A_IconTip := SAT.traytip
			TraySetIcon(SAT.icon.location)
			A_TrayMenu.delete()
			A_TrayMenu.add(SAT.title, doMenuItem)
			A_TrayMenu.default := SAT.title
			A_TrayMenu.add()
		case "after":
			A_TrayMenu.add()
			setMenuItem("Settings" . U_ellipsis, A_TrayMenu, setSubMenu("TRAY\Settings"))
			setMenuItem("About" . U_ellipsis, A_TrayMenu, doMenuItem)
			setMenuItem("Exit", A_TrayMenu, doMenuItem)
			if (__DEBUGGING) {
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
				; setMenuItem("Reload", thisMenu, doMenuItem)
				; setMenuItem("Pause hotstrings", thisMenu, doMenuItem)
				; if (__Modules.has("AutoCorrect")) {
				; 	setMenuItem("Rebuild AutoCorrect list", thisMenu, doMenuItem)
				; }
		}
		return thisMenu
	}
}



doMenuItem(name, position, menu) {
	SA := __Settings.app
	SAP := __Settings.apps
	SAT := __Settings.app.tray
	SFP := __Settings.settingsFilePath

	switch (name) {
		case SAT.title:
			(A_IsCompiled ? showAboutDialog() : Reload())
		case "About" . U_ellipsis:
			showAboutDialog()
		case "Edit config" . U_ellipsis:
			if (!FileExist(SFP)) {
				doSettingsFileUpdate()
			}
			exitcode := RunWait(A_WinDir . "\notepad.exe " . StrWrap(SFP, 5))
			if (exitcode == 0) {
				Reload()
			}
		case "Save current config":
			doSettingsFileUpdate()
		case "Exit":
			ExitApp()
		case "Show menu paths":
			alertMenuPaths()
		case "Reload":
			Reload()
		case "Rebuild AutoCorrect list":
			__Modules["AutoCorrect"].buildDefaultList()
		case "Pause Hotstrings":
			Suspend(-1)
		default:
			MsgBox("Menu item " . StrWrap(name, 5) . " doesn't exist")
	}
}



showAboutDialog() {
	SA := __Settings.app

	title := SA.name . " — About" . U_ellipsis
	msg := MsgboxJoin([
		SA.name, "v" . SA.build.version . " (" . SA.build.date . ")", "",
		"Repo @ " . SA.build.repo,
		"AutoHotkey v2 @ autohotkey.com",
		"Icons @ flaticon.com/authors/juicy-fish"
	])
	MsgBox(msg, title, (0 + 64 + 4096))
}



loadModules() {
	__Modules["AutoCorrect"] := module__AutoCorrect()

	__Modules["DesktopHideMediaPopup"] := module__DesktopHideMediaPopup()
	__Modules["DesktopHidePeekButton"] := module__DesktopHidePeekButton()
	setMenuItem("---", "TRAY\Desktop")
	__Modules["DesktopGatherWindows"] := module__DesktopGatherWindows()

	__Modules["KeyboardExplorerBackspace"] := module__KeyboardExplorerBackspace()
	__Modules["KeyboardExplorerDialogSlashes"] := module__KeyboardExplorerDialogSlashes()
	__Modules["KeyboardTextManipulation"] := module__KeyboardTextManipulation()

	__Modules["MouseSwapButtons"] := module__MouseSwapButtons()
	__Modules["VolumeMouseWheel"] := module__VolumeMouseWheel()
}



doExit(reason, code) {
	if (IsSet(__Modules) && isMap(__Modules)) {
		for (key, module in __Modules) {
			if (module.hasMethod("__Delete")) {
				module.__Delete()
			}
			module := unset
		}
	}
}



doSettingsFileUpdate() {
	SA := __Settings.app
	SAB := __Settings.app.build
	SAE := __Settings.app.environment
	SFP := __Settings.settingsFilePath

	moduleName := "App"
	moduleExists := iniSectionExists(moduleName)
	IniWrite(SA.name, SFP, moduleName, "name")
	IniWrite(SAB.version, SFP, moduleName, "version")
	if (!moduleExists) {
		FileAppend("`n", SFP)
	}

	moduleName := "Environment"
	moduleExists := iniSectionExists(moduleName)
	IniWrite(toString(SAE.startWithWindows), SFP, moduleName, "startWithWindows")
	IniWrite(toString(false), SFP, moduleName, "enableExtendedRightMouseClick")
	if (!moduleExists) {
		FileAppend("`n", SFP)
	}

	; TODO: move this to a module
	moduleName := "CloseAppsWithCtrlW"
	moduleExists := iniSectionExists(moduleName)
	IniWrite(toString(false), SFP, moduleName, "enabled")
	IniWrite("[`"notepad.exe`",`"vlc.exe`"]", SFP, moduleName, "apps")
	if (!moduleExists) {
		FileAppend("`n", SFP)
	}

	for (key, module in __Modules) {
		if (module.hasMethod("updateSettingsFile")) {
			moduleName := module.moduleName
			moduleExists := iniSectionExists(moduleName)
			module.updateSettingsFile()
			if (!moduleExists) {
				FileAppend("`n", SFP)
			}
		}
	}
}



checkStartWithWindows() {
	SAE := __Settings.app.environment

	startWithWindows := SAE.startWithWindows
	startupFolder := A_AppData . "\Microsoft\Windows\Start Menu\Programs\Startup"
	startupShortcut := startupFolder . "\" . __Settings.app.name . ".lnk"
	shortcutExists := (FileExist(startupShortcut) ? true : false)

	if (!startWithWindows && shortcutExists) {
		FileDelete(startupShortcut)
	} else if (startWithWindows && !shortcutExists) {
		wsh := ComObject("WScript.Shell")
		shortcut := wsh.CreateShortcut(startupShortcut)
		shortcut.TargetPath := A_ScriptFullPath
		shortcut.WorkingDirectory := A_ScriptDir
		shortcut.Description := __Settings.app.name
		; shortcut.IconLocation := A_ScriptDir . "\icons\app-icon-debugging.ico"
		shortcut.Save()
	}
}



checkCloseAppsWithCtrlW() {
	global closeAppsWithCtrlW_enabled := getIniVal("CloseAppsWithCtrlW", "enabled", false)
	if (closeAppsWithCtrlW_enabled) {
		if (doCloseAppsWithCtrlWGroupAdd := true) {
			apps := getIniVal("closeAppsWithCtrlW", "apps", [])
			for (i, app in apps) {
				; TODO: use StrUnwrap()
				app := Trim(StrReplace(app, "`"", ""))
				app := Trim(StrReplace(app, "'", ""))
				GroupAdd("closeAppsWithCtrlW", "ahk_exe " . app)
			}
		}
	}
}
checkCloseAppsWithCtrlW()
#HotIf (WinActive("ahk_group closeAppsWithCtrlW") && closeAppsWithCtrlW_enabled)
$^w:: WinClose("A")
#HotIf



checkExtendedRightMouseClick() {
	global extendedRightMouseClick_enabled := getIniVal("Environment", "enableExtendedRightMouseClick", false)
}
checkExtendedRightMouseClick()
#HotIf (WinActive("ahk_group explorerWindows") && extendedRightMouseClick_enabled)
$RButton:: SendInput("+{RButton}")
#HotIf
