xquery version "1.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare copy-namespaces no-preserve, inherit;

import module namespace functx="http://www.functx.com" 
    at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";
    
(:Matches items in first and second dsc and puts in pointers.:)

declare variable $EAD as document-node()+ := doc("sample_input.EAD.xml");

let $oldbox := $EAD//ead:dsc[1]//ead:container[matches(@type, "box|volume|carton") or (count(../ead:container)=1 and not(matches(@type, "folio|column|page"))) and not(../ead:unitid)]
let $oldunitid := $EAD//ead:dsc[1]//ead:unitid[@type="itemnumber" and not(../ead:container)]
let $newbox := $EAD//ead:dsc[2]//ead:container
let $newboxid := $newbox/@id
let $newc := $newbox/ancestor::ead:c[1]
let $newcid := $newc/@id

return
if ($oldbox)
then
    for $x in $oldbox
    return
    (delete node $newboxid,
    replace node $x with <container xmlns="urn:isbn:1-931666-22-9"><ptr target="{$newcid[../ead:did/ead:container/@id=$x/text()]/string()}"/></container>,
    (:process subordinate containers:)
    if ($x/../ead:container[not(matches(@type, "box|volume|carton|reel") or (count(../ead:container)=1 and not(matches(@type, "folio|column|page"))))])
    then
        for $c in $x/../ead:container[not(matches(@type, "box|volume|carton|reel") or (count(../ead:container)=1 and not(matches(@type, "folio|column|page"))))]
        return
            if ($c/@parent)
            then 
                for $i in $c[../ead:container/text()=$newboxid]/@parent 
                return
                replace node $i with attribute parent {$newcid[../ead:did/ead:container/@id=$x/text()]/string()}
            else(insert node attribute parent {$newcid[../ead:did/ead:container/@id=$x/text()]/string()} into $c)
    else()
    )
 else if ($oldunitid)
 then
    for $v in $oldunitid
    return
    (delete node $newboxid,
    replace node $v with <unitid xmlns="urn:isbn:1-931666-22-9"><ptr target="{$newcid[../ead:did/ead:container/@id=concat($v/@type, " ", $v/text())]/string()}"/></unitid>) (:is the space here really true?:)
else()
