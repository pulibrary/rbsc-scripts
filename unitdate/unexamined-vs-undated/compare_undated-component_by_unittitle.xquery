xquery version "1.0";
declare default element namespace "urn:isbn:1-931666-22-9";
declare copy-namespaces no-preserve, no-inherit;

(:this query compares component id's from two input lists. Note that for any substantive project, it should
be rewritten to run on a logarithmic algorithm, as it currently does n^2. It runs for this particular purpose
(input files for 300k+ lines), so I didn't go through the effort of making it more efficient. But it may not
scale up much.:)

import module namespace functx="http://www.functx.com" 
    at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";

(:declare variable $CURRENT-COLL as document-node()+ := doc("../../rbscXSL/test2.xml");
declare variable $OLD-COLL as document-node()+ := doc("../../rbscXSL/test1.xml");:)
declare variable $CURRENT-COLL as document-node()+ := doc("../../rbscXSL/Data Cleanup various/unittitles_current.xml");
declare variable $OLD-COLL as document-node()+ := doc("../../rbscXSL/testALL.xml");
(:declare variable $CURRENT-COLL as document-node()+ := doc("/db/pulfa/xsl/unittitles_current.xml");
declare variable $OLD-COLL as document-node()+ := doc("/db/pulfa/xsl/unittitles_SVN4349.xml.xml");:)


let $current-unittitle := subsequence($CURRENT-COLL//unittitle, 1)
let $old-unittitle := subsequence($OLD-COLL//unittitle, 1)

let $results :=
for $x in $old-unittitle
where $x/string()=$current-unittitle/string() 
      and $x/@parent=$current-unittitle/@parent 
      and $x/@compare-id=$current-unittitle/@compare-id
      and $x/@eadid=$current-unittitle/@eadid
return $current-unittitle[@parent=$x/@parent 
      and @compare-id=$x/@compare-id
      and @eadid=$x/@eadid]
      
let $result :=
for $i in $results
order by $i/@id/string()
return
    <undated-item>{$i/@id/string()}</undated-item>
    
return 
<results count="{count($result)}">{$result}</results>

