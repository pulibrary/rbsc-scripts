;Macro to conduct ISBN search in Voyager and populate Access DB field based on search result

#include <Constants.au3>
#include <file.au3>
#include <MsgBoxConstants.au3>


;Run("C:/Voyager/Catalog.exe")
;WinWaitActive("Voyager Cataloging")
;Send("rh")
;Send("{TAB}")
;Send("68573556")
;Send("{TAB}")
;Send("!o")
;Sleep(2000)

;bring Voyager to the foreground, open boolean search, open dialog box.
WinActivate("Voyager Cataloging")
WinWaitActive("Voyager Cataloging")
WinSetState("Voyager Cataloging", "", @SW_SHOW)
Send("!r")	;Record menu
Send("s")	;Search
WinActivate("Search")
Send("!k")	;Keyword tab
Send("!o")	;boolean search
Send("!f")	;activate text box
Send("!a")	;clear all
While 1
$verify = MsgBox(4, "Do you have an ISBN/ISSN?", "")
If $verify = 6 Then
	;validate ISBN input
    Local $ISBNinput = StringRegExpReplace(InputBox("ISBN/ISSN", "Enter the ISBN/ISSN."), "-", "")
	If StringRegExp($ISBNinput, "(?i)\d$|x$") Then
		If StringLen($ISBNinput)==10 Then
			Send($ISBNinput)
			ExitLoop
		ElseIf StringLen($ISBNinput)==13 Then
			Send($ISBNinput)
			ExitLoop
		Else
			MsgBox(0, "Check your input!", "ISBN/ISSN must be 10 or 13 characters long. Please try again.")
			ContinueLoop ;start over
		EndIf
	Else
		MsgBox(0, "Check your input!", "ISBN/ISSN must end with a digit or the letter X. Please try again.")
		ContinueLoop ;start over
	EndIf
ElseIf $verify = 7 Then
	;massage keyword input
	Local $KWinput = StringRegExpReplace(InputBox("Keyword Search", "Enter a keyword or phrase."), " ", " AND ")
	Send($KWinput)
	ExitLoop
EndIf
WEnd
Send("!s")
Sleep(500)
;if single match, grab bibid, switch back to Access, find green field and send
If ControlCommand("Voyager Cataloging", "", 32768, "IsEnabled") Then
	Local $bibid = StringRegExpReplace(StringRegExpReplace(ControlGetText("Voyager Cataloging", "", 32768), "^Bib\s\(*", ""), "\)*\s.*", "")
	;MsgBox(0, "", $bibid)
	Send("^{F4}")
	WinActivate("Microsoft Access - Derrida2014 : Database (Access 2007 - 2010)")
	MouseClick("", 1073, 247)
	Local $color = PixelGetColor(1073, 247)
	If $color = 2273612 Then
		Send($bibid)
		Else
			MsgBox(0, "error", "unable to acquire target")
	EndIf
;if multiple matches, switch back to Access, find green field and send "multiples"
ElseIf ControlCommand("Titles Index", "", 4, "IsEnabled") Then
	MsgBox(0, "Error: Multiples", "multiples found")
	Send("^{F4}")
	WinActivate("Microsoft Access - Derrida2014 : Database (Access 2007 - 2010)")
	MouseClick("", 1073, 247)
	Local $color = PixelGetColor(1073, 247)
	If $color = 2273612 Then
		Send("multiples")
		Else
			MsgBox(0, "error", "unable to acquire target")
	EndIf
;if no matches, switch back to Access, find green field and send "none_found"
ElseIf ControlCommand("Voyager", "No matches were found for this search", "", "IsEnabled") Then
	Sleep(1000)
	Send("{ENTER}")
	Send("!c")
	WinActivate("Microsoft Access - Derrida2014 : Database (Access 2007 - 2010)")
	MouseClick("", 1073, 247)
	Local $color = PixelGetColor(1073, 247)
	If $color = 2273612 Then
		Send("none_found")
		Else
			MsgBox(0, "error", "unable to acquire target")
	EndIf
;if none of the above, open error message
Else
	WinSetState("Voyager Cataloging", "", @SW_SHOW)
	MsgBox(0, "", "something's wrong")
EndIf


