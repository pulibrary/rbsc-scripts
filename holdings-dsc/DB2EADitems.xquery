xquery version "1.0";
declare copy-namespaces no-preserve, inherit;

import module namespace functx="http://www.functx.com" 
    at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";

declare namespace ead="urn:isbn:1-931666-22-9";

(:This update query will create a second dsc with items for each Voyager record for which a perfect match can be established in EAD:)

(:declare variable $EAD as document-node()* := doc("../../eads/mss/C0001.EAD.xml"); :)
declare variable $EAD as document-node()* := collection("../../eads/mss")/doc(document-uri(.));
declare variable $VOY as document-node()* := doc("MatchingItems_5-6.xml");

let $item := $VOY//item

let $container := 
    for $x in $EAD//ead:container[matches(@type, "box|volume|carton|reel") or (count(../ead:container)=1 
                                    and not(matches(@type, "folio|column|page")))
                                    and not(../ead:unitid)]
    order by $x//ancestor::ead:ead//ead:eadid/text()
    return     
    <eaditem><enum>{lower-case(concat($x//ancestor::ead:ead//ead:eadid/text(), " ", $x/@type, ' ', $x/text()))}</enum><type>{$x/@type/string()}</type><value>{$x/text()}</value></eaditem>

let $unitid1 := 
    for $x in $EAD//ead:dsc//ead:c[not(ead:did/ead:container)]/ead:did/ead:unitid
    order by $x//ancestor::ead:ead//ead:eadid/text()
    return
    if (not(matches($x, 'no\.')) and not(matches($x//ancestor::ead:ead//ancestor::ead:eadid, '(C0787)|(C0744.06)')))
    then <eaditem><enum>{lower-case(concat($x//ancestor::ead:ead//ead:eadid, ' (no. ',$x/text(), ')'))}</enum><type>unitid</type><value>{$x/text()}</value></eaditem>
    else <eaditem><enum>{lower-case(concat($x//ancestor::ead:ead//ead:eadid, ' (', $x/text(), ')'))}</enum><type>unitid</type><value>{$x/text()}</value></eaditem>
    
let $unitid2 :=
    for $x in $EAD//ead:container[matches(@type, "box|volume|carton|reel") or (count(../ead:container)=1 
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
            then <eaditem><enum>{lower-case(concat($s//ancestor::ead:ead//ead:eadid, ' (no. ', $s/../ead:unitid[@type="itemnumber"]/text(), ') ', $s/@type, " ", $s/text()))}</enum><unitid>{$s/../ead:unitid[@type="itemnumber"]/text()}</unitid><type>{$s/@type/string()}</type><value>{$s/text()}</value></eaditem>
            else <eaditem><enum>{lower-case(concat($s//ancestor::ead:ead//ead:eadid, ' (', $s/../ead:unitid[@type="itemnumber"]/text(), ') ', $s/@type, " ", $s/text()))}</enum><unitid>{$s/../ead:unitid[@type="itemnumber"]/text()}</unitid><type>{$s/@type/string()}</type><value>{$s/text()}</value></eaditem>,
        for $v in $x[../ead:unitid[@type="accessionnumber"]]
        return
            if (not(matches($v[1], 'no\.')) and not(matches($v//ancestor::ead:ead//ancestor::ead:eadid, '(C0787)|(C0744.06)')))
            then <eaditem><enum>{lower-case(concat($v//ancestor::ead:ead//ead:eadid, ' (no. ', $v/../ead:unitid[@type="accessionnumber"][1]/text(), ') ', $v/@type, " ", $v/text()))}</enum><unitid>{$v/../ead:unitid[@type="accessionnumber"][1]/text()}</unitid><type>{$v/@type/string()}</type><value>{$v/text()}</value></eaditem>
            else <eaditem><enum>{lower-case(concat($v//ancestor::ead:ead//ead:eadid, ' (', $v/../ead:unitid[@type="accessionnumber"][1]/text(), ') ', $v/@type, " ", $v/text()))}</enum><unitid>{$v/../ead:unitid[@type="accessionnumber"][1]/text()}</unitid><type>{$v/@type/string()}</type><value>{$v/text()}</value></eaditem>
        )
    else 
        if (not(matches($x/../ead:unitid, 'no\.')) and not(matches($x//ancestor::ead:ead//ancestor::ead:eadid, '(C0787)|(C0744.06)')))
        then <eaditem><enum>{lower-case(concat($x//ancestor::ead:ead//ead:eadid, ' (no. ', $x/../ead:unitid/text(), ') ', $x/@type, " ", $x/text()))}</enum><unitid>{$x/../ead:unitid/text()}</unitid><type>{$x/@type/string()}</type><value>{$x/text()}</value></eaditem>
        else <eaditem><enum>{lower-case(concat($x//ancestor::ead:ead//ead:eadid, ' (', $x/../ead:unitid/text(), ') ', $x/@type, " ", $x/text()))}</enum><unitid>{$x/../ead:unitid/text()}</unitid><type>{$x/@type/string()}</type><value>{$x/text()}</value></eaditem>
        
let $enum := functx:distinct-deep(($container, $unitid1, $unitid2))

let $new-c := 
    for $c in $enum
    let $containertype := 
        if(matches($c//type/text(), "box|carton")) 
        then "box" 
        else  if(matches($c//type/text(), "volume")) 
                then "volume" 
                else  if(matches($c//type/text(), "unitid")) 
                        then "unitid" 
                        else $c/type        
    let $physicalbox := if($c//value[.!=""]) then <container type="{$containertype}">{$c//value/text()}</container> else()
    let $barcode := if($item[normalize-space(lower-case(ENUM/text()))=$c//enum]/ITEM_BARCODE) then <unitid type="barcode">{$item[normalize-space(lower-case(ENUM/text()))=$c//enum]/ITEM_BARCODE/text()}</unitid> else()
    let $physloc := if($item[normalize-space(lower-case(ENUM/text()))=$c//enum]/MFHD_LOCATION) then <physloc type="code">{$item[normalize-space(lower-case(ENUM/text()))=$c//enum]/MFHD_LOCATION/text()}</physloc> else()
    let $unitid := if($c//unitid[.!=""]) then <unitid type="itemnumber">{$c//unitid/text()}</unitid> else()
    let $collectioncode := <collectioncode>{substring-before($c//enum, " ")}</collectioncode>
    
    return
    for $i in $item[normalize-space(lower-case(ENUM/text()))=$c//enum]
    return
    <c level="otherlevel" otherlevel="physicalitem" xmlns="urn:isbn:1-931666-22-9">
        <did>{
                $unitid,
                $physicalbox,
                $barcode,
                $physloc,
                $collectioncode
        }</did>
    </c>
    
let $collectioncode := $new-c//collectioncode

let $newdsc :=  
    for $i in $EAD//ead:eadid
    return <dsc type="othertype" othertype="physicalholdings" xmlns="urn:isbn:1-931666-22-9" id="{$i}">
    {for $y in $new-c//$collectioncode[string()=lower-case($i/string())]
    return $y[string()=lower-case($i/string())]/../..}
    </dsc>

let $dscid := $newdsc//@id

for $e in $EAD
    return 
    for $t in $newdsc//$dscid[string()=$e//ead:eadid/string()]
    return
    (insert node $t[string()=$e//ead:eadid/string()]/.. as last into $e[.//ead:eadid/string()=$t//$dscid/string()]//ead:archdesc
    )
    (:still need to remove collectioncode and dsc/@id--they're constructed nodes, so need to be removed outside this query:)
    
    
    
