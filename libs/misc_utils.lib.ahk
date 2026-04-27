/**********************************************************
 * @type {AHKLibrary}
 * @name Misc Utils
 * @author Rob McInnes (Cirieno)
 * @file misc_utils.lib.ahk
 *********************************************************/


MsgboxJoin(msg) {
	if (isArray(msg)) {
		return msg.join("`n")
	}
	return msg
}


checkMemoryUsage() {
	pid := DllCall("GetCurrentProcessId")
	h := DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
	DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
	DllCall("CloseHandle", "Int", h)
	return
}


; Reload the script on save while editing it in debug mode.
; #HotIf __DEBUGGING && WinActive("`.ahk",)
; ~^s:: {
; 	title := WinGetTitle("A")
; 	if (InStr(title, A_ScriptName)) {
; 		Sleep(500)
; 		Reload()
; 	}
; }
; #HotIf
