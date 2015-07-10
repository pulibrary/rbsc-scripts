<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="urn:isbn:1-931666-33-4" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:ead="urn:isbn:1-931666-22-9"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ns2="http://www.w3.org/1999/xlink"
    xmlns:cpf="urn:isbn:1-931666-33-4" version="2.0" exclude-result-prefixes="#all">

    <xsl:template match="@*|node()|comment()|processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()|comment()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="cpf:nameEntry">
        <xsl:copy>
            <xsl:copy-of select="@*|node()"/>
            <xsl:if test="../following-sibling::cpf:description/cpf:existDates">
                <useDates>
                    <xsl:copy-of select="../following-sibling::cpf:description/cpf:existDates/*"/>
                </useDates>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
