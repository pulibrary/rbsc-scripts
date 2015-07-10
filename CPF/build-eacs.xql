xquery version "1.0";

(:add useDates -- done:)
(:account for chronlist:)
(:de-dupe biogHist:)
(:insert authorizedForm:)
(:prior to running this, re-run viaf matching on mss:)
(:revise for loc, not only viaf:)
(:normalize file names:)

declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace eac = "urn:isbn:1-931666-33-4";
declare namespace xlink = "http://www.w3.org/1999/xlink";
(:declare namespace functx = "http://www.functx.com";:) 

import module namespace functx="http://www.functx.com" 
    at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";
    
declare copy-namespaces no-preserve, inherit;

declare variable $COLL as document-node()+ := collection("/db/pulfa/eads");

declare variable $names as document-node() := doc("/db/names/names.xml");

(:declare variable $names as document-node() := doc("/home/heberlei/workspace/rbscXSL/DataCleanup2011_all/names-collection.xml");
:)
declare function local:store-eac($eac as node(), $filename as xs:string) as xs:string {
    let $auth := xmldb:authenticate("/db/eac-out", "admin", "admin")
    return xmldb:store("/db/eac-out", escape-uri($filename, false()), $eac, "application/xml")
};

declare function local:calc-name($src) as xs:string {
    normalize-space(lower-case(replace($src, '\p{P}|\p{Z}|\n\s*', '')))
};

declare function local:remove-subdivisions($name) 
as xs:string {
lower-case(replace(tokenize($name, "\s?(\-{2}|–)\s?")[1], '\p{P}|\p{Z}|\n\s*', ''))
};

for $name as xs:string? in (subsequence($names/names/name, 1, 15))
let $fname as xs:string? := local:calc-name(local:remove-subdivisions($name)),
    $id as xs:string := util:hash(util:uuid($fname), 'MD5'),(:util:hash(concat(util:random(120001), $fname), 'MD5'),:)
    $eac :=
<eac-cpf xmlns="urn:isbn:1-931666-33-4" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:xlink="http://www.w3.org/1999/xlink">
{
let $subset as document-node()* :=  
for $record in $COLL[exists(.//(ead:persname|ead:corpname|ead:famname|ead:subject)
                [not(ancestor::ead:index) and local:calc-name(local:remove-subdivisions(./string())) eq $fname]
              )]       
            order by $record//ead:eadid/string()
            return $record
       return (
<control>
{
        (for $record in $subset
        let $ID :=
        (  
        (:this needs revising for the loc authfilenumbers:)
        <recordId>
          {substring-after($record//ead:archdesc/ead:did/ead:origination/*/@authfilenumber/string(), "viaf/")}
        </recordId>,
        <otherRecordID>{$id}</otherRecordID>
        )
        where ($fname = local:calc-name(local:remove-subdivisions($record//ead:archdesc/ead:did/ead:origination/*)))
        return
        if ($record//ead:archdesc/ead:did/ead:origination/*/@authfilenumber)
        then $ID
        else (<recordId>{$id}</recordId>)
)[1]
      }
      
   <maintenanceStatus>derived</maintenanceStatus>
   <maintenanceAgency>
       <agencyCode>US-NjP</agencyCode>
       <agencyName>Princeton University Library. Department of Rare Books and Special Collections.
       </agencyName>
   </maintenanceAgency>
   <maintenanceHistory>
       <maintenanceEvent>
           <eventType>derived</eventType>                  
           <eventDateTime standardDateTime="{current-dateTime()}"/>
           <agentType>machine</agentType>
           <agent>xQuery/Saxon-PE9.3.0.5</agent>
           <eventDescription>Derived from EAD instances.</eventDescription>
       </maintenanceEvent>
   </maintenanceHistory>
   <sources>
       { 
       for $record in $subset
              let $eadid := $record//ead:eadid/string()
              let $eadid-alpha := tokenize($eadid, '\d')[1]
              let $eadid-num := tokenize($eadid, '^\D') [2]
              let $eadid-num1 := tokenize($eadid-num, '\.')[1]
              let $eadid-num2 := tokenize($eadid-num, '\.')[2]
              let $eadid-num3 := tokenize($eadid-num, '\.')[3]
              order by $eadid-alpha, $eadid-num1 empty least, number($eadid-num2) empty least, number($eadid-num3) empty least
       return
       <source xlink:type="simple" xlink:href="http://findingaids.princeton.edu/collections/{$record//ead:eadid}">
           <sourceEntry>
           {
               concat("EAD finding aid for ", $record//ead:eadid)
           }
           </sourceEntry>
       </source>
       }
  </sources>
</control>,
<cpfDescription>
      {
(for $record in $subset
    return
      for $full-name in $record//ead:archdesc/ead:did/ead:origination/(ead:persname|ead:corpname|ead:famname)
         [not(ancestor::ead:index) and local:calc-name(local:remove-subdivisions(./string())) eq $fname]
        return      
        (
        let $identity :=
        (
         <identity>
     <entityType>
    {           
        if ($name/@type="corpname")
        then "corporateBody"
        else if ($name/@type="persname")
        then "person"
        else if ($name/@type="famname")
        then "family"
        else <error><message>entity type must not be empty</message></error>
     }
     </entityType>

     <nameEntry>     
{
            if (matches($full-name, ',\s*\d{4}'))
            then( 
            <part>
            {
            functx:substring-before-match($full-name/string(), ',\s*\d{4}')
            }
            </part>
            )  
            else if (matches($full-name, '\w{3}\.\s*$'))
            then( 
            <part>
            {
            functx:substring-before-match($full-name/string(), '\s*\.\s*$')
            }
            </part>
            ) 
            else <part>{$full-name/string()}</part> 
     }
     {

if (matches($name, '\d{4}$'))
          then(
         <useDates>           
            {
            if (matches($name, '\d{4}$'))
            then 
            <dateRange>
            {
                if (matches($name, '\d{8}$'))
                then
                (
                   <fromDate standardDate="{functx:substring-after-last-match(functx:substring-before-last-match($name/string(), '\d{4}'), '\D')}">
                   {
                   functx:substring-after-last-match(functx:substring-before-last-match($name/string(), '\d{4}'), '\D') 
                   }
                   </fromDate>,
                   <toDate standardDate="{functx:substring-after-last-match($name/string(), '\D\d{4}')}">
                   {
                   functx:substring-after-last-match($name/string(), '\D\d{4}')
                   }
                   </toDate>
                   )
                else if (matches($name, '\D\d{4}$'))
                then
                   <fromDate standardDate="{functx:substring-after-last-match($name/string(), '\D')}">
                   {
                   concat(functx:substring-after-last-match($name/string(), '\D'), '-')
                   }
                   </fromDate>
                else ""
                }
            </dateRange> 
           else "" 
           }
         </useDates>
         )
         else ""         
         }  
     </nameEntry>
 </identity>
)
return
$identity))[1],

<description>
{

if (matches($name, '\d{4}$'))
          then(
         <existDates>           
            {
            if (matches($name, '\d{4}$'))
            then 
            <dateRange>
            {
                if (matches($name, '\d{8}$'))
                then
                (
                   <fromDate standardDate="{functx:substring-after-last-match(functx:substring-before-last-match($name/string(), '\d{4}'), '\D')}">
                   {
                   functx:substring-after-last-match(functx:substring-before-last-match($name/string(), '\d{4}'), '\D') 
                   }
                   </fromDate>,
                   <toDate standardDate="{functx:substring-after-last-match($name/string(), '\D\d{4}')}">
                   {
                   functx:substring-after-last-match($name/string(), '\D\d{4}')
                   }
                   </toDate>
                   )
                else if (matches($name, '\D\d{4}$'))
                then
                   <fromDate standardDate="{functx:substring-after-last-match($name/string(), '\D')}">
                   {
                   concat(functx:substring-after-last-match($name/string(), '\D'), '-')
                   }
                   </fromDate>
                else ""
                }
            </dateRange> 
           else "" 
           }
         </existDates>
         )
         else ""         
         }     
       { 
       if (exists($subset//ead:occupation[local:calc-name(local:remove-subdivisions(../../ead:did/ead:origination/*))=$fname]))
       then
       <occupations>        
        {
            for $record in $subset  
            where ($record//ead:occupation)
                   and ($fname = local:calc-name(local:remove-subdivisions($record//ead:archdesc/ead:did/ead:origination/*)))
            return
            for $occupation in $record//ead:occupation
            return
               <occupation>
                   <term>
                       {$occupation/string()}
                   </term>
               </occupation> 
               }
      </occupations>
      else""
  }
  { 
  if (exists($subset//ead:function[local:calc-name(local:remove-subdivisions(../../ead:did/ead:origination/*))=$fname]))
       then
       <functions>       
{
       for $record in $subset  
       where ($record//ead:function)
       and ($fname = local:calc-name(local:remove-subdivisions($record//ead:archdesc/ead:did/ead:origination/*)))
       return
            for $function in $record//ead:function
            return
               <function>
                   <term>
                       {$function/string()}
                   </term>
               </function> 
               }
      </functions>
      else""
  }
 {
         for $record in $subset
         where ($fname = local:calc-name(local:remove-subdivisions($record//ead:archdesc/ead:did/ead:origination/*)))
             and ($record//ead:bioghist)
         order by $record//ead:eadid
         return
      (
       <biogHist>
         {
         for $bioghist in $record//ead:bioghist[1]
         let $p := $bioghist/ead:p
         for $x in $p
         return
         <p>
            {
             $x/string()
             }
         </p>
         }
                  <citation>
         {
          concat("From the finding aid for ", $record//ead:eadid)
         }
         </citation>
         </biogHist>

         )
         }
</description>, 
<relations>
{
let $all-values as element()* := (

for $record in $subset
        let $coll-origination := $record//ead:archdesc/ead:did/ead:origination/*
        for $origination in $coll-origination
        return
        if(local:calc-name(local:remove-subdivisions($origination))[.=$fname])
        then 
       <resourceRelation xlink:type="simple" xlink:href="http://findingaids.princeton.edu/collections/{$record//ead:eadid}" resourceRelationType="creatorOf">
       </resourceRelation>
       else(),

for $record in $subset
        let $coll-subject := $record//ead:archdesc/ead:controlaccess/*
        for $subject in $coll-subject
        return        
        if(local:calc-name(local:remove-subdivisions($subject))[.=$fname])
        then 
       <resourceRelation xlink:type="simple" xlink:href="http://findingaids.princeton.edu/collections/{$record//ead:eadid}" resourceRelationType="subjectOf">
       </resourceRelation>
       else(),
       
for $record in $subset
        let $dsc-origination := $record//ead:dsc//ead:did/ead:origination/*
        for $origination in $dsc-origination
        return
        if(local:calc-name(local:remove-subdivisions($origination))[.=$fname])
        then 
       <resourceRelation xlink:type="simple" xlink:href="http://findingaids.princeton.edu/collections/{$record//ead:eadid}/{$origination/../../../substring-after(@id, "_")}" resourceRelationType="creatorOf">
       </resourceRelation>
       else(),
    
for $record in $subset
        let $dsc-subject := $record//ead:dsc//ead:controlaccess/*
        for $subject in $dsc-subject
        return
        if(local:calc-name(local:remove-subdivisions($subject))[.=$fname])
        then 
       <resourceRelation xlink:type="simple" xlink:href="http://findingaids.princeton.edu/collections/{$record//ead:eadid}/{$subject/../../substring-after(@id, "_")}" resourceRelationType="subjectOf">
       </resourceRelation>
       else()
)

for $value in functx:distinct-deep($all-values)

let $href := substring-after($value/@xlink:href, 'http://findingaids.princeton.edu/collections/')
let $tokens := tokenize($href, '/c')
let $coll-code-letters := xs:string(replace($tokens[1], "[\d\p{P}]", ""))
let $coll-code-numbers := replace($tokens[1], "[\D\.]", "")
let $comp-code := number($tokens[2])
order by $coll-code-letters, $coll-code-numbers, $comp-code empty least

return $value


}

</relations>

}
</cpfDescription>
)}
</eac-cpf>

return
 if($eac//eac:biogHist)
 then local:store-eac($eac, concat($fname, ".CPF.xml"))
 else ()

