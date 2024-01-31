; Compile-time settings for "File Properties > Details" panel
;@Ahk2Exe-Let PName = AHK Desktop Helper, PVersion = 2.1.0.1, PAuthor = Rob McInnes, PCompany = Cirieno Ltd
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



#Requires AutoHotkey v2
#ClipboardTimeout 2000
#SingleInstance force
#WinActivateForce
A_HotkeyInterval := 2000
A_MaxHotkeysPerInterval := 2000
DetectHiddenText(true)
DetectHiddenWindows(true)
FileEncoding("UTF-8-RAW")
Persistent(true)
SetTitleMatchMode("slow")
SetWorkingDir(A_ScriptDir)



global _Settings := populateGlobalVars()
populateGlobalVars() {
	_S := {}

	_S.app := {
		name: "AHK Desktop Helper",
		author: { name: "Rob McInnes", email: "rob.mcinnes@cirieno.co.uk", company: "Cirieno Ltd" },
		build: { version: "2.1.0.1", date: "2024-02", repo: "github.com/cirieno/ahk-desktop-helper" }
	}

	_S.app.tray := {
		title: _S.app.name,
		traytip: "[=" . _S.app.name . " - " . _S.app.build.version . "]",
		icon: { location: (A_IsCompiled == true ? A_ScriptName : "icons\app-icon-debugging.ico"), index: -0 },
		includeSubmenuIcons: false
			; useToast: getIniVal("Environment", "useToast", true, 1), msgTimeout: 2000
	}

	_S.app.environment := {
		company: getIniVal("Environment", "company", ""),
		user: getIniVal("Environment", "user", A_UserName),
		computerName: A_ComputerName,
		domain: EnvGet("USERDOMAIN"),
		architecture: (A_Is64bitOS ? "x64" : "x86")
	}

	_S.apps := {
		Notepad: { location: A_WinDir . "\notepad.exe" }
	}

	_S.modules := Map()

	return _S
}



#Include ".\utils\constants.ahk"
#Include ".\utils\utils.ahk"
#Include "*i .\modules\autocorrect.module.ahk"
#Include "*i .\modules\desktop-file-dialogs.ahk"
#Include "*i .\modules\desktop-hide-media-popup.module.ahk"
#Include "*i .\modules\desktop-hide-peek-button.module.ahk"
#Include "*i .\modules\keyboard-keylocks.module.ahk"
#Include "*i .\modules\mouse-swap-buttons.module.ahk"
#Include "*i .\modules\volume-mousewheel.module.ahk"
#Include "*i .\modules\volume-steps.module.ahk"
; #include "*i .\modules\prevent-sleep.module.ahk"
; #include "*i .\modules\disable-proxy.module.ahk"
; #include "*i .\modules\enable-proxy-overrides.module.ahk"



doSettingsFileCheck()
doStartWithWindowsCheck()
drawMenu("init")
loadModules()
drawMenu("exit")
SetTimer(checkMemoryUsage, 5 * (60 * 1000))
OnExit(doExit)



drawMenu(section) {
	_SA := _Settings.app
	_ST := _Settings.app.tray
	_SI := _Settings.app.tray.icon
	_SM := _Settings.app.tray.menuHandles := Map()
	trayMenu := A_TrayMenu

	switch section {
		case "init":
			A_IconTip := _ST.traytip
			TraySetIcon(_SI.location)
			trayMenu.delete()
			trayMenu.add(_ST.title, doMenuItem)
			; trayMenu.setIcon(_ST.title, _SI.location)
			trayMenu.default := _ST.title
			trayMenu.add()
		case "exit":
			settingsMenu := Menu()
			settingsMenu.add("Edit config" . ellipsis, doMenuItem)
			trayMenu.add()
			trayMenu.add("Settings" . ellipsis, settingsMenu)
			trayMenu.add("About" . ellipsis, doMenuItem)
			trayMenu.add("Exit", doMenuItem)
			if (A_IsCompiled == false) {
				trayMenu.add()
				trayMenu.addStandard()
			}
	}
}



doMenuItem(name, position, menu) {
	_SA := _Settings.app
	_ST := _Settings.app.tray
	_S := _Settings.apps

	switch name {
		case "About" . ellipsis, _ST.title:
			local arr := [
				_SA.name, "v" . _SA.build.version . " (" . _SA.build.date . ")", "",
				"Repo @ " . _SA.build.repo,
				"AutoHotkey v2 @ autohotkey.com",
				"AutoCorrect @ github.com/cdelahousse",
				"Icons @ flaticon.com/authors/xnimrodx"
			]
			MsgBox(join(arr, "`n"), _ST.title, 4160)
		case "Edit config" . ellipsis:
			local exitcode := RunWait(_S.Notepad.location . " user_settings.ini")
			if (exitcode == 0) {
				Reload()
			}
		case "Exit":
			ExitApp()
	}
}



loadModules() {
	; try {
	_Settings.modules["AutoCorrect"] := module__AutoCorrect()
	_Settings.modules["DesktopFileDialogs"] := module__DesktopFileDialogs()
	_Settings.modules["DesktopHideMediaPopup"] := module__DesktopHideMediaPopup()
	_Settings.modules["DesktopHidePeekButton"] := module__DesktopHidePeekButton()
	_Settings.modules["KeyboardKeylocks"] := module__KeyboardKeylocks()
	_Settings.modules["MouseSwapButtons"] := module__MouseSwapButtons()
	_Settings.modules["VolumeSteps"] := module__VolumeSteps()
	_Settings.modules["VolumeMouseWheel"] := module__VolumeMouseWheel()
	; } catch Error as e {
	; 	; MsgBox("Exception thrown!`n`nwhat: " e.what "`nfile: " e.file . "`nline: " e.line "`nmessage: " e.message "`nextra: " e.extra, _Settings.app.name, 16)
	; 	; MsgBox(16, _Settings.app.name, "Exception thrown!`n`nwhat: " Error.what "`nfile: " Error.file . "`nline: " Error.line "`nmessage: " Error.message "`nextra: " Error.extra)
	; }
}



doExit(reason, code) {
	for each, module in _Settings.modules {
		module.__Delete()
		module := ""
	}
}



doSettingsFileCheck() {
	sectionExists := IniRead("user_settings.ini", "Environment", , false)
	if (!sectionExists) {
		section := join([
			"[Environment]",
			"user = `"<your email>`"",
			"company = `"<your company>`"",
			"startWithWindows = false",
			"enableTextManipulationHotkeys = false",
			"enableExtendedRightMouseClick = false"
		], "`n")
		FileAppend("" . section . "`n", "user_settings.ini")
	}
}



doStartWithWindowsCheck() {
	startWithWindows := getIniVal("Environment", "startWithWindows", false)
	startupFolder := "C:\Users\" . A_UserName . "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
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



doTextManipulation(what, reselect := true) {
	clipboardSaved := ClipboardAll()
	A_Clipboard := ""
	Send("^c")
	ClipWait()
	len := StrLen(A_Clipboard)
	switch what {
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
	clipboardSaved := null
}



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



GroupAdd("closeWindows", "ahk_exe notepad.exe")
GroupAdd("closeWindows", "ahk_exe thunderbird.exe")
GroupAdd("closeWindows", "ahk_exe vlc.exe")
#HotIf WinActive("ahk_group closeWindows")
$^w:: WinClose("A")
#HotIf



GroupAdd("explorerWindows", "ahk_class CabinetWClass")
GroupAdd("explorerWindows", "ahk_class ExploreWClass")
GroupAdd("explorerWindows", "ahk_class Progman")
GroupAdd("explorerWindows", "ahk_class WorkerW")
GroupAdd("explorerWindows", "ahk_class #32770")
GroupAdd("explorerWindows", "ahk_exe explorer.exe")
enableExtendedRightMouseClick := getIniVal("Environment", "enableExtendedRightMouseClick", false)
#HotIf WinActive("ahk_group explorerWindows") && enableExtendedRightMouseClick
$RButton:: SendInput("+{RButton}")
#HotIf
