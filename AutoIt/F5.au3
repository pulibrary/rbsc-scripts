HotKeySet("{F5}", "runF5")
While(1)
    Sleep(100)
Wend
Func runF5()
	Run("ISBN2bibid.exe", "")
EndFunc

;Run("ISBN2bibid.au3", "\\Lib-tsserver\rbsc\Technical Services\Heberlein\Projects\Derrida 2014"))