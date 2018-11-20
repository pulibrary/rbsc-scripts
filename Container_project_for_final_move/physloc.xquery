xquery version "1.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare default element namespace "urn:isbn:1-931666-22-9";
declare copy-namespaces no-preserve, inherit;

import module namespace functx="http://www.functx.com" 
    at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";

declare variable $COLL as document-node()+ := collection("../../../eads/mss");

let $physloc := distinct-values($COLL//ead:physloc[@type="code"]/text())

return $physloc