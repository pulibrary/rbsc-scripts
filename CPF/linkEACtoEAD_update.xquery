xquery version "1.0";

declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace eac-cpf = "urn:isbn:1-931666-33-4";
declare namespace xlink = "http://www.w3.org/1999/xlink";

import module namespace functx="http://www.functx.com" 
    at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";

declare copy-namespaces no-preserve, inherit;

declare variable $source as document-node()* := collection("C://home/heberlei/workspace/eacs");
declare variable $target as document-node() := collection("C://home/heberlei/workspace/eads");

for $resourceRelation as element() in $source//eac-cpf:resourceRelation
let $url := 
    if (not(contains(substring-after($resourceRelation/@xlink:href, 'collections/'), '/c')))
    then (substring-after($resourceRelation/@xlink:href, 'collections/'))
    else if (contains(substring-after($resourceRelation/@xlink:href, 'collections/'), '/c'))
    then functx:substring-after-last($resourceRelation/@xlink:href, '/')
    else (),
    $new := <foo/>
where (translate($url, '/', '_') eq $target//ead:c/@id)
return  
insert node ($new) after $target
