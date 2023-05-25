;// Compile-time settings for "File Properties > Details" panel:
;@Ahk2Exe-Let PName = AHK Desktop Helper, PVersion = 1.7.4, PAuthor = Rob McInnes, PCompany = Cirieno Ltd
;@Ahk2Exe-SetName %U_PName%
;@Ahk2Exe-SetDescription %U_PName%
;@Ahk2Exe-SetProductName %U_PName%
;@Ahk2Exe-SetFileVersion %U_PVersion%
;@Ahk2Exe-SetProductVersion %U_PVersion%
;@Ahk2Exe-SetCopyright %U_PCompany%
;@Ahk2Exe-SetLanguage 0x0809
;@Ahk2Exe-SetOrigFilename ahk-desktop-helper.ahk
;@Ahk2Exe-ExeName C:\Program Files (portable)\%U_PName%\%U_PName%.exe
;@Ahk2Exe-SetMainIcon icons\cog-wheel-4.ico


;#region [AUTORUN]
#clipboardTimeout 1500 ;// how long the script keeps trying to access the clipboard
; #keyHistory 20     ;// keyboard and mouse events displayed by the KeyHistory window
; #hotstring NoMouse
#maxHotkeysPerInterval 200
#noEnv ;// prevents empty variables from being looked up
#persistent
#singleInstance force
#winActivateForce
#warn
autotrim on
; critical off
; coordmode mouse, screen
; detectHiddenText on
; detectHiddenWindows off
process priority,, low
sendMode input
; setBatchLines -1
; setControlDelay 0
; setKeyDelay 0
; setMouseDelay 0
; setWinDelay 0
setTitleMatchMode 2
setTitleMatchMode slow
; stringCaseSense off
setWorkingDir % A_ScriptDir

global ahkMsgFormatTooltip := 1
global ahkMsgFormatMsgbox := 2
global ahkMsgFormatToast := 3

global __Settings := populateGlobalVars()
drawMenu("init")
global __Modules := loadModules()
drawMenu("exit")
return
;#endregion [AUTORUN]


#include .\utils\utils.ahk


populateGlobalVars(){
	local _S := {}

	_S.app := {0:0
		, name: "AHK Desktop Helper"
		, author: { name: "Rob McInnes", email: "rob.mcinnes@cirieno.co.uk", company: "Cirieno Ltd" }
		, build: { version: "1.7.4", date: "2022-12", repo: "github.com/cirieno/ahk-desktop-helper" } }
	_S.app.tray := {0:0
		, title: _S.app.name
		, traytip: "[=" . _S.app.name . " - " . _S.app.build.version . "]"
		, icon: { location: (A_IsCompiled ? A_ScriptName : "icons\cog-wheel-3.ico"), index: -0 }
		, useToast: getIniVal("Environment\useToast", true)
		, msgTimeout: 2000 }
	_S.app.environment := {0:0
		, company: getIniVal("Environment\company", _S.app.author.company)
		, computerName: A_ComputerName
		, user: A_UserName
		, domain: getAppEnvironmentDomain() }
	_S.app.debugging := {0:0
		, enabled: getIniVal("AppDebugging\enabled", !A_IsCompiled)
		, activateOnLoad: getIniVal("AppDebugging\active", !A_IsCompiled)
		, notifyUser: getIniVal("AppDebugging\notify", true)
		, menuLabel: "Debugging mode" }
	_S.app.debugging.enabled := (_S.app.debugging.activateOnLoad ? true : _S.app.debugging.enabled)
	_S.app.debugging.active := (_S.app.debugging.enabled && _S.app.debugging.activateOnLoad)
	; appDebugging_set((__D.enabled && __D.active), false)

	_S.apps := {0:0
		, "Notepad": { location: A_WinDir . "\notepad.exe" }
		, "Everything Search": { location: "C:\Program Files\Everything Search\Everything.exe" } }

	return _S
}

; TODO: add this to the autocorrect module "Use 3rd party autocorrect" + also edit
; #include *i .\utils\AutoCorrect.ahk
; #include *i .\modules\disable-proxy.module.ahk
; #include *i .\modules\enable-proxy-overrides.module.ahk
#include *i .\modules\autocorrect.module.ahk
#include *i .\modules\key-locks.module.ahk
#include *i .\modules\prevent-sleep.module.ahk
#include *i .\modules\swap-mouse-buttons.module.ahk
#include *i .\modules\user-hotkeys.module.ahk
#include *i .\modules\volume-mouse-wheel.module.ahk
#include *i .\modules\volume.module.ahk


loadModules(){
	local e
	local _M := {}

	try {
		_M.KeyLocks := new Module__KeyLocks
		_M.PreventSleep := new Module__PreventSleep
		_M.SwapMouseButtons := new Module__SwapMouseButtons
		_M.UserHotkeys := new Module__UserHotkeys
		_M.Volume := new Module__Volume
		_M.VolumeMouseWheel := new Module__VolumeMouseWheel
		; _M.DisableProxy := new Module__DisableProxy
		; _M.EnableProxyOverrides := new Module__EnableProxyOverrides
		; _M.PreventSleep := new Module__PreventSleep
	} catch e {
		MsgBox, 16, % __Settings.app.name, % "Exception thrown!`n`nwhat: " e.what "`nfile: " e.file . "`nline: " e.line "`nmessage: " e.message "`nextra: " e.extra
	}

	return _M
}


drawMenu(part := ""){
	local _A := __Settings.app
	local _T := __Settings.app.tray
	local _I := __Settings.app.tray.icon
	local _D := __Settings.app.debugging
	doMenuItem__about := func("doMenuItem__about").bind()
	doMenuItem__editIni := func("doMenuItem__editIni").bind()
	doMenuItem__exit := func("doMenuItem__exit").bind()
	if (part == "init"){
		menu tray, noStandard
		menu tray, icon, % _I.location, % (_I.index == 0 ? "" : _I.index)
		menu tray, tip, % _T.traytip
		menu tray, add, % _T.title, doMenuItem__about
		menu tray, icon, % _T.title, % _T.icon.location, (_T.index == 0 ? "" : _T.index), 26
		menu tray, default, % _T.title
		menu tray, add
	} else if (part == "exit"){
		menu settingsSub, add, % "Edit config...", doMenuItem__editIni
		menu tray, add
		menu tray, add, % "Settings...", :settingsSub
		menu tray, add, % "About...", doMenuItem__about
		menu tray, add, % "Exit", doMenuItem__exit
		if (_D.enabled){
			menu tray, add
			menu tray, standard
		}
	}
}


doMenuItem__about(){
	local _A := __Settings.app
	local _T := __Settings.app.tray
	msgBox 4160, % _T.title, % ""
		. "" . _A.name . "`n"
		. "v" . _A.build.version . " (" . _A.build.date . ")" . "`n`n"
		. "Repo @ " . _A.build.repo . "`n"
		. "AutoHotkey @ autohotkey.com`n"
		. "AutoCorrect @ github.com/cdelahousse`n"
		. "Icons @ flaticon.com/authors/juicy-fish"
}


doMenuItem__editIni(){
	local _A := __Settings.apps
	runwait % _A["Notepad"].location . " user_settings.ini"
	if (errorLevel == 0){
		reload
	}
}


doMenuItem__exit:
	exitApp
return


doMenuItem__null:
return


; Reload this script on save
#ifWinActive `.ahk
	~^s::
		{
			winGetTitle strTitle, A
			ifInString strTitle, %A_ScriptName%
			{
				timeout := 500
				sleep % timeout
				reload
			}
			return
		}
#ifWinActive





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
