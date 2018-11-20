#include <Constants.au3>
#include <file.au3>
#include <Date.au3>
#include <AutoItConstants.au3>
#include <Excel.au3>
#RequireAdmin

; Create application object
Local $oExcel = _Excel_Open()

;maximize Excel and set to stay on top
WinActivate("Microsoft Excel")
WinWaitActive("Microsoft Excel")
WinSetState("Microsoft Excel", "", @SW_MAXIMIZE)
WinSetOnTop("Microsoft Excel", "", 1)

;open Excel file and parse tab-delimited text to columns
;this method doesn't parse to UTF-8
;~ Local $sTextFile = @ScriptDir & "\oclcSaveFile.txt"
;~ Global $oWorkbook = _Excel_BookOpenText($oExcel, $sTextFile, Default, $xlDelimited, Default, True, "	")
;~ Sleep(500)

;open Excel file and parse tab-delimited text to columns
Global $oWorkbook = _Excel_BookNew($oExcel)
Send("!f")
Send("o")

Sleep(1000)
Local $file = "\\Lib-tsserver\rbsc\Technical Services\Heberlein\Projects\Authorities Committee\oclcSaveFile.txt"
Send($file, 1)
Sleep(1000)
Send("!o")
Sleep(1000)
Send("!o")
Sleep(1000)
Send("{END}")
Sleep(1000)
Send("{UP 8}")
Send("!n")
Sleep(1000)
Send("!n")
Sleep(1000)
Send("!f")
Sleep(1000)

;find and delete blank rows
Send("{F5}")
Sleep(300)
Send("!s")
Sleep(300)
Send("k")
Sleep(300)
Send("{ENTER}")
Sleep(300)
If ControlCommand("Microsoft Excel", "No cells were found", 4001, "IsEnabled") Then
	;MsgBox(0, "", "no blanks found")
	Send("{Enter}")
Else
	;MsgBox(0, "", "blanks found")
	Send("^-")
	Sleep(300)
	Send("u")
	Sleep(300)
	Send("{ENTER}")
	Sleep(300)
EndIf

;sort on column C
$oWorkbook = $oExcel.ActiveWorkbook
_Excel_RangeSort($oWorkbook, Default, Default, "C:C", Default, Default, $xlNo)

;show only records expiring in three weeks or less
_Excel_FilterSet($oWorkbook, Default, Default, 3, "<22")

;copy column B and paste into column G
Local $oRange = $oWorkbook.ActiveSheet.Range("B:B")
_Excel_RangeCopyPaste($oWorkbook.ActiveSheet, $oRange, "G1", Default, Default, -4163, True)

;remove tags, overwriting string in column G
Local $rowname = "G"
Local $rownumber = 1
Global $xlup = -4162
while $rownumber <= $oWorkbook.ActiveSheet.Range("A65536").End($xlup).Row
	If @error = -1 Then ExitLoop
	$line = _Excel_RangeRead($oWorkbook, Default, $rowname & $rownumber)
	_Excel_RangeWrite($oWorkbook, Default, StringRegExpReplace($line, "\[\d*\]", ""), $rowname & $rownumber)
	$rownumber = $rownumber + 1
WEnd

;copy range G to text file
Local $oRange = _Excel_RangeCopyPaste($oWorkbook.ActiveSheet, "G:G", Default, Default, Default, Default, True)
;use this to copy range to new sheet instead
;_Excel_BookSave($oWorkbook)
;_Excel_SheetAdd($oWorkbook, -1, False, 1)
;_Excel_RangeCopyPaste($oWorkbook.ActiveSheet, Default, "A:A")
Send(FileWriteLine(FileOpen("oclcExpiring.txt", $FO_OVERWRITE + $FO_UTF8), ClipGet()))

;delete data
Send("{TAB}")
Send("^a")
Send("^a")
Send("^-")
Send("^-")
Send("^s")

;close worksheet
Send("!f")
Send("c")
Sleep(300)

;close Excel
Send("!f")
Send("x")

;allow window to go to the background
WinSetOnTop("Microsoft Excel", "", 0)
Exit

