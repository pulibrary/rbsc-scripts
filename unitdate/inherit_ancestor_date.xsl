<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="urn:isbn:1-931666-22-9" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:ead="urn:isbn:1-931666-22-9"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ns2="http://www.w3.org/1999/xlink"
    version="2.0" exclude-result-prefixes="#all">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Aug 26, 2014</xd:p>
            <xd:p><xd:b>Author:</xd:b> heberlei</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>


    <xsl:template match="@*|node()|processing-instruction()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="@*[not(name()='calendar') and not(name()='era')]|node()|processing-instruction()|comment()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="ead:unitdate[.='unexamined']">
        <xsl:if test="../../../ead:did/ead:unitdate[@normal]">
            <unitdate>
            <xsl:attribute name="normal"><xsl:value-of select="../../../ead:did/ead:unitdate/@normal"/></xsl:attribute>
            <xsl:attribute name="certainty">inherited</xsl:attribute>
                <xsl:copy-of select="../../../ead:did/ead:unitdate/text()"/>
            </unitdate>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
