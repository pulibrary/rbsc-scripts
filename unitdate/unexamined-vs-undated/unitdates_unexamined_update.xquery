xquery version "1.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare copy-namespaces no-preserve, inherit;

declare variable $COLL as document-node()+ := collection("../../eads/mss")/doc(document-uri(.));
declare variable $FILE as document-node()+ := doc("compare_undated-component_by_unittitle-results.xml");

let $coll-comp := $COLL//ead:c
let $file-id := $FILE//undated-item/string()

for $c in $coll-comp[./@id/string()=$file-id]
let $unitdate := $c/ead:did/ead:unitdate
return 
replace value of node $unitdate with <text>unexamined</text>