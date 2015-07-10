xquery version "1.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare copy-namespaces no-preserve, inherit;

import module namespace functx="http://www.functx.com" 
    at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";

declare variable $EAD as document-node()+ := collection("../../../eads/mudd/univarchives")/doc(document-uri(.));
(:
collection("../../eads/mss")/doc(document-uri(.));
doc("sample_input.EAD.xml");
:)

let $container := $EAD//ead:container[@type="box" or (not(preceding-sibling::ead:container or following-sibling::ead:container) and not(matches(@type, "folio|column|page")))] 
(:boxes OR any standalone container elements except folio, column. What about the copy boxes, though? Need to exclude reel? Also, possibly, C0719 (graphic arts item):)
for $x in $container[matches(., "-")]
    let $type := $x/@type
    return
    if (count(tokenize($x, "-")) = 2)
    then
        let $min := xs:integer(normalize-space(tokenize($x, "-")[1]))
        let $max := xs:integer(normalize-space(tokenize($x, "-")[2]))
        return 
            for $i in $min to $max
            order by $i descending
            return(
            insert node <container type="{$type}" xmlns="urn:isbn:1-931666-22-9">{$i}</container> as first into $x/../self::ead:did,
            delete node $x)
    else()