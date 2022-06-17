;// Compile-time settings for "File Properties > Details" panel:
;@Ahk2Exe-SetName Desktop Helper
;@Ahk2Exe-SetDescription Desktop Helper
;@Ahk2Exe-SetFileVersion 1.4.8
;@Ahk2Exe-SetCopyright Rob McInnes <rob.mcinnes@cirieno.co.uk>
;@Ahk2Exe-SetLanguage 0x0809
;@Ahk2Exe-SetOrigFilename desktop-helper.ahk
;// @Ahk2Exe-ExeName C:\Program Files (user)\Desktop Helper\Desktop Helper.exe
;@Ahk2Exe-SetMainIcon icons\cog_1.ico


;#region AUTO_EXECUTE
	#clipboardTimeout 1500     ;// how long the script keeps trying to access the clipboard
	; #keyHistory 20     ;// keyboard and mouse events displayed by the KeyHistory window
	; #hotstring NoMouse
	#noEnv     ;// prevents empty variables from being looked up
	#persistent
	#singleInstance force
	#winActivateForce
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

	groupAdd _grpExplorerWindows, ahk_class ExploreWClass
	groupAdd _grpExplorerWindows, ahk_class CabinetWClass
	groupAdd _grpExplorerWindows, ahk_class Progman

	#Include utils\Utils.ahk

	;/* GLOBAL SETTINGS OBJECT */
	global _modules := {}
	global _objSettings := {}

	_objSettings.app := {0:0
		, name: "Desktop Helper"
		, author: { name: "Rob McInnes" , email: "rob.mcinnes@cirieno.co.uk" , company: "Cirieno Ltd" }
		, build: { version: "1.4.8" , date: "2022-06" }}

	_objSettings.app.tray := {0:0
		, title: _objSettings.app.name
		, tooltip: (A_IsCompiled ? _objSettings.app.name : A_ScriptName)
		, icon: { location: (A_IsCompiled ? A_ScriptName : "icons\cog_2.ico"), index: -0 }
		, useToast: getIniVal("Tray\useToast", true)
		, msgTimeout: 2000 }

	_objSettings.app.environment := {0:0
		, company: getIniVal("Environment\company", "Cirieno Ltd")
		, computerName: A_ComputerName
		, user: A_UserName
		, domain: getAppEnvironmentDomain() }

	_objSettings.app.debugging := {0:0
		, enabled: getIniVal("AppDebugging\enabled", !A_IsCompiled)
		, active: getIniVal("AppDebugging\active", !A_IsCompiled)
		, notify: getIniVal("AppDebugging\notify", true)
		, menuLabel: "Debugging mode" }

	_objSettings.apps := {0:0
		, "Everything Search": { location: "C:\Program Files\Everything Search\Everything.exe" }
		, "Notepad++": { location: "C:\Program Files\Notepad++\notepad++.exe" } }

	; if instr(_objSettings.app.environment.company, "Saga") {
	; 	_objSettings.app.author.email := "rob.mcinnes@saga.co.uk"
	; }

	global __D := _objSettings.app.debugging
	appDebugging_set((__D.enabled && __D.active), false)

	#Include modules\disable-proxy.module.ahk
	#Include modules\enable-proxy-overrides.module.ahk
	#Include modules\prevent-sleep.module.ahk
	#Include modules\set-volume.module.ahk
	#Include modules\set-volume-mouse-wheel.module.ahk
	#Include modules\swap-mouse-buttons.module.ahk
	_modules.DisableProxy := new Module__DisableProxy
	_modules.EnableProxyOverrides := new Module__EnableProxyOverrides
	_modules.PreventSleep := new Module__PreventSleep
	_modules.SetVolume := new Module__SetVolume
	_modules.SetVolumeWithMouseWheel := new Module__SetVolumeWithMouseWheel
	_modules.SwapMouseButtons := new Module__SwapMouseButtons

	drawMenu()
return
;#endregion AUTO_EXECUTE



;#region DRAW_MENU
drawMenu() {
	menu tray, noStandard
	drawMenuItem__title(_objSettings.app.tray)
	_modules.DisableProxy.drawMenuItems()
	_modules.EnableProxyOverrides.drawMenuItems()
	; TODO: maybe put these two ^^ under the submenu :Proxy
	_modules.PreventSleep.drawMenuItems()
	_modules.SwapMouseButtons.drawMenuItems()
	_modules.SetVolume.drawMenuItems()
	; _modules.SetVolumeWithMouseWheel.drawMenuItems()
	; TODO: maybe put these two ^^ under the submenu :Volume and remove subclassing
	drawMenuItem__exit(_objSettings.app.debugging)

	_I := _objSettings.app.tray.icon
	menu tray, icon, % _I.location, % (_I.index == 0 ? "" : _I.index)
	menu tray, tip, % _objSettings.app.tray.tooltip
}
doMenuItem__null:
	return
doMenuItem__exit:
	exitApp
	return
doMenuItem__reload:
	return
doMenuItem__about:
	_S := _objSettings.app
	msgBox 4160, % _S.tray.title, % ""
		. "" . _S.author.name . " <" . _S.author.email . ">" . "`n"
		. "v" . _S.build.version . " (" . _S.build.date . ")" . "`n"
		. (!A_IsCompiled ? "un" : "") . "compiled AutoHotkey script" . "`n"
		. "`n"
		. "AutoCorrect from <https://github.com/cdelahousse>"
	return
;#endregion DRAW_MENU



;#region DRAW_MENU_ITEMS
drawMenuItem__title(_S) {
	menu tray, add, % _S.title, doMenuItem__about
	menu tray, icon, % _S.title, % _S.icon.location, (_S.index == 0 ? "" : _S.index), 26
	menu tray, default, % _S.title
	menu tray, add
}
drawMenuItem__appDebugging(_S) {
	if (_S.enabled) {
		menu tray, add
		menu tray, add, % _S.menuLabel, appDebugging_toggle
		__tickMenuItem("tray", (_S.active ? "check" : "uncheck"), _S.menuLabel)
	}
}
drawMenuItem__exit(_S) {
	menu tray, add
	menu tray, add, % "About...", doMenuItem__about
	if (_S.enabled) {
		drawMenuItem__appDebugging(_S)
		menu tray, add
		menu tray, standard
	} else {
		menu tray, add, % "Exit", doMenuItem__exit
	}
}
;#endregion DRAW_MENU_ITEMS



;#region APP_DEBUGGING
appDebugging_toggle() {
	_S := _objSettings.app.debugging
	appDebugging_set(!_S.active, _S.notify)
}
appDebugging_set(action := false, notify := false) {
	_S := _objSettings.app.debugging
	_S.active := action
	__tickMenuItem("tray", (_S.active ? "check" : "uncheck"), _S.menuLabel)
	__notify("AppDebugging", notify, _S.active)
	; tooltipMsg("AppDebugging is now " . (_S.active ? "ON" : "OFF"), , _objSettings.app.tray.msgTimeout)
}
;#endregion APP_DEBUGGING



;#region GLOBAL_HOTKEYS
#Include utils\AutoCorrect.ahk
#Include utils\UserCorrect.ahk
#Include utils\UserCorrect_p.ahk
;#endregion GLOBAL_HOTKEYS



;//
__tickMenuItem(menuName, action, labelName) {
	menu % menuName, useErrorLevel
	menu % menuName, % action, % labelName
	menu % menuName, useErrorLevel, off
}


__notify(module := "", notify := false, active := false, forceFormat := 0) {
	if (notify || (__D.enabled && __D.active)) {
		_T := _objSettings.app.tray
		sendMsg(module . " is " . (active ? "ON" : "OFF"), module, _T.msgTimeout, (forceFormat ? forceFormat : (_T.useToast ? ahkMsgFormatToast : ahkMsgFormatMsgbox)))
	}
}
;//



























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
		;  tooltipMsg("Reloading script: " . A_ScriptName, , timeout)
		sleep % timeout
		reload
		}
	return
	}
 #ifWinActive
