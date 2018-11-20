;Macro to conduct ISBN search in Voyager and populate Access DB field based on search result

#include <Constants.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>

;bring Voyager to the foreground, open boolean search, open dialog box.
WinActivate("Voyager Cataloging")
WinWaitActive("Voyager Cataloging")
WinSetState("Voyager Cataloging", "", @SW_SHOW)

Func Utf82Unicode($Utf8String)
    Local $BufferSize = StringLen($Utf8String) * 2
    Local $Buffer = DllStructCreate("byte[" & $BufferSize & "]")
    Local $Return = DllCall("Kernel32.dll", "int", "MultiByteToWideChar", _
        "int", 65001, _
        "int", 0, _
        "str", $Utf8String, _
        "int", StringLen($Utf8String), _
        "ptr", DllStructGetPtr($Buffer), _
        "int", $BufferSize)
    Local $UnicodeString = StringLeft(DllStructGetData($Buffer, 1), $Return[0] * 2)
    $Buffer = 0
    Return $UnicodeString
EndFunc

Func Unicode2Asc($UniString)
    If Not IsBinary($UniString) Then
        SetError(1)
        Return $UniString
    EndIf

    Local $BufferLen = StringLen($UniString)
    Local $Input = DllStructCreate("byte[" & $BufferLen & "]")
    Local $Output = DllStructCreate("char[" & $BufferLen & "]")
    DllStructSetData($Input, 1, $UniString)
    Local $Return = DllCall("kernel32.dll", "int", "WideCharToMultiByte", _
        "int", 0, _
        "int", 0, _
        "ptr", DllStructGetPtr($Input), _
        "int", $BufferLen / 2, _
        "ptr", DllStructGetPtr($Output), _
        "int", $BufferLen, _
        "int", 0, _
        "int", 0)
    Local $AscString = DllStructGetData($Output, 1)
    $Output = 0
    $Input = 0
    Return $AscString
EndFunc

$file = FileOpen("bibids.txt", 0)
    If @error = -1 Then
		MsgBox(0, "Error", "Unable to open file.")
	EndIf
While 1
    $line = FileReadLine($file)
    If @error = -1 Then ExitLoop
	Send("!r")	;Record menu
	Send("i")	;Search
	Send("b")
	;MsgBox(0, "line", $line)
	Send($line)
	Send("{ENTER}")
	Sleep(1000)
	If ControlCommand("Voyager Cataloging", "", 32768, "IsEnabled") Then
		$008language = StringMid(StringStripWS(StringRegExpReplace(StringRegExpReplace(String(WinGetText("Voyager Cataloging", "")), "(\A[\D\S]+00&7)", ""), "(00&6[\D\S]+)", ""), $STR_STRIPALL), 36, 3)
		;MsgBox(0, "langcode", $008language)
		;MsgBox(0, "test", StringLen(StringStripWS(StringRegExpReplace(StringRegExpReplace(String(WinGetText("Voyager Cataloging", "")), "(\A[\D\S]+00&7)", ""), "(00&6[\D\S]+)", ""), $STR_STRIPALL)))
			If ControlCommand("Voyager Cataloging", "", 7, "IsVisible") Then
				If ControlCommand("Voyager Cataloging", "", 8, "IsVisible") Then
				Send("{TAB 7}")
				Else
					Send("{TAB 6}")
				EndIf
			ElseIf ControlCommand("Voyager Cataloging", "", 8, "IsVisible") Then
				Send("{TAB 6}")
			Else
				Send("{TAB 5}")
			EndIf
			Send("{ENTER 3}")
			;While 1 ;GET LANGCODE FROM 041
				;Local $get041 = StringRegExpReplace(StringRegExpReplace(StringRegExpReplace(String(WinGetText("Voyager Cataloging", "")), "(\A.*)", ""), "\A\n[\D\S]+?\n", ""), "(?<=\A\n\d{3})[\D\S]*", "")
					While 1 ;GET 245i2
						Local $field = WinGetText("Voyager Cataloging", "")
						$fieldname = StringRegExpReplace(StringRegExpReplace(StringRegExpReplace($field, "(\A.*)", ""), "\A\n[\D\S]+?\n", ""), "(?<=\A\n\d{3})[\D\S]*", "")
						;MsgBox(0, "this should be a three-letter fieldname", $fieldname)
						If StringInStr($fieldname, "245") Then
							Send("{TAB 2}")
							;Send("{ENTER 2}")
							Local $245string = WinGetText("Voyager Cataloging", "")
							Local $245istring = StringRegExpReplace(StringRegExpReplace($245string, "(\A.*)", ""), "\A\n[\D\S]+?\n", "")
							;MsgBox(0, "this should have gotten rid of leading lines", $245istring)
							$245i2 = String(StringRegExpReplace($245istring, "(?<=\A\n\d)[\D\S]*", ""))
							;MsgBox(0, "this should be 245i2", $245i2)
							If $245i2 <> 0 Then
							While 1 ;GET 245 ARTICLE; COMPARE LENGTH TO i2
								Send("{TAB}")
								Local $245 = StringRegExpReplace(StringRegExpReplace(WinGetText("Voyager Cataloging", ""), "(\A.*)", ""), "\A\n[\D\S]+?\n", "")
								$245strip = StringStripWS(StringRegExpReplace($245, "[\D\S]+?‡a", ""), $STR_STRIPLEADING)
								;MsgBox(0, "return $245strip", $245strip)
								$245article = StringLeft($245strip, $245i2)
								;MsgBox(0, "article", $245article)
								$245art_plus_1 = StringLeft($245strip, $245i2+1)
								;MsgBox(0, "this should be the leading article + 1 character", $245art_plus_1)
								;MsgBox(0, "this should be the leading article", $245article)
								;MsgBox(0, "test", "First " & $245i2 & " characters of 245$a are '" & $245article & "'.")

								If $008language = "afr" Then
									$afr = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(die\s|'n\s)(\p{Ps}|\s{Pi}|"")?$")
									$afr_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$afr_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									If $afr Then ;if match, pass through
										If $afr_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $afr_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $afr Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
										Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
									EndIf

								ElseIf $008language = "alb" Then
									$alb = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(një\s)(\p{Ps}|\s{Pi}|"")?$")
									$alb_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$alb_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									If $alb Then ;if match, pass through
										If $alb_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $alb_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $alb Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
										Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
									EndIf

								ElseIf $008language = "ara" Then
									$ara1 = (StringLen($245article)=3 And StringRegExp($245art_plus_1, "(*UCP)^(?i)al-\p{L}$") And Not (Asc(StringRight($245art_plus_1, 1))=63 Or StringRegExp(StringRight($245art_plus_1, 1), "[’'‘`?]")))
									$ara2 = (StringLen($245article)=4 And StringRegExp($245article, "(*UCP)^(?i)al-\p{L}$") And (Asc(StringRight($245article, 1))=63 Or (StringRegExp($245article, "^(?i)al-[’'‘`?]$"))))
									$ara3 = (StringLen($245article)=4 And StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-$") And Not (Asc(StringRight($245art_plus_1, 1))=63 Or (StringRegExp($245art_plus_1, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-[’'‘`?]$"))))
									$ara4 = (StringLen($245article)=5 And StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-\p{L}$") And (Asc(StringRight($245article, 1))=63 Or (StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-['`?]$"))))
									$ara5 = (StringLen($245article)=5 And StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-(\p{Pe}|\p{Pf})$") And Not (Asc(StringRight($245art_plus_1, 1))=63 Or (StringRegExp($245art_plus_1, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-[’'‘`?]$"))))
									$ara6 = (StringLen($245article)=6 And StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-(\p{Pe}|\p{Pf})$") And (Asc(StringRight($245article, 1))=63 Or (StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-[’'‘`?]$"))))

									;MsgBox(0, "string to match", $245i2 & ": " & $245article & " ASCII: " & Asc(StringRight($245article, 1)) & " " & (Asc(StringRight($245article, 1))=63 Or StringRegExp(StringRight($245article, 1), "[’'‘`?]")))
									If ($ara1 or $ara2 or $ara3 or $ara4 or $ara5 or $ara6) Then ;if match, pass through
										Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
									ElseIf StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?al-") Then
										Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
									Else
										Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "bal" Then
									$bal = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(al-)(\p{Ps}|\s{Pi}|"")?$")
									$bal_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$bal_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									If $bal Then ;if match, pass through
										If $bal_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $bal_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $bal Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
										Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
									EndIf

								ElseIf $008language = "baq" Then
									$baq = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(bat\s)(\p{Ps}|\s{Pi}|"")?$")
									$baq_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$baq_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "is the following letter in upper case?", $eng_upper)
									If $baq Then ; if match, check case
										If $baq_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $baq_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $baq Then;if match, pass through
											Send(FileWriteLine(FileOpen("potential_word_articles.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
										Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "dra" Then
									$dra = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(al-)(\p{Ps}|\s{Pi}|"")?$")
									$dra_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$dra_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									If $dra Then ;if match, pass through
										If $dra_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $dra_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $dra Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
									EndIf
										Else
										Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
									EndIf

								ElseIf $008language = "bre" Then
									$bre = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(al\s|an\s|ar\s|eul\s|eun\s|eur\s|ul\s|un\s|ur\s)(\p{Ps}|\s{Pi}|"")?$")
									$bre_article = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(al\s|an\s|ar\s)(\p{Ps}|\s{Pi}|"")?$")
									$bre_ambiguous = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(eul\s|eun\s|eur\s|ul\s|un\s|ur\s)(\p{Ps}|\s{Pi}|"")?$")
									$bre_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$bre_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $bre Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $bre_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $bre_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $bre_article Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $bre_ambiguous Then
											Send(FileWriteLine(FileOpen("potential_word_articles.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "cat" Then
									$cat = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(en\s|un\s|una\s|el\s|els\s|l'|la\s|les\s)(\p{Ps}|\s{Pi}|"")?$")
									$cat_article = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(el\s|els\s|l'|la\s|les\s)(\p{Ps}|\s{Pi}|"")?$")
									$cat_ambiguous = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(en\s|un\s|una\s)(\p{Ps}|\s{Pi}|"")?$")
									$cat_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$cat_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $cat Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $cat_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $cat_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $cat_article Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $cat_ambiguous Then
											Send(FileWriteLine(FileOpen("potential_word_articles.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "dan" Then
									$dan = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(den\s|de\s|det\s|en\s|et\s)(\p{Ps}|\s{Pi}|"")?$")
									$dan_article = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(den\s|de\s|det\s)(\p{Ps}|\s{Pi}|"")?$")
									$dan_ambiguous = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(en\s|et\s)(\p{Ps}|\s{Pi}|"")?$")
									$dan_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$dan_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $dan Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $dan_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $dan_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $dan_article Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $dan_ambiguous Then
											Send(FileWriteLine(FileOpen("potential_word_articles.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "dut" Then
									$dut = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(de\s|een\s|eene\s|het\s|[’'`]n\s|['`’]t\s)(\p{Ps}|\s{Pi}|"")?$")
									$dut_article = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(de\s|het\s|['`’]n\s|['`’]t\s)(\p{Ps}|\s{Pi}|"")?$")
									$dut_ambiguous = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(een\s|eene\s)(\p{Ps}|\s{Pi}|"")?$")
									$dut_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$dut_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $dut Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $dut_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $dut_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $dut_article Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $dut_ambiguous Then
											Send(FileWriteLine(FileOpen("potential_word_articles.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "eng" Then
									$eng = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(a\s|an\s|d'\s?|de\s|the\s|ye\s)(\p{Ps}|\s{Pi}|"")?$")
									$eng_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$eng_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "is the following letter in upper case?", $eng_upper)
									If $eng Then ; if match, check case
										If $eng_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $eng_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $eng Then ;if match, pass through
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))

										EndIf
									Else
										Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "epo" Then
									$epo = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(la\s)(\p{Ps}|\s{Pi}|"")?$")
									$epo_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$epo_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $epo Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $epo_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $epo_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $epo Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "fij" Then
									$fij = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(a\s|e\sdua\sna\s|e\sna\sdua\s|na\s)(\p{Ps}|\s{Pi}|"")?$")
									$fij_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$fij_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $fij Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $fij_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $fij_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $fij Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "fre" Then ;check French values
									$fre = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(l'|la\s|le\s|les\s|un\s|une\s)(\p{Ps}|\s{Pi}|"")?$")
									$fre_article = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(l'|la\s|le\s|les\s)(\p{Ps}|\s{Pi}|"")?$")
									$fre_ambiguous = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(un\s|une\s)(\p{Ps}|\s{Pi}|"")?$")
									$fre_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$fre_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation

									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $fre Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $fre_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $fre_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $fre_article Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $fre_ambiguous Then
											Send(FileWriteLine(FileOpen("potential_word_articles.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "gag" Then
									$gag = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(a\s|as\s|unha\s|o\s)(\p{Ps}|\s{Pi}|"")?$")
									$gag_article = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(a\s|as\s|unha\s)(\p{Ps}|\s{Pi}|"")?$")
									$gag_ambiguous = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(o\s)(\p{Ps}|\s{Pi}|"")?$")
									$gag_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$gag_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation

									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $gag Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $gag_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $gag_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $gag_article Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $gag_ambiguous Then
											Send(FileWriteLine(FileOpen("potential_word_articles.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "ger" Then
										$ger = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(das\s|dem\s|den\s|der\s|des\s|die\s|einem\s|einen\s|einer\s|eines\s|ein\s|eine\s)(\p{Ps}|\s{Pi}|"")?$")
										$ger_article = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(das\s|dem\s|den\s|der\s|des\s|die\s|einem\s|einen\s|einer\s|eines\s)(\p{Ps}|\s{Pi}|"")?$")
										$ger_ambiguous = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(ein\s|eine\s)(\p{Ps}|\s{Pi}|"")?$")
										$ger_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									If  $ger Then ;if match, check case
										If $ger_article Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $ger_ambiguous Then
											Send(FileWriteLine(FileOpen("potential_word_articles.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $ger_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
									EndIf

								ElseIf $008language = "grc" Then
									$grc = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(hai\s|he¯\s|ho\s|hoi\s|ta\s|tain\s|tais\s|tas\s|te¯\s|te¯n\s|te¯s\s|to\s|to¯\s|to¯n\s|toin\s|tois\s|ton\s|tou\s)(\p{Ps}|\s{Pi}|"")?$")
									$grc_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$grc_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									If $grc Then ;if match, pass through
										If $grc_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $grc_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
										Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "gre" Then
									$gre = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(e¯\s|hai\s|he¯\s|ho\s|hoi\s|o\s|oi\s|ta\s|te¯\s|te¯s\s|tis\s|to\s|ton\s|to¯n\s|tou\s|tous\s|ena\s|enan\s|enas\s|enos\s|heis\s|hen\s|hena\s|henan\s|henas\s|henos\s|mia\s|mian\s|mias\s)(\p{Ps}|\s{Pi}|"")?$")
									$gre_article = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(e¯\s|hai\s|he¯\s|ho\s|hoi\s|o\s|oi\s|ta\s|te¯\s|te¯s\s|tis\s|to\s|ton\s|to¯n\s|tou\s|tous\s)(\p{Ps}|\s{Pi}|"")?$")
									$gre_ambiguous = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(ena\s|enan\s|enas\s|enos\s|heis\s|hen\s|hena\s|henan\s|henas\s|henos\s|mia\s|mian\s|mias\s)(\p{Ps}|\s{Pi}|"")?$")
									$gre_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$gre_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									If $gre Then ;if match, pass through
										If $gre_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $gre_article Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $gre_ambiguous Then
											Send(FileWriteLine(FileOpen("potential_word_articles.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $gre_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
										Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
									EndIf

								ElseIf $008language = "haw" Then
									$haw = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(he\s|ka\s|ke\s|na\s|o\s)(\p{Ps}|\s{Pi}|"")?$")
									$haw_article = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(he\s|ka\s|ke\s|na\s)(\p{Ps}|\s{Pi}|"")?$")
									$haw_ambiguous = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(o\s)(\p{Ps}|\s{Pi}|"")?$")
									$haw_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$haw_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation

									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $haw Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $haw_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $haw_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $haw_article Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $haw_ambiguous Then
											Send(FileWriteLine(FileOpen("potential_word_articles.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "heb" Then
									$heb1 = (StringLen($245article)=3 And StringRegExp($245art_plus_1, "(*UCP)^(?i)(ha-|he-)\p{L}$") And Not (Asc(StringRight($245art_plus_1, 1))=63 Or StringRegExp(StringRight($245art_plus_1, 1), "[’'‘`?]$")))
									$heb2 = (StringLen($245article)=4 And StringRegExp($245article, "(*UCP)^(?i)(ha-|he-)\p{L}$") And (Asc(StringRight($245article, 1))=63 Or (StringRegExp($245article, "^(?i)(ha-|he-)[’'‘`?]$"))))
									$heb3 = (StringLen($245article)=4 And StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")(ha-|he-)$") And Not (Asc(StringRight($245art_plus_1, 1))=63 Or (StringRegExp($245art_plus_1, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")(ha-|he-)[’'‘`?]$"))))
									$heb4 = (StringLen($245article)=5 And StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")(ha-|he-)\p{L}$") And (Asc(StringRight($245article, 1))=63 Or (StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")(ha-|he-)[’'‘`?]$"))))
									$heb5 = (StringLen($245article)=5 And StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")(ha-|he-)(\p{Pe}|\p{Pf})$") And Not (Asc(StringRight($245art_plus_1, 1))=63 Or (StringRegExp($245art_plus_1, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")(ha-|he-)[’'‘`?]$"))))
									$heb6 = (StringLen($245article)=6 And StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")(ha-|he-)(\p{Pe}|\p{Pf})$") And (Asc(StringRight($245article, 1))=63 Or (StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")(ha-|he-)[’'‘`?]$"))))

									;MsgBox(0, "string to match", $245i2 & ": " & $245article & " ASCII: " & Asc(StringRight($245article, 1)) & " " & (Asc(StringRight($245article, 1))=63 Or StringRegExp(StringRight($245article, 1), "[’'‘`?]")))
									If ($heb1 or $heb2 or $heb3 or $heb4 or $heb5 or $heb6) Then ;if match, pass through
										Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
									ElseIf StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(ha-|he-)") Then
										Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
									Else
										Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "hun" Then
									$hun = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(a\s|egy\s|az\s)(\p{Ps}|\s{Pi}|"")?$")
									$hun_excl = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(az\saz\s)(\p{Ps}|\s{Pi}|"")?$")
									$hun_article = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(a\s|az\s)(\p{Ps}|\s{Pi}|"")?$")
									$hun_ambiguous = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(egy\s)(\p{Ps}|\s{Pi}|"")?$")
									$hun_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$hun_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation

									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If ($hun and not $hun_excl) Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $hun_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $hun_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $hun_article Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $hun_ambiguous Then
											Send(FileWriteLine(FileOpen("potential_word_articles.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "ice" Then
									$ice = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(in\s|hina\s|hinar\s|hinir\s|hinn\s|hinna\s|hinnar\s|hinni\s|hins\s|hinu\s|hinum\s|hið\s|['`’]r\s)(\p{Ps}|\s{Pi}|"")?$")
									$ice_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$ice_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation

									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $ice Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $ice_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $ice_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $ice Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "iri" Then
									$iri = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(an\s|an\st-|na\s|na\sh-|an\st\s|na\sh\s)(\p{Ps}|\s{Pi}|"")?$")
									$iri_article = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(an\s|an\st-|na\s|na\sh-)(\p{Ps}|\s{Pi}|"")?$")
									$iri_ambiguous = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(an\st\s|na\sh\s)(\p{Ps}|\s{Pi}|"")?$")
									$iri_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$iri_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation

									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $iri Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $iri_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $iri_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $iri_article Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $iri_ambiguous Then
											Send(FileWriteLine(FileOpen("potential_word_articles.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf StringRegExp($008language, "mla|mlg") Then
									$mlg = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(ny\s)(\p{Ps}|\s{Pi}|"")?$")
									$mlg_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$mlg_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $mlg Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $mlg_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $mlg_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $mlg Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "ita" Then
									$ita = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(gl'|gli\s|i\s|il\s|l'|un\s|la\s|le\s|li\s|lo\s|un\s|una\s|uno\s)(\p{Ps}|\s{Pi}|"")?$")
									$ita_article = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(gl'|gli\s|i\s|il\s|l'|un\s)(\p{Ps}|\s{Pi}|"")?$")
									$ita_ambiguous = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(la\s|le\s|li\s|lo\s|un\s|una\s|uno\s)(\p{Ps}|\s{Pi}|"")?$")
									$ita_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$ita_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									If $ita Then ;if match, pass through
										If $ita_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $ita_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $ita_article Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $ita_ambiguous Then
											Send(FileWriteLine(FileOpen("potential_word_articles.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
										Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "mlt" Then
									$mlt = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(il-|l-)(\p{Ps}|\s{Pi}|"")?$")
									$mlt_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$mlt_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $mlt Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $mlt_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $mlt_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $mlt Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "mao" Then
									$mao = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(he\s|nga¯\s|te\s)(\p{Ps}|\s{Pi}|"")?$")
									$mao_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$mao_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $mao Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $mao_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $mao_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $mao Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "nap" Then
									$nap = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?([’'`]o\s)(\p{Ps}|\s{Pi}|"")?$")
									$nap_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$nap_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $nap Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $nap_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $nap_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $nap Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "niu" Then
									$niu = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(a\s|e\s|e\staha\s|ha\s|ko\se\s)(\p{Ps}|\s{Pi}|"")?$")
									$niu_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$niu_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $niu Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $niu_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $niu_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $niu Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "nor" Then
									$nor = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(de\s|dei\s|den\s|det\s|e\s|ei\s|ein\s|eit\s|en\s|et\s)(\p{Ps}|\s{Pi}|"")?$")
									$nor_article = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(de\s|dei\s|den\s|det\s|e\s)(\p{Ps}|\s{Pi}|"")?$")
									$nor_ambiguous = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(ei\s|ein\s|eit\s|en\s|et\s)(\p{Ps}|\s{Pi}|"")?$")
									$nor_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$nor_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation

									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $nor Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $nor_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $nor_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $nor_article Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $nor_ambiguous Then
											Send(FileWriteLine(FileOpen("potential_word_articles.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "oci" Then
									$oci = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(il\s|l[’']|la\s|las\s|le\s|les\s|lh\s|lhi\s|li\s|lis\s|los\s|lou\s|lu\s|uns\s|us\s|un\s|una\s|uno\s|lo\s)(\p{Ps}|\s{Pi}|"")?$")
									$oci_article = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(il\s|l[’']|la\s|las\s|le\s|les\s|lh\s|lhi\s|li\s|lis\s|los\s|lou\s|lu\s|uns\s|us\s)(\p{Ps}|\s{Pi}|"")?$")
									$oci_ambiguous = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(un\s|una\s|uno\s|lo\s)(\p{Ps}|\s{Pi}|"")?")
									$oci_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$oci_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation

									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $oci Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $oci_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $oci_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $oci_article Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $oci_ambiguous Then
											Send(FileWriteLine(FileOpen("potential_word_articles.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "pro" Then
									$pro = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(ih[’']|l[’']|la\s|las\s|le\s|les\s|lh\s|lhi\s|li\s|lis\s|los\s|lou\s|lu\s|un\s|una\s|uno\s|uns\s|us\s|lo\s)(\p{Ps}|\s{Pi}|"")?$")
									$pro_article = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(ih[’']|l[’']|la\s|las\s|le\s|les\s|lh\s|lhi\s|li\s|lis\s|los\s|lou\s|lu\s)(\p{Ps}|\s{Pi}|"")?$")
									$pro_ambiguous = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(un\s|una\s|uno\s|uns\s|us\s|lo\s)(\p{Ps}|\s{Pi}|"")?$")
									$pro_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$pro_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation

									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $pro Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $pro_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $pro_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $pro_article Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $pro_ambiguous Then
											Send(FileWriteLine(FileOpen("potential_word_articles.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
									EndIf

								ElseIf $008language = "pan" Then
									$pan1 = (StringLen($245article)=3 And StringRegExp($245art_plus_1, "(*UCP)^(?i)al-\p{L}$") And Not (Asc(StringRight($245art_plus_1, 1))=63 Or StringRegExp(StringRight($245art_plus_1, 1), "[’'‘`?]$")))
									$pan2 = (StringLen($245article)=4 And StringRegExp($245article, "(*UCP)^(?i)al-\p{L}$") And (Asc(StringRight($245article, 1))=63 Or (StringRegExp($245article, "^(?i)al-[’'‘`?]"))))
									$pan3 = (StringLen($245article)=4 And StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-$") And Not (Asc(StringRight($245art_plus_1, 1))=63 Or (StringRegExp($245art_plus_1, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-[’'‘`?]$"))))
									$pan4 = (StringLen($245article)=5 And StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-\p{L}$") And (Asc(StringRight($245article, 1))=63 Or (StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-['`?]$"))))
									$pan5 = (StringLen($245article)=5 And StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-(\p{Pe}|\p{Pf})$") And Not (Asc(StringRight($245art_plus_1, 1))=63 Or (StringRegExp($245art_plus_1, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-[’'‘`?]$"))))
									$pan6 = (StringLen($245article)=6 And StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-(\p{Pe}|\p{Pf})$") And (Asc(StringRight($245article, 1))=63 Or (StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-[’'‘`?]$"))))

									;MsgBox(0, "string to match", $245i2 & ": " & $245article & " ASCII: " & Asc(StringRight($245article, 1)) & " " & (Asc(StringRight($245article, 1))=63 Or StringRegExp(StringRight($245article, 1), "[’'‘`?]")))
									If ($pan1 or $pan2 or $pan3 or $pan4 or $pan5 or $pan6) Then ;if match, pass through
										Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
									ElseIf StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?al-") Then
										Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
									Else
										Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "per" Then
									$per1 = (StringLen($245article)=3 And StringRegExp($245art_plus_1, "(*UCP)^(?i)al-\p{L}$") And Not (Asc(StringRight($245art_plus_1, 1))=63 Or StringRegExp(StringRight($245art_plus_1, 1), "[’'‘`?]$")))
									$per2 = (StringLen($245article)=4 And StringRegExp($245article, "(*UCP)^(?i)al-\p{L}$") And (Asc(StringRight($245article, 1))=63 Or (StringRegExp($245article, "^(?i)al-[’'‘`?]$"))))
									$per3 = (StringLen($245article)=4 And StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-$") And Not (Asc(StringRight($245art_plus_1, 1))=63 Or (StringRegExp($245art_plus_1, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-[’'‘`?]$"))))
									$per4 = (StringLen($245article)=5 And StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-\p{L}$") And (Asc(StringRight($245article, 1))=63 Or (StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-['`?]$"))))
									$per5 = (StringLen($245article)=5 And StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-(\p{Pe}|\p{Pf})$") And Not (Asc(StringRight($245art_plus_1, 1))=63 Or (StringRegExp($245art_plus_1, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-[’'‘`?]$"))))
									$per6 = (StringLen($245article)=6 And StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-(\p{Pe}|\p{Pf})$") And (Asc(StringRight($245article, 1))=63 Or (StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-[’'‘`?]$"))))

									;MsgBox(0, "string to match", $245i2 & ": " & $245article & " ASCII: " & Asc(StringRight($245article, 1)) & " " & (Asc(StringRight($245article, 1))=63 Or StringRegExp(StringRight($245article, 1), "[’'‘`?]")))
									If ($per1 or $per2 or $per3 or $per4 or $per5 or $per6) Then ;if match, pass through
										Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
									ElseIf StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?al-") Then
										Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
									Else
										Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "por" Then
									$por = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(a\s|as\s|os\s|um\s|uma\s|o\s)(\p{Ps}|\s{Pi}|"")?$")
									$por_article = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(a\s|as\s|os\s)(\p{Ps}|\s{Pi}|"")?$")
									$por_ambiguous = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(um\s|uma\s|o\s)(\p{Ps}|\s{Pi}|"")?$")
									$por_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$por_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									If $por Then ;if match, pass through
										If $por_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $por_article Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $por_ambiguous Then
											Send(FileWriteLine(FileOpen("potential_word_articles.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $por_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
										Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
									EndIf

								ElseIf $008language = "rar" Then
									$rar = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(nga¯\s|te\s)(\p{Ps}|\s{Pi}|"")?$")
									$rar_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$rar_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $rar Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $rar_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $rar_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $rar Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "rum" Then
									$rum = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(o\s|un\s)(\p{Ps}|\s{Pi}|"")?$")
									$rum_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$rum_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "is the following letter in upper case?", $eng_upper)
									If $rum Then ; if match, check case
										If $rum_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $rum_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $rum Then;if match, pass through
											Send(FileWriteLine(FileOpen("potential_word_articles.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
										Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf StringRegExp($008language, "sao|smo") Then
									$sao = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(le\s|[’'‘`?]o\sle\s|[’'‘`?]o\slo\s|[’'‘`?]o\sse\s|se\s)(\p{Ps}|\s{Pi}|"")?$")
									$sao_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$sao_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $sao Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $sao_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $sao_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $sao Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "sco" Then
									$sco = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(a\s|an\s|ane\s)(\p{Ps}|\s{Pi}|"")?$")
									$sco_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$sco_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $sco Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $sco_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $sco_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $sco Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "gla" Then
									$gla = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(a[’'‘`?]\s|am\s|an\s|an\st-|na\s|na\sh-)(\p{Ps}|\s{Pi}|"")?$")
									$gla_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$gla_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $gla Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $gla_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $gla_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $gla Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "spa" Then
									$spa = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(el\s|la\s|las\s|lo\s|los\s|un\s|una\s)(\p{Ps}|\s{Pi}|"")?$")
									$spa_article = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(el\s|la\s|las\s|los\s)(\p{Ps}|\s{Pi}|"")?$")
									$spa_ambiguous = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(lo\s|un\s|una\s)(\p{Ps}|\s{Pi}|"")?$")
									$spa_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$spa_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									If $spa Then ;if match, pass through
										If $spa_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $spa_article Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $spa_ambiguous Then
											Send(FileWriteLine(FileOpen("potential_word_articles.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $spa_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
										Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "swe" Then
									$swe = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(de\s|den\s|det\s|en\s|ett\s)(\p{Ps}|\s{Pi}|"")?$")
									$swe_article = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(de\s|den\s|det\s)(\p{Ps}|\s{Pi}|"")?$")
									$swe_ambiguous = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(en\s|ett\s)(\p{Ps}|\s{Pi}|"")?$")
									$swe_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$swe_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									If $swe Then ;if match, pass through
										If $swe_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $swe_article Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $swe_ambiguous Then
											Send(FileWriteLine(FileOpen("potential_word_articles.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $swe_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
										Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
									EndIf

;non-renderding diacritics might mean trouble:
								ElseIf $008language = "tgl" Then
									$tgl = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(ang\s|ang\smga\s|ang\smg?a\s|ang\smganga\s|ang\sma?a\s|mga\s|mg?a\s|ma?a\s|manga\s)(\p{Ps}|\s{Pi}|"")?$")
									$tgl_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$tgl_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $tgl Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $tgl_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $tgl_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $tgl Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "tah" Then
									$tah = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(e\s|e\stahi\s|hui\s|ma\s|maa\s|mau\s|na\s|o\s|pue\s|tau\s|te\s|te\shoe\s)(\p{Ps}|\s{Pi}|"")?$")
									$tah_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$tah_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $tah Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $tah_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $tah_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $tah Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "tkl" Then
									$tkl = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(he\s|ko\sna\s|ko\ste\s|na\s|ni\s|o\s|te\s|na¯\s|na?\s)(\p{Ps}|\s{Pi}|"")?$")
									$tkl_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$tkl_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $tkl Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $tkl_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $tkl_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $tkl Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "ton" Then
									$ton = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(e\s|ha\s|he\s|ko\se\s|ko\sha\s|koe\s)(\p{Ps}|\s{Pi}|"")?$")
									$ton_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$ton_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $ton Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $ton_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $ton_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $ton Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "tur" Then
									$tur = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(al-)(\p{Ps}|\s{Pi}|"")?$")
									$tur_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$tur_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $tur Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $tur_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $tur_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $tur Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "urd" Then
									$urd1 = (StringLen($245article)=3 And StringRegExp($245art_plus_1, "(*UCP)^(?i)al-\p{L}$") And Not (Asc(StringRight($245art_plus_1, 1))=63 Or StringRegExp(StringRight($245art_plus_1, 1), "[’'‘`?]$")))
									$urd2 = (StringLen($245article)=4 And StringRegExp($245article, "(*UCP)^(?i)al-\p{L}$") And (Asc(StringRight($245article, 1))=63 Or (StringRegExp($245article, "^(?i)al-[’'‘`?]$"))))
									$urd3 = (StringLen($245article)=4 And StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-$") And Not (Asc(StringRight($245art_plus_1, 1))=63 Or (StringRegExp($245art_plus_1, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-[’'‘`?]$"))))
									$urd4 = (StringLen($245article)=5 And StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-\p{L}$") And (Asc(StringRight($245article, 1))=63 Or (StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-['`?]$"))))
									$urd5 = (StringLen($245article)=5 And StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-(\p{Pe}|\p{Pf})$") And Not (Asc(StringRight($245art_plus_1, 1))=63 Or (StringRegExp($245art_plus_1, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-[’'‘`?]$"))))
									$urd6 = (StringLen($245article)=6 And StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-(\p{Pe}|\p{Pf})$") And (Asc(StringRight($245article, 1))=63 Or (StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-[’'‘`?]$"))))

									;MsgBox(0, "string to match", $245i2 & ": " & $245article & " ASCII: " & Asc(StringRight($245article, 1)) & " " & (Asc(StringRight($245article, 1))=63 Or StringRegExp(StringRight($245article, 1), "[’'‘`?]")))
									If ($urd1 or $urd2 or $urd3 or $urd4 or $urd5 or $urd6) Then ;if match, pass through
										Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
									ElseIf StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?al-") Then
										Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
									Else
										Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "wln" Then
									$wln = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(des\s|ein\s|enne\s|l[’'‘`?]|les\s|li\s)(\p{Ps}|\s{Pi}|"")?$")
									$wln_article = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(des\s|enne\s|l[’'‘`?]|les\s|li\s)(\p{Ps}|\s{Pi}|"")?$")
									$wln_ambiguous = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(ein\s)(\p{Ps}|\s{Pi}|"")?$")
									$wln_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$wln_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									If $wln Then ;if match, pass through
										If $wln_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $wln_article Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $wln_ambiguous Then
											Send(FileWriteLine(FileOpen("potential_word_articles.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $wln_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
										Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "fry" Then
									$fry = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(de\s|[’'‘`?]e\s|in\s|it\s|[’'‘`?]n\s|[’'‘`?]t\s)(\p{Ps}|\s{Pi}|"")?$")
									$fry_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$fry_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $fry Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $fry_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $fry_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $fry Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "lah" Then
									$lah1 = (StringLen($245article)=3 And StringRegExp($245art_plus_1, "(*UCP)^(?i)al-\p{L}$") And Not (Asc(StringRight($245art_plus_1, 1))=63 Or StringRegExp(StringRight($245art_plus_1, 1), "[’'‘`?]$")))
									$lah2 = (StringLen($245article)=4 And StringRegExp($245article, "(*UCP)^(?i)al-\p{L}$") And (Asc(StringRight($245article, 1))=63 Or (StringRegExp($245article, "^(?i)al-[’'‘`?]$"))))
									$lah3 = (StringLen($245article)=4 And StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-$") And Not (Asc(StringRight($245art_plus_1, 1))=63 Or (StringRegExp($245art_plus_1, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-[’'‘`?]$"))))
									$lah4 = (StringLen($245article)=5 And StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-\p{L}$") And (Asc(StringRight($245article, 1))=63 Or (StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-['`?]$"))))
									$lah5 = (StringLen($245article)=5 And StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-(\p{Pe}|\p{Pf})$") And Not (Asc(StringRight($245art_plus_1, 1))=63 Or (StringRegExp($245art_plus_1, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-[’'‘`?]$"))))
									$lah6 = (StringLen($245article)=6 And StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-(\p{Pe}|\p{Pf})$") And (Asc(StringRight($245article, 1))=63 Or (StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")al-[’'‘`?]$"))))

									;MsgBox(0, "string to match", $245i2 & ": " & $245article & " ASCII: " & Asc(StringRight($245article, 1)) & " " & (Asc(StringRight($245article, 1))=63 Or StringRegExp(StringRight($245article, 1), "[’'‘`?]")))
									If ($lah1 or $lah2 or $lah3 or $lah4 or $lah5 or $lah6) Then ;if match, pass through
										Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
									ElseIf StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?al-") Then
										Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
									Else
										Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "wel" Then
									$wel = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(y\s|yr\s)(\p{Ps}|\s{Pi}|"")?$")
									$wel_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$wel_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									;MsgBox(0, "test", "First " & $245i2 & " chars of 245a spell '" & $245article & "' " & Asc(StringLeft( $245article, 1)) & " " &$fre)
									If $wel Then ;if match, check case
										;MsgBox(0, "test", "TRUE: First " & $245i2 & " chars of 245a spell '" & $245article &"'," & @LF & "which is valid in 008: '" & $008language & "'.")
										If $wel_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $wel_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $wel Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
											Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

								ElseIf $008language = "yid" Then
									$wln = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(a\s|an\s|dem\s|der\s|di\s|die\s|dos\s|eyn\s|eyne\s)(\p{Ps}|\s{Pi}|"")?$")
									$wln_article = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(a\s|an\s|dem\s|der\s|di\s|die\s|dos\s)(\p{Ps}|\s{Pi}|"")?$")
									$wln_ambiguous = StringRegExp($245article, "(*UCP)^(?i)(\p{Ps}|\s{Pi}|"")?(eyn\s|eyne\s)(\p{Ps}|\s{Pi}|"")?$")
									$wln_upper = StringRegExp($245art_plus_1, "(*UCP)\P{P}\p{Lu}$")  ;check following character case
									$wln_punct = StringRegExp($245art_plus_1, "(*UCP)(\p{Ps}|\s{Pi}|"")$")  ;check following for opening punctuation
									If $wln Then ;if match, pass through
										If $wln_upper Then
											Send(FileWriteLine(FileOpen("suspect_uppercase.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $wln_article Then
											Send(FileWriteLine(FileOpen("passed.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $wln_ambiguous Then
											Send(FileWriteLine(FileOpen("potential_word_articles.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										ElseIf $wln_punct Then
											Send(FileWriteLine(FileOpen("check245i2.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										Else
											Send(FileWriteLine(FileOpen("other.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
										EndIf
									Else
										Send(FileWriteLine(FileOpen("invalid_article_for_008.txt", $FO_APPEND), $line & "		008: " & $008language & "	245i2: " & $245i2 & "	" & $245i2 & " chars from 245a: '" & $245article & "' 	Title: " & StringLeft($245strip, 30) & @CRLF))
								EndIf

							Else
								Send(FileWriteLine(FileOpen("invalid_008_langcode_or_not_RDA-C2.txt", $FO_APPEND), $line & ": " & $008language & @CRLF))
							EndIf

								ExitLoop
							WEnd
							EndIf
							ExitLoop
						Else
							Send("{DOWN}")
							Send("{ENTER}")
						EndIf
					WEnd
	EndIf
Send("^{F4}")
Send("y")
_FileWriteToLine("bibids.txt", 1, "", True)
WEnd
FileClose($file)

