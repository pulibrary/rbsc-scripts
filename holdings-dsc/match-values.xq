xquery version "1.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare copy-namespaces no-preserve, inherit;

import module namespace functx="http://www.functx.com" 
    at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";
    
(:declare variable $EAD as document-node()+ := doc("../../eads/mss/RTC01.EAD.xml");:)
(:declare variable $ead as document-node()* := collection("../../eads/mss")/doc(document-uri(.));:)
declare variable $EAD as document-node()* := doc("sample_input.EAD.xml");

for $ead in $EAD
return

let $oldboxonly := $EAD//ead:dsc[1]//ead:did[not(ead:unitid)]/ead:container[matches(@type, "box|volume|carton") or (count(../ead:container)=1 and not(matches(@type, "folio|column|page")))]
let $oldunitidonly := $EAD//ead:dsc[1]//ead:did[not(ead:container)]/ead:unitid[@type="itemnumber"]
let $oldboxwithunitid := $EAD//ead:dsc[1]//ead:did[ead:unitid]/ead:container[matches(@type, "box|volume|carton") or (count(../ead:container)=1 and not(matches(@type, "folio|column|page")))]
let $newbox := $EAD//ead:dsc[2]//ead:container[@id]
let $oldbox := $EAD//ead:dsc[1]//ead:container
let $newc := $newbox/ancestor::ead:c[1]
let $newcid := $newc/@id

return
(for $x in $oldboxonly
    return
    if ($newcid[$x/@type=../ead:did[not(ead:unitid[@type="itemnumber"])]/ead:container/@type and $x/text()=../ead:did[not(ead:unitid[@type="itemnumber"])]/ead:container/text()])
    then replace value of node $x with text {$newcid[($x/@type=../ead:did[not(ead:unitid[@type="itemnumber"])]/ead:container/@type) and ($x/text()=../ead:did[not(ead:unitid[@type="itemnumber"])]/ead:container/text())]/../ead:did/ead:container/@id}
    else(),
for $v in $oldunitidonly
    return 
    if ($newcid[name($v)="unitid" and $v/text()=../ead:did/ead:container[@type="unitid"]/text()])
    then replace value of node $v with text {$newcid[name($v)="unitid" and $v/text()=../ead:did/ead:container[@type="unitid"]/text()]/../ead:did/ead:container/@id}
    else(),    
for $z in $oldboxwithunitid
    return
    if ($newcid[($z/@type=../ead:did/ead:container/@type) and ($z/text()=../ead:did/ead:container/text()) and ($z/../ead:unitid[@type="itemnumber"]/text()=../ead:did/ead:unitid[@type="itemnumber"]/text())])
    then replace value of node $z with text {$newcid[($z/@type=../ead:did/ead:container/@type) and $z/text()=../ead:did/ead:container/text() and ($z/../ead:unitid[@type="itemnumber"]/text()=../ead:did/ead:unitid[@type="itemnumber"]/text())]/../ead:did/ead:container/@id}
    else(),
for $t in $ead//ead:dsc[2]//ead:container[@id]
    return 
    (replace value of node $t/text() with text {$t/@id},
    delete node $t/@id)
)
