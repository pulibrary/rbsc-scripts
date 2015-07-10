
xquery version "1.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare default element namespace "urn:isbn:1-931666-22-9";
declare copy-namespaces no-preserve, inherit;

declare variable $COLL as document-node()+ := collection("../../eads/lae");

let $eadid := $COLL//ead:eadid
let $unittitles as element()+ := 
    for $x in $COLL//ead:ead//ead:dsc//(ead:c)[ead:did//unitdate[matches(., 'undated')] or not(ead:did//ead:unitdate)]/ead:did/ead:unittitle
    return
    <unittitle id="{$x/../../@id}" compare-id="{number(substring-after($x/../../@id, '_c'))}" eadid="{$x/ancestor::ead:ead//ead:eadid/text()}" parent="{normalize-space(lower-case(replace($x/ancestor::ead:c[2]/ead:did/ead:unittitle, '\p{P}|\p{Z}|\p{N}|\p{M}|\p{S}|\n', '')))}">{normalize-space(lower-case(replace($x, '\p{P}|\p{Z}|\p{N}|\p{M}|\p{S}|\n', '')))}</unittitle>

return(
<totalresults  component-count="{count($unittitles)}">
 {
 for $t in $unittitles
 order by string($t)
return if ($t/text()) then $t else () 
 }
    

</totalresults>
)


