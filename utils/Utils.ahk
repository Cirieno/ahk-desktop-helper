;#region
getIniVal(nodeName := "", defaultVal := "") {
	arr := strSplit(nodeName, "\")
	IniRead nodeVal, % A_WorkingDir . "\user_settings.ini", % arr[1], % arr[2]
	if (nodeVal == "ERROR") {
		return defaultVal
	}
	if (isBoolean(defaultVal) && !isBoolean(nodeVal)) {
		; msgbox % nodeName . " = " . nodeVal
		if isTruthy(nodeVal) {
			return true
		} else if isFalsy(nodeVal) {
			return false
		} else {
			return defaultVal
		}
	}
	; if ((defaultVal is number) && (nodeVal is not number)) {
	; 	return defaultVal
	; }
	return nodeVal
}
;#endregion



;#region
isBoolean(val) {
	return (val == 1 || val == 0)
}
isTruthy(val) {
	StringUpper val, val
	return (val == 1 || val == "1" || val == "T" || val == "TRUE" || val == "ENABLED" || val == "ACTIVE" || val == "ON")
}
isFalsy(val) {
	StringUpper val, val
	return (val == 0 || val == "0" || val = "" || val == "F" || val == "FALSE" || val == "DISABLED" || val == "DEACTIVE" || val == "INACTIVE" || val == "OFF")
}
isInArray(haystack, needle) {
	for ii, val in haystack {
		if (val == needle) {
			return true
		}
	}
	return false
}



;#region CUSTOM TOOLTIP / MSGBOX / TOAST
/**
 * @param {string} text - Body text
 * @param {string} [title] - Headline text
 * @param {string} [timeout=5000] - Timeout
 */
sendMsg(text := "", title := "", timeout := 5000, ahkMsgFormat := 0) {
	; switch ahkMsgFormat {
	; 	case ahkMsgFormatTooltip: {
	; 			tooltipMsg(text, title, timeout)
	; 		}
	; 	case ahkMsgFormatMsgbox: {
	; 			msgboxMsg(text, title, timeout)
	; 		}
	; 	case ahkMsgFormatToast: {
	; 			toastMsg(text, title)
	; 		}
	; }
}
__sendMsg(text := "", title := "", timeout := 5000, ahkMsgFormat := 0){
	; sendMsg(text, title, timeout, ahkMsgFormat)
}
tooltipMsg(text := "", title := "", timeout := 5000, id := 1) {
	local _A := __Settings.app
	local _T := __Settings.app.tray

	tooltip % _T.traytip . "`n" . (strLen(title) > 0 ? title . "`n" : "") . text,,, % id
	setTimer clearTooltip, % (timeout * -1)
}
clearTooltip(){
	tooltip
}
msgboxMsg(text := "", title := "", timeout := 5000) {
	; title := (strlen(title) > 0 ? title : _objSettings.app.title)
	; msgBox 8192, % title, % text, % timeout
}
toastMsg(text := "", title := "", timeout := 5000) {
	; traytip % (strLen(title) ? title : null), % text
}
;#endregion CUSTOM TOOLTIP + MSGBOX + TOAST



;//

; //



; //
getAppEnvironmentDomain(){
	envGet val, USERDOMAIN
	return val
}
; //


; SetTimer, % WatchCursor, 100
WatchCursor(){
	MouseGetPos,,, id, control
	WinGetTitle, title, ahk_id %id%
	WinGetClass, class, ahk_id %id%
	ToolTip, ahk_id %id%`nahk_class %class%`n%title%`nControl: %control%
}
