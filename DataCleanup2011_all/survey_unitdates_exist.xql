xquery version "1.0";

declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace eac = "urn:isbn:1-931666-33-4";
declare namespace xlink = "http://www.w3.org/1999/xlink";

(:declare default element namespace "urn:isbn:1-931666-33-4";:)

declare variable $COLL as document-node()+ := collection("/db/ead");

(:
declare variable $COLL as document-node()+ := collection("/C:/Documents%20and%20Settings/heberlei/My%20Documents/SVN%20Working%20Copies/trunk/EAD2samples/ead");
:)
(:let $unitdates as element()+ := $COLL//(ead:unitdate)
return $unitdates:)

(:let $unitdates as element()+ := $COLL//(ead:unitdate)
return count($unitdates[not(@normal) and ((.='undated') or (.='') or (contains(., 'no year')))])
:)

(:let $unitdates as element()+ := $COLL//(ead:unitdate)
return count($unitdates[not(@normal) and not(.='undated') and not(.='') and not(contains(., 'no year'))]):)


(:let $unitdates as element()+ := $COLL//(ead:unitdate)
return count($unitdates[not(@type='inclusive') and (matches(., '-') or matches(., '\d{4}s'))]):)

let $unitdates as element()+ := $COLL//(ead:unitdate)
return $unitdates[(@type='inclusive') and not(matches(., '-') or matches(., '\d{4}s'))]


(:let $unitdates as element()+ := $COLL//(ead:unitdate)
return $unitdates[not(contains(., 'no year')) and not(.='') 
and not(.='undated') and
not(
matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s)(\d{1,2})(\.*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s*)(\.*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s)(\d{1,2})(\s*-\s*)(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s)(\d{1,2})(\s*)(\.*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s*)(-)(\d{4})(\s*)(January|February|March|April|May|June|July|August|September|October|November|December)(\s*)(\.*\s*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s)(\d{1,2})(\s*-\s*)(\d{1,2})(\.*\s*)($)')
or matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s*-\s*)(January|February|March|April|May|June|July|August|September|October|November|December)(\s*)(\.*\s*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s*-\s*)(\d{4})(\s*)(\.*\s*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s*-\s*)(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s*)(\.*\s*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s*-\s*)(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s)(\d{1,2})(\s*)(\.*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s*-\s*)(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s)(\d{1,2})(\s*)(\.*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s)(\d{1,2})(\s*-\s*)(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s*)(\.*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s)(\d{1,2})(\s*-\s*)(\d{4})(\s*)(\.*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s)(\d{1,2})(\s*-\s*)(January|February|March|April|May|June|July|August|September|October|November|December)(\s*)(\.*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s)(\d{1,2})(\s*-\s*)(January|February|March|April|May|June|July|August|September|October|November|December)(\s)(\d{1,2})(\s*)(\.*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s*-\s*)(January|February|March|April|May|June|July|August|September|October|November|December)(\s)(\d{1,2})(\s*)(\.*$)')
or matches(., '(^)(circa\s)*(\d{4})(s*)(\s*-\s*)*(\d{4})*(s)*(\s*\.*\s*)')
)
]:)


(:let $unitdates as element()+ := $COLL//(ead:unitdate[not(contains(., 'no year')) and not(.='') 
and not(.='undated') and not(@normal) 
and 
(
matches(., '(^)(\d{4})(\s*-\s*)()\d{4}(\s*)(\.*$)')
or matches(., '(^)(\d{4})(\s*)(\.*$)')
)
])
return count($unitdates):)


(:let $unitdates as element()+ := $COLL//(ead:unitdate)
return count($unitdates[@normal and not(contains(., 'no year')) and not(.='') 
and not(.='undated') and matches(@normal, '^\d{4}/\d{4}$')
and
(
matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s)(\d{1,2})(\.*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s*)(\.*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s)(\d{1,2})(\s*-\s*)(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s)(\d{1,2})(\s*)(\.*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s*)(-)(\d{4})(\s*)(January|February|March|April|May|June|July|August|September|October|November|December)(\s*)(\.*\s*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s)(\d{1,2})(\s*-\s*)(\d{1,2})(\.*\s*)($)')
or matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s*-\s*)(January|February|March|April|May|June|July|August|September|October|November|December)(\s*)(\.*\s*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s*-\s*)(\d{4})(\s*)(\.*\s*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s*-\s*)(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s*)(\.*\s*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s*-\s*)(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s)(\d{1,2})(\s*)(\.*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s*-\s*)(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s)(\d{1,2})(\s*)(\.*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s)(\d{1,2})(\s*-\s*)(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s*)(\.*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s)(\d{1,2})(\s*-\s*)(\d{4})(\s*)(\.*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s)(\d{1,2})(\s*-\s*)(January|February|March|April|May|June|July|August|September|October|November|December)(\s*)(\.*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s)(\d{1,2})(\s*-\s*)(January|February|March|April|May|June|July|August|September|October|November|December)(\s)(\d{1,2})(\s*)(\.*$)')
or matches(., '(^)(circa\s)*(\d{4})(\s)(January|February|March|April|May|June|July|August|September|October|November|December)(\s*-\s*)(January|February|March|April|May|June|July|August|September|October|November|December)(\s)(\d{1,2})(\s*)(\.*$)')
)
]):)

(:let $unittitles as element()+ := $COLL//(ead:dsc//ead:did)
return count($unittitles[ead:unittitle and not(.//ead:unitdate) and not(ead:unitdate)]):)

(:let $unittitles as element()+ := $COLL//(ead:unittitle)
return count($unittitles):)

(:let $unitdates as element()+ := $COLL//(ead:unitdate)
return count($unitdates[@calendar and @era]):)

(:let $unitdates as element()+ := $COLL//(ead:unitdate)
return count($unitdates[not(.='undated') and not(.='') and not(contains(., 'no year'))]):)

 