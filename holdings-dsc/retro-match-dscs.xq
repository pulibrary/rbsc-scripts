xquery version "1.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare copy-namespaces no-preserve, inherit;

import module namespace functx="http://www.functx.com" 
    at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";
    
(:Matches items in first and second dsc and puts in pointers.:)

(:declare variable $EAD as document-node()+ := doc("../../eads/mss/RTC01.EAD.xml");:)
(:declare variable $ead as document-node()* := collection("../../eads/mss")/doc(document-uri(.));:)
declare variable $EAD as document-node()* := doc("sample_input.EAD.xml");

for $ead in $EAD
return

let $oldboxonly := $EAD//ead:dsc[1]//ead:did[not(ead:unitid)]/ead:container[matches(@type, "box|volume|carton") or (count(../ead:container)=1 and not(matches(@type, "folio|column|page")))]
let $oldunitidonly := $EAD//ead:dsc[1]//ead:did[not(ead:container)]/ead:unitid[@type="itemnumber"]
let $oldboxwithunitid := $EAD//ead:dsc[1]//ead:did[ead:unitid]/ead:container[matches(@type, "box|volume|carton") or (count(../ead:container)=1 and not(matches(@type, "folio|column|page")))]
let $newbox := $EAD//ead:dsc[2]//ead:container
let $oldbox := $EAD//ead:dsc[1]//ead:container
let $newc := $newbox/ancestor::ead:c[1]
let $newcid := $newc/@id
let $extraunitid := $newc/ead:did/ead:unitid[@type="itemnumber"]

return
(for $x in $oldboxonly
    return
(:process subordinate containers first:)
        if (count($x/../ead:container)>1 and $x/../ead:container[not(matches(@type, "box|volume|carton|folio|column|page"))])
        then(
            if (count($x/../ead:container[matches(@type, "box|carton")])=1 and count($x/../ead:container[matches(@type, "folder")])=1)
            then            
                    (for $c in $x/../ead:container[count($x/../ead:container)>1 and not(matches(@type, "box|volume|carton|folio|column|page"))]
                    return
                        if ($newcid[$x/@type=../ead:did[not(ead:unitid[@type="itemnumber"])]/ead:container/@type and $x/text()=../ead:did[not(ead:unitid[@type="itemnumber"])]/ead:container/text()])
                        then
                            if ($c/@parent)
                            then 
                                for $i in $c[../ead:container/text()=$newbox/text()]/@parent 
                                return
                                  (replace node $i with attribute parent {$newcid[$x/@type=../ead:did[not(ead:unitid[@type="itemnumber"])]/ead:container/@type and $x/text()=../ead:did[not(ead:unitid[@type="itemnumber"])]/ead:container/text()]/string()},
                                            delete node $x)
                            else(insert node attribute parent {$newcid[$x/@type=../ead:did[not(ead:unitid[@type="itemnumber"])]/ead:container/@type and $x/text()=../ead:did[not(ead:unitid[@type="itemnumber"])]/ead:container/text()]/string()} into $c,
                                   delete node $x)
                       else()
                    )
             else (
             if ((count($x/../ead:container)>2 and (count($x/../ead:container[matches(@type, "box|carton")])>1 and $x/../ead:container[matches(@type, "folder")]) or count($x/../ead:container[matches(@type, "folder")])>1))
             then 
                    (for $c in $x/following-sibling::ead:container[1][matches(@type, "folder")]
                    return
                        if ($newcid[$x/@type=../ead:did[not(ead:unitid[@type="itemnumber"])]/ead:container/@type and $x/text()=../ead:did[not(ead:unitid[@type="itemnumber"])]/ead:container/text()])
                        then
                            if ($c/@parent)
                            then
                                for $i in $c/@parent
                                return
                                    (replace node $i with attribute parent {$newcid[../ead:did/ead:container/@type=$c/preceding-sibling::ead:container[matches(@type, "box|carton")][1]/@type and ../ead:did/ead:container/text()=$c/preceding-sibling::ead:container[matches(@type, "box|carton")][1]/text()]/string()},
                                            delete node $x[matches(following-sibling::ead:container[1]/@type, "folder")])
                            else (insert node attribute parent {$newcid[../ead:did/ead:container/@type=$c/preceding-sibling::ead:container[matches(@type, "box|carton")][1]/@type and ../ead:did/ead:container/text()=$c/preceding-sibling::ead:container[matches(@type, "box|carton")][1]/text()]/string()} into $c,
                                     delete node $x[matches(following-sibling::ead:container[1]/@type, "folder")])
                        else(),
                    for $c in $x/following-sibling::ead:container[1][not(matches(@type, "folder"))]
                    return replace node $c with <container xmlns="urn:isbn:1-931666-22-9"><ptr target="{$newcid[../ead:did/ead:container/@type=$c/preceding-sibling::ead:container[matches(@type, "box|carton")][1]/@type and ../ead:did/ead:container/text()=$c/preceding-sibling::ead:container[matches(@type, "box|carton")][1]/text()]}"/></container>,
                    delete node $x[not(matches(following-sibling::ead:container[1]/@type, "folder"))]
                    )
             else ()
             )
                 )
 (:if no subordinate containers, proceed with replacement of box/volume :) 
          else if ($newcid[$x/@type=../ead:did[not(ead:unitid[@type="itemnumber"])]/ead:container/@type and $x/text()=../ead:did[not(ead:unitid[@type="itemnumber"])]/ead:container/text()])
          then
            replace node $x with <container xmlns="urn:isbn:1-931666-22-9"><ptr target="{$newcid[($x/@type=../ead:did[not(ead:unitid[@type="itemnumber"])]/ead:container/@type) and ($x/text()=../ead:did[not(ead:unitid[@type="itemnumber"])]/ead:container/text())]}"/></container>
          else(),
(:if no containers but unitid, insert pointer:)
for $v in $oldunitidonly
    return 
    if ($newcid[name($v)="unitid" and $v/text()=../ead:did/ead:container[@type="unitid"]/text()])
    then replace node $v with <unitid xmlns="urn:isbn:1-931666-22-9" type="{$v/@type}"><ptr target="{$newcid[name($v)="unitid" and $v/text()=../ead:did/ead:container[@type="unitid"]/text()]}"/></unitid>
    else(),    
(:if unitid AND containers:)
for $z in $oldboxwithunitid
(:process subordinate containers first:)
    return
    if (count($z/../ead:container)>1 and $z/../ead:container[not(matches(@type, "box|volume|carton|folio|column|page"))])
    then(
        for $i in $z/../ead:container[count($z/../ead:container)>1 and not(matches(@type, "box|volume|carton|folio|column|page"))]
        return
        if ($newcid[($z/@type=../ead:did/ead:container/@type) and ($z/text()=../ead:did/ead:container/text())])
        then
            if($i/@parent)
            then
                for $x in $i[../ead:container/text()=$newbox/text()]/@parent 
                return (replace node $x with attribute parent {$newcid[($z/@type=../ead:did/ead:container/@type) and ($z/text()=../ead:did/ead:container/text())]/string()},
                           delete node $z)
            else (insert node attribute parent {$newcid[($z/@type=../ead:did/ead:container/@type) and ($z/text()=../ead:did/ead:container/text())]/string()} into $i,
                    delete node $z)
    else()
    )
(:if no subordinate containers, proceed with replacement of box/volume:)
    else if ($newcid[($z/@type=../ead:did/ead:container/@type) and ($z/text()=../ead:did/ead:container/text()) and ($z/../ead:unitid[@type="itemnumber"]/text()=../ead:did/ead:unitid[@type="itemnumber"]/text())])
    then
       replace node $z with <container xmlns="urn:isbn:1-931666-22-9"><ptr target="{$newcid[($z/@type=../ead:did/ead:container/@type) and $z/text()=../ead:did/ead:container/text() and ($z/../ead:unitid[@type="itemnumber"]/text()=../ead:did/ead:unitid[@type="itemnumber"]/text())]}"/></container>
    else(),
(:finish by deleting the redundant dsc[2]//unitid:)
delete node $extraunitid
)
