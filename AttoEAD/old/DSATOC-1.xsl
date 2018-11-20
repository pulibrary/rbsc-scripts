<?xml version="1.0" encoding="UTF-8"?>

<!-- REGINE'S EDITS BELOW -->

<xsl:stylesheet xmlns="urn:isbn:1-931666-22-9" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:ead="urn:isbn:1-931666-22-9"
    xmlns:xlink="http://www.w3.org/1999/xlink" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:output method="xml" indent="yes" exclude-result-prefixes="#all" />
    <xsl:strip-space elements="p"/>
    
    <!--  This template adds the @audience and the ns ead and xlink -->
    <xsl:template match="/*">
        <xsl:copy >
            <xsl:attribute name="audience" select="'external'"/>
            <xsl:namespace name="ead" select="'urn:isbn:1-931666-22-9'"/>
            <xsl:namespace name="xlink" select="'http://www.w3.org/1999/xlink'"/>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="ead:p[not(*) and not(text())]"/>

    
    <!-- This template copies the remainder of the document  -->
    <xsl:template match="@* | node() | processing-instruction() | comment()">
        
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
   
    
    <!-- This template adds @encodinganalog, @urn, and @url to eadid and grabs as its value the value of <unitid>. 
    -->
    <xsl:template match="ead:eadid">
        <xsl:variable name="url" as="xs:string*">
            <xsl:value-of select="@url"/>
        </xsl:variable>
        <xsl:variable name="urn" as="xs:string*" select="tokenize($url, '.edu/')"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="encodinganalog">dc:identifier</xsl:attribute>
            <xsl:attribute name="urn">
                <xsl:value-of select="$urn[position()=last()]"/>
            </xsl:attribute>
            <xsl:attribute name="url">
                <xsl:value-of select="@url"/>
            </xsl:attribute>
            <!--   <xsl:value-of select="following-sibling::ead:filedesc//ead:num"/>-->
            <xsl:value-of
                select="ancestor::ead:eadheader/following-sibling::ead:archdesc/ead:did/ead:unitid"/>
            <xsl:apply-templates select="*[not(text())]"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="ead:titleproper">
        <xsl:variable name="date" as="element()?">
            <xsl:analyze-string select="current()" regex="[^\w](\d{{3,4}}\-?(\d{{3,4}})?)">
                <xsl:matching-substring>
                    <date normal="{replace(regex-group(1), '\-', '/')}">
                        <xsl:if test="contains(regex-group(1), '-')">
                            <xsl:attribute name="type" select="'inclusive'"/>
                        </xsl:if>
                        <xsl:value-of select="regex-group(1)"/>
                    </date>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:variable name="title" as="xs:string*">
            <xsl:analyze-string select="current()"
                regex="(\w{{2,3}}\d{{3}})|([^\w](\d{{3,4}}\-?(\d{{3,4}})?))|:\sfinding\said|\s"
                flags="i">
                <xsl:non-matching-substring>
                    <xsl:value-of select="current()"/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <titleproper>
            <xsl:value-of select="$title"/>
            <xsl:if test="$date">&#160;</xsl:if>
            <xsl:copy-of select="$date"/>
            <xsl:if test="matches(current(), 'finding aid', 'i')">: Finding Aid</xsl:if>
        </titleproper>
    </xsl:template>

    <!-- These templates insert a descrule with our boilerplate if none exists. 
        If one exists, it gets changed to our boilerplate-->
    <xsl:template match="ead:profiledesc">
        <xsl:choose>
            <xsl:when test="ead:descrules">
                <xsl:copy copy-namespaces="no">
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>

                    <xsl:for-each select="ead:descrules">
                        <xsl:call-template name="descrules"/>
                        <descrules xmlns="urn:isbn:1-931666-22-9">
                            <xsl:text>Finding aid content adheres to that prescribed by </xsl:text>
                            <emph render="italic">
                                <expan abbr="dacs" altrender="MARC">
                                    <xsl:text>Describing Archives: A Content Standard</xsl:text>
                                </expan>
                            </emph>
                            <xsl:text>.</xsl:text>
                        </descrules>
                    </xsl:for-each>
                </xsl:copy>

            </xsl:when>
            <xsl:otherwise>
                <xsl:copy copy-namespaces="no">
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                    <descrules xmlns="urn:isbn:1-931666-22-9">
                        <xsl:text>Finding aid content adheres to that prescribed by </xsl:text>
                        <emph render="italic">
                            <expan abbr="dacs" altrender="MARC">
                                <xsl:text>Describing Archives: A Content Standard</xsl:text>
                            </expan>
                            <xsl:text>.</xsl:text>
                        </emph>
                    </descrules>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="descrules" match="ead:descrules"/>

    <!-- This template replaces the langusage element with a language element containing langusage. 
        It tests for languages present in the langusage string and inserts a separate language element for each. 
        It also adds an attribute to langusage. ARE THERE OTHER LANGUAGES I SHOULD INCLUDE? ALSO, 
        THEY USE SPANISH HERE INCORRECTLY, REALLY.-->
    <xsl:template match="ead:langusage">
        <xsl:variable name="langusage-string" as="xs:string"
            select="normalize-space(string(//ead:langusage))"/>
        <langusage xmlns="urn:isbn:1-931666-22-9">
            <xsl:text>Finding aid written in </xsl:text>
            <xsl:if test="contains($langusage-string, 'English')">
                <language>
                    <xsl:attribute name="langcode">eng</xsl:attribute>
                    <xsl:text>English</xsl:text>
                </language>
            </xsl:if>
            <xsl:if test="contains($langusage-string, 'Spanish')">
                <language>
                    <xsl:attribute name="langcode">spa</xsl:attribute>
                    <xsl:text>, </xsl:text><xsl:text>Spanish</xsl:text>
                </language>
            </xsl:if>
            <xsl:if test="contains($langusage-string, 'Portuguese')">
                <language>
                    <xsl:attribute name="langcode">por</xsl:attribute>
                    <xsl:text>, </xsl:text><xsl:text>Portuguese</xsl:text>
                </language>
            </xsl:if>
            <xsl:text>.</xsl:text>
        </langusage>
    </xsl:template>

    <!-- END <eadheader> PROCESSING -->

    <!-- BEGIN <archdesc> PROCESSING -->
    
    <!-- These templates keep the bioghist and descgrp elements as well as some other elements from being copied over -->
    <xsl:template match="ead:bioghist/ead:head" mode="hl-did"/>
    <xsl:template match="ead:archdesc/ead:scopecontent" mode="hl-did"/>
    <xsl:template match="ead:archdesc/ead:arrangement" mode="hl-did"/>
    <xsl:template match="ead:archdesc/ead:accessrestrict" mode="hl-did"/>
    <xsl:template match="ead:archdesc/ead:userestrict" mode="hl-did"/>
    <xsl:template match="ead:archdesc/ead:otherfindaid" mode="hl-did"/>
    <xsl:template match="ead:archdesc/ead:relatedmaterial" mode="hl-did"/>
    <xsl:template match="ead:archdesc/ead:prefercite" mode="hl-did"/>
    <xsl:template match="ead:archdesc/ead:processinfo" mode="hl-did"/>
    <xsl:template name="head" match="ead:did/ead:head" mode="hl-did"/>    
    <xsl:template match="ead:origination" mode="hl-did"/>
   
     
    <!-- This template adds two attributes to <archdesc> and sorts elements into <descgrp> -->
    <xsl:template match="ead:archdesc">
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="relatedencoding">marc21</xsl:attribute>
            <xsl:attribute name="type">findingaid</xsl:attribute>
            <xsl:apply-templates mode="hl-did"/>
        </xsl:copy>

    </xsl:template>


    <!-- BEGIN HIGH-LEVEL <did> PROCESSING -->

    <!-- This is the generic template that matches everything that isn't matched by a rule below-->
    <xsl:template match="* | processing-instruction() | comment()" mode="hl-did">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="hl-did"/>
        </xsl:copy>
    </xsl:template>

    <!-- The following templates add a <head> element to the hl-did if none is present and replace it if one is present.
        At the same time, they insert boilerplate for origination.-->
    <xsl:template match="ead:did[parent::ead:archdesc]" mode="hl-did">
        <xsl:choose>
            <xsl:when test="ead:head">
                <xsl:copy copy-namespaces="no">
                    <xsl:copy-of select="@*"/>
                    <head xmlns="urn:isbn:1-931666-22-9">Summary Information</head>
                    <xsl:apply-templates mode="hl-did"/>
                    <xsl:for-each select="ead:head">
                        <xsl:call-template name="head"/>
                    </xsl:for-each>
                    <origination label="Creator: ">
                        <corpname encodinganalog="110" source="lcnaf">Princeton University.
                            Library</corpname>
                    </origination>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy copy-namespaces="no">
                    <xsl:copy-of select="@*"/>
                    <head xmlns="urn:isbn:1-931666-22-9">Summary Information</head>
                    <xsl:apply-templates mode="hl-did"/>
                    <origination label="Creator: ">
                        <corpname encodinganalog="110" source="lcnaf">Princeton University.
                            Library</corpname>
                    </origination>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>

    <!-- The following templates add a LABEL attribute with the value as specified 
    RH: changed values and added physloc, abstract. Added encodinganalogs.-->

    <!--These templates nest unitdate in unittitle (only in hl-did, but could easily be expanded by making the match less specific).
        If unitdate is a date range, they add a type attribute. If unittitle does not end in a comma, a comma gets inserted. 
        They also normalize single years and year ranges (no more complex dates for now).
        SOME OF THESE TITLES CONTAIN A DATE: DOES THIS NEED TO BE ADDRESSED? DIFFERENT FROM UNITDATE!-->
    <xsl:template match="ead:archdesc/ead:did/ead:unittitle" mode="hl-did">
        <xsl:variable name="unitdate-string" as="xs:string"
            select="normalize-space(string(following-sibling::ead:unitdate))"/>
        <xsl:variable name="tokens" as="xs:string*" select="tokenize($unitdate-string, '-')"/>
        <xsl:variable name="range1" as="xs:string*" select="$tokens[position() = 1]"/>
        <xsl:variable name="range2" as="xs:string*" select="$tokens[position() = last()]"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="encodinganalog">245$a</xsl:attribute>
            <xsl:attribute name="label">Title and dates: </xsl:attribute>
            <xsl:apply-templates mode="hl-did"/>
            <xsl:if test="substring(., string-length(.)) != ','">
                <xsl:text>, </xsl:text></xsl:if><xsl:text> </xsl:text>
            <unitdate xmlns="urn:isbn:1-931666-22-9">
                <xsl:attribute name="normal">
                    <xsl:choose>
                        <xsl:when test="matches($unitdate-string, '-')">
                            <xsl:value-of select="$range1"/>/<xsl:value-of select="$range2"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$unitdate-string"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:if test="matches($unitdate-string, '-')">
                    <xsl:attribute name="type">inclusive</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="following-sibling::ead:unitdate"/>
            </unitdate>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="ead:archdesc/ead:did/ead:unitdate" mode="hl-did"/>

       <!-- This template adds attributes to unitid -->
    <xsl:template match="ead:unitid" mode="hl-did">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="encodinganalog">084$a</xsl:attribute>
            <xsl:attribute name="countrycode">US</xsl:attribute>
            <xsl:attribute name="repositorycode">US-NjP</xsl:attribute>
            <xsl:attribute name="type">collection</xsl:attribute>
            <xsl:attribute name="label">Call number: </xsl:attribute>
            <xsl:apply-templates mode="hl-did"/>
        </xsl:copy>
    </xsl:template>

    <!-- This template adds an attribute to physdesc -->
    <xsl:template match="ead:physdesc" mode="hl-did">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="label">Size: </xsl:attribute>
            <xsl:apply-templates mode="hl-did"/>
        </xsl:copy>
    </xsl:template>

    <!-- This template adds an attribute to extent -->
    <xsl:template match="ead:extent" mode="hl-did">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="encodinganalog">300$a</xsl:attribute>
            <xsl:apply-templates mode="hl-did"/>
        </xsl:copy>
    </xsl:template>

    <!-- This template adds attributes to langmaterial -->
    <xsl:template match="ead:langmaterial" mode="hl-did">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="encodinganalog">546$a</xsl:attribute>
            <xsl:attribute name="label">Language(s) of Material: </xsl:attribute>
            <xsl:apply-templates mode="hl-did"/>
        </xsl:copy>
    </xsl:template>

    <!-- This template spells out the languages of the attributes in the content of the language element -->
    <xsl:template match="ead:langmaterial/ead:language" mode="hl-did">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="encodinganalog">041$a</xsl:attribute>
            <xsl:choose>
                <xsl:when test="@langcode='spa'">
                    <xsl:text>Spanish </xsl:text>
                </xsl:when>
                <xsl:when test="@langcode='eng'">
                    <xsl:text>English </xsl:text>
                </xsl:when>
                <xsl:when test="@langcode='por'">
                    <xsl:text>Portuguese </xsl:text>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates mode="hl-did"/>
        </xsl:copy>
    </xsl:template>

    <!-- This template adds an attribute -->
    <xsl:template match="ead:physloc" mode="hl-did">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="label">Storage note: </xsl:attribute>
            <xsl:apply-templates mode="hl-did"/>
        </xsl:copy>
    </xsl:template>

    <!-- This template adds an attribute -->
    <xsl:template match="ead:abstract" mode="hl-did">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="label">Abstract: </xsl:attribute>
            <xsl:apply-templates mode="hl-did"/>
        </xsl:copy>
    </xsl:template>

     <!-- This template adds repository address if none is present  and adds attributes-->
    <xsl:template match="ead:repository" mode="hl-did">
        <xsl:choose>
            <xsl:when test="ead:address">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="id">LAERepository</xsl:attribute>
                    <xsl:attribute name="encodinganalog">852$a</xsl:attribute>
                    <xsl:attribute name="label">Location: </xsl:attribute>
                    <xsl:apply-templates mode="hl-did"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="id">LAERepository</xsl:attribute>
                    <xsl:attribute name="encodinganalog">852$a</xsl:attribute>
                    <xsl:attribute name="label">Location: </xsl:attribute>
                    <xsl:apply-templates mode="hl-did"/>
                    <address xmlns="urn:isbn:1-931666-22-9">
                        <addressline>One Washington Road</addressline>
                        <addressline>Princeton, New Jersey, 08544</addressline>
                        <addressline>(609) 258-3184</addressline>
                    </address>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- END HIGH-LEVEL <did> PROCESSING SECTION-->

    <!-- BEGIN <bioghist> and <descgrp> PROCESSING  -->
    
    <!-- These templates copy over bioghist. They suppress the old <head> and add a new one as well as a <dao>.  They then group elements into descgrps-->
    <xsl:template match="ead:bioghist" mode="hl-did">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <head>History of the Princeton University Library Latin American Ephemera Collections</head>
            <dao xlink:title="Princeton University Latin American Ephemera Collections"
                xlink:href="bioghist-images/laelogo.jpg"/>
            <xsl:apply-templates mode="hl-did"/>
        </xsl:copy>
        <descgrp id="dacs3">
            <xsl:copy-of select="preceding-sibling::ead:scopecontent"/>
            <xsl:copy-of select="preceding-sibling::ead:arrangement"/>
        </descgrp>
        <descgrp id="dacs4">
            <head>Access and Use</head>
            <xsl:choose>
                <xsl:when test="preceding-sibling::ead:accessrestrict">
                    <xsl:copy-of select="preceding-sibling::ead:accessrestrict"/>
                </xsl:when>
                <xsl:otherwise>
                    <accessrestrict>
                        <head>Access</head>
                        <p>Collection is open for research use.</p>
                    </accessrestrict>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="preceding-sibling::ead:userestrict">
                    <xsl:copy-of select="preceding-sibling::ead:userestrict"/>
                </xsl:when>
                <xsl:otherwise>
                    <userestrict id="ref66">
                        <head>Restrictions on Use and Copyright Information</head>
                        <p>Photocopies may be made for research purposes. Researchers are responsible for
                            determining any copyright questions.</p>
                    </userestrict>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:copy-of select="preceding-sibling::ead:otherfindaid"/>
        </descgrp>
        <descgrp id="dacs6">
            <head>Related Materials</head>
            <xsl:choose>
                <xsl:when test="following-sibling::ead:relatedmaterial"><xsl:copy-of select="following-sibling::ead:relatedmaterial"/></xsl:when>
                <xsl:otherwise><p>Researchers are encouraged to consult Princeton University Library's Finding Aids
                    Site at <title render="italic">http://diglib.princeton.edu/ead/</title>, as well
                    as the <title render="italic">Guide to the Princeton University Latin American
                        Microfilm Collections</title> and its supplements.</p></xsl:otherwise>
            </xsl:choose>
        </descgrp>
        <descgrp id="dacs7">
            <head>Processing and Other Information</head>
            <xsl:copy-of select="preceding-sibling::ead:prefercite | following-sibling::ead:prefercite"/>
            <xsl:copy-of select="preceding-sibling::ead:processinfo | following-sibling::ead:processinfo"/>
        </descgrp>
    </xsl:template>
    
    <!-- This template puts in boilerplate and adds @encodinganalog. When it's already there, it gets replaced.-->
    <xsl:template match="ead:controlaccess" mode="hl-did">
        <controlaccess>
            <head>Subject Headings</head>
            <p>These materials have been indexed in the <extref
                xlink:href="http://catalog.princeton.edu">Princeton University Library online
                catalog</extref> using the following terms. Those seeking related materials
                should search under these terms.</p>
            <xsl:copy-of select="node()[not(self::ead:subject/@source[.='Local']) and not(self::ead:subject/@source[.='local'])]"/>
            <xsl:for-each select="ead:subject/@source[.='Local'] | ead:subject/@source[.='local']">
                <subject source="local" encodinganalog="690" >
                    <xsl:value-of select="ancestor::ead:subject"/>
                </subject>
            </xsl:for-each>
        </controlaccess>    
    </xsl:template>
    
    <!-- END <descgrp> PROCESSING -->

    <!-- BEGIN <dsc> PROCESSING SECTION -->

    <!-- This template adds a @type and a <head> -->
	<xsl:template match="ead:dsc" mode="hl-did">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="type">combined</xsl:attribute>
            <head>Contents List</head>
            <xsl:apply-templates mode="hl-did"/>
        </xsl:copy>
    </xsl:template>

    <!-- This is the generic template that matches everything that isn't matched by the rules specified below -->
    <xsl:template match="* | processing-instruction() | comment()" mode="dsc">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="dsc"/>
        </xsl:copy>
    </xsl:template>

    <!-- END <dsc> PROCESSING SECTION -->

</xsl:stylesheet>

<!-- END REGINE'S EDITS -->


	<!-- Dan's tests-->
	<!--  <bioghist encodinganalog="545$a">
		<xsl:if test="marc:datafield[@tag=545]">
			<xsl:if test="marc:datafield[@tag=545][@ind1='0']">
				<head>Biography</head>
				<dao title="Princeton University Shield" href="bioghist-images/shieldlogo.jpg"/>
				<xsl:for-each select="marc:datafield[@tag=545]">
					<p>
						<xsl:value-of select="."/>
					</p>
				</xsl:for-each>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag=545][@ind1='1']">
				<head>Organizational History</head>
				<dao title="Princeton University Shield" href="bioghist-images/shieldlogo.jpg"/>
				<xsl:for-each select="marc:datafield[@tag=545]">
					<p>
						<xsl:value-of select="."/>
					</p>
				</xsl:for-each>
			</xsl:if>

		</xsl:if>
	</bioghist>
	<descgrp id="dacs3">
		<scopecontent encodinganalog="520$a">
			<head>Description</head>
			<xsl:for-each select="ead:archdesc/ead:scopecontent">
				<p>

					<xsl:value-of select="."/>


				</p>
			</xsl:for-each>
		</scopecontent>
		<xsl:for-each select="ead:archdesc/ead:arrangement">
			<arrangement encodinganalog="351$a">
				<head>Arrangement</head>
				<p>
					<xsl:value-of select="."/>
				</p>
			</arrangement>
		</xsl:for-each>
		</descgrp>-->
	<!--	<xsl:if test="marc:datafield[@tag=351] and not (marc:datafield[@tag=520])">
		<descgrp id="dacs3">
		<xsl:for-each select="marc:datafield[@tag=351]">
		<arrangement encodinganalog="351" id="a4">
		<head>Arrangement</head>
		<p>
		<xsl:value-of select="."/>
		</p>
		</arrangement>
		</xsl:for-each>
		</descgrp>
		</xsl:if> -->
	<!-- <xsl:for-each select="marc:datafield[@tag=351]">
		<arrangement encodinganalog="351" id="a4">
		<head>Arrangement</head>
		<p>
		<xsl:value-of select="."/>
		</p>
		</arrangement>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=520]">
		<scopecontent encodinganalog="520" id="asc">
		<head>Description</head>
		<p>
		<xsl:value-of select="."/>
		</p>
		</scopecontent>
		
		</xsl:for-each> -->
	<!--  <descgrp id="dacs4">
		<head>Access and Use</head>
		<accessrestrict encodinganalog="506$a">
			<head>Access Restrictions</head>
			<xsl:if test="ead:archdesc/ead:accessrestrict">
				<p>
					<xsl:value-of select="ead:arcdesc/ead:accessrestrict"/>
				</p>
			</xsl:if>
			<xsl:if test="not(ead:arcdesc/ead:accessrestrict)">
				<p>
					<xsl:text>The collection is open for research.</xsl:text>
				</p>
			</xsl:if>
		</accessrestrict>
		<userestrict encodinganalog="540$a">
			<head>Restrictions on Use and Copyright</head>
			<xsl:if test="ead:archdesc/ead:userestrict">
				<p>
					<xsl:value-of select="ead:archdesc/ead:userestrict"/>
				</p>
			</xsl:if>
			<xsl:if test="not(ead:archdesc/ead:userestrict)">
				<p>
					<xsl:text>Single photocopies may be made for research purposes. Permission to publish materials from the collection must be requested from the Curator of the Public Policy Papers. Researchers are responsible for determining any copyright questions.</xsl:text>
				</p>
			</xsl:if>
		</userestrict>
		<xsl:for-each select="ead:archdesc/ead:phystech]">
			<phystech encodinganalog="538$a">
				<p>
					<xsl:value-of select="."/>
				</p>
			</phystech>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=555]">
			<otherfindaid encodinganalog="555$u">
				<head>Other Finding Aid(s)</head>
				<p>
					<xsl:value-of select="."/>
				</p>
			</otherfindaid>
		</xsl:for-each>
	</descgrp>
	<xsl:if test="marc:datafield[@tag=541] or marc:datafield[@tag=561]">
		<descgrp id="dacs5">
			<head>Acquisition and Appraisal</head>
			<xsl:for-each select="marc:datafield[@tag=561]">
				<custodhist encodinganalog="561$a">
					<head>Custodial History</head>
					<p>
						<xsl:value-of select="."/>
					</p>
				</custodhist>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=541]">
				<acqinfo encodinganalog="541$a">
					<head>Provenance and Acquisition</head>
					<p>
						<xsl:for-each select="marc:subfield">
							<xsl:value-of select="."/>
							<xsl:if test="position()!=last()">
								<xsl:text> </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</p>
				</acqinfo>
			</xsl:for-each>
		</descgrp>
		</xsl:if> -->
	<!--
		<descgrp id="dacs5">
		<head>Acquisition and Appraisal</head>
		<xsl:for-each select="marc:datafield[@tag=561]">
		
		<custodhist encodinganalog="561" id="a16">
		<head>Custodial History</head>
		<p>
		<xsl:value-of select="."/>
		</p>
		</custodhist>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=541]">
		<acqinfo encodinganalog="541" id="a19">
		
		<head>Provenance and Acquistiion</head>
		<p>
		<xsl:value-of select="."/>
		</p>
		</acqinfo>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=584]">
		<head>Accrurals</head>
		<accruals encodinganalog="584" id="a10">
		<p>
		<xsl:value-of select="."/>
		</p>
		</accruals>
		</xsl:for-each>
		</descgrp> -->
	<!-- <xsl:if
		test="marc:datafield[@tag=535] or marc:datafield[@tag=530] or marc:datafield[@tag=544] or marc:datafield[@tag=581]">
		<descgrp id="dacs6">
			<head>Related Materials</head>
			<xsl:for-each select="marc:datafield[@tag=535]">
				<originalsloc encodinganalog="535">
					<head>Location of Originals</head>
					<p>
						<xsl:value-of select="."/>
					</p>
				</originalsloc>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=530]">
				<altformavail encodinganalog="530$a" id="a9">
					<head>Location of Copies or Alternate Formats</head>
					<p>
						<xsl:value-of select="."/>
					</p>
				</altformavail>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=544]">
				<relatedmaterial encodinganalog="544$a">
					<head>Related Archival Material</head>
					<p>
						<xsl:value-of select="."/>
					</p>
				</relatedmaterial>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=581]">
				<bibliography encodinganalog="581$a">
					<head>Publications Citing These Papers</head>
					<p>
						<xsl:value-of select="."/>
					</p>
				</bibliography>
			</xsl:for-each>
		</descgrp>
		</xsl:if>  -->
	<!--	<descgrp id="dacs6">
		<head>Related Material</head>
		<xsl:for-each select="marc:datafield[@tag=544]">
		<relatedmaterial encodinganalog="544 1" id="a6">
		<head>Related material</head>
		<p>
		<xsl:value-of select="."/>
		</p>
		</relatedmaterial>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=530]">
		<altformavail encodinganalog="530" id="a9">
		<p>
		<xsl:value-of select="."/>
		</p>
		</altformavail>
		<xsl:for-each select="marc:datafield[@tag=535]">
		<originalsloc encodinganalog="535">
		<p>
		<xsl:value-of select="."/>
		</p>
		</originalsloc>
		</xsl:for-each>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=544]">
		<separatedmaterial encodinganalog="544 0" id="a7">
		<head>Separated Material</head>
		<p>
		<xsl:value-of select="."/>
		</p>
		</separatedmaterial>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=581]">
		<bibliography encodinganalog="581" id="a11">
		<p>
		<xsl:value-of select="."/>
		</p>
		</bibliography>
		</xsl:for-each>
		</descgrp> -->
	<!--  <descgrp id="dacs7">
		<head>Processing and Other Information</head>
		<xsl:for-each select="marc:datafield[@tag=500]">
			<note label="General Note">
				<p>
					<xsl:value-of select="."/>
				</p>
			</note>
		</xsl:for-each>
		<prefercite encodinganalog="524$a">
			<head>Preferred Citation</head>
			<p>Identification of specific item; Date (if known); (Collection Title), Box and Folder
				Number; Department of Rare Books and Special Collections, Princeton University
				Library.</p>
		</prefercite>
		</descgrp>-->
	<!-- BEGIN <dsc> PROCESSING SECTION -->

	<!--  <xsl:template match="ead:dsc">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="dsc"/>
		</xsl:copy>
	</xsl:template>-->
	<!-- This is the generic template that matches everything that isn't matched by the rules specified below -->
	<!--  <xsl:template match="* | processing-instruction() | comment()" mode="dsc">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="dsc"/>
		</xsl:copy>
	</xsl:template>-->
	<!-- The following template adds a LABEL attribute that matches the TYPE attribute of container -->
	<!-- <xsl:template match="ead:container" mode="dsc">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="label">
				<xsl:value-of select="@type"/>
			</xsl:attribute>
			<xsl:apply-templates mode="dsc"/>
		</xsl:copy>
	</xsl:template> -->

	<!-- END <dsc> PROCESSING SECTION -->

	<!-- BEGIN ADDITIONAL USER MODIFICATION SECTION -->



	<!-- END ADDITIONAL USER MODIFICATION SECTION


</xsl:stylesheet> -->
