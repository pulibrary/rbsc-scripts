;This macro changes a string in the enum field

#include <Constants.au3>
#include <file.au3>

Run("C:/Voyager/Catalog.exe")
WinWaitActive("Voyager Cataloging")
Send("rh")
Send("{TAB}")
Send("68573556")
Send("{TAB}")
Send("!o")
Sleep(2000)
Send("!r")
;Send("s")
;WinActivate("Search")
;ControlClick("Search", "", 14)
;Send("c")
;Send("{TAB 2}")
;Send("C0100")
;Send("!s")
;Sleep(1000)
;Send("!o")
;Sleep(1000)
;Send("^t")
;Send("!o")

Send("{i 2}")

$file = FileOpen("C0100.txt", 0)

While 1
    $line = FileReadLine($file)
    If @error = -1 Then ExitLoop
    Send($line)
	Send("!r")
	WinActivate("Voyager Cataloging")
	ControlClick("Voyager Cataloging", "", 13)
	$string = ControlGetText("Voyager Cataloging", "", 13)
	;MsgBox(0, "test", "variable returns:" & $string)
	;Send(StringReplace($string, "v.", "volume"))
	;$substring = StringInStr($string, "v.")
	;MsgBox(0, "test", "substring occurs at position" & $substring)
	If StringRegExp($string, "Volume ") Then
	ControlSetText("Voyager Cataloging", $string, 13, "")
	Send(StringRegExpReplace($string, "Volume ", "Volume L"))

	EndIf
	;Send("Box 1")
	Send("^q")
	Sleep(1000)
	Send("{ENTER}")
	Send("!r")
	Send("{i 2}")
WEnd
FileClose($file)