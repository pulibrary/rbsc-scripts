
xquery version "1.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare default element namespace "urn:isbn:1-931666-22-9";
declare copy-namespaces no-preserve, inherit;

declare variable $COLL as document-node()+ := collection("/db/pulfa/eads?recurse=yes;select=*.xml");

let $eadid := $COLL//ead:eadid
let $old-unittitles := 
    for $x in $COLL//ead:ead//ead:dsc//(ead:c|ead:c01|ead:c02|ead:c03|ead:c04|ead:c05|ead:c06|ead:c07|ead:c08|ead:c09|ead:c10|ead:c11|ead:c12)[not(ead:did//ead:unitdate)]/ead:did/ead:unittitle
    order by $x ascending
    return $x
let $old-unittitle :=
    for $x in $old-unittitles
(:    order by $x/ancestor::ead:ead//ead:eadid/text():)
    return <old-unittitle eadid="{$x/ancestor::ead:ead//ead:eadid/text()}">{normalize-space(string($x))}</old-unittitle>
let $plain-distinct-eadids :=
    for $x in distinct-values($old-unittitle/@eadid)
    return $x
let $plain-distinct-eadid :=
    for $x in $plain-distinct-eadids
    return $x
let $counts-per-eadids := 
    for $x in $plain-distinct-eadid
    order by count($old-unittitle/@eadid[.=$x]) descending
    return 
            if ($x = $old-unittitle/@eadid)
            then <occurrences per="{count($old-unittitle/@eadid[.=$x])}">{$x}</occurrences>
            else()

return(
<totalresults ead-count="{count($counts-per-eadids)}" component-count="{count($old-unittitle)}">
(:<eadids ead-count="{count($counts-per-eadids)}">{$counts-per-eadids}</eadids>,:)
<old-undateds component-count="{count($old-unittitle)}">
    {if(exists($old-unittitle))
    then $old-unittitle
    else()}
</old-undateds>
</totalresults>
)




