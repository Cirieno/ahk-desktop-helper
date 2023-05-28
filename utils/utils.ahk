;#region []
; TODO: check if file exists, if not, create it
getIniVal(nodeName := "", defaultVal := "") {
	arr := strSplit(nodeName, "\")
	; TODO: check section and attr exists
	; MsgBox(A_WorkingDir . "\user_settings.ini" . arr[1] . arr[2])
	nodeVal := IniRead(A_WorkingDir . "\user_settings.ini", arr[1], arr[2])
	;IniRead nodeVal, % A_WorkingDir . "\user_settings.ini", % arr[1], % arr[2]
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
;#endregion []


;#region []
isBoolean(val) {
	return (val == 1 || val == 0)
}


isTruthy(val) {
	val := StrUpper(val)
	return (val == 1 || val == "1" || val == "T" || val == "TRUE" || val == "ENABLED" || val == "ACTIVE" || val == "ON")
}


isFalsy(val) {
	val := StrUpper(val)
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


join(params, sep) {
	for index, param in params {
		str .= param . sep
	}
	return SubStr(str, 1, -StrLen(sep))
}
;#endregion []


;#region [CUSTOM TOOLTIP / MSGBOX / TOAST]
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
	; 			customMsgBox(text, title, timeout)
	; 		}
	; 	case ahkMsgFormatToast: {
	; 			toastMsg(text, title)
	; 		}
	; }
}


__sendMsg(text := "", title := "", timeout := 5000, ahkMsgFormat := 0) {
	; sendMsg(text, title, timeout, ahkMsgFormat)
}


tooltipMsg(text := "", title := "", timeout := 5000, id := 1) {
	local _A := _Settings.app
	local _T := _Settings.app.tray

	ToolTip(_T.traytip . "`n" . (strLen(title) > 0 ? title . "`n" : "") . text, , , id)
	SetTimer(clearTooltip, (timeout * -1))

	;tooltip % _T.traytip . "`n" . (strLen(title) > 0 ? title . "`n" : "") . text,,, % id
	;setTimer clearTooltip, % (timeout * -1)
}


clearTooltip() {
	ToolTip()
}


customMsgBox(text := "", title := "", timeout := 5000) {
	; title := (strlen(title) > 0 ? title : _objSettings.app.title)
	; msgBox 8192, % title, % text, % timeout
}


toastMsg(text := "", title := "", timeout := 5000) {
	; traytip % (strLen(title) ? title : null), % text
}
;#endregion [CUSTOM TOOLTIP + MSGBOX + TOAST]


;#region []
getAppEnvironmentDomain() {
	val := EnvGet("USERDOMAIN")
	return val
}
;#endregion []


; SetTimer, % WatchCursor, 100
; WatchCursor(){
; 	MouseGetPos,,, id, control
; 	WinGetTitle, title, ahk_id %id%
; 	WinGetClass, class, ahk_id %id%
; 	ToolTip, ahk_id %id%`nahk_class %class%`n%title%`nControl: %control%
; }


; OLD OLD OLD (but not necessarily wrong)
; -------------------------------------


;#region CUSTOM TOOLTIP / MSGBOX / TOAST
/**
 * @param {string} text - Body text
 * @param {string} [title] - Headline text
 * @param {string} [timeout=5000] - Timeout
 */
; tooltipMsg(text := "", title := "", timeout := 5000, id := "") {
; 	tooltip % "" . "=[" . _objSettings.app.title . "]" . "`n" . (strLen(title) > 0 ? title . "`n" : "") . text,,,
; 		setTimer clearTooltip, % (timeout * -1)
; }
; customMsgBox(text := "", title := "", timeout := 5000) {
; 	title := (strlen(title) > 0 ? title : _objSettings.app.title)
; 	msgBox 8192, % title, % text, % timeout
; }
; toastMsg(text := "", title := "", timeout := 5000) {
; 	TrayTip % (strLen(title) ? title : null), % text, % (timeout / 1000)
; }
; sendMsg(text := "", title := "", timeout := 5000, forceTooltip := false) {
; 	if (forceTooltip || !_objSettings.app.tray.useToast) {
; 		tooltipMsg(text, title, timeout)
; 	} else {
; 		toastMsg(text, title)
; 	}
; }
;#endregion CUSTOM TOOLTIP + MSGBOX + TOAST


; ;//
; tickMenuItem(menuName, action, labelName) {
; 	menu % menuName, useErrorLevel
; 	menu % menuName, % action, % labelName
; 	menu % menuName, useErrorLevel, off
; }
; ;//
; getAppEnvironmentDomain() {
; 	envGet val, USERDOMAIN
; 	return val
; }
