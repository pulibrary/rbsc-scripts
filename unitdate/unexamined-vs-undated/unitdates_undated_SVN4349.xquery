
xquery version "1.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare default element namespace "urn:isbn:1-931666-22-9";
declare copy-namespaces no-preserve, inherit;
declare option ead:omit-xml-declaration "yes";

declare variable $COLL as document-node()+ := collection("../../db_4349_cid/pulfa/publicpolicy");
(:declare variable $COLL as document-node()+ := collection("/db/pulfa/eads");:)

let $old-unittitles as element()+:= 
    for $x in $COLL//ead:ead//ead:dsc//(ead:c|ead:c01|ead:c02|ead:c03|ead:c04|ead:c05|ead:c06|ead:c07|ead:c08|ead:c09|ead:c10|ead:c11|ead:c12)[not(ead:did//ead:unitdate)]/ead:did/ead:unittitle
    (:return <unittitle compare-id="{$x/../../@id}" eadid="{$x/ancestor::ead:ead//ead:eadid/text()}" parent="{normalize-space(lower-case(replace($x/(ancestor::ead:c|ancestor::ead:c01|ancestor::ead:c02|ancestor::ead:c03|ancestor::ead:c04|ancestor::ead:c05|ancestor::ead:c06|ancestor::ead:c07|ancestor::ead:c08|ancestor::ead:c09|ancestor::ead:c10|ancestor::ead:c11|ancestor::ead:c12)[2]/ead:did/ead:unittitle, '\p{P}|\p{Z}|\p{N}|\p{M}|\p{S}|\n', '')))}">{normalize-space(string(lower-case(replace($x, '\p{P}|\p{Z}|\p{N}|\p{M}|\p{S}|\n', ''))))}</unittitle>
:)
return <unittitle compare-id="{$x/../../@id}" 
                eadid="{$x/ancestor::ead:ead//ead:eadid/text()}" 
                parent="{normalize-space(lower-case(replace($x/ancestor::*[position()=3 and matches(name(), 'c|c01|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12')]/ead:did/ead:unittitle, '\p{P}|\p{Z}|\p{N}|\p{M}|\p{S}|\n', '')))}">{normalize-space(string(lower-case(replace($x, '\p{P}|\p{Z}|\p{N}|\p{M}|\p{S}|\n', ''))))}</unittitle>

return(
<totalresults component-count="{count($old-unittitles)}">
{
 for $t in $old-unittitles
 order by string($t)
 return if ($t/text()) then $t else()
}
</totalresults>
)


