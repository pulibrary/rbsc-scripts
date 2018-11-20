xquery version "3.0";
declare copy-namespaces no-preserve, inherit;

import module namespace functx = "http://www.functx.com"
at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";

declare variable $FILE as document-node()+ := doc("nonBasicLatin-cids.xml");

let $codepoints := $FILE//codepoints

for $i in $codepoints//codepoint
order by $i/number(@codepoint) ascending
return $i