;// Compile-time settings for "File Properties > Details" panel:
;@Ahk2Exe-SetName Desktop Helper
;@Ahk2Exe-SetDescription Desktop Helper
;@Ahk2Exe-SetFileVersion 1.6.2
;// Ahk2Exe-SetCopyright Rob McInnes <rob.mcinnes@cirieno.co.uk>
;@Ahk2Exe-SetCopyright Cirieno Ltd
;@Ahk2Exe-SetLanguage 0x0809
;@Ahk2Exe-SetOrigFilename desktop-helper.ahk
;@Ahk2Exe-ExeName C:\Program Files (user)\Desktop Helper\Desktop Helper.exe
;@Ahk2Exe-SetMainIcon icons\cog-wheel-4.ico


;#region [AUTORUN]
#clipboardTimeout 1500 ;// how long the script keeps trying to access the clipboard
; #keyHistory 20     ;// keyboard and mouse events displayed by the KeyHistory window
; #hotstring NoMouse
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
; sendMode Input
; setBatchLines -1
; setControlDelay 0
; setKeyDelay 0
; setMouseDelay 0
; setWinDelay 0
setTitleMatchMode 2
setTitleMatchMode slow
; stringCaseSense off
setCapsLockState off
setNumLockState on
setScrollLockState off
setWorkingDir %A_ScriptDir%

global ahkBoolean := 11
global ahkInteger := 3
global ahkString := 8
global ahkMsgFormatTooltip := 1
global ahkMsgFormatMsgbox := 2
global ahkMsgFormatToast := 3

global __Settings := {}
populateGlobalVars()

drawMenu()
drawMenuItem__title()

global __Modules := { loaded: {}}
; #Include *i .\modules\disable-proxy.module.ahk
; #Include *i .\modules\enable-proxy-overrides.module.ahk
; #Include *i .\modules\prevent-sleep.module.ahk
#Include *i .\modules\set-volume.module.ahk
#Include *i .\modules\set-volume-mouse-wheel.module.ahk
#Include *i .\modules\swap-mouse-buttons.module.ahk
#Include *i .\modules\user-hotkeys.module.ahk
; __Modules.DisableProxy := new Module__DisableProxy
; __Modules.EnableProxyOverrides := new Module__EnableProxyOverrides
; __Modules.PreventSleep := new Module__PreventSleep
if (__Modules.loaded.SetVolume){
	__Modules.SetVolume := new Module__SetVolume
}
if (__Modules.loaded.SetVolumeMouseWheel){
	__Modules.SetVolumeMouseWheel := new Module__SetVolumeMouseWheel
}
if (__Modules.loaded.SwapMouseButtons){
	__Modules.SwapMouseButtons := new Module__SwapMouseButtons
}
if (__Modules.loaded.UserHotkeys){
	__Modules.UserHotkeys := new Module__UserHotkeys
}

drawMenuItem__exit()
return
;#endregion [AUTORUN]
#Include .\utils\utils.ahk
#Include .\utils\AutoCorrect.ahk
; #Include .\utils\UserCorrect_p.ahk


populateGlobalVars(){
	__Settings.app := {0:0
		, name: "Desktop Helper"
		, author: { name: "Rob McInnes", email: "rob.mcinnes@cirieno.co.uk", company: "Cirieno Ltd" }
		, build: { version: "1.6.1", date: "2022-06", repo: "github.com/cirieno/desktop-helper" } }

	__Settings.app.tray := {0:0
		, title: __Settings.app.name
		, traytip: "[=" . __Settings.app.name . "]"
		, icon: { location: (A_IsCompiled ? A_ScriptName : "icons\cog-wheel-3.ico"), index: -0 }
		, useToast: getIniVal("Tray\useToast", true)
		, msgTimeout: 2000 }

	__Settings.app.environment := {0:0
		, company: getIniVal("Environment\company", __Settings.app.author.company)
		, computerName: A_ComputerName
		, user: A_UserName
		, domain: getAppEnvironmentDomain() }

	__Settings.app.debugging := {0:0
		, enabledOnInit: getIniVal("AppDebugging\enabled", !A_IsCompiled)
		, activeOnInit: getIniVal("AppDebugging\active", !A_IsCompiled)
		, notifyUser: getIniVal("AppDebugging\notify", true)
		, menuLabel: "Debugging mode" }
	__Settings.app.debugging.enabled := (__Settings.app.debugging.activeOnInit ? true : __Settings.app.debugging.enabledOnInit)
	__Settings.app.debugging.active := (__Settings.app.debugging.enabled && __Settings.app.debugging.activeOnInit)
	; appDebugging_set((__D.enabled && __D.active), false)

	__Settings.apps := {0:0
		, "Notepad": { location: A_WinDir . "\notepad.exe" }
		, "Everything Search": { location: "C:\Program Files\Everything Search\Everything.exe" } }
}


;#region [MENU]
drawMenu(){
	local _T := __Settings.app.tray
	local _I := __Settings.app.tray.icon

	menu tray, noStandard
	menu tray, icon, % _I.location, % (_I.index == 0 ? "" : _I.index)
	menu tray, tip, % _T.traytip
}


drawMenuItem__title(){
	local _T := __Settings.app.tray

	doMenuItem__about := func("doMenuItem__about").bind()

	menu tray, add, % _T.title, doMenuItem__about
	menu tray, icon, % _T.title, % _T.icon.location, (_T.index == 0 ? "" : _T.index), 26
	menu tray, default, % _T.title
	menu tray, add
}


drawMenuItem__exit(){
	local _D := __Settings.app.debugging

	doMenuItem__about := func("doMenuItem__about").bind()
	doMenuItem__editAutoCorrect := func("doMenuItem__editAutoCorrect").bind()
	doMenuItem__editIni := func("doMenuItem__editIni").bind()
	doMenuItem__exit := func("doMenuItem__exit").bind()
	doMenuItem__reload := func("doMenuItem__reload").bind()

	menu settingsSub, add, % "Edit config...", doMenuItem__editIni
	; menu settingsSub, add, % "Edit hotkeys...", doMenuItem__editUserHotkeys
	; menu settingsSub, add, % "Reload", doMenuItem__reload

	menu tray, add
	menu tray, add, % "Settings...", :settingsSub
	menu tray, add
	menu tray, add, % "About...", doMenuItem__about
	if (_D.enabled) {
		; drawMenuItem__appDebugging(_S)
		menu tray, add
		menu tray, standard
	} else {
		menu tray, add, % "Exit", doMenuItem__exit
	}
}


doMenuItem__about(){
	local _A := __Settings.app
	local _T := __Settings.app.tray

	msgBox 4160, % _T.title, % ""
	. "" . _A.name . "`n"
	. "v" . _A.build.version . " (" . _A.build.date . ")" . "`n"
	. "`n"
	; . (!A_IsCompiled ? "un" : "") . "compiled AutoHotkey script" . "`n"
	. "Repo @ " . _A.build.repo . "`n"
	. "AutoHotkey @ autohotkey.com`n"
	. "AutoCorrect @ github.com/cdelahousse`n"
	. "Icons @ flaticon.com/authors/juicy-fish"
}


doMenuItem__editIni(){
	local _A = __Settings.apps

	runwait % _A["Notepad"].location . " user_settings.ini"
	if (errorLevel == 0) {
		reload
	}
}


doMenuItem__reload:
	reload
	return


doMenuItem__exit:
    exitApp
	return


doMenuItem__null:
	return
















; ;#region [DEBUGGING]
; appDebugging_toggle(){
; 	_S := __Settings.app.debugging
; 	appDebugging_set(!_S.active, _S.notify)
; }
; appDebugging_set(action := false, notify := false) {
; 	_S := __Settings.app.debugging
; 	_S.active := action
; 	__tickMenuItem("tray", (_S.active ? "check" : "uncheck"), _S.menuLabel)
; 	__notify("AppDebugging", notify, _S.active)
; 	; tooltipMsg("AppDebugging is now " . (_S.active ? "ON" : "OFF"),, __Settings.app.tray.msgTimeout)
; }
; ;#endregion

; ;#region [GLOBAL_HOTKEYS]
; ;#endregion

; ;//
; __tickMenuItem(menuName, action, labelName) {
; 	menu % menuName, useErrorLevel
; 	menu % menuName, % action, % labelName
; 	menu % menuName, useErrorLevel, off
; }

; __notify(moduleName := "", notify := false, active := false, forceFormat := 0) {
; 	_D := __Settings.app.debugging
; 	if (notify || (_D.enabled && _D.active)) {
; 		_T := __Settings.app.tray
; 		sendMsg(moduleName . " is " . (active ? "ON" : "OFF"), moduleName, _T.msgTimeout, (forceFormat ? forceFormat : (_T.useToast ? ahkMsgFormatToast : ahkMsgFormatMsgbox)))
; 	}
; }
; ;//

/**
 * Reload this script on save
*/
#ifWinActive `.ahk
    ~^s::
        {
            winGetTitle strTitle, A
            ifInString strTitle, %A_ScriptName%
            {
                timeout := 500
                ;  tooltipMsg("Reloading script: " . A_ScriptName,, timeout)
                sleep % timeout
                reload
            }
            return
        }
#ifWinActive

; groupAdd _grpExplorerWindows, ahk_class ExploreWClass
; groupAdd _grpExplorerWindows, ahk_class CabinetWClass
; groupAdd _grpExplorerWindows, ahk_class Progman



; drawMenuItem__appDebugging(_S) {
; 	if (_S.enabled) {
; 		menu tray, add
; 		menu tray, add, % _S.menuLabel, appDebugging_toggle
; 		__tickMenuItem("tray", (_S.active ? "check" : "uncheck"), _S.menuLabel)
; 	}
; }
