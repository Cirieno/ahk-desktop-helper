;// * = an ending character is not required to trigger
;// O = remove the trigger character
;// C = case sensitive
;// R = send raw
;// B0 = turn off backspacing
; https://www.autohotkey.com/docs/Hotstrings.htm

:*:adevtnure::adventure
:*:baords::boards
:*:boolaen::boolean
:*:breif::brief
:*:broswer::browser
:*:champaign::champagne
:*:chatchup::catch-up
:*:corect::correct
:*:deisgn::design
:*:deisng::design
:*:dekstop::desktop
:*:en dif::end if
:*:fasle::false
:*:flase::false
:*:haedline::headline
:*:helpdeks::helpdesk
:*:herlper::helper
:*:in stall::install
:*:itneger::integer
:*:javascrtip::javascript
:*:jquesy::jquery
:*:maring::margin
:*:ocming::coming
:*:oslid::solid
:*:peroprty::property
:*:quesystring::querystring
:*:retrun::return
:*:satrted::started
:*:statsu::status
:*C:GDRP::GDPR
; //
:*://shrug::{U+02DC}\_({U+30C4})_/{U+02DC}
:*://date::
	send % A_YYYY . "-" . A_MM . "-" . A_DD
	return
:*://time::
	send % A_Hour . ":" . A_Min
	return

; #A:: return
; #B:: return
; #C:: return
; #D:: return
; #F:: return
; #G:: return
; #H:: return
; #I:: return
; #J:: return
; #K:: return
; #L:: return
; #M:: #D     ;// minimise all windows
#N:: run % _objSettings.apps["Notepad++"].location
; #O:: return
; #P:: return
; #Q:: return
; #S:: swapMouseButtons_toggle(true)
#S:: run % _objSettings.apps["Everything Search"].location
; #T:: run % gSettings.apps["Task Manager"].exe_path
; #U:: return
; #V:: run % gSettings.apps["VS Code"].exe_path
; #W:: return
; #Y:: return
; #Z:: return
; +#Up::supermaxWindow()

#IfWinActive ahk_exe excel.exe
+enter:: send !{enter}	;// hard line-breaks (ALT-enter)
#ifWinActive ahk_exe grepwin.exe
^w:: winClose A
#ifWinActive ahk_group _grpExplorerWindows
F1::return	;// cancel help
F3::return	;// cancel find
#ifWinActive
