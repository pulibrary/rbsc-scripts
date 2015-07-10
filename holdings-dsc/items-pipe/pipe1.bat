if not exist "C:\Users\%USERNAME%\Desktop\Labels" mkdir C:\Users\%USERNAME%\Desktop\Labels
2>"C:\Users\%USERNAME%\Desktop\Labels\log.txt" (
java -cp "C:\Program Files\Oxygen XML Editor 16\lib\saxon9ee.jar" net.sf.saxon.Query -update:on -t -q:"C:\Users\%USERNAME%\Documents\SVN Working Copies\trunk\rbscXSL\Locations2015\AbID2dsc-items.xq"
"C:\Users\%USERNAME%\Documents\SVN Working Copies\trunk\rbscXSL\Locations2015\items-pipe\pipe2.bat"
)
