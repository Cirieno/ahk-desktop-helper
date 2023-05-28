;// Compile-time settings for "File Properties > Details" panel:
;@Ahk2Exe-Let PName = AHK Desktop Helper, PVersion = "1.7.4", PAuthor = Rob McInnes, PCompany = Cirieno Ltd
;@Ahk2Exe-ExeName C:\Program Files (portable)\%U_PName%\%U_PName%.exe
;@Ahk2Exe-SetCopyright %U_PCompany%
;@Ahk2Exe-SetDescription %U_PName%
;@Ahk2Exe-SetFileVersion %U_PVersion%
;@Ahk2Exe-SetLanguage 0x0809
;@Ahk2Exe-SetMainIcon icons\app-icon-compiled.ico
;@Ahk2Exe-SetName %U_PName%
;@Ahk2Exe-SetOrigFilename ahk-desktop-helper.ahk
;@Ahk2Exe-SetProductName %U_PName%
;@Ahk2Exe-SetProductVersion %U_PVersion%


#clipboardTimeout 1500 ;// how long the script keeps trying to access the clipboard
; #keyHistory 20     ;// keyboard and mouse events displayed by the KeyHistory window
; #hotstring NoMouse
A_MaxHotkeysPerInterval := 200
; REMOVED: #noEnv ;// prevents empty variables from being looked up
Persistent
#singleInstance force
#winActivateForce
#warn
; REMOVED: autotrim on
; critical off
; coordmode mouse, screen
; detectHiddenText on
; detectHiddenWindows off
ErrorLevel := ProcessSetPriority("low")
SendMode("input")
; setBatchLines -1
; setControlDelay 0
; setKeyDelay 0
; setMouseDelay 0
; setWinDelay 0
SetTitleMatchMode(2)
SetTitleMatchMode("slow")
; stringCaseSense off
SetWorkingDir(A_ScriptDir)

; global ahkMsgFormatTooltip := 1
; global ahkMsgFormatMsgbox := 2
; global ahkMsgFormatToast := 3

global _Settings := populateGlobalVars()
drawMenu("init")
loadModules()
drawMenu("exit")


populateGlobalVars() {
	local _S := {}

	_S.app := {
		name: "AHK Desktop Helper",
		author: { name: "Rob McInnes", email: "rob.mcinnes@cirieno.co.uk", company: "Cirieno Ltd" },
		build: { version: "2.0.0", date: "2023-06", repo: "github.com/cirieno/ahk-desktop-helper" }
	}
	_S.app.tray := {
		title: _S.app.name,
		traytip: "[=" . _S.app.name . " - " . _S.app.build.version . "]",
		icon: { location: (A_IsCompiled ? "icons\app-icon-compiled.ico" : "icons\app-icon-debugging.ico") },
		useToast: getIniVal("Environment\useToast", true), msgTimeout: 2000
	}
	_S.app.environment := {
		company: getIniVal("Environment\company", _S.app.author.company),
		computerName: A_ComputerName,
		user: A_UserName,
		domain: getAppEnvironmentDomain()
	}
	; _S.app.debugging := {
	; 	enabled: getIniVal("AppDebugging\enabled", !A_IsCompiled),
	; 	activateOnLoad: getIniVal("AppDebugging\active", !A_IsCompiled),
	; 	notifyUser: getIniVal("AppDebugging\notify", true),
	; 	menuLabel: "Debugging mode"
	; }
	; _S.app.debugging.enabled := (_S.app.debugging.activateOnLoad ? true : _S.app.debugging.enabled)
	; _S.app.debugging.active := (_S.app.debugging.enabled && _S.app.debugging.activateOnLoad)
	; appDebugging_set((__D.enabled && __D.active), false)
	_S.apps := {
		Notepad: { location: A_WinDir . "\notepad.exe" },
		Everything_Search: { location: "C:\Program Files\Everything Search\Everything.exe" }
	}
	_S.modules := Map()

	return _S
}


; TODO: add this to the autocorrect module "Use 3rd party autocorrect" + also edit
; #Include "*i .\modules\prevent-sleep.module.ahk"
; #Include "*i .\modules\user-hotkeys.module.ahk"
; #Include "*i .\modules\volume-mouse-wheel.module.ahk"
; #include *i .\modules\disable-proxy.module.ahk
; #include *i .\modules\enable-proxy-overrides.module.ahk
#Include ".\utils\utils.ahk"
#Include "*i .\modules\autocorrect.module.ahk"
#Include "*i .\modules\key-locks.module.ahk"
#Include "*i .\modules\swap-mouse-buttons.module.ahk"
#Include "*i .\modules\volume.module.ahk"

loadModules() {
	; try {
	Module__KeyLocks()
	Module__SwapMouseButtons
	Module__Volume()
		;_M.PreventSleep := new Module__PreventSleep
		;_M.UserHotkeys := new Module__UserHotkeys
		;_M.VolumeMouseWheel := new Module__VolumeMouseWheel
		; _M.DisableProxy := new Module__DisableProxy
		; _M.EnableProxyOverrides := new Module__EnableProxyOverrides
		; _M.PreventSleep := new Module__PreventSleep
	; } catch as e {
	; MsgBox("Exception thrown!`n`nwhat: " e.what "`nfile: " e.file . "`nline: " e.line "`nmessage: " e.message "`nextra: " e.extra, __Settings.app.name, 16)
	;		MsgBox, 16, % __Settings.app.name, % "Exception thrown!`n`nwhat: " e.what "`nfile: " e.file . "`nline: " e.line "`nmessage: " e.message "`nextra: " e.extra
	; }
}


drawMenu(part := "") {
	local _A := _Settings.app
	local _T := _Settings.app.tray
	local _I := _Settings.app.tray.icon
	; local _D := _Settings.app.debugging
	local trayMenu := A_TrayMenu

	if (part == "init") {
		A_IconTip := _T.traytip
		TraySetIcon(_I.location)
		trayMenu.delete()
		trayMenu.add(_T.title, doMenuItem)
		trayMenu.setIcon(_T.title, _I.location)
		trayMenu.default := _T.title
		trayMenu.add()
	} else if (part == "exit") {
		settingsMenu := Menu()
		settingsMenu.add("Edit config...", doMenuItem)
		trayMenu.add()
		trayMenu.add("Settings...", settingsMenu)
		trayMenu.add("About...", doMenuItem)
		trayMenu.add("Exit", doMenuItem)
		; if (_D.enabled) {
		; 	trayMenu.add()
		; 	trayMenu.AddStandard()
		; }
	}
}


doMenuItem(name, position, menu) {
	local _A := _Settings.app
	local _T := _Settings.app.tray
	local _S := _Settings.apps

	if ((name == "About...") || (name == _T.title)) {
		local arr := [
			_A.name, "v" . _A.build.version . " (" . _A.build.date . ")", "",
			"Repo @ " . _A.build.repo,
			"AutoHotkey @ autohotkey.com",
			"AutoCorrect @ github.com/cdelahousse",
			"Icons @ flaticon.com/authors/juicy-fish"
		]
		MsgBox(join(arr, "`n"), _T.title, 4160)
	} else if (name == "Edit config...") {
		local exitcode := RunWait(_S.Notepad.location . " user_settings.ini")
		if (exitcode == 0) {
			Reload()
		}
	} else if (name == "Exit") {
		ExitApp()
	}
}


; Reload this script on save
#HotIf WinActive("`.ahk",)
~^s::
{
	local title := WinGetTitle("A")
	if InStr(title, A_ScriptName) {
		Sleep(500)
		Reload()
	}
}
#HotIf


; groupAdd _grpExplorerWindows, ahk_class ExploreWClass
; groupAdd _grpExplorerWindows, ahk_class CabinetWClass
; groupAdd _grpExplorerWindows, ahk_class Progman

; ahkFalse := 0
; ahkTrue := 1
; ahkInteger := 3
; ahkString := 8
; ahkBoolean := 11

; drawMenuItem__appDebugging(_S){
; 	if (_S.enabled){
; 		menu tray, add
; 		menu tray, add, % _S.menuLabel, appDebugging_toggle
; 		__tickMenuItem("tray", (_S.active ? "check" : "uncheck"), _S.menuLabel)
; 	}
; }

; setMemoryCheck(){
;     setTimer checkMemoryUsage, % (60000 * -1)
; }
; checkMemoryUsage(){
;     pid := DllCall("GetCurrentProcessId")
;     h := DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
;     DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
;     DllCall("CloseHandle", "Int", h)
;     return
; }


; appDebugging_toggle(){
; 	_S := __Settings.app.debugging
; 	appDebugging_set(!_S.active, _S.notify)
; }
; appDebugging_set(action := false, notify := false){
; 	_S := __Settings.app.debugging
; 	_S.active := action
; 	__tickMenuItem("tray", (_S.active ? "check" : "uncheck"), _S.menuLabel)
; 	__notify("AppDebugging", notify, _S.active)
; 	; tooltipMsg("AppDebugging is now " . (_S.active ? "ON" : "OFF"),, __Settings.app.tray.msgTimeout)
; }

; __tickMenuItem(menuName, action, labelName){
; 	menu % menuName, useErrorLevel
; 	menu % menuName, % action, % labelName
; 	menu % menuName, useErrorLevel, off
; }

; __notify(moduleName := "", notify := false, active := false, forceFormat := 0){
; 	_D := __Settings.app.debugging
; 	if (notify || (_D.enabled && _D.active)){
; 		_T := __Settings.app.tray
; 		sendMsg(moduleName . " is " . (active ? "ON" : "OFF"), moduleName, _T.msgTimeout, (forceFormat ? forceFormat : (_T.useToast ? ahkMsgFormatToast : ahkMsgFormatMsgbox)))
; 	}
; }
