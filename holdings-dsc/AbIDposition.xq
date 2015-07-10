xquery version "1.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare copy-namespaces no-preserve, inherit;

import module namespace functx="http://www.functx.com" 
    at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";

(:declare variable $EAD as document-node()+ := doc("../../eads/mss/C1091.EAD.xml");:)
(:declare variable $EAD as document-node()* := collection("../../eads/mss")/doc(document-uri(.));:)
declare variable $EAD as document-node()* := doc("sample_input.EAD.xml");


for $x in $EAD//ead:ead//ead:dsc[2]
    let $component := $x//ead:c
    let $eadid := $x//ancestor::ead:ead//ead:eadid
    return
    for $c at $pos in $component
    return
    if (not($c/@id))
    then insert node attribute id {concat($eadid, "_i", $pos)} into $c
    else()

