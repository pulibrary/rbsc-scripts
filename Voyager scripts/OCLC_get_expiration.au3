#include <Constants.au3>
#include <file.au3>
#include <Date.au3>
#include <AutoItConstants.au3>
#include <FileConstants.au3>

; assuming OCLC is open and logged in already
; set OCLC on top
WinActivate("OCLC Connexion")
WinWaitActive("OCLC Connexion")
WinSetState("OCLC Connexion", "", @SW_MAXIMIZE)
WinSetOnTop("OCLC Connexion", "", 1)
;open Authorities Online Save File
Send("!{F3}")
Sleep(500)
;retrieve all by replace date
Send("{TAB}")
Send("r")
Send("{ENTER}")
;get number of results
WinActivate("OCLC Connexion", "Your search")
WinWaitActive("OCLC Connexion", "Your search")
$results = StringRegExpReplace(WinGetText("OCLC Connexion", "Your search"), "([\D\S]*?search resulted in\s)([\D\S]+?)(\smatches[\D\S]*)", "$2")
;test $results
;MsgBox(0, "", $results)
;close dialog
Send("{ENTER}")
;compute number of screens to copy
Local $iterations = Number($results) / 100
;test $iterations
;MsgBox(0, "", $iterations)
While $iterations > 0
	;select all
	MouseClick("right")
	Send("a")
	Sleep(300)
	;copy
	MouseClick("right")
	Send("c")
	Sleep(300)
	;paste to file
	Send(FileWriteLine(FileOpen("oclcSaveFile.txt", $FO_APPEND + $FO_UTF8), ClipGet()))
	Sleep(300)
	;open next 100
	Send("!v")
	Sleep(300)
	Send("v")
	Sleep(300)
	Send("^!X")
	Sleep(300)
	;start over
	$iterations = $iterations - 1
WEnd
;close last table
Send("!w")
Send("w")
WinSetOnTop("OCLC Connexion", "", 0)

Exit
