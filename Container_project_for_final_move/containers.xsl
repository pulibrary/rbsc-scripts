<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ead="urn:isbn:1-931666-22-9"
    version="2.0">
    <xsl:output method="xml" indent="no"/>        
        
        <xsl:template match="@*|node()">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
        </xsl:template>
    
    
    <xsl:template match="ead:container[not(deep-equal(., preceding-sibling::container[1]))]">
        
    </xsl:template>
</xsl:stylesheet>