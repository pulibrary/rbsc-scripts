xquery version "1.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare copy-namespaces no-preserve, inherit;

import module namespace functx="http://www.functx.com" 
    at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";

declare variable $COLL as document-node()+ := collection("/db/pulfa/eads"); (:collection("../../eads_SVN_4349/mss")/doc(document-uri(.));:) (:?recurse=yes;select=*.xml:)

for $x in $COLL//ead:ead
    let $component := 
        $x//(ead:c|ead:c01|ead:c02|ead:c03|ead:c04|ead:c05|ead:c06|ead:c07|ead:c08|ead:c09|ead:c10|ead:c11|ead:c12)

    return
    for $c at $pos in $component
    return
    insert node attribute id {$pos} into $c

