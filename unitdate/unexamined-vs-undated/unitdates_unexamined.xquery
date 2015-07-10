
xquery version "1.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare default element namespace "urn:isbn:1-931666-22-9";
declare copy-namespaces no-preserve, inherit;

declare variable $COLL as document-node()+ := collection("/C:/Users/kbolding/Documents/SVN%20Working%20Copies/trunk/eads/mss?recurse=yes;select=*.xml");

let $unitdates as element()+ := 
    for $x in $COLL//ead:ead//ead:dsc//(ead:c)[ead:did//unitdate[@certainty]]/ead:did/ead:unitdate
    return
    <unitdate eadid="{$x/ancestor::ead:ead//ead:eadid/text()}">{normalize-space(string($x))}</unitdate>
let $plain-distinct-eadids :=
    for $x in distinct-values($unitdates/@eadid)
    return $x
let $plain-distinct-eadid :=
    for $x in $plain-distinct-eadids
    return $x
let $counts-per-eadids := 
    for $x in $plain-distinct-eadid
    order by count($unitdates/@eadid[.=$x]) descending
    return 
            if ($x = $unitdates/@eadid)
            then <occurrences per="{count($unitdates/@eadid[.=$x])}">{$x}</occurrences>
            else()

return(
<totalresults ead-count="{count($counts-per-eadids)}" component-count="{count($unitdates)}">
<eadids ead-count="{count($counts-per-eadids)}">{$counts-per-eadids}</eadids>
</totalresults>
)