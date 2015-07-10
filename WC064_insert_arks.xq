xquery version "1.0";

declare namespace ead="urn:isbn:1-931666-22-9";

(:This xQuery Update inserts arks from WC064_ARKS.xml:)
(:If running on Linux box, make sure support for XQ1.1/3.0 is DISabled:)

declare variable $EAD as document-node()* := doc("WC064.EAD.xml");
declare variable $ARKS as document-node()* := doc("WC064_ARKS.xml");

let $did := $EAD//ead:did
let $ark_item := $ARKS//item

for $c in $did[ead:unitid/string()=$ark_item/unitid/string()]
return
insert node $ark_item[unitid/string()=$c/ead:unitid/string()]/dao as last into $c