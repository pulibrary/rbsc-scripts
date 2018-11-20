xquery version "1.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare copy-namespaces no-preserve, inherit;

import module namespace functx="http://www.functx.com" 
    at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";

declare variable $EAD as document-node()+ := doc("file:///C:/Users/heberlei/Documents/SVN%20Working%20Copies/trunk/eads/mss/C0183.EAD.xml");

let $component-original := $EAD//ead:container[matches(., '(original)')]/ancestor::ead:c[1]

for $i in $component-original
return
(replace node $i with 
(<c level="file" xmlns="urn:isbn:1-931666-22-9">
        <did>
            {$i/ead:did/*[not(self::ead:container)]}
        </did>
        {$i/*[not(self::ead:did)]}
    <c level="{$i/@level}">
        <did>
            {$i/ead:did/*}
        </did>
        {$i/*[not(self::ead:accessrestrict) and not(self::ead:did)]}
        <accessrestrict type="closed"><p>Originals restricted; use access copies.</p></accessrestrict>
    </c>
    <c level="{$i/@level}">
        <did>
            <container type="{$i/ead:did/ead:container[matches(., '(original)')]/@type}">{replace($i/ead:did/ead:container[matches(., '(original)')], ' \(original\)', '')} (copy)</container>
            {$i/ead:did/*[not(self::ead:unittitle) and not(self::ead:container[matches(., '(original)')])]}
            <unittitle>Access Copy for: {$i/ead:did/ead:unittitle/string()}</unittitle>
        </did>
        {$i/*[not(self::ead:accessrestrict) and not(self::ead:did)]}
        <accessrestrict type="open"><p>Access copies are open for research.</p></accessrestrict>
    </c>
</c>)
)   


       
    