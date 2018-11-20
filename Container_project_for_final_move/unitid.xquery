
xquery version "1.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare copy-namespaces no-preserve, inherit;

import module namespace functx="http://www.functx.com" 
    at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";

declare variable $COLL as document-node()+ := collection("../../../eads/mss");
(:declare variable $COLL as document-node()+ := collection("/db/pulfa/eads");:)

let $unitid1 := 
    for $x in $COLL//ead:dsc//ead:c[not(ead:did/ead:container)]/ead:did/ead:unitid
    order by $x//ancestor::ead:ead//ead:eadid/text()
    return
    if (not(matches($x, 'no\.')) and not(matches($x/ancestor::eadid, 'C0787')))
    then <item>{concat($x//ancestor::ead:ead//ead:eadid, ' (no. ',$x, ')')}</item>
    else <item>{concat($x//ancestor::ead:ead//ead:eadid, ' (', $x, ')')}</item>
    
let $unitid2 :=
    for $x in $COLL//ead:container[../ead:unitid]
    order by $x//ancestor::ead:ead//ead:eadid/text()
    return
    if (count($x/../ead:unitid)>1)
    then 
        (
        for $s in $x[../ead:unitid[@type="itemnumber"]]
        return 
            if (not(matches($s/../ead:unitid[@type="itemnumber"], 'no\.')) and not(matches($x/ancestor::eadid, 'C0787')))
            then <item>{concat($s//ancestor::ead:ead//ead:eadid, ' (no. ', $s/../ead:unitid[@type="itemnumber"], ') ', $s/@type, " ", $s)}</item>
            else <item>{concat($s//ancestor::ead:ead//ead:eadid, ' (', $s/../ead:unitid[@type="itemnumber"], ') ', $s/@type, " ", $s)}</item>,
        for $v in $x[../ead:unitid[@type="accessionnumber"]]
        return
            if (not(matches($v/../ead:unitid[@type="accessionnumber"][1], 'no\.')) and not(matches($x/ancestor::eadid, 'C0787')))
            then <item>{concat($v//ancestor::ead:ead//ead:eadid, ' (no. ', $v/../ead:unitid[@type="accessionnumber"][1], ') ', $v/@type, " ", $v)}</item>
            else <item>{concat($v//ancestor::ead:ead//ead:eadid, ' (', $v/../ead:unitid[@type="accessionnumber"][1], ') ', $v/@type, " ", $v)}</item>
        )
    else 
        if (not(matches($x/../ead:unitid, 'no\.')) and not(matches($x/ancestor::eadid, 'C0787')))
        then <item>{concat($x//ancestor::ead:ead//ead:eadid, ' (no. ', $x/../ead:unitid, ') ', $x/@type, " ", $x)}</item>
        else <item>{concat($x//ancestor::ead:ead//ead:eadid, ' (', $x/../ead:unitid, ') ', $x/@type, " ", $x)}</item>


return 
($unitid1, $unitid2)


    


