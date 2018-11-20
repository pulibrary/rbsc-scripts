<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="urn:isbn:1-931666-22-9" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:ead="urn:isbn:1-931666-22-9"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ns2="http://www.w3.org/1999/xlink"
    version="2.0" exclude-result-prefixes="#all">


    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Apr 22, 2010</xd:p>
            <xd:p><xd:b>Author:</xd:b> heberlei</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>

    <xsl:output method="xml" indent="yes" exclude-result-prefixes="#all"/>
    <xsl:strip-space elements="p"/>

    <!--  EAD:EAD: This template adds the @audience and the ns ead and xlink to the root element-->
    <xsl:template match="/*">
        <xsl:copy>
            <xsl:attribute name="audience" select="'external'"/>
            <xsl:namespace name="ead" select="'urn:isbn:1-931666-22-9'"/>
            <xsl:namespace name="xlink" select="'http://www.w3.org/1999/xlink'"/>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- This template matches everything in hl-did that isn't matched by a rule below and copies it unless empty-->
    <xsl:template match="@*|node()" mode="hl-did">
        <xsl:if test=".!=''">
            <xsl:copy>
                <xsl:copy-of select="@*[not(name()='label')]"/> <!--  and not(name()='id') and not(name()='parent') -->
                <xsl:apply-templates mode="hl-did"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>

    <!-- This template copies everything else unless matched below or empty-->
    <xsl:template match="@*|node()">
        <xsl:if test=".!=''">
            <xsl:copy>
                <xsl:apply-templates select="@*[not(name()='label')]|node()"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>

    <!-- EADID: This template adds @encodinganalog, @urn, and @url to eadid and grabs as its value the value of <unitid>. 
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
            <xsl:value-of
                select="ancestor::ead:eadheader/following-sibling::ead:archdesc/ead:did/ead:unitid"/>
            <xsl:apply-templates select="*[not(text())]"/>
        </xsl:copy>
    </xsl:template>



    <!-- LANGUSAGE: This template replaces the langusage element with a language element containing langusage. 
        It adds an attribute to langusage. -->
    <xsl:template match="ead:langusage">
        <xsl:variable name="langusage-string" as="xs:string"
            select="normalize-space(string(//ead:langusage))"/>
        <langusage xmlns="urn:isbn:1-931666-22-9">
            <xsl:text>Finding aid written in </xsl:text>
            <xsl:if test="contains($langusage-string, 'English')">
                <language encodinganalog="dc:language">
                    <xsl:attribute name="langcode">eng</xsl:attribute>
                    <xsl:text>English</xsl:text>
                </language>
            </xsl:if>. </langusage>
    </xsl:template>

    <!-- These templates keep certain elements from being copied over -->
    <xsl:template match="ead:archdesc/ead:scopecontent" mode="hl-did"/>
    <xsl:template match="ead:archdesc/ead:arrangement" mode="hl-did"/>
    <xsl:template match="ead:archdesc/ead:accessrestrict" mode="hl-did"/>
    <xsl:template match="ead:archdesc/ead:userestrict" mode="hl-did"/>
    <xsl:template match="ead:archdesc/ead:otherfindaid" mode="hl-did"/>
    <xsl:template match="ead:archdesc/ead:relatedmaterial" mode="hl-did"/>
    <xsl:template match="ead:archdesc/ead:prefercite" mode="hl-did"/>
    <xsl:template match="ead:archdesc/ead:processinfo" mode="hl-did"/>
    <xsl:template match="ead:archdesc/ead:bibliography" mode="hl-did"/>
    <xsl:template match="ead:archdesc/ead:custodhist" mode="hl-did"/>
    <xsl:template match="ead:archdesc/ead:acqinfo" mode="hl-did"/>
    <xsl:template match="ead:archdesc/ead:appraisal" mode="hl-did"/>
    <xsl:template match="ead:archdesc/ead:accruals" mode="hl-did"/>
    <xsl:template match="ead:archdesc/ead:phystech" mode="hl-did"/>
    <xsl:template match="ead:archdesc/ead:originalsloc" mode="hl-did"/>
    <xsl:template match="ead:archdesc/ead:altformavail" mode="hl-did"/>
    <xsl:template match="ead:archdesc/ead:note" mode="hl-did"/>
    <xsl:template match="ead:repository/ead:corpname" mode="hl-did"/>
    <xsl:template match="ead:langmaterial[@label]" mode="hl-did"/>

    <xsl:template match="ead:head" mode="hl-did"/>
    <xsl:template match="ead:num" mode="hl-did"/>

    <xsl:template match="ead:dao" mode="hl-did"/>
    <xsl:template match="ead:odd" mode="hl-did"/>

    <!-- DAO -->
    <xsl:template match="ead:dsc//ead:dao" mode="hl-did">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="hl-did"/>
        </xsl:copy>
    </xsl:template>

    <!-- TITLEPROPER: adds @encodinganalog
    -->
    <xsl:template match="ead:titleproper">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="encodinganalog">dc:title</xsl:attribute>
            <xsl:apply-templates mode="hl-did"/>
        </xsl:copy>
    </xsl:template>

    <!-- TITLEPROPER/DATE adds encodinganalog -->
    <xsl:template match="ead:titleproper/ead:date" mode="hl-did">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="encodinganalog">dc:date</xsl:attribute>
            <xsl:apply-templates mode="hl-did"/>
        </xsl:copy>
    </xsl:template>

    <!-- TITLESTMT/AUTHOR adds punctuation -->
    <xsl:template match="ead:titlestmt/ead:author">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
            <xsl:text>.</xsl:text>
        </xsl:copy>
    </xsl:template>

    <!-- ARCHDESC: This template adds two attributes -->
    <xsl:template match="ead:archdesc">
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*"/>
            
            <xsl:attribute name="relatedencoding">marc21</xsl:attribute>
            <xsl:attribute name="type">findingaid</xsl:attribute>
            
            <xsl:apply-templates mode="hl-did"/>
            
        </xsl:copy>
    </xsl:template>

    <!-- ARCHDESC/UNITDATE: add @encodinganalog -->
    <xsl:template match="ead:archdesc/ead:unitdate">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="encodinganalog">245$f</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <!--UNITDATE: These templates add "undated" to folders but not virtual tabs.
        -->
    <xsl:template match="ead:unittitle" mode="hl-did">
          <xsl:copy>
            <xsl:copy-of select="@*"/>             
            <xsl:if test="parent::ead:did/parent::ead:archdesc">
                <xsl:attribute name="encodinganalog">245$a</xsl:attribute>
            </xsl:if>
              <xsl:apply-templates mode="hl-did"></xsl:apply-templates>
          </xsl:copy>    
<xsl:if test="not(following-sibling::ead:unitdate) and ancestor::ead:dsc">    
                    <xsl:choose>
                        <!-- don't put in "undated" for virtual tabs -->
                        <xsl:when
                            test="../../child::ead:c"/>
                        <xsl:otherwise>
                            <!-- do put in "undated" for folders -->
                            <unitdate>
                                <xsl:text>undated</xsl:text>
                            </unitdate>
                        </xsl:otherwise>
                    </xsl:choose>
      </xsl:if>    
    </xsl:template>

    <!-- UNITID: This template adds attributes to unitid -->
    <xsl:template match="ead:unitid" mode="hl-did">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="encodinganalog">084$a</xsl:attribute>
            <xsl:attribute name="countrycode">US</xsl:attribute>
            <xsl:attribute name="repositorycode">US-NjP</xsl:attribute>
            <xsl:attribute name="type">collection</xsl:attribute>
            <xsl:apply-templates mode="hl-did"/>
        </xsl:copy>
    </xsl:template>

    <!-- ORIGINATION: This template adds attributes to origination -->
    <xsl:template match="ead:archdesc/ead:did/ead:origination" mode="hl-did">
        <xsl:copy>
            <xsl:copy-of select="@*[not(name()='label')]"/>
            <xsl:if test="ead:persname[not(.='') and not(@role='Contributor (ctb)')]">
                    <xsl:attribute name="encodinganalog">600</xsl:attribute>
            </xsl:if>
            <xsl:if test="ead:corpname[not(.='') and not(@role='Contributor (ctb)')]">
                    <xsl:attribute name="encodinganalog">610</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <!-- PHYSDESC: This template removes and attribute from physdesc -->
    <xsl:template match="ead:physdesc" mode="hl-did">
        <xsl:copy>
            <xsl:copy-of select="@*[not(name()='label')]"/>
            <xsl:apply-templates></xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <!-- EXTENT: This template adds an attribute to extent -->
    <xsl:template match="ead:archdesc/ead:did/ead:physdesc/ead:extent">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="encodinganalog">300$a</xsl:attribute>
            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>
    
    <!-- DESCRULES: inser boilerplate -->
    <xsl:template match="ead:descrules">
        <descrules>Finding aid content adheres to that prescribed by <emph render="italic">
            <expan abbr="dacs" altrender="MARC">Describing Archives: A Content
                Standard</expan>. </emph>
        </descrules>
    </xsl:template>


    <!-- LANGMATERIAL: This template adds attributes to langmaterial and expands language. -->
    <xsl:template match="ead:langmaterial" mode="hl-did">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="encodinganalog">546$a</xsl:attribute>
            <xsl:apply-templates mode="hl-did"/>

            <xsl:for-each select="//ead:langmaterial/ead:language[not(@langcode='mul')]">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="encodinganalog">041$a</xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="@langcode='aar'">
                            <xsl:text>Afar</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='aa'">
                            <xsl:text>Afar</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='abk'">
                            <xsl:text>Abkhazian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ab'">
                            <xsl:text>Abkhazian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ace'">
                            <xsl:text>Achinese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ach'">
                            <xsl:text>Acoli</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ada'">
                            <xsl:text>Adangme</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ady'">
                            <xsl:text>Adyghe or Adygei</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='afa'">
                            <xsl:text>Afro-Asiatic (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='afh'">
                            <xsl:text>Afrihili</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='afr'">
                            <xsl:text>Afrikaans</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='af'">
                            <xsl:text>Afrikaans</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ain'">
                            <xsl:text>Ainu</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='aka'">
                            <xsl:text>Akan</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ak'">
                            <xsl:text>Akan</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='akk'">
                            <xsl:text>Akkadian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='alb'">
                            <xsl:text>Albanian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sqi'">
                            <xsl:text>Albanian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sq'">
                            <xsl:text>Albanian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ale'">
                            <xsl:text>Aleut</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='alg'">
                            <xsl:text>Algonquian languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='alt'">
                            <xsl:text>Southern Altai</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='amh'">
                            <xsl:text>Amharic</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='am'">
                            <xsl:text>Amharic</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ang'">
                            <xsl:text>English, Old (ca.450-1100)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='anp'">
                            <xsl:text>Angika</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='apa'">
                            <xsl:text>Apache languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ara'">
                            <xsl:text>Arabic</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ar'">
                            <xsl:text>Arabic</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='arc'">
                            <xsl:text>Aramaic</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='arg'">
                            <xsl:text>Aragonese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='an'">
                            <xsl:text>Aragonese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='arm'">
                            <xsl:text>Armenian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='hye'">
                            <xsl:text>Armenian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='hy'">
                            <xsl:text>Armenian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='arn'">
                            <xsl:text>Mapudungun or Mapuche</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='arp'">
                            <xsl:text>Arapaho</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='art'">
                            <xsl:text>Artificial (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='arw'">
                            <xsl:text>Arawak</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='asm'">
                            <xsl:text>Assamese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='as'">
                            <xsl:text>Assamese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ast'">
                            <xsl:text>Asturian or Bable</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ath'">
                            <xsl:text>Athapascan languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='aus'">
                            <xsl:text>Australian languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ava'">
                            <xsl:text>Avaric</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='av'">
                            <xsl:text>Avaric</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ave'">
                            <xsl:text>Avestan</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ae'">
                            <xsl:text>Avestan</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='awa'">
                            <xsl:text>Awadhi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='aym'">
                            <xsl:text>Aymara</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ay'">
                            <xsl:text>Aymara</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='aze'">
                            <xsl:text>Azerbaijani</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='az'">
                            <xsl:text>Azerbaijani</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bad'">
                            <xsl:text>Banda languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bai'">
                            <xsl:text>Bamileke languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bak'">
                            <xsl:text>Bashkir</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ba'">
                            <xsl:text>Bashkir</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bal'">
                            <xsl:text>Baluchi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bam'">
                            <xsl:text>Bambara</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bm'">
                            <xsl:text>Bambara</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ban'">
                            <xsl:text>Balinese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='baq'">
                            <xsl:text>Basque</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='eus'">
                            <xsl:text>Basque</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='eu'">
                            <xsl:text>Basque</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bas'">
                            <xsl:text>Basa</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bat'">
                            <xsl:text>Baltic (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bej'">
                            <xsl:text>Beja</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bel'">
                            <xsl:text>Belarusian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='be'">
                            <xsl:text>Belarusian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bem'">
                            <xsl:text>Bemba</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ben'">
                            <xsl:text>Bengali</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bn'">
                            <xsl:text>Bengali</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ber'">
                            <xsl:text>Berber (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bho'">
                            <xsl:text>Bhojpuri</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bih'">
                            <xsl:text>Bihari</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bh'">
                            <xsl:text>Bihari</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bik'">
                            <xsl:text>Bikol</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bin'">
                            <xsl:text>Bini or Edo</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bis'">
                            <xsl:text>Bislama</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bi'">
                            <xsl:text>Bislama</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bla'">
                            <xsl:text>Siksika</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bnt'">
                            <xsl:text>Bantu (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bos'">
                            <xsl:text>Bosnian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bs'">
                            <xsl:text>Bosnian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bra'">
                            <xsl:text>Braj</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bre'">
                            <xsl:text>Breton</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='br'">
                            <xsl:text>Breton</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='btk'">
                            <xsl:text>Batak languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bua'">
                            <xsl:text>Buriat</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bug'">
                            <xsl:text>Buginese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bul'">
                            <xsl:text>Bulgarian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bg'">
                            <xsl:text>Bulgarian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bur'">
                            <xsl:text>Burmese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mya'">
                            <xsl:text>Burmese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='my'">
                            <xsl:text>Burmese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='byn'">
                            <xsl:text>Blin or Bilin</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='cad'">
                            <xsl:text>Caddo</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='cai'">
                            <xsl:text>Central American Indian (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='car'">
                            <xsl:text>Galibi Carib</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='cat'">
                            <xsl:text>Catalan or Valencian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ca'">
                            <xsl:text>Catalan or Valencian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='cau'">
                            <xsl:text>Caucasian (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ceb'">
                            <xsl:text>Cebuano</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='cel'">
                            <xsl:text>Celtic (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='cha'">
                            <xsl:text>Chamorro</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ch'">
                            <xsl:text>Chamorro</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='chb'">
                            <xsl:text>Chibcha</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='che'">
                            <xsl:text>Chechen</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ce'">
                            <xsl:text>Chechen</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='chg'">
                            <xsl:text>Chagatai</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='chi'">
                            <xsl:text>Chinese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='zho'">
                            <xsl:text>Chinese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='zh'">
                            <xsl:text>Chinese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='chk'">
                            <xsl:text>Chuukese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='chm'">
                            <xsl:text>Mari</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='chn'">
                            <xsl:text>Chinook jargon</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='cho'">
                            <xsl:text>Choctaw</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='chp'">
                            <xsl:text>Chipewyan</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='chr'">
                            <xsl:text>Cherokee</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='chu'">
                            <xsl:text>Church Slavic or Old Slavonic or Church Slavonic or Old Bulgarian or Old Church Slavonic</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='cu'">
                            <xsl:text>Church Slavic or Old Slavonic or Church Slavonic or Old Bulgarian or Old Church Slavonic</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='chv'">
                            <xsl:text>Chuvash</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='cv'">
                            <xsl:text>Chuvash</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='chy'">
                            <xsl:text>Cheyenne</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='cmc'">
                            <xsl:text>Chamic languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='cop'">
                            <xsl:text>Coptic</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='cor'">
                            <xsl:text>Cornish</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kw'">
                            <xsl:text>Cornish</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='cos'">
                            <xsl:text>Corsican</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='co'">
                            <xsl:text>Corsican</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='cpe'">
                            <xsl:text>Creoles and pidgins, English based (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='cpf'">
                            <xsl:text>Creoles and pidgins, French-based (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='cpp'">
                            <xsl:text>Creoles and pidgins, Portuguese-based (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='cre'">
                            <xsl:text>Cree</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='cr'">
                            <xsl:text>Cree</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='crh'">
                            <xsl:text>Crimean Tatar or Crimean Turkish</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='crp'">
                            <xsl:text>Creoles and pidgins (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='csb'">
                            <xsl:text>Kashubian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='cus'">
                            <xsl:text>Cushitic (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='cze'">
                            <xsl:text>Czech</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ces'">
                            <xsl:text>Czech</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='cs'">
                            <xsl:text>Czech</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='dak'">
                            <xsl:text>Dakota</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='dan'">
                            <xsl:text>Danish</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='da'">
                            <xsl:text>Danish</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='dar'">
                            <xsl:text>Dargwa</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='day'">
                            <xsl:text>Land Dayak languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='del'">
                            <xsl:text>Delaware</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='den'">
                            <xsl:text>Slave (Athapascan)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='dgr'">
                            <xsl:text>Dogrib</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='din'">
                            <xsl:text>Dinka</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='div'">
                            <xsl:text>Divehi or Dhivehi or Maldivian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='dv'">
                            <xsl:text>Divehi or Dhivehi or Maldivian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='doi'">
                            <xsl:text>Dogri</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='dra'">
                            <xsl:text>Dravidian (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='dsb'">
                            <xsl:text>Lower Sorbian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='dua'">
                            <xsl:text>Duala</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='dum'">
                            <xsl:text>Dutch, Middle (ca.1050-1350)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='dut'">
                            <xsl:text>Dutch or Flemish</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nld'">
                            <xsl:text>Dutch or Flemish</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nl'">
                            <xsl:text>Dutch or Flemish</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='dyu'">
                            <xsl:text>Dyula</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='dzo'">
                            <xsl:text>Dzongkha</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='dz'">
                            <xsl:text>Dzongkha</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='efi'">
                            <xsl:text>Efik</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='egy'">
                            <xsl:text>Egyptian (Ancient)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='eka'">
                            <xsl:text>Ekajuk</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='elx'">
                            <xsl:text>Elamite</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='eng'">
                            <xsl:text>English</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='en'">
                            <xsl:text>English</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='enm'">
                            <xsl:text>English, Middle (1100-1500)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='epo'">
                            <xsl:text>Esperanto</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='eo'">
                            <xsl:text>Esperanto</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='est'">
                            <xsl:text>Estonian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='et'">
                            <xsl:text>Estonian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ewe'">
                            <xsl:text>Ewe</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ee'">
                            <xsl:text>Ewe</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ewo'">
                            <xsl:text>Ewondo</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='fan'">
                            <xsl:text>Fang</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='fao'">
                            <xsl:text>Faroese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='fo'">
                            <xsl:text>Faroese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='fat'">
                            <xsl:text>Fanti</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='fij'">
                            <xsl:text>Fijian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='fj'">
                            <xsl:text>Fijian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='fil'">
                            <xsl:text>Filipino or Pilipino</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='fin'">
                            <xsl:text>Finnish</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='fi'">
                            <xsl:text>Finnish</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='fiu'">
                            <xsl:text>Finno-Ugrian (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='fon'">
                            <xsl:text>Fon</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='fre'">
                            <xsl:text>French</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='fra'">
                            <xsl:text>French</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='fr'">
                            <xsl:text>French</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='frm'">
                            <xsl:text>French, Middle (ca.1400-1600)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='fro'">
                            <xsl:text>French, Old (842-ca.1400)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='frr'">
                            <xsl:text>Northern Frisian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='frs'">
                            <xsl:text>Eastern Frisian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='fry'">
                            <xsl:text>Western Frisian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='fy'">
                            <xsl:text>Western Frisian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ful'">
                            <xsl:text>Fulah</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ff'">
                            <xsl:text>Fulah</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='fur'">
                            <xsl:text>Friulian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='gaa'">
                            <xsl:text>Ga</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='gay'">
                            <xsl:text>Gayo</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='gba'">
                            <xsl:text>Gbaya</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='gem'">
                            <xsl:text>Germanic (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='geo'">
                            <xsl:text>Georgian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kat'">
                            <xsl:text>Georgian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ka'">
                            <xsl:text>Georgian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ger'">
                            <xsl:text>German</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='deu'">
                            <xsl:text>German</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='de'">
                            <xsl:text>German</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='gez'">
                            <xsl:text>Geez</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='gil'">
                            <xsl:text>Gilbertese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='gla'">
                            <xsl:text>Gaelic or Scottish Gaelic</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='gd'">
                            <xsl:text>Gaelic or Scottish Gaelic</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='gle'">
                            <xsl:text>Irish</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ga'">
                            <xsl:text>Irish</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='glg'">
                            <xsl:text>Galician</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='gl'">
                            <xsl:text>Galician</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='glv'">
                            <xsl:text>Manx</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='gv'">
                            <xsl:text>Manx</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='gmh'">
                            <xsl:text>German, Middle High (ca.1050-1500)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='goh'">
                            <xsl:text>German, Old High (ca.750-1050)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='gon'">
                            <xsl:text>Gondi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='gor'">
                            <xsl:text>Gorontalo</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='got'">
                            <xsl:text>Gothic</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='grb'">
                            <xsl:text>Grebo</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='grc'">
                            <xsl:text>Greek, Ancient (to 1453)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='gre'">
                            <xsl:text>Greek, Modern (1453-)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ell'">
                            <xsl:text>Greek, Modern (1453-)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='el'">
                            <xsl:text>Greek, Modern (1453-)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='grn'">
                            <xsl:text>Guarani</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='gn'">
                            <xsl:text>Guarani</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='gsw'">
                            <xsl:text>Swiss German or Alemannic</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='guj'">
                            <xsl:text>Gujarati</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='gu'">
                            <xsl:text>Gujarati</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='gwi'">
                            <xsl:text>Gwich'in</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='hai'">
                            <xsl:text>Haida</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='hat'">
                            <xsl:text>Haitian or Haitian Creole</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ht'">
                            <xsl:text>Haitian or Haitian Creole</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='hau'">
                            <xsl:text>Hausa</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ha'">
                            <xsl:text>Hausa</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='haw'">
                            <xsl:text>Hawaiian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='heb'">
                            <xsl:text>Hebrew</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='he'">
                            <xsl:text>Hebrew</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='her'">
                            <xsl:text>Herero</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='hz'">
                            <xsl:text>Herero</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='hil'">
                            <xsl:text>Hiligaynon</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='him'">
                            <xsl:text>Himachali</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='hin'">
                            <xsl:text>Hindi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='hi'">
                            <xsl:text>Hindi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='hit'">
                            <xsl:text>Hittite</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='hmn'">
                            <xsl:text>Hmong</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='hmo'">
                            <xsl:text>Hiri Motu</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ho'">
                            <xsl:text>Hiri Motu</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='hsb'">
                            <xsl:text>Upper Sorbian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='hun'">
                            <xsl:text>Hungarian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='hu'">
                            <xsl:text>Hungarian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='hup'">
                            <xsl:text>Hupa</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='iba'">
                            <xsl:text>Iban</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ibo'">
                            <xsl:text>Igbo</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ig'">
                            <xsl:text>Igbo</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ice'">
                            <xsl:text>Icelandic</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='isl'">
                            <xsl:text>Icelandic</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='is'">
                            <xsl:text>Icelandic</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ido'">
                            <xsl:text>Ido</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='io'">
                            <xsl:text>Ido</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='iii'">
                            <xsl:text>Sichuan Yi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ii'">
                            <xsl:text>Sichuan Yi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ijo'">
                            <xsl:text>Ijo languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='iku'">
                            <xsl:text>Inuktitut</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='iu'">
                            <xsl:text>Inuktitut</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ile'">
                            <xsl:text>Interlingue</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ie'">
                            <xsl:text>Interlingue</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ilo'">
                            <xsl:text>Iloko</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ina'">
                            <xsl:text>Interlingua (International Auxiliary Language Association)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ia'">
                            <xsl:text>Interlingua (International Auxiliary Language Association)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='inc'">
                            <xsl:text>Indic (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ind'">
                            <xsl:text>Indonesian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='id'">
                            <xsl:text>Indonesian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ine'">
                            <xsl:text>Indo-European (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='inh'">
                            <xsl:text>Ingush</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ipk'">
                            <xsl:text>Inupiaq</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ik'">
                            <xsl:text>Inupiaq</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ira'">
                            <xsl:text>Iranian (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='iro'">
                            <xsl:text>Iroquoian languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ita'">
                            <xsl:text>Italian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='it'">
                            <xsl:text>Italian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='jav'">
                            <xsl:text>Javanese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='jv'">
                            <xsl:text>Javanese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='jbo'">
                            <xsl:text>Lojban</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='jpn'">
                            <xsl:text>Japanese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ja'">
                            <xsl:text>Japanese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='jpr'">
                            <xsl:text>Judeo-Persian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='jrb'">
                            <xsl:text>Judeo-Arabic</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kaa'">
                            <xsl:text>Kara-Kalpak</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kab'">
                            <xsl:text>Kabyle</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kac'">
                            <xsl:text>Kachin or Jingpho</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kal'">
                            <xsl:text>Kalaallisut or Greenlandic</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kl'">
                            <xsl:text>Kalaallisut or Greenlandic</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kam'">
                            <xsl:text>Kamba</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kan'">
                            <xsl:text>Kannada</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kn'">
                            <xsl:text>Kannada</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kar'">
                            <xsl:text>Karen languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kas'">
                            <xsl:text>Kashmiri</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ks'">
                            <xsl:text>Kashmiri</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kau'">
                            <xsl:text>Kanuri</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kr'">
                            <xsl:text>Kanuri</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kaw'">
                            <xsl:text>Kawi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kaz'">
                            <xsl:text>Kazakh</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kk'">
                            <xsl:text>Kazakh</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kbd'">
                            <xsl:text>Kabardian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kha'">
                            <xsl:text>Khasi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='khi'">
                            <xsl:text>Khoisan (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='khm'">
                            <xsl:text>Central Khmer</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='km'">
                            <xsl:text>Central Khmer</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kho'">
                            <xsl:text>Khotanese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kik'">
                            <xsl:text>Kikuyu or Gikuyu</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ki'">
                            <xsl:text>Kikuyu or Gikuyu</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kin'">
                            <xsl:text>Kinyarwanda</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='rw'">
                            <xsl:text>Kinyarwanda</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kir'">
                            <xsl:text>Kirghiz or Kyrgyz</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ky'">
                            <xsl:text>Kirghiz or Kyrgyz</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kmb'">
                            <xsl:text>Kimbundu</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kok'">
                            <xsl:text>Konkani</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kom'">
                            <xsl:text>Komi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kv'">
                            <xsl:text>Komi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kon'">
                            <xsl:text>Kongo</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kg'">
                            <xsl:text>Kongo</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kor'">
                            <xsl:text>Korean</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ko'">
                            <xsl:text>Korean</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kos'">
                            <xsl:text>Kosraean</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kpe'">
                            <xsl:text>Kpelle</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='krc'">
                            <xsl:text>Karachay-Balkar</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='krl'">
                            <xsl:text>Karelian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kro'">
                            <xsl:text>Kru languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kru'">
                            <xsl:text>Kurukh</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kua'">
                            <xsl:text>Kuanyama or Kwanyama</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kj'">
                            <xsl:text>Kuanyama or Kwanyama</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kum'">
                            <xsl:text>Kumyk</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kur'">
                            <xsl:text>Kurdish</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ku'">
                            <xsl:text>Kurdish</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='kut'">
                            <xsl:text>Kutenai</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='lad'">
                            <xsl:text>Ladino</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='lah'">
                            <xsl:text>Lahnda</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='lam'">
                            <xsl:text>Lamba</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='lao'">
                            <xsl:text>Lao</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='lo'">
                            <xsl:text>Lao</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='lat'">
                            <xsl:text>Latin</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='la'">
                            <xsl:text>Latin</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='lav'">
                            <xsl:text>Latvian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='lv'">
                            <xsl:text>Latvian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='lez'">
                            <xsl:text>Lezghian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='lim'">
                            <xsl:text>Limburgan or Limburger or Limburgish</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='li'">
                            <xsl:text>Limburgan or Limburger or Limburgish</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='lin'">
                            <xsl:text>Lingala</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ln'">
                            <xsl:text>Lingala</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='lit'">
                            <xsl:text>Lithuanian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='lt'">
                            <xsl:text>Lithuanian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='lol'">
                            <xsl:text>Mongo</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='loz'">
                            <xsl:text>Lozi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ltz'">
                            <xsl:text>Luxembourgish or Letzeburgesch</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='lb'">
                            <xsl:text>Luxembourgish or Letzeburgesch</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='lua'">
                            <xsl:text>Luba-Lulua</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='lub'">
                            <xsl:text>Luba-Katanga</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='lu'">
                            <xsl:text>Luba-Katanga</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='lug'">
                            <xsl:text>Ganda</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='lg'">
                            <xsl:text>Ganda</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='lui'">
                            <xsl:text>Luiseno</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='lun'">
                            <xsl:text>Lunda</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='luo'">
                            <xsl:text>Luo (Kenya and Tanzania)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='lus'">
                            <xsl:text>Lushai</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mac'">
                            <xsl:text>Macedonian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mkd'">
                            <xsl:text>Macedonian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mk'">
                            <xsl:text>Macedonian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mad'">
                            <xsl:text>Madurese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mag'">
                            <xsl:text>Magahi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mah'">
                            <xsl:text>Marshallese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mh'">
                            <xsl:text>Marshallese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mai'">
                            <xsl:text>Maithili</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mak'">
                            <xsl:text>Makasar</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mal'">
                            <xsl:text>Malayalam</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ml'">
                            <xsl:text>Malayalam</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='man'">
                            <xsl:text>Mandingo</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mao'">
                            <xsl:text>Maori</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mri'">
                            <xsl:text>Maori</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mi'">
                            <xsl:text>Maori</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='map'">
                            <xsl:text>Austronesian (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mar'">
                            <xsl:text>Marathi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mr'">
                            <xsl:text>Marathi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mas'">
                            <xsl:text>Masai</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='may'">
                            <xsl:text>Malay</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='msa'">
                            <xsl:text>Malay</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ms'">
                            <xsl:text>Malay</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mdf'">
                            <xsl:text>Moksha</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mdr'">
                            <xsl:text>Mandar</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='men'">
                            <xsl:text>Mende</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mga'">
                            <xsl:text>Irish, Middle (900-1200)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mic'">
                            <xsl:text>Mi'kmaq or Micmac</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='min'">
                            <xsl:text>Minangkabau</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mis'">
                            <xsl:text>Miscellaneous languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mkh'">
                            <xsl:text>Mon-Khmer (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mlg'">
                            <xsl:text>Malagasy</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mg'">
                            <xsl:text>Malagasy</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mlt'">
                            <xsl:text>Maltese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mt'">
                            <xsl:text>Maltese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mnc'">
                            <xsl:text>Manchu</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mni'">
                            <xsl:text>Manipuri</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mno'">
                            <xsl:text>Manobo languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='moh'">
                            <xsl:text>Mohawk</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mol'">
                            <xsl:text>Moldavian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mo'">
                            <xsl:text>Moldavian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mon'">
                            <xsl:text>Mongolian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mn'">
                            <xsl:text>Mongolian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mos'">
                            <xsl:text>Mossi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mun'">
                            <xsl:text>Munda languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mus'">
                            <xsl:text>Creek</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mwl'">
                            <xsl:text>Mirandese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='mwr'">
                            <xsl:text>Marwari</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='myn'">
                            <xsl:text>Mayan languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='myv'">
                            <xsl:text>Erzya</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nah'">
                            <xsl:text>Nahuatl languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nai'">
                            <xsl:text>North American Indian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nap'">
                            <xsl:text>Neapolitan</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nau'">
                            <xsl:text>Nauru</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='na'">
                            <xsl:text>Nauru</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nav'">
                            <xsl:text>Navajo or Navaho</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nv'">
                            <xsl:text>Navajo or Navaho</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nbl'">
                            <xsl:text>Ndebele, South or South Ndebele</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nr'">
                            <xsl:text>Ndebele, South or South Ndebele</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nde'">
                            <xsl:text>Ndebele, North or North Ndebele</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nd'">
                            <xsl:text>Ndebele, North or North Ndebele</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ndo'">
                            <xsl:text>Ndonga</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ng'">
                            <xsl:text>Ndonga</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nds'">
                            <xsl:text>Low German or Low Saxon or German, Low or Saxon, Low</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nep'">
                            <xsl:text>Nepali</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ne'">
                            <xsl:text>Nepali</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='new'">
                            <xsl:text>Nepal Bhasa or Newari</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nia'">
                            <xsl:text>Nias</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nic'">
                            <xsl:text>Niger-Kordofanian (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='niu'">
                            <xsl:text>Niuean</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nno'">
                            <xsl:text>Norwegian Nynorsk or Nynorsk, Norwegian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nn'">
                            <xsl:text>Norwegian Nynorsk or Nynorsk, Norwegian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nob'">
                            <xsl:text>BokmÃ¥l, Norwegian or Norwegian BokmÃ¥l</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nb'">
                            <xsl:text>BokmÃ¥l, Norwegian or Norwegian BokmÃ¥l</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nog'">
                            <xsl:text>Nogai</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='non'">
                            <xsl:text>Norse, Old</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nor'">
                            <xsl:text>Norwegian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='no'">
                            <xsl:text>Norwegian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nso'">
                            <xsl:text>Pedi or Sepedi or Northern Sotho</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nub'">
                            <xsl:text>Nubian languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nwc'">
                            <xsl:text>Classical Newari or Old Newari or Classical Nepal Bhasa</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nya'">
                            <xsl:text>Chichewa or Chewa or Nyanja</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ny'">
                            <xsl:text>Chichewa or Chewa or Nyanja</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nym'">
                            <xsl:text>Nyamwezi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nyn'">
                            <xsl:text>Nyankole</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nyo'">
                            <xsl:text>Nyoro</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nzi'">
                            <xsl:text>Nzima</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='oci'">
                            <xsl:text>Occitan (post 1500) or ProvenÃ§al</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='oc'">
                            <xsl:text>Occitan (post 1500) or ProvenÃ§al</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='oji'">
                            <xsl:text>Ojibwa</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='oj'">
                            <xsl:text>Ojibwa</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ori'">
                            <xsl:text>Oriya</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='or'">
                            <xsl:text>Oriya</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='orm'">
                            <xsl:text>Oromo</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='om'">
                            <xsl:text>Oromo</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='osa'">
                            <xsl:text>Osage</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='oss'">
                            <xsl:text>Ossetian or Ossetic</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='os'">
                            <xsl:text>Ossetian or Ossetic</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ota'">
                            <xsl:text>Turkish, Ottoman (1500-1928)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='oto'">
                            <xsl:text>Otomian languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='paa'">
                            <xsl:text>Papuan (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='pag'">
                            <xsl:text>Pangasinan</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='pal'">
                            <xsl:text>Pahlavi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='pam'">
                            <xsl:text>Pampanga</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='pan'">
                            <xsl:text>Panjabi or Punjabi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='pa'">
                            <xsl:text>Panjabi or Punjabi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='pap'">
                            <xsl:text>Papiamento</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='pau'">
                            <xsl:text>Palauan</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='peo'">
                            <xsl:text>Persian, Old (ca.600-400 B.C.)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='per'">
                            <xsl:text>Persian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='fas'">
                            <xsl:text>Persian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='fa'">
                            <xsl:text>Persian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='phi'">
                            <xsl:text>Philippine (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='phn'">
                            <xsl:text>Phoenician</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='pli'">
                            <xsl:text>Pali</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='pi'">
                            <xsl:text>Pali</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='pol'">
                            <xsl:text>Polish</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='pl'">
                            <xsl:text>Polish</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='pon'">
                            <xsl:text>Pohnpeian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='por'">
                            <xsl:text>Portuguese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='pt'">
                            <xsl:text>Portuguese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='pra'">
                            <xsl:text>Prakrit languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='pro'">
                            <xsl:text>ProvenÃ§al, Old (to 1500)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='pus'">
                            <xsl:text>Pushto</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ps'">
                            <xsl:text>Pushto</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='que'">
                            <xsl:text>Quechua</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='qu'">
                            <xsl:text>Quechua</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='raj'">
                            <xsl:text>Rajasthani</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='rap'">
                            <xsl:text>Rapanui</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='rar'">
                            <xsl:text>Rarotongan or Cook Islands Maori</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='roa'">
                            <xsl:text>Romance (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='roh'">
                            <xsl:text>Romansh</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='rm'">
                            <xsl:text>Romansh</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='rom'">
                            <xsl:text>Romany</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='rum'">
                            <xsl:text>Romanian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ron'">
                            <xsl:text>Romanian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ro'">
                            <xsl:text>Romanian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='run'">
                            <xsl:text>Rundi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='rn'">
                            <xsl:text>Rundi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='rup'">
                            <xsl:text>Aromanian or Arumanian or Macedo-Romanian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='rus'">
                            <xsl:text>Russian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ru'">
                            <xsl:text>Russian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sad'">
                            <xsl:text>Sandawe</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sag'">
                            <xsl:text>Sango</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sg'">
                            <xsl:text>Sango</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sah'">
                            <xsl:text>Yakut</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sai'">
                            <xsl:text>South American Indian (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sal'">
                            <xsl:text>Salishan languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sam'">
                            <xsl:text>Samaritan Aramaic</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='san'">
                            <xsl:text>Sanskrit</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sa'">
                            <xsl:text>Sanskrit</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sas'">
                            <xsl:text>Sasak</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sat'">
                            <xsl:text>Santali</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='scc'">
                            <xsl:text>Serbian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='srp'">
                            <xsl:text>Serbian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sr'">
                            <xsl:text>Serbian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='scn'">
                            <xsl:text>Sicilian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sco'">
                            <xsl:text>Scots</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='scr'">
                            <xsl:text>Croatian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='hrv'">
                            <xsl:text>Croatian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='hr'">
                            <xsl:text>Croatian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sel'">
                            <xsl:text>Selkup</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sem'">
                            <xsl:text>Semitic (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sga'">
                            <xsl:text>Irish, Old (to 900)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sgn'">
                            <xsl:text>Sign Languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='shn'">
                            <xsl:text>Shan</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sid'">
                            <xsl:text>Sidamo</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sin'">
                            <xsl:text>Sinhala or Sinhalese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='si'">
                            <xsl:text>Sinhala or Sinhalese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sio'">
                            <xsl:text>Siouan languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sit'">
                            <xsl:text>Sino-Tibetan (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sla'">
                            <xsl:text>Slavic (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='slo'">
                            <xsl:text>Slovak</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='slk'">
                            <xsl:text>Slovak</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sk'">
                            <xsl:text>Slovak</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='slv'">
                            <xsl:text>Slovenian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sl'">
                            <xsl:text>Slovenian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sma'">
                            <xsl:text>Southern Sami</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sme'">
                            <xsl:text>Northern Sami</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='se'">
                            <xsl:text>Northern Sami</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='smi'">
                            <xsl:text>Sami languages (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='smj'">
                            <xsl:text>Lule Sami</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='smn'">
                            <xsl:text>Inari Sami</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='smo'">
                            <xsl:text>Samoan</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sm'">
                            <xsl:text>Samoan</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sms'">
                            <xsl:text>Skolt Sami</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sna'">
                            <xsl:text>Shona</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sn'">
                            <xsl:text>Shona</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='snd'">
                            <xsl:text>Sindhi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sd'">
                            <xsl:text>Sindhi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='snk'">
                            <xsl:text>Soninke</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sog'">
                            <xsl:text>Sogdian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='som'">
                            <xsl:text>Somali</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='so'">
                            <xsl:text>Somali</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='son'">
                            <xsl:text>Songhai languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sot'">
                            <xsl:text>Sotho, Southern</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='st'">
                            <xsl:text>Sotho, Southern</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='spa'">
                            <xsl:text>Spanish or Castilian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='es'">
                            <xsl:text>Spanish or Castilian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='srd'">
                            <xsl:text>Sardinian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sc'">
                            <xsl:text>Sardinian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='srn'">
                            <xsl:text>Sranan Tongo</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='srr'">
                            <xsl:text>Serer</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ssa'">
                            <xsl:text>Nilo-Saharan (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ssw'">
                            <xsl:text>Swati</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ss'">
                            <xsl:text>Swati</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='suk'">
                            <xsl:text>Sukuma</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sun'">
                            <xsl:text>Sundanese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='su'">
                            <xsl:text>Sundanese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sus'">
                            <xsl:text>Susu</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sux'">
                            <xsl:text>Sumerian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='swa'">
                            <xsl:text>Swahili</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sw'">
                            <xsl:text>Swahili</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='swe'">
                            <xsl:text>Swedish</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='sv'">
                            <xsl:text>Swedish</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='syr'">
                            <xsl:text>Syriac</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tah'">
                            <xsl:text>Tahitian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ty'">
                            <xsl:text>Tahitian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tai'">
                            <xsl:text>Tai (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tam'">
                            <xsl:text>Tamil</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ta'">
                            <xsl:text>Tamil</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tat'">
                            <xsl:text>Tatar</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tt'">
                            <xsl:text>Tatar</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tel'">
                            <xsl:text>Telugu</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='te'">
                            <xsl:text>Telugu</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tem'">
                            <xsl:text>Timne</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ter'">
                            <xsl:text>Tereno</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tet'">
                            <xsl:text>Tetum</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tgk'">
                            <xsl:text>Tajik</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tg'">
                            <xsl:text>Tajik</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tgl'">
                            <xsl:text>Tagalog</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tl'">
                            <xsl:text>Tagalog</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tha'">
                            <xsl:text>Thai</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='th'">
                            <xsl:text>Thai</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tib'">
                            <xsl:text>Tibetan</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bod'">
                            <xsl:text>Tibetan</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='bo'">
                            <xsl:text>Tibetan</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tig'">
                            <xsl:text>Tigre</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tir'">
                            <xsl:text>Tigrinya</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ti'">
                            <xsl:text>Tigrinya</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tiv'">
                            <xsl:text>Tiv</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tkl'">
                            <xsl:text>Tokelau</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tlh'">
                            <xsl:text>Klingon or tlhIngan-Hol</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tli'">
                            <xsl:text>Tlingit</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tmh'">
                            <xsl:text>Tamashek</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tog'">
                            <xsl:text>Tonga (Nyasa)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ton'">
                            <xsl:text>Tonga (Tonga Islands)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='to'">
                            <xsl:text>Tonga (Tonga Islands)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tpi'">
                            <xsl:text>Tok Pisin</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tsi'">
                            <xsl:text>Tsimshian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tsn'">
                            <xsl:text>Tswana</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tn'">
                            <xsl:text>Tswana</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tso'">
                            <xsl:text>Tsonga</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ts'">
                            <xsl:text>Tsonga</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tuk'">
                            <xsl:text>Turkmen</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tk'">
                            <xsl:text>Turkmen</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tum'">
                            <xsl:text>Tumbuka</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tup'">
                            <xsl:text>Tupi languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tur'">
                            <xsl:text>Turkish</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tr'">
                            <xsl:text>Turkish</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tut'">
                            <xsl:text>Altaic (Other)</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tvl'">
                            <xsl:text>Tuvalu</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='twi'">
                            <xsl:text>Twi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tw'">
                            <xsl:text>Twi</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='tyv'">
                            <xsl:text>Tuvinian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='udm'">
                            <xsl:text>Udmurt</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='uga'">
                            <xsl:text>Ugaritic</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='uig'">
                            <xsl:text>Uighur or Uyghur</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ug'">
                            <xsl:text>Uighur or Uyghur</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ukr'">
                            <xsl:text>Ukrainian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='uk'">
                            <xsl:text>Ukrainian</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='umb'">
                            <xsl:text>Umbundu</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='und'">
                            <xsl:text>Undetermined</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='urd'">
                            <xsl:text>Urdu</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ur'">
                            <xsl:text>Urdu</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='uzb'">
                            <xsl:text>Uzbek</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='uz'">
                            <xsl:text>Uzbek</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='vai'">
                            <xsl:text>Vai</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ven'">
                            <xsl:text>Venda</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ve'">
                            <xsl:text>Venda</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='vie'">
                            <xsl:text>Vietnamese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='vi'">
                            <xsl:text>Vietnamese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='vol'">
                            <xsl:text>VolapÃ¼k</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='vo'">
                            <xsl:text>VolapÃ¼k</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='vot'">
                            <xsl:text>Votic</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='wak'">
                            <xsl:text>Wakashan languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='wal'">
                            <xsl:text>Walamo</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='war'">
                            <xsl:text>Waray</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='was'">
                            <xsl:text>Washo</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='wel'">
                            <xsl:text>Welsh</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='cym'">
                            <xsl:text>Welsh</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='cy'">
                            <xsl:text>Welsh</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='wen'">
                            <xsl:text>Sorbian languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='wln'">
                            <xsl:text>Walloon</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='wa'">
                            <xsl:text>Walloon</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='wol'">
                            <xsl:text>Wolof</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='wo'">
                            <xsl:text>Wolof</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='xal'">
                            <xsl:text>Kalmyk or Oirat</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='xho'">
                            <xsl:text>Xhosa</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='xh'">
                            <xsl:text>Xhosa</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='yao'">
                            <xsl:text>Yao</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='yap'">
                            <xsl:text>Yapese</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='yid'">
                            <xsl:text>Yiddish</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='yi'">
                            <xsl:text>Yiddish</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='yor'">
                            <xsl:text>Yoruba</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='yo'">
                            <xsl:text>Yoruba</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='ypk'">
                            <xsl:text>Yupik languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='zap'">
                            <xsl:text>Zapotec</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='zen'">
                            <xsl:text>Zenaga</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='zha'">
                            <xsl:text>Zhuang or Chuang</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='za'">
                            <xsl:text>Zhuang or Chuang</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='znd'">
                            <xsl:text>Zande languages</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='zul'">
                            <xsl:text>Zulu</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='zu'">
                            <xsl:text>Zulu</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='zun'">
                            <xsl:text>Zuni</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='zxx'">
                            <xsl:text>No linguistic content</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='nqo'">
                            <xsl:text>N'Ko</xsl:text>
                        </xsl:when>
                        <xsl:when test="@langcode='zza'">
                            <xsl:text>Zaza or Dimili or Dimli or Kirdki or Kirmanjki or Zazaki</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:apply-templates mode="hl-did"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

    <!-- PHYSLOC: This template adds an attribute -->
    <xsl:template match="ead:physloc" mode="hl-did">
        <xsl:copy>
            <xsl:copy-of select="@*[not(name()='label')]|node()"/>
            <xsl:apply-templates mode="hl-did"/>
        </xsl:copy>
    </xsl:template>


    <!-- ABSTRACT: This template adds an attribute -->
    <xsl:template match="ead:abstract" mode="hl-did">
        <xsl:copy>
            <xsl:copy-of select="@*[not(name()='label')]|node()"/>
            <xsl:apply-templates mode="hl-did"/>
        </xsl:copy>
    </xsl:template>

    <!-- REPOSITORY: This template adds repository address and adds attributes-->
    <xsl:template match="ead:repository" mode="hl-did">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="id">manuscriptsRepository</xsl:attribute>
            <xsl:attribute name="encodinganalog">852$a</xsl:attribute>
            <xsl:apply-templates mode="hl-did"/>
            <corpname>Princeton University Library. Department of Rare Books and Special
                Collections.</corpname>
            <subarea>Manuscripts Division</subarea>
            <address>
               <addressline>One Washington Road</addressline>
               <addressline>Princeton, New Jersey 08544 USA</addressline>
            </address>

        </xsl:copy>

    </xsl:template>

    <!-- PUBLISHER: add @id -->
    <xsl:template match="ead:publicationstmt">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="id">rbscAddress</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <!-- PUBLICATIONSTMT/ADDRESS -->
    <xsl:template match="ead:publicationstmt/ead:address">
        <address>
                        <addressline>Manuscripts Division</addressline>
                        <addressline>One Washington Road</addressline>
                        <addressline>Princeton, New Jersey 08544 USA</addressline>
                        <addressline>Phone: (609) 258-3184</addressline>
                        <addressline>Fax: (609) 258-2324</addressline>
                        <addressline altrender="email">rbsc@princeton.edu</addressline>
                        <addressline altrender="url">http://www.princeton.edu/~rbsc</addressline>
                    </address>
    </xsl:template>

    <!-- PUBLISHER: add @encodinganalog -->
    <xsl:template match="ead:publicationstmt/ead:publisher">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="encodinganalog">dc:publisher</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <!-- PUBLICATIONSTMT/DATE adds encodinganalog and normalizes date-->
    <xsl:template match="ead:publicationstmt/ead:date">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="encodinganalog">dc:date</xsl:attribute>
            <xsl:attribute name="normal">
                <xsl:analyze-string select="string(.)" regex="\d{{4}}">
                    <xsl:matching-substring>
                        <xsl:value-of select="normalize-space(current())"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:attribute>
            <xsl:text>Published in </xsl:text>
            <xsl:apply-templates/>
            <xsl:text>.</xsl:text>
        </xsl:copy>
    </xsl:template>
    
    <!-- COMPONENTS: create unique @id-->
<!--    <xsl:template match="ead:c" mode="hl-did">
        <xsl:copy>
            <xsl:copy-of select="@*[not(name()='id')]"/>
            <xsl:attribute name="id">
                <xsl:value-of select="//ead:eadid"/><xsl:value-of select="generate-id(.)"/>
            </xsl:attribute>
            <xsl:apply-templates mode="hl-did"></xsl:apply-templates>
            </xsl:copy>
    </xsl:template>-->

<!-- TITLE: replace with emph -->
    <xsl:template match="ead:title" mode="hl-did">
        <emph render="italic">
            <xsl:apply-templates mode="hl-did"></xsl:apply-templates>
        </emph>
    </xsl:template>
    <xsl:template match="ead:title">
        <emph render="italic">
            <xsl:apply-templates></xsl:apply-templates>
        </emph>
    </xsl:template>

<!-- P: eliminate whitespace from line feeder -->
    <xsl:template match="ead:p/text()[contains(., '( ')]" mode="hl-did">
    <xsl:copy-of select=" replace(., '\(\s', '(')"></xsl:copy-of>
</xsl:template>
    
    <!-- BIOGHIST: These templates copy over bioghist and group elements in descgrp's. 
    -->
    <xsl:template match="ead:archdesc/ead:bioghist" mode="hl-did">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="encodinganalog">545$a</xsl:attribute>

            <xsl:apply-templates select="ead:p" mode="hl-did"/>            
            
        </xsl:copy>
        
        <xsl:if
            test="preceding-sibling::ead:scopecontent | following-sibling::ead:scopecontent | preceding-sibling::ead:arrangement | following-sibling::ead:arrangement">
            <descgrp id="dacs3">
                <xsl:if
                    test="preceding-sibling::ead:scopecontent | following-sibling::ead:scopecontent">
                    <scopecontent encodinganalog="520$a">
                        <xsl:apply-templates
                            select="preceding-sibling::ead:scopecontent/ead:p | following-sibling::ead:scopecontent/ead:p"
                        />
                    </scopecontent>
                </xsl:if>
                <xsl:if
                    test="preceding-sibling::ead:arrangement | following-sibling::ead:arrangement">
                    <arrangement encodinganalog="351$a">
                        <xsl:choose>
                            <xsl:when
                                test="preceding-sibling::ead:arrangement/ead:list[@type[.='ordered']] | following-sibling::ead:arrangement/ead:list[@type[.='ordered']]">
                                <xsl:apply-templates
                                    select="preceding-sibling::ead:arrangement/(ead:p|ead:list)[not(.[@type[.='ordered']])] | following-sibling::ead:arrangement/(ead:p|ead:list)[not(.[@type[.='ordered']])]"/>
                                <list type="simple">
                                    <xsl:for-each select="//ead:arrangement//ead:ref">
                                        <item>
                                            <xsl:variable name="refposition" select="position()"
                                                as="xs:integer"/>
                                            <ref>
                                                <xsl:copy-of select="@altrender"/>
                                                <xsl:attribute name="target">
                                                  <xsl:value-of
                                                  select="(//ead:c[@level='series'] | //ead:c[@level='subseries'])[position()=$refposition]/@id"
                                                  />
                                                </xsl:attribute>
                                                <xsl:apply-templates select="./*"/>
                                            </ref>
                                        </item>
                                    </xsl:for-each>
                                </list>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates
                                    select="preceding-sibling::ead:arrangement/ead:p| following-sibling::ead:arrangement/ead:p"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                    </arrangement>
                </xsl:if>
            </descgrp>
        </xsl:if>
        <xsl:if
            test="preceding-sibling::ead:accessrestrict | following-sibling::ead:accessrestrict | preceding-sibling::ead:userestrict | following-sibling::ead:userestrict | preceding-sibling::ead:phystech | following-sibling::ead:phystech | preceding-sibling::ead:otherfindaid | following-sibling::ead:otherfindaid">
            <descgrp id="dacs4">
                <xsl:choose>
                    <xsl:when
                        test="preceding-sibling::ead:accessrestrict | following-sibling::ead:accessrestrict">
                        <accessrestrict encodinganalog="506$a">
                            <xsl:apply-templates
                                select="preceding-sibling::ead:accessrestrict[1]/ead:p | following-sibling::ead:accessrestrict[1]/ead:p"
                            />
                        </accessrestrict>
                        <xsl:if test="preceding-sibling::ead:accessrestrict[2] | following-sibling::ead:accessrestrict[2]">
                            <accessrestrict encodinganalog="506$a">
                                <xsl:apply-templates
                                    select="preceding-sibling::ead:accessrestrict[2]/ead:p | following-sibling::ead:accessrestrict[2]/ead:p"
                                />
                            </accessrestrict>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <accessrestrict encodinganalog="506$a">
                            <p>Collection is open for research use.</p>
                        </accessrestrict>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when
                        test="preceding-sibling::ead:userestrict | following-sibling::ead:userestrict">
                        <userestrict encodinganalog="540$a">
                            <xsl:apply-templates
                                select="preceding-sibling::ead:userestrict/ead:p | following-sibling::ead:userestrict/ead:p"
                            />
                        </userestrict>
                    </xsl:when>
                    <xsl:otherwise>
                        <userestrict encodinganalog="540$a">
                            <p>Photocopies may be made for research purposes. Researchers are
                                responsible for determining any copyright questions.</p>
                        </userestrict>
                    </xsl:otherwise>
                </xsl:choose>

                <xsl:if test="preceding-sibling::ead:phystech | following-sibling::ead:phystech">
                    <phystech encodinganalog="538$a">
                        <xsl:apply-templates
                            select="preceding-sibling::ead:phystech/ead:p | following-sibling::ead:phystech/ead:p"
                        />
                    </phystech>
                </xsl:if>
                <xsl:if
                    test="preceding-sibling::ead:otherfindaid | following-sibling::ead:otherfindaid">
                    <otherfindaid encodinganalog="555$u">
                        <xsl:apply-templates
                            select="preceding-sibling::ead:otherfindaid/ead:p | following-sibling::ead:otherfindaid/ead:p"
                        />
                    </otherfindaid>
                </xsl:if>
            </descgrp>
        </xsl:if>
        <xsl:if
            test="preceding-sibling::ead:custodhist | following-sibling::ead:custodhist | preceding-sibling::ead:acqinfo | following-sibling::ead:acqinfo | preceding-sibling::ead:appraisal | following-sibling::ead:appraisal | preceding-sibling::ead:accruals | following-sibling::ead:accruals">
            <descgrp id="dacs5">

                <xsl:if test="preceding-sibling::ead:custodhist | following-sibling::ead:custodhist">
                    <custodhist encodinganalog="561$a">
                        <xsl:apply-templates
                            select="preceding-sibling::ead:custodhist/ead:p | following-sibling::ead:custodhist/ead:p"
                        />
                    </custodhist>
                </xsl:if>
                <xsl:if test="preceding-sibling::ead:acqinfo | following-sibling::ead:acqinfo">
                    <acqinfo encodinganalog="541$a">
                        <xsl:apply-templates
                            select="preceding-sibling::ead:acqinfo/ead:p | following-sibling::ead:acqinfo/ead:p"
                        />
                    </acqinfo>
                </xsl:if>
                <xsl:if test="preceding-sibling::ead:appraisal | following-sibling::ead:appraisal">
                    <appraisal encodinganalog="583$a">
                        <xsl:apply-templates
                            select="preceding-sibling::ead:appraisal/ead:p | following-sibling::ead:appraisal/ead:p"
                        />
                    </appraisal>
                </xsl:if>
                <xsl:if test="preceding-sibling::ead:accruals | following-sibling::ead:accruals">
                    <accruals encodinganalog="584$a">
                        <xsl:apply-templates
                            select="preceding-sibling::ead:accruals/ead:p | following-sibling::ead:accruals/ead:p"
                        />
                    </accruals>
                </xsl:if>
            </descgrp>
        </xsl:if>
        <xsl:if
            test="following-sibling::ead:originalsloc | preceding-sibling::ead:originalsloc | following-sibling::ead:altformavail | preceding-sibling::ead:altformavail | following-sibling::ead:relatedmaterial | preceding-sibling::ead:relatedmaterial | following-sibling::ead:bibliography/ead:head[contains(string(.), 'Publications Citing These Papers')] | preceding-sibling::ead:bibliography/ead:head[contains(string(.), 'Publications Citing These Papers')]">
            <descgrp id="dacs6"><xsl:if
                    test="following-sibling::ead:originalsloc | preceding-sibling::ead:originalsloc">

                    <originalsloc encodinganalog="535$a">
                        <xsl:apply-templates
                            select="following-sibling::ead:originalsloc/ead:p | preceding-sibling::ead:originalsloc/ead:p"
                        />
                    </originalsloc>
                </xsl:if>
                <xsl:if
                    test="following-sibling::ead:altformavail | preceding-sibling::ead:altformavail">

                    <altformavail encodinganalog="530$a">
                        <xsl:apply-templates
                            select="following-sibling::ead:altformavail/ead:p | preceding-sibling::ead:altformavail/ead:p"
                        />
                    </altformavail>
                </xsl:if>
                <xsl:if
                    test="following-sibling::ead:relatedmaterial | preceding-sibling::ead:relatedmaterial">
                    <relatedmaterial encodinganalog="544$a">

                        <xsl:apply-templates
                            select="following-sibling::ead:relatedmaterial/ead:p | preceding-sibling::ead:relatedmaterial/ead:p"
                        />
                    </relatedmaterial>
                </xsl:if>
                <xsl:if
                    test="following-sibling::ead:bibliography/ead:head[contains(string(.), 'Publications Citing These Papers')] | preceding-sibling::ead:bibliography/ead:head[contains(string(.), 'Publications Citing These Papers')]">
                    <bibliography id="pubcitingpapers" encodinganalog="581$a">

                        <xsl:apply-templates
                            select="following-sibling::ead:bibliography[./contains(string(.), 'Publications Citing These Papers')]/ead:p | preceding-sibling::ead:bibliography[./contains(string(.), 'Publications Citing These Papers')]/ead:p"
                        />
                    </bibliography>
                </xsl:if>
            </descgrp>
        </xsl:if>
        <xsl:if
            test="following-sibling::ead:note | preceding-sibling::ead:note | following-sibling::ead:processinfo | preceding-sibling::ead:processinfo | preceding-sibling::ead:prefercite | following-sibling::ead:prefercite | following-sibling::ead:bibliography/ead:head[contains(string(.), 'Works Cited')] | preceding-sibling::ead:bibliography/ead:head[contains(string(.), 'Works Cited')]">
            <descgrp id="dacs7">

                <xsl:if
                    test="following-sibling::ead:note | preceding-sibling::ead:note | following-sibling::ead:odd | preceding-sibling::ead:odd">
                    <note>
                        <xsl:apply-templates
                            select="following-sibling::ead:note/ead:p | preceding-sibling::ead:note/ead:p"/>
                        <xsl:apply-templates
                            select="following-sibling::ead:odd/ead:p | preceding-sibling::ead:odd/ead:p"
                        />
                    </note>
                </xsl:if>
                <xsl:if
                    test="following-sibling::ead:processinfo/ead:head[contains(string(.), 'Conservation')] | preceding-sibling::ead:processinfo/ead:head[contains(string(.), 'Conservation')]">
                    <processinfo id="conservation" encodinganalog="583$a">
                        <xsl:apply-templates
                            select="following-sibling::ead:processinfo[./contains(string(.), 'Conservation')]/ead:p | preceding-sibling::ead:processinfo[./contains(string(.), 'Conservation')]/ead:p"
                        />
                    </processinfo>
                </xsl:if>
                <xsl:if test="preceding-sibling::ead:prefercite | following-sibling::ead:prefercite">
                    <prefercite encodinganalog="524$a">
                        <xsl:apply-templates
                            select="preceding-sibling::ead:prefercite/ead:p | following-sibling::ead:prefercite/ead:p"
                        />
                    </prefercite>
                </xsl:if>
                <xsl:if
                    test="following-sibling::ead:bibliography/ead:head[contains(string(.), 'Works Cited')] | preceding-sibling::ead:bibliography/ead:head[contains(string(.), 'Works Cited')]">
                    <bibliography id="workscited" encodinganalog="581$a">
                        <xsl:apply-templates
                            select="following-sibling::ead:bibliography[./contains(string(.), 'Works Cited')]/ead:p | preceding-sibling::ead:bibliography[./contains(string(.), 'Works Cited')]/ead:p"
                        />
                    </bibliography>
                </xsl:if>
                <xsl:if
                    test="following-sibling::ead:processinfo/ead:head[contains(string(.), 'Processing Information')] | preceding-sibling::ead:processinfo/ead:head[contains(string(.), 'Processing Information')]">
                    <processinfo id="processing" encodinganalog="583$a">
                        <xsl:apply-templates
                            select="following-sibling::ead:processinfo[./contains(string(.), 'Processing Information')]/ead:p | preceding-sibling::ead:processinfo[./contains(string(.), 'Processing Information')]/ead:p"
                        />
                    </processinfo>
                </xsl:if>
            </descgrp>
        </xsl:if>
    <xsl:choose>
        <xsl:when test="preceding-sibling::ead:dao | following-sibling::ead:dao ">
            <dao>
                <xsl:attribute name="xlink:title">
                    <xsl:value-of
                        select="normalize-space(//ead:archdesc/ead:dao/ead:daodesc/ead:p)"/>
                </xsl:attribute>
                <xsl:attribute name="xlink:href">
                    <xsl:value-of select="//ead:archdesc/ead:dao/@ns2:href"/>
                </xsl:attribute>
            </dao>
        </xsl:when>
        <xsl:otherwise>
            <dao xlink:title="Princeton University Manuscripts Division"
                xlink:href="bioghist-images/msslogo.jpg"/>
        </xsl:otherwise>
    </xsl:choose>
    </xsl:template>



    
    <!-- CONTROLACCESS: This template puts in boilerplate and adds @encodinganalogs in ascending order -->
    <xsl:template match="ead:archdesc/ead:controlaccess" mode="hl-did">
        <controlaccess>
            <p>These materials have been indexed in the <extref
                    xlink:href="http://catalog.princeton.edu">Princeton University Library online
                    catalog</extref> using the following terms. Those seeking related materials
                should search under these terms.</p>

            <xsl:for-each select="ead:persname[not(.='') and not(@role='Contributor (ctb)')]">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="encodinganalog">600</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="ead:corpname[not(.='') and not(@role='Contributor (ctb)')]">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="encodinganalog">610</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="ead:subject[@source='lcsh' and not(.='')]">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="encodinganalog">650</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="ead:geogname[not(.='')]">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="encodinganalog">651</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="ead:genreform[not(.='')]">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="encodinganalog">655</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="ead:occupation[not(.='')]">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="encodinganalog">656</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="ead:function[not(.='')]">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="encodinganalog">657</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:for-each>
            <xsl:for-each
                select="ead:subject[not(.='')]/@source[.='Local'] | ead:subject[not(.='')]/@source[.='local']">
                <subject source="local" encodinganalog="690">
                    <xsl:value-of select="ancestor::ead:subject"/>
                </subject>
            </xsl:for-each>
            <xsl:for-each select="ead:persname[@role='Contributor (ctb)' and not(.='')]">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="encodinganalog">700</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="ead:corpname[@role='Contributor (ctb)' and not(.='')]">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="encodinganalog">710</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:for-each>
        </controlaccess>
    </xsl:template>

    <!-- DSC: Add attribute-->
    <xsl:template match="ead:dsc" mode="hl-did">
        <xsl:if test="not(.='')">
            <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:attribute name="type">combined</xsl:attribute>
                <xsl:apply-templates mode="hl-did"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>

    <!-- EMPH: add render@ -->
    <xsl:template match="ead:emph[not(@render)]" mode="hl-did">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="render">italic</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
