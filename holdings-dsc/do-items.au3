; Macro to swap out filenames in xQueries based on user input. Adapted from https://www.autoitscript.com/forum/topic/64422-replaceinfile/
#include <File.au3>
;#include <Array.au3>

Local $EAD = InputBox("file path", "enter path to target EAD file")
Local $EADinput = "file:///" & StringReplace(StringReplace($EAD, "\", "/"), " ", "%20")
Local $AbIDinput = "file:///" & StringReplace(StringReplace(InputBox("file path", "enter path to AbID output file"), "\", "/"), " ", "%20")
; DEBUG = MsgBox(0, "", $EADinput)

ReplaceInFile("C:\Users\" & @UserName & "\Documents\SVN Working Copies\trunk\rbscXSL\Locations2015\labels-pipe\labels1.bat", "C:\Users\%USERNAME%\Documents\SVN Working Copies\trunk\rbscXSL\Locations2015\sample_input.EAD.xml", $EAD)
ReplaceInFile("C:\Users\" & @UserName & "\Documents\SVN Working Copies\trunk\rbscXSL\Locations2015\AbID2dsc-items.xq", "sample_input.EAD.xml", $EADinput)
ReplaceInFile("C:\Users\" & @UserName & "\Documents\SVN Working Copies\trunk\rbscXSL\Locations2015\AbID2dsc-items.xq", "sample_input.AbID.xml", $AbIDinput)
ReplaceInFile("C:\Users\" & @UserName & "\Documents\SVN Working Copies\trunk\rbscXSL\Locations2015\AbIDposition.xq", "sample_input.EAD.xml", $EADinput)
ReplaceInFile("C:\Users\" & @UserName & "\Documents\SVN Working Copies\trunk\rbscXSL\Locations2015\match-values.xq", "sample_input.EAD.xml", $EADinput)
ReplaceInFile("C:\Users\" & @UserName & "\Documents\SVN Working Copies\trunk\rbscXSL\Locations2015\labels-pipe\labels1.bat", "sample_input.EAD.xml", $EADinput)
ReplaceInFile("C:\Users\" & @UserName & "\Documents\SVN Working Copies\trunk\rbscXSL\Locations2015\retro-match-dscs.xq", "sample_input.EAD.xml", $EADinput)

RunWait("C:\Users\" & @UserName & "\Documents\SVN Working Copies\trunk\rbscXSL\Locations2015\items-pipe\pipe1.bat")

ReplaceInFile("C:\Users\" & @UserName & "\Documents\SVN Working Copies\trunk\rbscXSL\Locations2015\AbID2dsc-items.xq", String($EADinput), "sample_input.EAD.xml")
ReplaceInFile("C:\Users\" & @UserName & "\Documents\SVN Working Copies\trunk\rbscXSL\Locations2015\AbID2dsc-items.xq", String($AbIDinput), "sample_input.AbID.xml")
ReplaceInFile("C:\Users\" & @UserName & "\Documents\SVN Working Copies\trunk\rbscXSL\Locations2015\AbIDposition.xq", String($EADinput), "sample_input.EAD.xml")
ReplaceInFile("C:\Users\" & @UserName & "\Documents\SVN Working Copies\trunk\rbscXSL\Locations2015\match-values.xq", String($EADinput), "sample_input.EAD.xml")
ReplaceInFile("C:\Users\" & @UserName & "\Documents\SVN Working Copies\trunk\rbscXSL\Locations2015\labels-pipe\labels1.bat", String($EADinput), "sample_input.EAD.xml")
ReplaceInFile("C:\Users\" & @UserName & "\Documents\SVN Working Copies\trunk\rbscXSL\Locations2015\retro-match-dscs.xq", String($EADinput), "sample_input.EAD.xml")
ReplaceInFile("C:\Users\" & @UserName & "\Documents\SVN Working Copies\trunk\rbscXSL\Locations2015\labels-pipe\labels1.bat", $EAD, "C:\Users\%USERNAME%\Documents\SVN Working Copies\trunk\rbscXSL\Locations2015\sample_input.EAD.xml")

Func ReplaceInFile($io_file, $io_word, $io_replacement)
	Local $Records
	$Lines = _FileCountLines($io_File)
	If Not _FileReadToArray($io_file, $Records) Then
		ConsoleWriteError("There was an error reading > " & $io_file & @CRLF)
		Exit
	ElseIf _FileReadToArray($io_file, $Records) == "" Then
		ConsoleWriteError("File was found to be blank!" & @CRLF)
	ElseIf Not @error Then
		ConsoleWrite("> File was all good!" & @CRLF)
	EndIf
	$File = FileOpen($io_file, 2)
; DEBUG = ConsoleWrite("+> Found: " & $Lines & " lines!" & @CRLF)
; DEBUG = _ArrayDisplay($Records)
	For $ax = 1 To $Records[0]
		ConsoleWrite("+> " & $Records[$ax] & @CRLF)
		$Replace = StringReplace($Records[$ax], $io_word, $io_replacement)
		ConsoleWrite("+> " & $Replace & @CRLF)
			FileWrite($File, $Replace & @CRLF)
		If Not @error Then
			ConsoleWrite("> Replaced String!" & @CRLF)
		Else
			ConsoleWriteError("Error replacing text!" & @CRLF)
		EndIf
	Next
	FileClose($File)
EndFunc