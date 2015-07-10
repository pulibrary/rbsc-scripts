<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="2.0" xmlns:ead="urn:isbn:1-931666-22-9"
    xmlns:njp="http://diglib.princeton.edu" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.w3.org/2005/xpath-functions">
    <xsl:output method="xml" encoding="utf-8" indent="yes"/>
    
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="/">
        <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
            <fo:layout-master-set>
                <fo:simple-page-master master-name="boxLabels" page-height="278mm"
                    page-width="216mm" margin-top="10mm" margin-bottom="10mm" margin-left="7mm"
                    margin-right="7mm">
                    <fo:region-body margin-top="0in" margin-bottom="0in" column-count="2"
                        column-gap="10mm"/>
                    <fo:region-before extent="0cm"/>
                    <fo:region-after extent="0cm"/>
                </fo:simple-page-master>
                
                <fo:page-sequence-master master-name="repeatME">
                    <fo:repeatable-page-master-reference master-reference="boxLabels"/>
                </fo:page-sequence-master>
            </fo:layout-master-set>
            <xsl:apply-templates select="ead:ead"/>
        </fo:root>
    </xsl:template>
    
    <xsl:template match="ead:ead">
        <fo:page-sequence master-reference="repeatME">
            <fo:flow flow-name="xsl-region-body">
                <fo:table>
                    <fo:table-column column-width="96mm"/>
                    <fo:table-body font-family="SansSerif">
                        <xsl:apply-templates select="//ead:dsc"/>
                    </fo:table-body>
                </fo:table>
            </fo:flow>
        </fo:page-sequence>
    </xsl:template>
    
    <xsl:template match="ead:container[@type='Box' or @type='box' or @type='volume' or @type='Volume']">
        
        <xsl:for-each select=".[not(.=preceding::ead:container[@type='Box' or @type='box'  or @type='volume' or @type='Volume'])]">
                <xsl:apply-templates mode="single" select="."/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template mode="single"
        match="ead:container[@type='Box' or @type='box' or @type='volume' or @type='Volume']">
        <fo:table-row height="3.3in" padding-bottom=".2in" padding-top=".2in" margin-left="3mm"
            margin-right="3mm">
            <fo:table-cell>
                <fo:block padding-bottom=".2in" padding-top=".2in" padding-left="2mm"
                    padding-right="2mm" border-color="black" border-style="solid"
                    border-width="thin" margin-top="9mm">
                    <fo:block font-weight="bold" font-size="16pt" font-family="SansSerif"
                        text-align="center" span="none" padding-after="12pt">
                        <xsl:value-of select="//ead:archdesc/ead:did/ead:unittitle"/>
                    </fo:block>
                    <fo:block font-weight="bold" font-family="SansSerif" font-size="11pt"
                        line-height="0.3in" text-align-last="justify" padding-before="10pt">
                        <xsl:value-of select="//ead:eadid"/>
                        <fo:leader leader-pattern="space"/>
                        <xsl:value-of
                            select="concat(upper-case(substring(normalize-space(@type),1,1)),
                            substring(normalize-space(@type), 2))"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text> </xsl:text>
                    </fo:block>
                    <fo:block text-align="left" line-height=".3" vertical-align="after">
                        <fo:external-graphic
                            src="C:\Users\heberlei\Desktop\msslogo.JPG"/>
                        <fo:external-graphic
                            src="C:\Users\elviaa\Desktop\msslogo.JPG"/>
                        <fo:external-graphic
                            src="C:\Users\kbolding\Desktop\msslogo.JPG"/>
                        <fo:external-graphic
                            src="C:\Users\mssstu1\Desktop\msslogo.JPG"/>
                        <fo:external-graphic
                            src="C:\Users\faithc\Desktop\msslogo.JPG"/>
                    </fo:block>
                    <fo:block font-weight="bold" font-family="SansSerif" font-size="11pt"
                        line-height="0.3in" span="none" text-align="center" vertical-align="after" padding-before="14pt">
                        <xsl:text>Princeton University Library</xsl:text>
                    </fo:block>
                </fo:block>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>  
</xsl:stylesheet>
