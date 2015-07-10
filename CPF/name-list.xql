xquery version "1.0";

declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace eac = "urn:isbn:1-931666-33-4";
declare namespace xlink = "http://www.w3.org/1999/xlink";

(:declare default element namespace "urn:isbn:1-931666-33-4";:)

declare variable $COLL as document-node()+ := collection("/db/ead");

declare function local:remove-subdivisions($name as element()) 
as element() {
    <name type="{local-name($name)}">{normalize-space(tokenize($name, "\s?(\-{2}|–)\s?")[1])}</name>
};

let $names as element()+ := $COLL//((ead:persname|ead:corpname|ead:famname|ead:subject[matches(@encodinganalog, "^[67][01]{2}$")])[not(ancestor::ead:index)])
let $filtered-names as element()+ :=
    for $name in $names
    return local:remove-subdivisions($name)
let $distinct-names as element()+ :=
    for $name in distinct-values($filtered-names)
    let $type as xs:string* := distinct-values($filtered-names[. eq $name]/@type/string())
    order by $name
    return
    <name count="{count($filtered-names[. eq $name])}" type="{string-join($type, ' ')}">{$name}</name>
return
<names>
    {$distinct-names}
</names>

 