
xquery version "1.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare copy-namespaces no-preserve, inherit;

import module namespace functx="http://www.functx.com" 
    at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";

declare variable $COLL as document-node()+ := collection("../../../eads?recurse=yes;select=*.xml");
(:declare variable $COLL as document-node()+ := collection("/db/pulfa/eads");:)

let $container := 
    for $x in $COLL//ead:container[matches(@type, "box|volume|carton|reel") or (count(../ead:container)=1 
                                    and not(matches(@type, "folio|column|page")))
                                    and not(../ead:unitid)]
    order by $x//ancestor::ead:ead//ead:eadid/text()
    return     
    <item><eadid>{$x//ancestor::ead:ead//ead:eadid/text()}</eadid><enum>{concat($x/@type, ' ', $x)}</enum></item>

let $unitid1 := 
    for $x in $COLL//ead:dsc//ead:c[not(ead:did/ead:container)]/ead:did/ead:unitid
    order by $x//ancestor::ead:ead//ead:eadid/text()
    return
    if (not(matches($x, 'no\.')) and not(matches($x//ancestor::ead:ead//ancestor::ead:eadid, '(C0787)|(C0744.06)')))
    then <item><eadid>{$x//ancestor::ead:ead//ead:eadid/text()}</eadid><enum>{concat($x//ancestor::ead:ead//ead:eadid, ' (no. ',$x, ')')}</enum></item>
    else <item><eadid>{$x//ancestor::ead:ead//ead:eadid/text()}</eadid><enum>{concat($x//ancestor::ead:ead//ead:eadid, ' (', $x, ')')}</enum></item>
    
let $unitid2 :=
    for $x in $COLL//ead:container[matches(@type, "box|volume|carton|reel") or (count(../ead:container)=1 
                                    and not(matches(@type, "folio|column|page")))
                                    and ../ead:unitid]
    order by $x//ancestor::ead:ead//ead:eadid/text()
    return
    if (count($x/../ead:unitid)>1)
    then 
        (
        for $s in $x[../ead:unitid[@type="itemnumber"]]
        return 
            if (not(matches($s, 'no\.')) and not(matches($s//ancestor::ead:ead//ancestor::ead:eadid, '(C0787)|(C0744.06)')))
            then <item><eadid>{$x//ancestor::ead:ead//ead:eadid/text()}</eadid><enum>{concat($s//ancestor::ead:ead//ead:eadid, ' (no. ', $s/../ead:unitid[@type="itemnumber"], ') ', $s/@type, " ", $s)}</enum></item>
            else <item><eadid>{$x//ancestor::ead:ead//ead:eadid/text()}</eadid><enum>{concat($s//ancestor::ead:ead//ead:eadid, ' (', $s/../ead:unitid[@type="itemnumber"], ') ', $s/@type, " ", $s)}</enum></item>,
        for $v in $x[../ead:unitid[@type="accessionnumber"]]
        return
            if (not(matches($v[1], 'no\.')) and not(matches($v//ancestor::ead:ead//ancestor::ead:eadid, '(C0787)|(C0744.06)')))
            then <item><eadid>{$x//ancestor::ead:ead//ead:eadid/text()}</eadid><enum>{concat($v//ancestor::ead:ead//ead:eadid, ' (no. ', $v/../ead:unitid[@type="accessionnumber"][1], ') ', $v/@type, " ", $v)}</enum></item>
            else <item><eadid>{$x//ancestor::ead:ead//ead:eadid/text()}</eadid><enum>{concat($v//ancestor::ead:ead//ead:eadid, ' (', $v/../ead:unitid[@type="accessionnumber"][1], ') ', $v/@type, " ", $v)}</enum></item>
        )
    else 
        if (not(matches($x/../ead:unitid, 'no\.')) and not(matches($x//ancestor::ead:ead//ancestor::ead:eadid, '(C0787)|(C0744.06)')))
        then <item><eadid>{$x//ancestor::ead:ead//ead:eadid/text()}</eadid><enum>{concat($x//ancestor::ead:ead//ead:eadid, ' (no. ', $x/../ead:unitid, ') ', $x/@type, " ", $x)}</enum></item>
        else <item><eadid>{$x//ancestor::ead:ead//ead:eadid/text()}</eadid><enum>{concat($x//ancestor::ead:ead//ead:eadid, ' (', $x/../ead:unitid, ') ', $x/@type, " ", $x)}</enum></item>


return 
($container, $unitid1, $unitid2)


    


