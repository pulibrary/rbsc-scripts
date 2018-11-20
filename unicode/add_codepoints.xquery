xquery version "3.0";
declare copy-namespaces no-preserve, inherit;

import module namespace functx = "http://www.functx.com"
at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";

declare variable $FILE as document-node()+ := doc("cotsen.xml");

let $codepoints := $FILE//codepoints

for $i in $codepoints//codepoint
return
insert node attribute codepoint {string-to-codepoints($i)} into $i