xquery version "1.0";

declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace eac-cpf = "urn:isbn:1-931666-33-4";
declare namespace xlink = "http://www.w3.org/1999/xlink";

declare copy-namespaces no-preserve, inherit;

declare variable $source as document-node()* := doc("C://home/heberlei/workspace/rbscXSL/resourceRelation.xml");
declare variable $target as document-node() := collection("C://home/heberlei/workspace/eacs");

for $resourceRelation as element() in $target//eac-cpf:resourceRelation
let $call-nr := substring-after($resourceRelation/@xlink:href, 'collections/'),
    $type := $resourceRelation/@resourceRelationType, 
    $new := <resourceRelation xlink:type="simple" xlink:href="http://findingaids.princeton.edu/collections/{$call-nr}" resourceRelationType="{$type}"/>
where ($call-nr eq $source//description)
return  
insert node ($new) after $target//eac-cpf:resourceRelation[./@xlink:href eq $new/@xlink:href]
