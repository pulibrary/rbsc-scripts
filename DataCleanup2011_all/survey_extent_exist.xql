xquery version "1.0";

declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace eac = "urn:isbn:1-931666-33-4";
declare namespace xlink = "http://www.w3.org/1999/xlink";

(:declare default element namespace "urn:isbn:1-931666-33-4";:)

declare variable $COLL as document-node()+ := collection("/db/ead");

(:
declare variable $COLL as document-node()+ := collection("/C:/Documents%20and%20Settings/heberlei/My%20Documents/SVN%20Working%20Copies/trunk/EAD2samples/ead");
:)

let $extents as element()+ := $COLL//(ead:extent)
return $extents



 