xquery version "1.0";

declare namespace ead="urn:isbn:1-931666-22-9";
declare default element namespace "urn:isbn:1-931666-22-9";

(:This xQuery Update replaces unitdates in Scribners Author Files I with "undated" if they are in fact biographical dates.:)

declare variable $FILE as document-node()* := doc("file:///C:/Documents%20and%20Settings/heberlei/My%20Documents/SVN%20Working%20Copies/trunk/eads/mss/C0101.EAD.xml");

for $c in $FILE//ead:c[@id='C0101_c000112']//ead:c[not(descendant::ead:c)]
let 
$unitdate := $c//ead:unitdate[not(.='undated')],
$unittitle := $c//ead:unittitle,
$dateinunittitle := replace($unittitle, '([\s\S]*)(\d{4}-\d{4})([\s\S]*)','$2')
return
if ($dateinunittitle[matches(., '\d{4}-\d{4}')])
then
if ($unitdate=$dateinunittitle)
then
(delete node $unitdate,
insert node <unitdate>undated</unitdate> after $unittitle)
else()
else()