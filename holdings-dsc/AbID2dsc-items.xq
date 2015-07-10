xquery version "1.0";
declare copy-namespaces no-preserve, inherit;
(:
1) transform AbID output into EAD
2) merge the two EAD's
3) create items
4) run normalizer: will assign cid's
5) replace containers in descriptive component with @id/@parent

-->edit production and Aeon XSLT
:)

declare namespace ead="urn:isbn:1-931666-22-9";

(:This xQuery Update creates items from AbId input and merges with EAD input:)
(:If running on Linux box, make sure support for XQ1.1/3.0 is DISabled:)

declare variable $EAD as document-node()* := doc("sample_input.EAD.xml");
declare variable $ITEMS as document-node()* := doc("sample_input.AbID.xml");

let $ead := $EAD//ead:ead
let $item := $ITEMS//dataroot/* 
let $new-c := 
    for $c in $item[CollectionCode=$ead/ead:eadheader/ead:eadid]
    let $newbox := <container>{if ($c/AtType[not(.="")]) then attribute type {$c/AtType} else(), if ($c/AbID/text()[not(.="")]) then attribute id {$c/AbID/text()} else(), $c/CollectionDesignation/text()}</container>
    let $barcode := <unitid type="barcode">{$c/BC/text()}</unitid>
    let $code := <physloc type="code">{$c/Location/text()}</physloc>
    return
    <c level="otherlevel" otherlevel="item" xmlns="urn:isbn:1-931666-22-9">
        <did>{
                $newbox,
                $barcode,
                $code
        }</did>
    </c>
let $newdsc := <dsc type="othertype" xmlns="urn:isbn:1-931666-22-9">{$new-c}</dsc>

return
    if ($ead//ead:dsc[2])
    then insert nodes $new-c as last into $ead//ead:dsc[2]    
    else insert node $newdsc as last into $ead//ead:archdesc


