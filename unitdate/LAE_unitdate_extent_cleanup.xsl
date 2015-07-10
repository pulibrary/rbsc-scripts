<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="urn:isbn:1-931666-22-9" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:ead="urn:isbn:1-931666-22-9"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ns2="http://www.w3.org/1999/xlink"
    version="2.0" exclude-result-prefixes="#all">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Sep 14, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> heberlei</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template
        match="ead:archdesc/ead:did/ead:unitid[matches(@label, 'alternate call number', 'i')]"/>
    <xsl:template
        match="ead:archdesc/ead:did/ead:physdesc[matches(@label, 'size of surrogate', 'i')]"/>

    <xsl:template match="ead:altformavail[@encodinganalog='530$a']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
            <p>
                <xsl:text>(</xsl:text>
                <xsl:value-of
                    select="//ead:archdesc/ead:did/ead:physdesc[matches(@label, 'size of surrogate', 'i')]/@label"/>
                <xsl:for-each
                    select="//ead:archdesc/ead:did/ead:physdesc[matches(@label, 'size of surrogate', 'i')]/*[position()=1]">
                    <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:for-each
                    select="//ead:archdesc/ead:did/ead:physdesc[matches(@label, 'size of surrogate', 'i')]/*[position()>1]">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="."/>
                </xsl:for-each>                    
                <xsl:text>)</xsl:text>
            </p>

        </xsl:copy>
    </xsl:template>


</xsl:stylesheet>
